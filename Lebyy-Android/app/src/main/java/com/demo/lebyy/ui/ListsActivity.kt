package com.demo.lebyy.ui

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.ItemTouchHelper
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.demo.lebyy.databinding.ActivityListsBinding

class ListsActivity : AppCompatActivity() {
    private lateinit var binding: ActivityListsBinding
    private var refreshCount = 0
    private var loadMoreCount = 0
    private var loadingMore = false
    private val refreshItems = mutableListOf<String>()
    private val swipeItems = mutableListOf<String>()
    private val infiniteItems = mutableListOf<Int>()
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityListsBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "lists")

        refreshItems += (1..8).map { "Refresh Item $it" }
        swipeItems += (1..6).map { "Swipe Row $it" }
        infiniteItems += (1..15)

        val refreshAdapter = SimpleTextAdapter(refreshItems, "test-RefreshItem")
        binding.refreshList.layoutManager = LinearLayoutManager(this)
        binding.refreshList.adapter = refreshAdapter
        binding.swipeRefresh.setOnRefreshListener {
            handler.postDelayed({
                refreshCount++
                refreshItems.clear()
                refreshItems += (1..8).map { "Refresh Item $it · v$refreshCount" }
                refreshAdapter.notifyDataSetChanged()
                binding.refreshCount.text = "Refresh count: $refreshCount"
                binding.refreshCount.contentDescription = "Refresh count: $refreshCount"
                binding.swipeRefresh.isRefreshing = false
            }, 800)
        }

        val swipeAdapter = SimpleTextAdapter(swipeItems, "test-SwipeRow")
        binding.swipeActionsList.layoutManager = LinearLayoutManager(this)
        binding.swipeActionsList.adapter = swipeAdapter
        ItemTouchHelper(object : ItemTouchHelper.SimpleCallback(0, ItemTouchHelper.LEFT or ItemTouchHelper.RIGHT) {
            override fun onMove(
                recyclerView: RecyclerView,
                viewHolder: RecyclerView.ViewHolder,
                target: RecyclerView.ViewHolder,
            ): Boolean = false

            override fun onSwiped(viewHolder: RecyclerView.ViewHolder, direction: Int) {
                val pos = viewHolder.bindingAdapterPosition
                if (pos < 0 || pos >= swipeItems.size) return
                val item = swipeItems.removeAt(pos)
                swipeAdapter.notifyItemRemoved(pos)
                if (direction == ItemTouchHelper.LEFT) {
                    binding.swipeActionResult.text = "Deleted: $item"
                } else {
                    binding.swipeActionResult.text = "Edited: $item"
                    swipeItems.add(pos, item)
                    swipeAdapter.notifyItemInserted(pos)
                }
            }
        }).attachToRecyclerView(binding.swipeActionsList)

        binding.resetSwipeRows.setOnClickListener {
            swipeItems.clear()
            swipeItems += (1..6).map { "Swipe Row $it" }
            swipeAdapter.notifyDataSetChanged()
            binding.swipeActionResult.text = "Deleted: —"
        }

        for (i in 1..10) {
            val card = TextView(this).apply {
                text = "Card $i"
                setPadding(36, 48, 36, 48)
                setBackgroundColor(0xFF12284B.toInt())
                setTextColor(0xFF42C6FF.toInt())
                contentDescription = "test-NestedCard-$i"
                val lp = ViewGroup.MarginLayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                )
                lp.rightMargin = 24
                layoutParams = lp
            }
            binding.nestedCards.addView(card)
        }

        val infiniteAdapter = IntTextAdapter(infiniteItems, "test-InfiniteItem")
        binding.infiniteList.layoutManager = LinearLayoutManager(this)
        binding.infiniteList.adapter = infiniteAdapter
        binding.infiniteList.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                if (dy <= 0 || loadingMore || loadMoreCount >= 5) return
                val lm = recyclerView.layoutManager as LinearLayoutManager
                val last = lm.findLastVisibleItemPosition()
                if (last >= infiniteItems.size - 2) loadMore(infiniteAdapter)
            }
        })
    }

    private fun loadMore(adapter: IntTextAdapter) {
        loadingMore = true
        binding.infiniteLoading.visibility = View.VISIBLE
        handler.postDelayed({
            val start = (infiniteItems.lastOrNull() ?: 0) + 1
            infiniteItems += (start until start + 10)
            loadMoreCount++
            adapter.notifyDataSetChanged()
            binding.infinitePageCount.text = "Pages loaded: $loadMoreCount"
            binding.infiniteLoading.visibility = View.GONE
            loadingMore = false
        }, 700)
    }
}

private class SimpleTextAdapter(
    private val items: MutableList<String>,
    private val cd: String,
) : RecyclerView.Adapter<SimpleTextAdapter.VH>() {
    class VH(val tv: TextView) : RecyclerView.ViewHolder(tv)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val tv = TextView(parent.context).apply {
            setPadding(28, 28, 28, 28)
            setTextColor(0xFFDBE7FF.toInt())
            setBackgroundColor(0xFF12284B.toInt())
            layoutParams = RecyclerView.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).also { (it as ViewGroup.MarginLayoutParams).bottomMargin = 8 }
        }
        return VH(tv)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        holder.tv.text = items[position]
        holder.tv.contentDescription = cd
    }

    override fun getItemCount(): Int = items.size
}

private class IntTextAdapter(
    private val items: MutableList<Int>,
    private val cd: String,
) : RecyclerView.Adapter<IntTextAdapter.VH>() {
    class VH(val tv: TextView) : RecyclerView.ViewHolder(tv)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val tv = TextView(parent.context).apply {
            setPadding(28, 28, 28, 28)
            setTextColor(0xFFDBE7FF.toInt())
            setBackgroundColor(0xFF12284B.toInt())
            layoutParams = RecyclerView.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).also { (it as ViewGroup.MarginLayoutParams).bottomMargin = 8 }
        }
        return VH(tv)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        holder.tv.text = "Infinite Item ${items[position]}"
        holder.tv.contentDescription = cd
    }

    override fun getItemCount(): Int = items.size
}
