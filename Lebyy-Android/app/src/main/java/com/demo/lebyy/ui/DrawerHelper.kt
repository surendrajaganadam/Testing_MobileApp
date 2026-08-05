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

    fun openDestination(activity: Activity, key: String) {
        val target = classForKey(key) ?: return
        val intent = Intent(activity, target)
        if (key == "shop") {
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        activity.startActivity(intent)
        if (activity !is CatalogActivity && key != "shop") {
            // leave caller as-is for shop; other screens replace
        }
        if (activity !is CatalogActivity) {
            activity.finish()
        }
    }

    fun classForKey(key: String): Class<out Activity>? = when (key) {
        "shop" -> CatalogActivity::class.java
        "orders" -> OrdersActivity::class.java
        "alerts" -> AlertsActivity::class.java
        "forms" -> FormControlsHubActivity::class.java
        "swipe_h" -> SwipeHorizontalActivity::class.java
        "swipe_v" -> SwipeVerticalActivity::class.java
        "gestures" -> GesturesActivity::class.java
        "lists" -> ListsActivity::class.java
        "waits" -> WaitsActivity::class.java
        "system" -> SystemActivity::class.java
        "navigation" -> NavigationActivity::class.java
        "settings" -> SettingsActivity::class.java
        "webview" -> WebViewActivity::class.java
        else -> null
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
        header.drawerForms.setOnClickListener { go(FormControlsHubActivity::class.java, "forms") }
        header.drawerSwipeHorizontal.setOnClickListener {
            go(SwipeHorizontalActivity::class.java, "swipe_h")
        }
        header.drawerSwipeVertical.setOnClickListener {
            go(SwipeVerticalActivity::class.java, "swipe_v")
        }
        header.drawerGestures.setOnClickListener { go(GesturesActivity::class.java, "gestures") }
        header.drawerLists.setOnClickListener { go(ListsActivity::class.java, "lists") }
        header.drawerWaits.setOnClickListener { go(WaitsActivity::class.java, "waits") }
        header.drawerSystem.setOnClickListener { go(SystemActivity::class.java, "system") }
        header.drawerNavigation.setOnClickListener { go(NavigationActivity::class.java, "navigation") }
        header.drawerSettings.setOnClickListener { go(SettingsActivity::class.java, "settings") }
        header.drawerWebView.setOnClickListener { go(WebViewActivity::class.java, "webview") }
        header.drawerLogout.setOnClickListener {
            drawerLayout.closeDrawer(GravityCompat.START)
            ShopState.resetSession()
            activity.startActivity(
                Intent(activity, MainActivity::class.java).apply {
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
        highlight(header.drawerLists, current == "lists")
        highlight(header.drawerWaits, current == "waits")
        highlight(header.drawerSystem, current == "system")
        highlight(header.drawerNavigation, current == "navigation")
        highlight(header.drawerSettings, current == "settings")
        highlight(header.drawerWebView, current == "webview")
    }

    private fun highlight(view: View, selected: Boolean) {
        view.alpha = if (selected) 1f else 0.75f
        view.isSelected = selected
    }
}
