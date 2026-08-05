package com.demo.lebyy.ui

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.demo.lebyy.R
import com.demo.lebyy.data.Catalog
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityProductDetailBinding
import com.google.android.material.button.MaterialButton
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
        renderWishlist(product.id)
        renderRating(product.id)

        val ratingButtons = listOf(
            binding.rating1, binding.rating2, binding.rating3, binding.rating4, binding.rating5,
        )
        ratingButtons.forEachIndexed { index, button ->
            button.setOnClickListener {
                ShopState.setRating(product.id, index + 1)
                renderRating(product.id)
            }
        }

        binding.buttonWishlist.setOnClickListener {
            ShopState.toggleWishlist(product.id)
            renderWishlist(product.id)
        }

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

    private fun renderWishlist(productId: String) {
        val wish = ShopState.isWishlisted(productId)
        binding.buttonWishlist.text = if (wish) "REMOVE FROM WISHLIST" else "ADD TO WISHLIST"
        binding.buttonWishlist.contentDescription =
            if (wish) "test-REMOVE FROM WISHLIST" else "test-ADD TO WISHLIST"
    }

    private fun renderRating(productId: String) {
        val rating = ShopState.rating(productId)
        binding.ratingValue.text = "Your rating: $rating/5"
        binding.ratingValue.contentDescription = "Your rating: $rating/5"
        val buttons = listOf(
            binding.rating1, binding.rating2, binding.rating3, binding.rating4, binding.rating5,
        )
        buttons.forEachIndexed { index, button ->
            val selected = rating >= index + 1
            button.backgroundTintList = ContextCompat.getColorStateList(
                this,
                if (selected) R.color.lebyy_accent else R.color.lebyy_surface,
            )
            (button as MaterialButton).setTextColor(
                ContextCompat.getColor(this, if (selected) R.color.lebyy_bg else R.color.lebyy_muted),
            )
        }
    }

    private fun renderQty() {
        binding.qtyValue.text = quantity.toString()
    }
}
