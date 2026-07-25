package com.lebyy.app.ui

import android.content.Intent
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.RecyclerView
import com.lebyy.app.R
import com.lebyy.app.data.Product
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ItemProductBinding
import java.util.Locale

class ProductAdapter(
    private val products: List<Product>,
    private val onCartChanged: () -> Unit,
) : RecyclerView.Adapter<ProductAdapter.VH>() {

    class VH(val binding: ItemProductBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val binding = ItemProductBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return VH(binding)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val product = products[position]
        val ctx = holder.itemView.context
        holder.binding.productImage.setImageResource(product.imageRes)
        holder.binding.productName.text = product.name
        holder.binding.productName.contentDescription = "test-${product.name}"
        holder.binding.productPrice.text = String.format(Locale.US, "$%.2f", product.price)
        holder.binding.productDesc.text = product.description

        holder.binding.root.setOnClickListener {
            ctx.startActivity(
                Intent(ctx, ProductDetailActivity::class.java).putExtra(
                    ProductDetailActivity.EXTRA_PRODUCT_ID,
                    product.id,
                ),
            )
        }

        val inCart = ShopState.isInCart(product.id)
        if (inCart) {
            holder.binding.buttonAddToCart.text = ctx.getString(R.string.remove)
            holder.binding.buttonAddToCart.contentDescription = "test-REMOVE"
            holder.binding.buttonAddToCart.setTextColor(ContextCompat.getColor(ctx, R.color.lebyy_text))
            holder.binding.buttonAddToCart.backgroundTintList =
                ContextCompat.getColorStateList(ctx, R.color.lebyy_surface_2)
            holder.binding.buttonAddToCart.setOnClickListener {
                ShopState.removeFromCart(product.id)
                onCartChanged()
            }
        } else {
            holder.binding.buttonAddToCart.text = ctx.getString(R.string.add_to_cart)
            holder.binding.buttonAddToCart.contentDescription = "test-ADD TO CART"
            holder.binding.buttonAddToCart.setTextColor(ContextCompat.getColor(ctx, R.color.lebyy_bg))
            holder.binding.buttonAddToCart.backgroundTintList =
                ContextCompat.getColorStateList(ctx, R.color.lebyy_accent)
            holder.binding.buttonAddToCart.setOnClickListener {
                ShopState.addToCart(product, 1)
                onCartChanged()
            }
        }
    }

    override fun getItemCount(): Int = products.size
}
