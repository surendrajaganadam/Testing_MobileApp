package com.demo.lebyy.ui

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.SeekBar
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.databinding.ActivityWaitsBinding

class WaitsActivity : AppCompatActivity() {
    private lateinit var binding: ActivityWaitsBinding
    private val handler = Handler(Looper.getMainLooper())
    private var delaySeconds = 3

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityWaitsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "waits")

        binding.delaySeek.progress = delaySeconds - 1
        binding.delayLabel.text = "Delay: ${delaySeconds}s"
        binding.delaySeek.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                delaySeconds = progress + 1
                binding.delayLabel.text = "Delay: ${delaySeconds}s"
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
                binding.delayedContent.contentDescription = "Content ready after ${seconds}s"
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
