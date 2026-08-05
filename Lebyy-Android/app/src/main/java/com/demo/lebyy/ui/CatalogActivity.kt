package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import com.demo.lebyy.R
import com.demo.lebyy.data.Catalog
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityCatalogBinding
import com.google.android.material.button.MaterialButton

class CatalogActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCatalogBinding
    private lateinit var adapter: ProductAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCatalogBinding.inflate(layoutInflater)
        setContentView(binding.root)

        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "shop")

        adapter = ProductAdapter(mutableListOf()) {
            invalidateOptionsMenu()
            refreshList()
        }
        binding.productList.layoutManager = LinearLayoutManager(this)
        binding.productList.adapter = adapter

        binding.shopSearch.setText(ShopState.shopSearch)
        binding.shopSearch.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                ShopState.shopSearch = s?.toString().orEmpty()
                binding.clearSearch.visibility =
                    if (ShopState.shopSearch.isEmpty()) View.GONE else View.VISIBLE
                refreshList()
            }
        })
        binding.clearSearch.setOnClickListener {
            binding.shopSearch.setText("")
            ShopState.shopSearch = ""
            binding.clearSearch.visibility = View.GONE
            refreshList()
        }

        fun selectSort(key: String, button: MaterialButton) {
            ShopState.shopSort = key
            listOf(binding.sortNameAsc, binding.sortNameDesc, binding.sortPriceLow, binding.sortPriceHigh)
                .forEach {
                    it.backgroundTintList = ContextCompat.getColorStateList(this, R.color.lebyy_surface)
                    it.setTextColor(ContextCompat.getColor(this, R.color.lebyy_text))
                }
            button.backgroundTintList = ContextCompat.getColorStateList(this, R.color.lebyy_accent)
            button.setTextColor(ContextCompat.getColor(this, R.color.lebyy_bg))
            refreshList()
        }
        binding.sortNameAsc.setOnClickListener { selectSort("nameAsc", binding.sortNameAsc) }
        binding.sortNameDesc.setOnClickListener { selectSort("nameDesc", binding.sortNameDesc) }
        binding.sortPriceLow.setOnClickListener { selectSort("priceLow", binding.sortPriceLow) }
        binding.sortPriceHigh.setOnClickListener { selectSort("priceHigh", binding.sortPriceHigh) }
        selectSort(ShopState.shopSort, when (ShopState.shopSort) {
            "nameDesc" -> binding.sortNameDesc
            "priceLow" -> binding.sortPriceLow
            "priceHigh" -> binding.sortPriceHigh
            else -> binding.sortNameAsc
        })
    }

    private fun refreshList() {
        val items = ShopState.filteredProducts(Catalog.products)
        adapter.submit(items)
        binding.shopCount.text = "Showing ${items.size} courses"
        binding.shopCount.contentDescription = "Showing ${items.size} courses"
        binding.shopEmpty.visibility = if (items.isEmpty()) View.VISIBLE else View.GONE
        binding.productList.visibility = if (items.isEmpty()) View.GONE else View.VISIBLE
    }

    override fun onResume() {
        super.onResume()
        invalidateOptionsMenu()
        refreshList()
    }

    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.catalog_toolbar, menu)
        val cartItem = menu.findItem(R.id.actionCart)
        val count = ShopState.cartCount()
        cartItem.title = "Cart ($count)"

        val actionView = LayoutInflater.from(this).inflate(R.layout.view_cart_action, null)
        val badge = actionView.findViewById<TextView>(R.id.cartBadge)
        if (count > 0) {
            badge.visibility = View.VISIBLE
            badge.text = if (count > 99) "99+" else count.toString()
            badge.contentDescription = "test-CartCount"
        } else {
            badge.visibility = View.GONE
        }
        actionView.setOnClickListener {
            startActivity(Intent(this, CartActivity::class.java))
        }
        cartItem.actionView = actionView
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.actionCart) {
            startActivity(Intent(this, CartActivity::class.java))
            return true
        }
        return super.onOptionsItemSelected(item)
    }
}
