package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityCheckoutOverviewBinding
import java.util.Locale

class CheckoutOverviewActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCheckoutOverviewBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCheckoutOverviewBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }
        binding.buttonCancel.setOnClickListener { finish() }

        val items = ShopState.cart().joinToString("\n") {
            String.format(
                Locale.US,
                "• %s x%d — $%.2f",
                it.product.name,
                it.quantity,
                it.lineTotal,
            )
        }
        binding.overviewItems.text = items.ifEmpty { "No items" }
        binding.shippingInfo.text = "${ShopState.firstName} ${ShopState.lastName}\n${ShopState.zipCode}"
        binding.overviewTotal.text = String.format(Locale.US, "Total: $%.2f", ShopState.cartTotal())

        binding.buttonFinish.setOnClickListener {
            ShopState.clearCart()
            startActivity(Intent(this, OrderCompleteActivity::class.java))
            finish()
        }
    }
}
