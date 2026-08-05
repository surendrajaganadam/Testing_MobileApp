package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivitySettingsBinding

class SettingsActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySettingsBinding
    private val handler = Handler(Looper.getMainLooper())
    private var remaining = 0
    private val tick = object : Runnable {
        override fun run() {
            if (!ShopState.sessionTimeoutEnabled) return
            if (remaining <= 1) {
                logoutNow()
                return
            }
            remaining--
            binding.sessionCountdown.text = "Logs out in: ${remaining}s"
            binding.sessionCountdown.contentDescription = "Logs out in: ${remaining}s"
            handler.postDelayed(this, 1000)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySettingsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "settings")

        binding.displayName.setText(ShopState.displayName)
        binding.sessionTimeoutToggle.isChecked = ShopState.sessionTimeoutEnabled
        val progress = ((ShopState.sessionTimeoutSeconds - 10) / 10).coerceIn(0, 11)
        binding.sessionTimeoutSeek.progress = progress
        binding.sessionTimeoutLabel.text = "Timeout: ${ShopState.sessionTimeoutSeconds}s"

        binding.saveProfile.setOnClickListener {
            ShopState.displayName = binding.displayName.text?.toString().orEmpty()
            binding.profileSaved.text = "Saved: ${ShopState.displayName}"
            resetTimer()
        }

        binding.sessionTimeoutToggle.setOnCheckedChangeListener { _, checked ->
            ShopState.sessionTimeoutEnabled = checked
            if (checked) resetTimer() else {
                handler.removeCallbacks(tick)
                binding.sessionCountdown.text = "Logs out in: —"
            }
        }

        binding.sessionTimeoutSeek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                ShopState.sessionTimeoutSeconds = 10 + progress * 10
                binding.sessionTimeoutLabel.text = "Timeout: ${ShopState.sessionTimeoutSeconds}s"
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {
                if (ShopState.sessionTimeoutEnabled) resetTimer()
            }
        })

        binding.resetSessionTimer.setOnClickListener { resetTimer() }
        binding.forceLogout.setOnClickListener { logoutNow() }

        if (ShopState.sessionTimeoutEnabled) resetTimer()
    }

    private fun resetTimer() {
        handler.removeCallbacks(tick)
        if (!ShopState.sessionTimeoutEnabled) return
        remaining = ShopState.sessionTimeoutSeconds
        binding.sessionCountdown.text = "Logs out in: ${remaining}s"
        handler.postDelayed(tick, 1000)
    }

    private fun logoutNow() {
        handler.removeCallbacks(tick)
        ShopState.resetSession()
        startActivity(
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            },
        )
        finish()
    }

    override fun onDestroy() {
        handler.removeCallbacks(tick)
        super.onDestroy()
    }
}
