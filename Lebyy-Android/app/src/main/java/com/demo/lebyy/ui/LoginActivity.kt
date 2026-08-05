package com.demo.lebyy.ui

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.demo.lebyy.R
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityLoginBinding

class LoginActivity : AppCompatActivity() {
    private lateinit var binding: ActivityLoginBinding
    private val handler = Handler(Looper.getMainLooper())
    private var longPressTriggered = false
    private var doubleTapCount = 0

    private val longPressRunnable = Runnable {
        longPressTriggered = true
        showGestureResult(R.string.login_long_press_done)
    }

    private val resetDoubleTapRunnable = Runnable {
        doubleTapCount = 0
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
                goHomeAfterLogin()
            } else {
                binding.loginError.visibility = View.VISIBLE
                binding.loginError.text = getString(R.string.login_error)
            }
        }

        binding.gestureResultDismiss.setOnClickListener {
            binding.gestureResultRow.visibility = View.GONE
            binding.gestureResult.text = ""
        }

        // Dedicated long-press target (2 seconds) — separate from double-tap to avoid conflicts.
        binding.buttonLongPress.setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    longPressTriggered = false
                    view.isPressed = true
                    handler.removeCallbacks(longPressRunnable)
                    handler.postDelayed(longPressRunnable, LONG_PRESS_MS)
                    true
                }

                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    view.isPressed = false
                    handler.removeCallbacks(longPressRunnable)
                    true
                }

                else -> false
            }
        }

        // Custom double-tap window so MobileWright's two sequential taps still count.
        binding.buttonDoubleTap.setOnClickListener {
            doubleTapCount += 1
            if (doubleTapCount >= 2) {
                handler.removeCallbacks(resetDoubleTapRunnable)
                doubleTapCount = 0
                showGestureResult(R.string.login_double_tap_done)
            } else {
                handler.removeCallbacks(resetDoubleTapRunnable)
                handler.postDelayed(resetDoubleTapRunnable, DOUBLE_TAP_WINDOW_MS)
            }
        }
    }

    private fun goHomeAfterLogin() {
        ShopState.resetSession()
        ShopState.loginSuccess()
        val dest = ShopState.destinationFromDeepLinkHost(
            intent?.data?.host ?: "",
        )
        if (dest != null && dest != "shop") {
            val target = DrawerHelper.classForKey(dest)
            if (target != null) {
                startActivity(Intent(this, MainActivity::class.java))
                startActivity(Intent(this, target))
                finish()
                return
            }
        }
        startActivity(
            Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                putExtra("open_tab", "shop")
            },
        )
        finish()
    }

    private fun handleDeepLink(intent: Intent?) {
        val uri = intent?.data ?: return
        ShopState.lastDeepLink = uri.toString()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    private fun showGestureResult(messageRes: Int) {
        binding.gestureResult.text = getString(messageRes)
        binding.gestureResultRow.visibility = View.VISIBLE
    }

    override fun onDestroy() {
        handler.removeCallbacks(longPressRunnable)
        handler.removeCallbacks(resetDoubleTapRunnable)
        super.onDestroy()
    }

    companion object {
        private const val LONG_PRESS_MS = 2000L
        private const val DOUBLE_TAP_WINDOW_MS = 800L
    }
}
