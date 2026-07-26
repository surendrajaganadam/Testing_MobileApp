package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.demo.lebyy.R
import com.demo.lebyy.data.OrderStatus
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityOrderDetailsBinding
import java.text.DateFormat
import java.util.Date
import java.util.Locale

class OrderDetailsActivity : AppCompatActivity() {
    private lateinit var binding: ActivityOrderDetailsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityOrderDetailsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val fromCheckout = intent.getBooleanExtra(EXTRA_FROM_CHECKOUT, false)

        if (fromCheckout) {
            // Use ORDER HISTORY button instead of back into checkout stack.
            binding.toolbar.navigationIcon = null
        } else {
            binding.toolbar.setNavigationOnClickListener { finish() }
        }

        binding.buttonOrderHistory.setOnClickListener {
            startActivity(Intent(this, OrdersActivity::class.java))
            finish()
        }

        val orderId = intent.getStringExtra(EXTRA_ORDER_ID).orEmpty()
        bindOrder(orderId)
    }

    override fun onResume() {
        super.onResume()
        val orderId = intent.getStringExtra(EXTRA_ORDER_ID).orEmpty()
        if (orderId.isNotEmpty()) {
            bindOrder(orderId)
        }
    }

    private fun bindOrder(orderId: String) {
        val order = ShopState.orderById(orderId)
        if (order == null) {
            binding.orderConfirmed.text = "Order not found"
            binding.buttonCancelOrder.visibility = View.GONE
            return
        }

        if (order.status == OrderStatus.CANCELLED) {
            binding.orderConfirmed.text = getString(R.string.order_cancelled)
            binding.orderConfirmed.contentDescription = "test-OrderCancelled"
            binding.orderConfirmed.setTextColor(ContextCompat.getColor(this, R.color.lebyy_accent))
            binding.buttonCancelOrder.visibility = View.GONE
        } else {
            binding.orderConfirmed.text = getString(R.string.order_confirmed)
            binding.orderConfirmed.contentDescription = "test-OrderConfirmed"
            binding.orderConfirmed.setTextColor(ContextCompat.getColor(this, R.color.lebyy_primary))
            binding.buttonCancelOrder.visibility = View.VISIBLE
            binding.buttonCancelOrder.setOnClickListener {
                if (ShopState.cancelOrder(order.id)) {
                    bindOrder(orderId)
                }
            }
        }

        binding.orderId.text = order.id
        binding.orderDate.text = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT)
            .format(Date(order.placedAtMs))
        binding.orderItems.text = order.items.joinToString("\n") {
            String.format(Locale.US, "• %s x%d — $%.2f", it.name, it.quantity, it.lineTotal)
        }
        binding.orderShipping.text = "${order.firstName} ${order.lastName}\n${order.zipCode}"
        binding.orderPayment.text = "Card ending ${order.cardLast4}"

        if (order.discount > 0) {
            binding.orderSubtotal.visibility = View.VISIBLE
            binding.orderDiscount.visibility = View.VISIBLE
            binding.orderSubtotal.text =
                String.format(Locale.US, "Subtotal: $%.2f", order.subtotal)
            binding.orderDiscount.text = String.format(
                Locale.US,
                "Discount (%s): −$%.2f",
                order.couponCode ?: "coupon",
                order.discount,
            )
        } else {
            binding.orderSubtotal.visibility = View.GONE
            binding.orderDiscount.visibility = View.GONE
        }

        binding.orderTotal.text = String.format(Locale.US, "Total: $%.2f", order.total)
    }

    companion object {
        const val EXTRA_ORDER_ID = "order_id"
        const val EXTRA_SHOW_PREVIOUS = "show_previous"
        const val EXTRA_FROM_CHECKOUT = "from_checkout"
    }
}
