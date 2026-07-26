package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.lebyy.app.R
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityOrderDetailsBinding
import java.text.DateFormat
import java.util.Date
import java.util.Locale

class OrderDetailsActivity : AppCompatActivity() {
    private lateinit var binding: ActivityOrderDetailsBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityOrderDetailsBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }

        val orderId = intent.getStringExtra(EXTRA_ORDER_ID).orEmpty()
        val showPrevious = intent.getBooleanExtra(EXTRA_SHOW_PREVIOUS, true)
        val order = ShopState.orderById(orderId)
        if (order == null) {
            binding.orderConfirmed.text = "Order not found"
            return
        }

        binding.orderId.text = order.id
        binding.orderDate.text = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT)
            .format(Date(order.placedAtMs))
        binding.orderItems.text = order.items.joinToString("\n") {
            String.format(Locale.US, "• %s x%d — $%.2f", it.name, it.quantity, it.lineTotal)
        }
        binding.orderShipping.text = "${order.firstName} ${order.lastName}\n${order.zipCode}"
        binding.orderPayment.text = "Card ending ${order.cardLast4}"
        binding.orderTotal.text = String.format(Locale.US, "Total: $%.2f", order.total)

        if (!showPrevious) return

        binding.previousOrdersTitle.visibility = View.VISIBLE
        val previous = ShopState.orders().filter { it.id != order.id }
        if (previous.isEmpty()) {
            binding.previousOrdersEmpty.visibility = View.VISIBLE
            return
        }

        previous.forEach { prev ->
            val row = TextView(this).apply {
                text = String.format(Locale.US, "%s  ·  $%.2f", prev.id, prev.total)
                setTextColor(ContextCompat.getColor(this@OrderDetailsActivity, R.color.lebyy_primary))
                textSize = 16f
                setPadding(0, 24, 0, 24)
                contentDescription = "test-PreviousOrder-${prev.id}"
                setOnClickListener {
                    startActivity(
                        Intent(this@OrderDetailsActivity, OrderDetailsActivity::class.java)
                            .putExtra(EXTRA_ORDER_ID, prev.id)
                            .putExtra(EXTRA_SHOW_PREVIOUS, false),
                    )
                }
            }
            binding.previousOrdersList.addView(
                row,
                LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                ),
            )
        }
    }

    companion object {
        const val EXTRA_ORDER_ID = "order_id"
        const val EXTRA_SHOW_PREVIOUS = "show_previous"
    }
}
