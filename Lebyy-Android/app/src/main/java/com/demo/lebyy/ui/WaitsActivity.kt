package com.demo.lebyy.ui

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.databinding.ActivityWaitsBinding

class WaitsActivity : AppCompatActivity() {
    private companion object {
        const val MIN_DELAY = 1
        const val MAX_DELAY = 8
    }

    private lateinit var binding: ActivityWaitsBinding
    private val handler = Handler(Looper.getMainLooper())
    private var delaySeconds = 3

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityWaitsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "waits")

        renderDelay()
        binding.delayMinus.setOnClickListener { setDelay(delaySeconds - 1) }
        binding.delayPlus.setOnClickListener { setDelay(delaySeconds + 1) }
        binding.delaySeek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                if (fromUser) setDelay(progress + MIN_DELAY)
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        binding.loadDelayed.setOnClickListener {
            binding.delayedContent.text = ""
            binding.loadingSpinner.visibility = View.VISIBLE
            val seconds = delaySeconds
            handler.postDelayed({
                binding.loadingSpinner.visibility = View.GONE
                binding.delayedContent.text = "Content ready after ${seconds}s"
            }, seconds * 1000L)
        }

        binding.simulateNetworkFail.setOnClickListener {
            setNetworkLoading()
            handler.postDelayed({ setNetworkError() }, 600)
        }
        binding.simulateNetworkSuccess.setOnClickListener {
            setNetworkLoading()
            handler.postDelayed({ setNetworkSuccess() }, 600)
        }
        binding.networkRetry.setOnClickListener {
            setNetworkLoading()
            handler.postDelayed({ setNetworkSuccess() }, 500)
        }
    }

    private fun setDelay(seconds: Int) {
        delaySeconds = seconds.coerceIn(MIN_DELAY, MAX_DELAY)
        renderDelay()
    }

    private fun renderDelay() {
        binding.delayLabel.text = "Delay: ${delaySeconds}s"
        if (binding.delaySeek.progress != delaySeconds - MIN_DELAY) {
            binding.delaySeek.progress = delaySeconds - MIN_DELAY
        }
    }

    private fun setNetworkLoading() {
        binding.networkStatus.text = "Status: Loading"
        binding.networkStatus.contentDescription = "test-NetworkStatus-Loading"
        binding.networkErrorMessage.visibility = View.GONE
        binding.networkRetry.visibility = View.GONE
    }

    private fun setNetworkError() {
        binding.networkStatus.text = "Status: Offline / Error"
        binding.networkStatus.contentDescription = "test-NetworkStatus-Error"
        binding.networkErrorMessage.visibility = View.VISIBLE
        binding.networkRetry.visibility = View.VISIBLE
    }

    private fun setNetworkSuccess() {
        binding.networkStatus.text = "Status: Success — data loaded"
        binding.networkStatus.contentDescription = "test-NetworkStatus-Success"
        binding.networkErrorMessage.visibility = View.GONE
        binding.networkRetry.visibility = View.GONE
    }
}
