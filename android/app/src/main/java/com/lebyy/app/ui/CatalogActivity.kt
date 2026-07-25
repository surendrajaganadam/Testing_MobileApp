package com.lebyy.app.ui

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import com.lebyy.app.R
import com.lebyy.app.data.Catalog
import com.lebyy.app.data.ShopState
import com.lebyy.app.databinding.ActivityCatalogBinding

class CatalogActivity : AppCompatActivity() {
    private lateinit var binding: ActivityCatalogBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCatalogBinding.inflate(layoutInflater)
        setContentView(binding.root)

        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "shop")

        binding.productList.layoutManager = LinearLayoutManager(this)
        binding.productList.adapter = ProductAdapter(Catalog.products) {
            invalidateOptionsMenu()
            (binding.productList.adapter as? ProductAdapter)?.notifyDataSetChanged()
        }
    }

    override fun onResume() {
        super.onResume()
        invalidateOptionsMenu()
        (binding.productList.adapter as? ProductAdapter)?.notifyDataSetChanged()
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
