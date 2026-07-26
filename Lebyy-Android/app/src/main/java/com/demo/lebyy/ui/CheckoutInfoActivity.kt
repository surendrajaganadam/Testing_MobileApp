package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.demo.lebyy.R
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityCheckoutInfoBinding

class CheckoutInfoActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCheckoutInfoBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCheckoutInfoBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.title = getString(R.string.shipping_title)
        binding.toolbar.setNavigationOnClickListener { finish() }
        binding.buttonCancel.setOnClickListener { finish() }

        binding.inputFirstName.setText(ShopState.firstName)
        binding.inputLastName.setText(ShopState.lastName)
        binding.inputZip.setText(ShopState.zipCode)

        ShopState.savedAddresses.forEach { address ->
            val row = TextView(this).apply {
                text = "${address.label}\n${address.firstName} ${address.lastName} · ${address.zipCode}"
                setTextColor(ContextCompat.getColor(this@CheckoutInfoActivity, R.color.lebyy_primary))
                textSize = 15f
                setPadding(0, 20, 0, 20)
                contentDescription = "test-SavedAddress-${address.id}"
                setOnClickListener {
                    ShopState.selectAddress(address)
                    binding.inputFirstName.setText(address.firstName)
                    binding.inputLastName.setText(address.lastName)
                    binding.inputZip.setText(address.zipCode)
                    refreshContinueEnabled()
                }
            }
            binding.savedAddressesList.addView(
                row,
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ),
            )
        }

        val watcher = object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
            override fun afterTextChanged(s: Editable?) = refreshContinueEnabled()
        }
        binding.inputFirstName.addTextChangedListener(watcher)
        binding.inputLastName.addTextChangedListener(watcher)
        binding.inputZip.addTextChangedListener(watcher)
        refreshContinueEnabled()

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
            startActivity(Intent(this, PaymentActivity::class.java))
        }
    }

    override fun onResume() {
        super.onResume()
        if (ShopState.exitCheckoutStack) {
            finish()
        }
    }

    private fun refreshContinueEnabled() {
        val ready = !binding.inputFirstName.text.isNullOrBlank() &&
            !binding.inputLastName.text.isNullOrBlank() &&
            !binding.inputZip.text.isNullOrBlank()
        binding.buttonContinue.isEnabled = ready
        binding.buttonContinue.alpha = if (ready) 1f else 0.45f
        binding.buttonContinue.backgroundTintList = ContextCompat.getColorStateList(
            this,
            if (ready) R.color.lebyy_accent else R.color.lebyy_surface,
        )
        binding.buttonContinue.setTextColor(
            ContextCompat.getColor(this, if (ready) R.color.lebyy_bg else R.color.lebyy_muted),
        )
    }
}
