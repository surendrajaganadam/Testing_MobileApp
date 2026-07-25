package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityCartBinding
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

        binding.buttonCheckout.setOnClickListener {
            if (ShopState.cart().isNotEmpty()) {
                startActivity(Intent(this, CheckoutInfoActivity::class.java))
            }
        }
        refresh()
    }

    override fun onResume() {
        super.onResume()
        refresh()
    }

    private fun refresh() {
        adapter.submit(ShopState.cart())
        binding.cartTotal.text = String.format(Locale.US, "Total: $%.2f", ShopState.cartTotal())
        binding.buttonCheckout.isEnabled = ShopState.cart().isNotEmpty()
    }
}
