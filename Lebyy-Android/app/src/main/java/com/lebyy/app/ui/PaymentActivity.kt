package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityPaymentBinding

class PaymentActivity : AppCompatActivity() {
    private lateinit var binding: ActivityPaymentBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPaymentBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }

        binding.buttonContinueReview.setOnClickListener {
            val number = binding.inputCardNumber.text?.toString()?.trim().orEmpty()
            // Practice app: accept any card number with no Luhn / length rules.
            if (number.isEmpty()) {
                Toast.makeText(this, "Enter a card number (any digits)", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            ShopState.cardNumber = number
            ShopState.cardExpiry = binding.inputCardExpiry.text?.toString()?.trim().orEmpty()
            ShopState.cardCvv = binding.inputCardCvv.text?.toString()?.trim().orEmpty()
            startActivity(Intent(this, CheckoutOverviewActivity::class.java))
        }
    }
}
