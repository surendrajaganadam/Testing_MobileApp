package com.demo.lebyy.ui

import android.app.Activity
import android.content.Intent
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.core.content.ContextCompat
import androidx.core.view.GravityCompat
import androidx.drawerlayout.widget.DrawerLayout
import com.demo.lebyy.R
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.DrawerHeaderBinding
import com.google.android.material.navigation.NavigationView

object DrawerHelper {
    fun setup(
        activity: AppCompatActivity,
        drawerLayout: DrawerLayout,
        navigationView: NavigationView,
        toolbar: Toolbar,
        current: String,
    ) {
        activity.setSupportActionBar(toolbar)
        toolbar.navigationIcon = ContextCompat.getDrawable(activity, R.drawable.ic_menu)
        toolbar.navigationContentDescription = "test-Menu"
        toolbar.setNavigationOnClickListener {
            drawerLayout.openDrawer(GravityCompat.START)
        }

        // Avoid duplicate headers on recreation
        if (navigationView.headerCount == 0) {
            val header = DrawerHeaderBinding.inflate(activity.layoutInflater, navigationView, false)
            navigationView.addHeaderView(header.root)
            navigationView.menu.clear()
            wire(activity, drawerLayout, header, current)
        } else {
            val headerView = navigationView.getHeaderView(0)
            val header = DrawerHeaderBinding.bind(headerView)
            wire(activity, drawerLayout, header, current)
        }
    }

    private fun wire(
        activity: AppCompatActivity,
        drawerLayout: DrawerLayout,
        header: DrawerHeaderBinding,
        current: String,
    ) {
        fun go(target: Class<out Activity>, key: String) {
            drawerLayout.closeDrawer(GravityCompat.START)
            if (current == key) return
            val intent = Intent(activity, target)
            if (key == "shop") {
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            activity.startActivity(intent)
            if (activity !is CatalogActivity) {
                activity.finish()
            }
        }

        header.drawerShop.setOnClickListener { go(CatalogActivity::class.java, "shop") }
        header.drawerOrders.setOnClickListener { go(OrdersActivity::class.java, "orders") }
        header.drawerAlerts.setOnClickListener { go(AlertsActivity::class.java, "alerts") }
        header.drawerForms.setOnClickListener { go(FormsActivity::class.java, "forms") }
        header.drawerSwipeHorizontal.setOnClickListener {
            go(SwipeHorizontalActivity::class.java, "swipe_h")
        }
        header.drawerSwipeVertical.setOnClickListener {
            go(SwipeVerticalActivity::class.java, "swipe_v")
        }
        header.drawerGestures.setOnClickListener { go(GesturesActivity::class.java, "gestures") }
        header.drawerWebView.setOnClickListener { go(WebViewActivity::class.java, "webview") }
        header.drawerLogout.setOnClickListener {
            drawerLayout.closeDrawer(GravityCompat.START)
            ShopState.resetSession()
            activity.startActivity(
                Intent(activity, LoginActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                },
            )
            activity.finish()
        }

        highlight(header.drawerShop, current == "shop")
        highlight(header.drawerOrders, current == "orders")
        highlight(header.drawerAlerts, current == "alerts")
        highlight(header.drawerForms, current == "forms")
        highlight(header.drawerSwipeHorizontal, current == "swipe_h")
        highlight(header.drawerSwipeVertical, current == "swipe_v")
        highlight(header.drawerGestures, current == "gestures")
        highlight(header.drawerWebView, current == "webview")
    }

    private fun highlight(view: View, selected: Boolean) {
        view.alpha = if (selected) 1f else 0.75f
        view.isSelected = selected
    }
}
