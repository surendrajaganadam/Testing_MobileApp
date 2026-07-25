package com.lebyy.app.ui

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.GestureDetector
import android.view.MotionEvent
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.GestureDetectorCompat
import com.lebyy.app.R
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityLoginBinding

class LoginActivity : AppCompatActivity() {
    private lateinit var binding: ActivityLoginBinding
    private val handler = Handler(Looper.getMainLooper())
    private var longPressTriggered = false

    private val longPressRunnable = Runnable {
        longPressTriggered = true
        Toast.makeText(this, R.string.login_long_press_done, Toast.LENGTH_SHORT).show()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        binding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Avoid Google Password Manager dialog covering the next screen during automation
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            window.decorView.importantForAutofill = View.IMPORTANT_FOR_AUTOFILL_NO_EXCLUDE_DESCENDANTS
        }

        binding.buttonLogin.setOnClickListener {
            val user = binding.inputUsername.text?.toString()?.trim().orEmpty()
            val pass = binding.inputPassword.text?.toString().orEmpty()
            if (user == "demo_user" && pass == "demo_pass") {
                ShopState.resetSession()
                startActivity(Intent(this, CatalogActivity::class.java))
                finish()
            } else {
                binding.loginError.visibility = View.VISIBLE
                binding.loginError.text = getString(R.string.login_error)
            }
        }

        binding.buttonLongPress.setOnTouchListener { _, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    longPressTriggered = false
                    handler.removeCallbacks(longPressRunnable)
                    handler.postDelayed(longPressRunnable, LONG_PRESS_MS)
                    true
                }

                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    handler.removeCallbacks(longPressRunnable)
                    true
                }

                else -> false
            }
        }

        val doubleTapDetector = GestureDetectorCompat(
            this,
            object : GestureDetector.SimpleOnGestureListener() {
                override fun onDown(e: MotionEvent): Boolean = true

                override fun onDoubleTap(e: MotionEvent): Boolean {
                    Toast.makeText(this@LoginActivity, R.string.login_double_tap_done, Toast.LENGTH_SHORT).show()
                    return true
                }
            },
        )
        binding.buttonDoubleTap.setOnTouchListener { _, event ->
            doubleTapDetector.onTouchEvent(event)
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(longPressRunnable)
        super.onDestroy()
    }

    companion object {
        private const val LONG_PRESS_MS = 2000L
    }
}
