package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.google.android.material.button.MaterialButton
import com.demo.lebyy.R
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityCheckoutOverviewBinding
import java.util.Locale

class CheckoutOverviewActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCheckoutOverviewBinding
    private var couponsVisible = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCheckoutOverviewBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }
        binding.buttonCancel.setOnClickListener { finish() }

        if (ShopState.cart().isEmpty()) {
            // Returned via back after placing — do not allow another place.
            binding.overviewItems.text = "Cart is empty — order already placed."
            binding.buttonPlaceOrder.isEnabled = false
            binding.buttonPlaceOrder.alpha = 0.45f
        } else {
            val items = ShopState.cart().joinToString("\n") {
                String.format(
                    Locale.US,
                    "• %s x%d — $%.2f",
                    it.product.name,
                    it.quantity,
                    it.lineTotal,
                )
            }
            binding.overviewItems.text = items
        }
        binding.shippingInfo.text = "${ShopState.firstName} ${ShopState.lastName}\n${ShopState.zipCode}"
        binding.paymentInfo.text = "Card ending ${ShopState.cardLast4()}"
        binding.inputCoupon.setText(ShopState.couponInput)

        populateSampleCoupons()
        refreshTotals()

        binding.buttonViewCoupons.setOnClickListener {
            setCouponsVisible(!couponsVisible)
        }

        binding.buttonApplyCoupon.setOnClickListener {
            ShopState.couponInput = binding.inputCoupon.text?.toString().orEmpty()
            if (ShopState.applyCoupon()) {
                binding.inputCoupon.setText(ShopState.couponInput)
                setCouponsVisible(false)
            }
            refreshTotals()
        }

        binding.buttonPlaceOrder.setOnClickListener {
            if (ShopState.cart().isEmpty()) return@setOnClickListener
            ShopState.couponInput = binding.inputCoupon.text?.toString().orEmpty()
            if (ShopState.appliedCoupon == null && ShopState.couponInput.isNotBlank()) {
                ShopState.applyCoupon()
            }
            val order = ShopState.placeOrder() ?: return@setOnClickListener
            // Open order details outside the checkout stack (My Orders style screen).
            startActivity(
                Intent(this, OrderDetailsActivity::class.java)
                    .putExtra(OrderDetailsActivity.EXTRA_ORDER_ID, order.id)
                    .putExtra(OrderDetailsActivity.EXTRA_FROM_CHECKOUT, true),
            )
            finish()
        }
    }

    override fun onResume() {
        super.onResume()
        if (ShopState.exitCheckoutStack) {
            finish()
            return
        }
        if (ShopState.cart().isEmpty()) {
            binding.buttonPlaceOrder.isEnabled = false
            binding.buttonPlaceOrder.alpha = 0.45f
        }
    }

    private fun populateSampleCoupons() {
        binding.couponList.removeAllViews()
        val pad = (12 * resources.displayMetrics.density).toInt()
        ShopState.sampleCoupons.forEach { coupon ->
            val row = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                setPadding(pad, pad, pad, pad)
                setBackgroundColor(ContextCompat.getColor(this@CheckoutOverviewActivity, R.color.lebyy_surface))
                contentDescription = "test-SampleCoupon-${coupon.code}"
            }

            val info = LinearLayout(this).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
            }
            info.addView(
                TextView(this).apply {
                    text = coupon.code
                    setTextColor(ContextCompat.getColor(this@CheckoutOverviewActivity, R.color.lebyy_primary))
                    textSize = 16f
                    setTypeface(typeface, android.graphics.Typeface.BOLD)
                },
            )
            info.addView(
                TextView(this).apply {
                    text = coupon.title
                    setTextColor(ContextCompat.getColor(this@CheckoutOverviewActivity, R.color.lebyy_muted))
                    textSize = 12f
                },
            )

            val applyBtn = MaterialButton(this).apply {
                text = getString(R.string.apply_coupon)
                contentDescription = "test-ApplyCoupon-${coupon.code}"
                setOnClickListener {
                    if (ShopState.applySampleCoupon(coupon)) {
                        binding.inputCoupon.setText(ShopState.couponInput)
                        setCouponsVisible(false)
                    }
                    refreshTotals()
                }
            }

            row.addView(info)
            row.addView(applyBtn)
            val lp = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT,
            ).apply { bottomMargin = pad }
            binding.couponList.addView(row, lp)
        }
    }

    private fun setCouponsVisible(visible: Boolean) {
        couponsVisible = visible
        binding.couponList.visibility = if (visible) View.VISIBLE else View.GONE
        binding.buttonViewCoupons.text =
            getString(if (visible) R.string.hide_coupons else R.string.view_coupons)
        binding.buttonViewCoupons.contentDescription =
            if (visible) "test-HIDE COUPONS" else "test-VIEW COUPONS"
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

        val applied = ShopState.appliedCoupon
        if (applied != null) {
            binding.couponStatus.text =
                "Coupon applied: $applied (−${ShopState.appliedCouponPercent}%)"
            binding.couponStatus.setTextColor(ContextCompat.getColor(this, R.color.lebyy_success))
            binding.couponStatus.contentDescription = "test-CouponApplied"
            binding.inputCoupon.contentDescription = "test-Coupon"
        } else {
            binding.couponStatus.text = getString(R.string.coupon_hint)
            binding.couponStatus.setTextColor(ContextCompat.getColor(this, R.color.lebyy_muted))
        }
    }
}
