package com.demo.lebyy.ui

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.data.Catalog
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityProductDetailBinding
import java.util.Locale

class ProductDetailActivity : AppCompatActivity() {
    companion object {
        const val EXTRA_PRODUCT_ID = "product_id"
    }

    private lateinit var binding: ActivityProductDetailBinding
    private var quantity = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityProductDetailBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.toolbar.setNavigationOnClickListener { finish() }

        val product = Catalog.byId(intent.getStringExtra(EXTRA_PRODUCT_ID).orEmpty())
        if (product == null) {
            finish()
            return
        }

        binding.detailImage.setImageResource(product.imageRes)
        binding.detailName.text = product.name
        binding.detailPrice.text = String.format(Locale.US, "$%.2f", product.price)
        binding.detailDesc.text = product.description
        renderQty()

        binding.buttonQtyMinus.setOnClickListener {
            if (quantity > 1) {
                quantity--
                renderQty()
            }
        }
        binding.buttonQtyPlus.setOnClickListener {
            quantity++
            renderQty()
        }
        binding.buttonAddToCart.setOnClickListener {
            ShopState.addToCart(product, quantity)
            Toast.makeText(this, "Added $quantity to cart", Toast.LENGTH_SHORT).show()
            finish()
        }
    }

    private fun renderQty() {
        binding.qtyValue.text = quantity.toString()
    }
}
