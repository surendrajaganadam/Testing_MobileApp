package com.demo.lebyy.ui

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.demo.lebyy.R
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityMainBinding
import com.demo.lebyy.databinding.ItemComponentBinding
import com.demo.lebyy.databinding.TabAccountLoggedInBinding
import com.demo.lebyy.databinding.TabComponentsBinding
import com.demo.lebyy.databinding.TabHomeBinding
import com.demo.lebyy.databinding.TabShopBinding
import com.demo.lebyy.databinding.ActivityLoginBinding

data class ComponentItem(
    val title: String,
    val subtitle: String,
    val accessibilityId: String,
    val open: () -> Unit,
)

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private var currentTab = R.id.tabHome

    override fun onCreate(savedInstanceState: Bundle?) {
        // Required: switches Theme.Lebyy.Splash → Theme.Lebyy before Material views inflate.
        installSplashScreen()
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.mainToolbar)

        binding.bottomNav.setOnItemSelectedListener { item ->
            currentTab = item.itemId
            showTab(item.itemId)
            true
        }
        val openTab = intent.getStringExtra("open_tab")
        binding.bottomNav.selectedItemId = when (openTab) {
            "shop" -> R.id.tabShop
            "account" -> R.id.tabAccount
            "components" -> R.id.tabComponents
            else -> R.id.tabHome
        }
        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    override fun onResume() {
        super.onResume()
        // Refresh account/shop gate after returning from login/catalog
        if (currentTab == R.id.tabAccount || currentTab == R.id.tabShop) {
            showTab(currentTab)
        }
    }

    fun selectTab(id: Int) {
        binding.bottomNav.selectedItemId = id
    }

    private fun handleDeepLink(intent: Intent?) {
        val uri = intent?.data ?: return
        ShopState.lastDeepLink = uri.toString()
        val host = uri.host.orEmpty().lowercase()
        when (host) {
            "home" -> selectTab(R.id.tabHome)
            "components", "catalog", "alerts", "forms", "gestures", "lists",
            "waits", "system", "navigation", "webview", "swipes",
            -> {
                selectTab(R.id.tabComponents)
            }
            "shop", "orders" -> selectTab(R.id.tabShop)
            "account", "login", "settings" -> selectTab(R.id.tabAccount)
        }
    }

    private fun showTab(id: Int) {
        binding.tabContainer.removeAllViews()
        when (id) {
            R.id.tabHome -> showHome()
            R.id.tabComponents -> showComponents()
            R.id.tabShop -> showShop()
            R.id.tabAccount -> showAccount()
        }
        binding.mainToolbar.title = when (id) {
            R.id.tabHome -> ""
            R.id.tabComponents -> "Components"
            R.id.tabShop -> "Shop"
            else -> "Account"
        }
        binding.mainToolbar.visibility = if (id == R.id.tabHome) View.GONE else View.VISIBLE
    }

    private fun showHome() {
        val home = TabHomeBinding.inflate(layoutInflater, binding.tabContainer, true)
        home.homeSupport.setOnClickListener {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://lebyy.com")))
        }
        home.homeGitHub.setOnClickListener {
            startActivity(
                Intent(
                    Intent.ACTION_VIEW,
                    Uri.parse("https://github.com/surendrajaganadam/Testing_MobileApp")
                )
            )
        }
    }

    private fun showComponents() {
        val tab = TabComponentsBinding.inflate(layoutInflater, binding.tabContainer, true)
        val items = listOf(
            ComponentItem("Alerts & Dialogs", "Alert, confirm, prompt, modal, sheet, toast", "test-Components-Alerts") {
                startActivity(Intent(this, AlertsActivity::class.java))
            },
            ComponentItem("Form Controls", "Text, switches, sliders, pickers, OTP…", "test-Components-Forms") {
                startActivity(Intent(this, FormControlsHubActivity::class.java))
            },
            ComponentItem("Swipes", "Horizontal carousel & vertical scroll", "test-Components-Swipes") {
                startActivity(Intent(this, SwipeHorizontalActivity::class.java))
            },
            ComponentItem("Gestures", "Long press, drag, pinch, multi-touch…", "test-Components-Gestures") {
                startActivity(Intent(this, GesturesActivity::class.java))
            },
            ComponentItem("Lists", "Refresh, swipe actions, nested, infinite", "test-Components-Lists") {
                startActivity(Intent(this, ListsActivity::class.java))
            },
            ComponentItem("Waits", "Delayed load & network retry", "test-Components-Waits") {
                startActivity(Intent(this, WaitsActivity::class.java))
            },
            ComponentItem("System", "Permissions, media, clipboard, orientation", "test-Components-System") {
                startActivity(Intent(this, SystemActivity::class.java))
            },
            ComponentItem("Navigation", "Bottom tabs demo & deep links", "test-Components-Navigation") {
                startActivity(Intent(this, NavigationActivity::class.java))
            },
            ComponentItem("WebView", "Hybrid browser & JS alerts", "test-Components-WebView") {
                startActivity(Intent(this, WebViewActivity::class.java))
            },
        )
        tab.componentsList.layoutManager = LinearLayoutManager(this)
        tab.componentsList.adapter = ComponentsAdapter(items)
    }

    private fun showShop() {
        val tab = TabShopBinding.inflate(layoutInflater, binding.tabContainer, true)
        if (ShopState.isLoggedIn) {
            tab.shopGateTitle.text = "Shop ready"
            tab.shopGateTitle.contentDescription = "test-ShopReady"
            tab.shopGoLogin.visibility = View.GONE
            tab.shopOpenCatalog.visibility = View.VISIBLE
            tab.shopOpenCatalog.setOnClickListener {
                startActivity(Intent(this, CatalogActivity::class.java))
            }
        } else {
            tab.shopGoLogin.visibility = View.VISIBLE
            tab.shopOpenCatalog.visibility = View.GONE
            tab.shopGoLogin.setOnClickListener { selectTab(R.id.tabAccount) }
        }
    }

    private fun showAccount() {
        if (ShopState.isLoggedIn) {
            val logged = TabAccountLoggedInBinding.inflate(layoutInflater, binding.tabContainer, true)
            logged.accountDisplayName.setText(ShopState.displayName)
            logged.openSettings.setOnClickListener {
                startActivity(Intent(this, SettingsActivity::class.java))
            }
            logged.accountLogout.setOnClickListener {
                ShopState.resetSession()
                currentTab = R.id.tabAccount
                showTab(R.id.tabAccount)
            }
        } else {
            // Embed login layout
            val login = ActivityLoginBinding.inflate(layoutInflater)
            binding.tabContainer.addView(
                login.root,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                ),
            )
            wireEmbeddedLogin(login)
        }
    }

    private fun wireEmbeddedLogin(login: ActivityLoginBinding) {
        login.buttonLogin.setOnClickListener {
            val user = login.inputUsername.text?.toString()?.trim().orEmpty()
            val pass = login.inputPassword.text?.toString().orEmpty()
            if (user == "demo_user" && pass == "demo_pass") {
                ShopState.resetSession()
                ShopState.loginSuccess()
                selectTab(R.id.tabShop)
            } else {
                login.loginError.visibility = View.VISIBLE
                login.loginError.text = getString(R.string.login_error)
            }
        }
    }
}

private class ComponentsAdapter(
    private val items: List<ComponentItem>,
) : RecyclerView.Adapter<ComponentsAdapter.VH>() {
    class VH(val binding: ItemComponentBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): VH {
        val binding = ItemComponentBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return VH(binding)
    }

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = items[position]
        holder.binding.componentTitle.text = item.title
        holder.binding.componentSubtitle.text = item.subtitle
        holder.binding.root.contentDescription = item.accessibilityId
        holder.binding.root.setOnClickListener { item.open() }
    }

    override fun getItemCount(): Int = items.size
}
