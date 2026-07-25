package com.lebyy.app.ui

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityLoginBinding

class LoginActivity : AppCompatActivity() {
    private lateinit var binding: ActivityLoginBinding

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
                binding.loginError.text = getString(com.lebyy.app.R.string.login_error)
            }
        }
    }
}
