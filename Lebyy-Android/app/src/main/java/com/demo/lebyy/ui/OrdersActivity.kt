package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
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
        class VH(val view: TextView) : RecyclerView.ViewHolder(view)

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
            val row = TextView(parent.context).apply {
                setPadding(24, 36, 24, 36)
                setTextColor(ContextCompat.getColor(parent.context, R.color.lebyy_primary))
                textSize = 16f
            }
            return VH(row)
        }

        override fun onBindViewHolder(holder: VH, position: Int) {
            val order = orders[position]
            val cancelled = if (order.status == OrderStatus.CANCELLED) " · CANCELLED" else ""
            holder.view.text =
                String.format(Locale.US, "%s  ·  $%.2f%s", order.id, order.total, cancelled)
            holder.view.contentDescription = "test-Order-${order.id}"
            holder.view.setOnClickListener { onClick(order) }
        }

        override fun getItemCount(): Int = orders.size
    }
}
