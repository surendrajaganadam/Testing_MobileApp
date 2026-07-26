package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.demo.lebyy.R
import com.demo.lebyy.data.Order
import com.demo.lebyy.data.OrderStatus
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityOrdersBinding
import java.util.Locale

class OrdersActivity : AppCompatActivity() {
    private lateinit var binding: ActivityOrdersBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityOrdersBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "orders")
        binding.ordersList.layoutManager = LinearLayoutManager(this)
    }

    override fun onResume() {
        super.onResume()
        val orders = ShopState.orders()
        if (orders.isEmpty()) {
            binding.ordersEmpty.visibility = View.VISIBLE
            binding.ordersList.visibility = View.GONE
        } else {
            binding.ordersEmpty.visibility = View.GONE
            binding.ordersList.visibility = View.VISIBLE
            binding.ordersList.adapter = OrdersAdapter(orders) { order ->
                startActivity(
                    Intent(this, OrderDetailsActivity::class.java)
                        .putExtra(OrderDetailsActivity.EXTRA_ORDER_ID, order.id)
                        .putExtra(OrderDetailsActivity.EXTRA_SHOW_PREVIOUS, false),
                )
            }
        }
    }

    private class OrdersAdapter(
        private val orders: List<Order>,
        private val onClick: (Order) -> Unit,
    ) : RecyclerView.Adapter<OrdersAdapter.VH>() {
        class VH(
            val root: LinearLayout,
            val title: TextView,
            val indexMarker: TextView,
        ) : RecyclerView.ViewHolder(root)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val root = LinearLayout(parent.context).apply {
                orientation = LinearLayout.VERTICAL
                layoutParams = RecyclerView.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                )
                setPadding(24, 36, 24, 36)
            }
            val title = TextView(parent.context).apply {
                setTextColor(ContextCompat.getColor(parent.context, R.color.lebyy_primary))
                textSize = 16f
            }
            // Zero-size node so tests can use stable index without knowing dynamic order id.
            val indexMarker = TextView(parent.context).apply {
                layoutParams = LinearLayout.LayoutParams(0, 0)
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
            }
            root.addView(title)
            root.addView(indexMarker)
            return VH(root, title, indexMarker)
        }

        override fun onBindViewHolder(holder: VH, position: Int) {
            val order = orders[position]
            val cancelled = if (order.status == OrderStatus.CANCELLED) " · CANCELLED" else ""
            holder.title.text =
                String.format(Locale.US, "%s  ·  $%.2f%s", order.id, order.total, cancelled)
            // Unique by dynamic order id
            holder.root.contentDescription = "test-Order-${order.id}"
            holder.title.contentDescription = "test-OrderId-${order.id}"
            // Stable index: 1 = latest order
            holder.indexMarker.contentDescription = "test-OrderIndex-${position + 1}"
            holder.root.setOnClickListener { onClick(order) }
        }

        override fun getItemCount(): Int = orders.size
    }
}
