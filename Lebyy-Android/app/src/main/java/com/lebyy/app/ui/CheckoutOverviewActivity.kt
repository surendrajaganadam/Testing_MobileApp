package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.lebyy.app.R
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
        binding.paymentInfo.text = "Card ending ${ShopState.cardLast4()}"
        binding.inputCoupon.setText(ShopState.couponInput)

        refreshTotals()

        binding.buttonApplyCoupon.setOnClickListener {
            ShopState.couponInput = binding.inputCoupon.text?.toString().orEmpty()
            if (ShopState.applyCoupon()) {
                binding.couponStatus.text = "Applied: ${ShopState.appliedCoupon} (−10%)"
                binding.couponStatus.setTextColor(
                    ContextCompat.getColor(this, R.color.lebyy_success),
                )
            } else {
                binding.couponStatus.text = getString(R.string.coupon_hint)
                binding.couponStatus.setTextColor(
                    ContextCompat.getColor(this, R.color.lebyy_muted),
                )
            }
            refreshTotals()
        }

        binding.buttonPlaceOrder.setOnClickListener {
            ShopState.couponInput = binding.inputCoupon.text?.toString().orEmpty()
            if (ShopState.appliedCoupon == null && ShopState.couponInput.isNotBlank()) {
                ShopState.applyCoupon()
            }
            val order = ShopState.placeOrder()
            startActivity(
                Intent(this, OrderDetailsActivity::class.java).putExtra(
                    OrderDetailsActivity.EXTRA_ORDER_ID,
                    order.id,
                ).putExtra(OrderDetailsActivity.EXTRA_SHOW_PREVIOUS, true),
            )
            finish()
        }
    }

    private fun refreshTotals() {
        binding.overviewSubtotal.text =
            String.format(Locale.US, "Subtotal: $%.2f", ShopState.cartSubtotal())
        val discount = ShopState.cartDiscount()
        if (discount > 0) {
            binding.overviewDiscount.visibility = View.VISIBLE
            binding.overviewDiscount.text =
                String.format(Locale.US, "Discount: −$%.2f", discount)
        } else {
            binding.overviewDiscount.visibility = View.GONE
        }
        binding.overviewTotal.text =
            String.format(Locale.US, "Total: $%.2f", ShopState.cartTotal())

        ShopState.appliedCoupon?.let {
            binding.couponStatus.text = "Applied: $it (−10%)"
            binding.couponStatus.setTextColor(ContextCompat.getColor(this, R.color.lebyy_success))
        }
    }
}
