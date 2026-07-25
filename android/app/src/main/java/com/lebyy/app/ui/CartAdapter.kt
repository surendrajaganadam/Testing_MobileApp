package com.lebyy.app.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.lebyy.app.data.CartLine
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ItemCartBinding
import java.util.Locale

class CartAdapter(
    private var items: List<CartLine>,
    private val onChanged: () -> Unit,
) : RecyclerView.Adapter<CartAdapter.VH>() {

    class VH(val binding: ItemCartBinding) : RecyclerView.ViewHolder(binding.root)

    fun submit(items: List<CartLine>) {
        this.items = items
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val binding = ItemCartBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return VH(binding)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val line = items[position]
        holder.binding.cartItemImage.setImageResource(line.product.imageRes)
        holder.binding.cartItemName.text = line.product.name
        holder.binding.cartItemPrice.text =
            String.format(Locale.US, "$%.2f each", line.product.price)
        holder.binding.cartItemQty.text =
            String.format(Locale.US, "Qty: %d  |  Line: $%.2f", line.quantity, line.lineTotal)
        holder.binding.buttonRemove.setOnClickListener {
            ShopState.removeFromCart(line.product.id)
            onChanged()
        }
    }

    override fun getItemCount(): Int = items.size
}
