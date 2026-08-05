package com.demo.lebyy.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.demo.lebyy.databinding.ActivitySwipeVerticalBinding
import com.demo.lebyy.databinding.ItemVerticalRowBinding

class SwipeVerticalActivity : AppCompatActivity() {
    private lateinit var binding: ActivitySwipeVerticalBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySwipeVerticalBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "swipe_v")

        val items = (1..40).map { "Views Item $it" }
        binding.verticalList.layoutManager = LinearLayoutManager(this)
        binding.verticalList.adapter = object : RecyclerView.Adapter<RowVH>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RowVH {
                val row = ItemVerticalRowBinding.inflate(LayoutInflater.from(parent.context), parent, false)
                return RowVH(row)
            }

            override fun onBindViewHolder(holder: RowVH, position: Int) {
                val label = items[position]
                holder.text.text = label
                holder.text.contentDescription = "test-$label"
                // Rows are inert on iOS — keep them non-interactive so swipe practice stays clean.
                holder.text.isClickable = false
                holder.text.background = null
            }

            override fun getItemCount(): Int = items.size
        }
    }

    private class RowVH(binding: ItemVerticalRowBinding) : RecyclerView.ViewHolder(binding.root) {
        val text: TextView = binding.listItemText
    }
}
