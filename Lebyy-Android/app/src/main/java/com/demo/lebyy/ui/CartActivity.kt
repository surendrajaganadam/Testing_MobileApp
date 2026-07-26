package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityCartBinding
import java.util.Locale

class CartActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCartBinding
    private lateinit var adapter: CartAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCartBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }

        adapter = CartAdapter(ShopState.cart()) { refresh() }
        binding.cartList.layoutManager = LinearLayoutManager(this)
        binding.cartList.adapter = adapter

        binding.buttonContinueShopping.setOnClickListener { finish() }

        binding.buttonCheckout.setOnClickListener {
            if (ShopState.cart().isNotEmpty()) {
                startActivity(Intent(this, CheckoutInfoActivity::class.java))
            }
        }
        refresh()
    }

    override fun onResume() {
        super.onResume()
        if (ShopState.exitCheckoutStack) {
            ShopState.exitCheckoutStack = false
            finish()
            return
        }
        refresh()
    }

    private fun refresh() {
        val lines = ShopState.cart()
        val empty = lines.isEmpty()
        binding.emptyCartPanel.visibility = if (empty) View.VISIBLE else View.GONE
        binding.cartList.visibility = if (empty) View.GONE else View.VISIBLE
        binding.cartTotal.visibility = if (empty) View.GONE else View.VISIBLE
        binding.buttonCheckout.visibility = if (empty) View.GONE else View.VISIBLE

        adapter.submit(lines)
        binding.cartTotal.text = String.format(Locale.US, "Total: $%.2f", ShopState.cartTotal())
        binding.buttonCheckout.isEnabled = !empty
    }
}
