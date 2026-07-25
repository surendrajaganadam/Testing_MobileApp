package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityCheckoutInfoBinding

class CheckoutInfoActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCheckoutInfoBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCheckoutInfoBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }
        binding.buttonCancel.setOnClickListener { finish() }

        binding.buttonContinue.setOnClickListener {
            val first = binding.inputFirstName.text?.toString()?.trim().orEmpty()
            val last = binding.inputLastName.text?.toString()?.trim().orEmpty()
            val zip = binding.inputZip.text?.toString()?.trim().orEmpty()
            if (first.isEmpty() || last.isEmpty() || zip.isEmpty()) {
                Toast.makeText(this, "Please fill all fields", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            ShopState.firstName = first
            ShopState.lastName = last
            ShopState.zipCode = zip
            startActivity(Intent(this, CheckoutOverviewActivity::class.java))
        }
    }
}
