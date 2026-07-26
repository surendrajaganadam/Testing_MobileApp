package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.demo.lebyy.R
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityPaymentBinding

class PaymentActivity : AppCompatActivity() {
    private lateinit var binding: ActivityPaymentBinding
    private var formattingCard = false
    private var formattingExpiry = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityPaymentBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }

        binding.inputCardNumber.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
            override fun afterTextChanged(s: Editable?) {
                if (formattingCard) return
                formattingCard = true
                val formatted = formatCardNumber(s?.toString().orEmpty())
                if (formatted != s?.toString()) {
                    binding.inputCardNumber.setText(formatted)
                    binding.inputCardNumber.setSelection(formatted.length)
                }
                formattingCard = false
                refreshContinueEnabled()
            }
        })

        binding.inputCardExpiry.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
            override fun afterTextChanged(s: Editable?) {
                if (formattingExpiry) return
                formattingExpiry = true
                val formatted = formatExpiry(s?.toString().orEmpty())
                if (formatted != s?.toString()) {
                    binding.inputCardExpiry.setText(formatted)
                    binding.inputCardExpiry.setSelection(formatted.length)
                }
                formattingExpiry = false
                refreshContinueEnabled()
            }
        })

        binding.inputCardCvv.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
            override fun afterTextChanged(s: Editable?) {
                val digits = s?.toString()?.filter { it.isDigit() }?.take(4).orEmpty()
                if (digits != s?.toString()) {
                    binding.inputCardCvv.setText(digits)
                    binding.inputCardCvv.setSelection(digits.length)
                }
                refreshContinueEnabled()
            }
        })

        refreshContinueEnabled()

        binding.buttonContinueReview.setOnClickListener {
            val digits = binding.inputCardNumber.text?.toString()?.filter { it.isDigit() }.orEmpty()
            val expiry = binding.inputCardExpiry.text?.toString()?.trim().orEmpty()
            if (digits.length != 16) {
                Toast.makeText(this, "Enter a 16-digit card number", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            if (expiry.length != 5) {
                Toast.makeText(this, "Enter expiry as MM/YY", Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            ShopState.cardNumber = binding.inputCardNumber.text?.toString().orEmpty()
            ShopState.cardExpiry = expiry
            ShopState.cardCvv = binding.inputCardCvv.text?.toString()?.trim().orEmpty()
            startActivity(Intent(this, CheckoutOverviewActivity::class.java))
        }
    }

    override fun onResume() {
        super.onResume()
        if (ShopState.exitCheckoutStack) {
            finish()
        }
    }

    private fun refreshContinueEnabled() {
        val digits = binding.inputCardNumber.text?.toString()?.filter { it.isDigit() }.orEmpty()
        val expiry = binding.inputCardExpiry.text?.toString().orEmpty()
        val ready = digits.length == 16 && expiry.length == 5
        binding.buttonContinueReview.isEnabled = ready
        binding.buttonContinueReview.alpha = if (ready) 1f else 0.45f
        binding.buttonContinueReview.backgroundTintList = ContextCompat.getColorStateList(
            this,
            if (ready) R.color.lebyy_accent else R.color.lebyy_surface,
        )
        binding.buttonContinueReview.setTextColor(
            ContextCompat.getColor(this, if (ready) R.color.lebyy_bg else R.color.lebyy_muted),
        )
    }

    companion object {
        fun formatCardNumber(raw: String): String {
            val digits = raw.filter { it.isDigit() }.take(16)
            return digits.chunked(4).joinToString(" ")
        }

        fun formatExpiry(raw: String): String {
            val digits = raw.filter { it.isDigit() }.take(4)
            if (digits.length <= 2) return digits
            return "${digits.take(2)}/${digits.drop(2)}"
        }
    }
}
