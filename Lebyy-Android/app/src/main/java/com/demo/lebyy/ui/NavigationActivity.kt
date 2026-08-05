package com.demo.lebyy.ui

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityNavigationBinding
import com.google.android.material.tabs.TabLayout

class NavigationActivity : AppCompatActivity() {
    private lateinit var binding: ActivityNavigationBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityNavigationBinding.inflate(layoutInflater)
        setContentView(binding.root)
        DrawerHelper.setup(this, binding.drawerLayout, binding.navigationView, binding.toolbar, "navigation")

        val link = ShopState.lastDeepLink.ifEmpty { "—" }
        binding.lastDeepLink.text = "Last deep link: $link"

        listOf("Home", "Search", "Profile").forEach { name ->
            val tab = binding.bottomTabs.newTab().setText(name)
            tab.view.contentDescription = "test-Tab-$name"
            binding.bottomTabs.addTab(tab)
        }
        binding.bottomTabs.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab) {
                val name = tab.text?.toString().orEmpty()
                binding.tabContent.text = "$name Tab"
                binding.tabContent.contentDescription = "test-TabContent-$name"
                binding.selectedTab.text = "Selected tab: $name"
            }
            override fun onTabUnselected(tab: TabLayout.Tab?) {}
            override fun onTabReselected(tab: TabLayout.Tab?) {}
        })
    }
}
