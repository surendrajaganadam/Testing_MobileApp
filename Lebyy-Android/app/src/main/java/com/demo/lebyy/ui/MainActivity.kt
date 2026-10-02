package com.demo.lebyy.ui

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.demo.lebyy.R
import com.demo.lebyy.data.BankState
import com.demo.lebyy.data.ShopState
import com.demo.lebyy.databinding.ActivityMainBinding
import com.demo.lebyy.databinding.TabBankBinding
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

    private val handler = Handler(Looper.getMainLooper())

    /** Login layout currently embedded in the Account tab, if any. */
    private var embeddedLogin: ActivityLoginBinding? = null
    private var doubleTapCount = 0

    /** Set when the Shop tab is entered so it lands straight on the catalog, like iOS. */
    private var pendingShopAutoOpen = false

    /** Guards the auto-open while a deep link drives navigation itself. */
    private var skipShopAutoOpenOnce = false

    private val longPressRunnable = Runnable { showLoginGestureResult(R.string.login_long_press_done) }
    private val resetDoubleTapRunnable = Runnable { doubleTapCount = 0 }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Required: switches Theme.Lebyy.Splash → Theme.Lebyy before Material views inflate.
        installSplashScreen()
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.mainToolbar)

        // Avoid the Google Password Manager dialog covering the embedded login during automation
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            window.decorView.importantForAutofill = View.IMPORTANT_FOR_AUTOFILL_NO_EXCLUDE_DESCENDANTS
        }

        binding.bottomNav.setOnItemSelectedListener { item ->
            currentTab = item.itemId
            if (item.itemId == R.id.tabShop) {
                pendingShopAutoOpen = !skipShopAutoOpenOnce
            }
            showTab(item.itemId)
            true
        }

        // Record the link before the first tab renders so Home can show the caption right away.
        intent?.data?.let { ShopState.lastDeepLink = it.toString() }

        binding.bottomNav.selectedItemId = when (intent.getStringExtra("open_tab")) {
            "shop" -> R.id.tabShop
            "bank" -> R.id.tabBank
            "account" -> R.id.tabAccount
            "components" -> R.id.tabComponents
            else -> R.id.tabHome
        }
        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        when (intent.getStringExtra("open_tab")) {
            "shop" -> selectTab(R.id.tabShop)
            "bank" -> selectTab(R.id.tabBank)
            "account" -> selectTab(R.id.tabAccount)
            "components" -> selectTab(R.id.tabComponents)
            "home" -> selectTab(R.id.tabHome)
        }
        handleDeepLink(intent)
    }

    override fun onResume() {
        super.onResume()
        // Refresh account/shop gate after returning from login/catalog
        if (currentTab == R.id.tabAccount || currentTab == R.id.tabShop || currentTab == R.id.tabBank) {
            showTab(currentTab)
        }
    }

    override fun onDestroy() {
        handler.removeCallbacks(longPressRunnable)
        handler.removeCallbacks(resetDoubleTapRunnable)
        super.onDestroy()
    }

    fun selectTab(id: Int) {
        binding.bottomNav.selectedItemId = id
    }

    // MARK: - Deep links

    private fun handleDeepLink(intent: Intent?) {
        val uri = intent?.data ?: return
        ShopState.lastDeepLink = uri.toString()
        val host = uri.host.orEmpty().ifEmpty { uri.path.orEmpty().trim('/') }.lowercase()
        navigateForDeepLinkHost(host)
    }

    /** Selects the matching tab *and* opens the target screen, mirroring iOS `handleDeepLink`. */
    private fun navigateForDeepLinkHost(host: String) {
        val tab = tabForDeepLinkHost(host) ?: return
        val destination = ShopState.destinationFromDeepLinkHost(host)

        if (ShopState.destinationRequiresLogin(destination) && !ShopState.isLoggedIn) {
            ShopState.pendingDeepLinkHost = host
            selectTab(R.id.tabAccount)
            return
        }

        skipShopAutoOpenOnce = destination != null
        selectTab(tab)
        skipShopAutoOpenOnce = false

        when {
            destination == null -> Unit
            destination == "shop" -> openCatalog()
            else -> DrawerHelper.classForKey(destination)?.let {
                startActivity(Intent(this, it))
            }
        }
    }

    private fun tabForDeepLinkHost(host: String): Int? = when (host) {
        "home" -> R.id.tabHome
        "components", "catalog", "alerts", "forms", "formcontrols", "swipes", "swipeh",
        "swipev", "swipehorizontal", "swipevertical", "gestures", "lists", "waits",
        "system", "navigation", "nav", "webview", "web",
        -> R.id.tabComponents
        "shop", "orders", "orderhistory" -> R.id.tabShop
        "bank" -> R.id.tabBank
        "account", "login", "settings" -> R.id.tabAccount
        else -> null
    }

    // MARK: - Tabs

    private fun showTab(id: Int) {
        embeddedLogin = null
        binding.tabContainer.removeAllViews()
        when (id) {
            R.id.tabHome -> showHome()
            R.id.tabComponents -> showComponents()
            R.id.tabShop -> showShop()
            R.id.tabBank -> showBank()
            R.id.tabAccount -> showAccount()
        }
        binding.mainToolbar.title = when (id) {
            R.id.tabHome -> ""
            R.id.tabComponents -> "Components"
            R.id.tabShop -> "Shop"
            R.id.tabBank -> "Bank"
            else -> "Account"
        }
        binding.mainToolbar.visibility = if (id == R.id.tabHome) View.GONE else View.VISIBLE
    }

    private fun showHome() {
        val home = TabHomeBinding.inflate(layoutInflater, binding.tabContainer, true)
        if (ShopState.lastDeepLink.isEmpty()) {
            home.homeDeepLink.visibility = View.GONE
        } else {
            home.homeDeepLink.visibility = View.VISIBLE
            home.homeDeepLink.text = getString(R.string.home_last_deep_link, ShopState.lastDeepLink)
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
                startActivity(Intent(this, SwipesHubActivity::class.java))
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

    /**
     * iOS makes the Shop tab *be* the catalog once signed in. Android keeps a thin launcher that
     * carries the same toolbar actions (Orders / Cart) and jumps straight into [CatalogActivity]
     * whenever the tab is entered.
     */
    private fun showShop() {
        val autoOpenCatalog = pendingShopAutoOpen
        pendingShopAutoOpen = false

        val tab = TabShopBinding.inflate(layoutInflater, binding.tabContainer, true)
        if (ShopState.isLoggedIn) {
            tab.shopGateTitle.text = getString(R.string.shop_ready)
            tab.shopGateTitle.contentDescription = "test-ShopReady"
            tab.shopGoLogin.visibility = View.GONE
            tab.shopOpenCatalog.visibility = View.VISIBLE
            tab.shopActionsRow.visibility = View.VISIBLE
            tab.shopOpenCatalog.setOnClickListener { openCatalog() }
            tab.shopOpenOrders.setOnClickListener {
                startActivity(Intent(this, OrdersActivity::class.java))
            }
            tab.shopCart.setOnClickListener {
                startActivity(Intent(this, CartActivity::class.java))
            }

            val count = ShopState.cartCount()
            if (count > 0) {
                tab.shopCartCount.visibility = View.VISIBLE
                tab.shopCartCount.text = if (count > 99) "99+" else count.toString()
            } else {
                tab.shopCartCount.visibility = View.GONE
            }

            if (autoOpenCatalog) openCatalog()
        } else {
            tab.shopGoLogin.visibility = View.VISIBLE
            tab.shopOpenCatalog.visibility = View.GONE
            tab.shopActionsRow.visibility = View.GONE
            tab.shopGoLogin.setOnClickListener { selectTab(R.id.tabAccount) }
        }
    }

    private fun openCatalog() {
        startActivity(Intent(this, CatalogActivity::class.java))
    }

    private fun showBank() {
        val tab = TabBankBinding.inflate(layoutInflater, binding.tabContainer, true)
        val root = tab.bankContent
        if (!ShopState.isLoggedIn) {
            addBankText(root, "Bank needs login", "test-BankLoginGateTitle")
            addBankButton(root, "Go to Login", "test-BankGoLogin") { selectTab(R.id.tabAccount) }
            return
        }
        if (BankState.isManager()) {
            root.contentDescription = "test-ManagerHome"
            addBankText(root, BankState.MANAGER_NAME, "test-ManagerName")
            addBankText(root, "Role: Manager", "test-BankRole")
            addBankText(root, "Pending: ${BankState.pendingTransfers().size}", "test-PendingCount")
            addBankText(root, "Customers: ${BankState.customers().size}", "test-CustomerCount")
            addBankButton(root, "Pending queue", "test-Bank-Pending") { BankActivity.open(this, "pending") }
            addBankButton(root, "Customers", "test-Bank-Customers") { BankActivity.open(this, "customers") }
            addBankButton(root, "Decision history", "test-Bank-Decisions") { BankActivity.open(this, "decisions") }
        } else {
            root.contentDescription = "test-BankHome"
            val customer = BankState.currentCustomer()
            addBankText(root, customer?.displayName.orEmpty(), "test-BankCustomerName")
            addBankText(root, "Role: Customer", "test-BankRole")
            customer?.accounts?.forEach { account ->
                addBankText(
                    root,
                    "${account.name} ${account.masked} · ${BankState.money(account.balance)}",
                    "test-Account-${account.name}",
                )
            }
            addBankButton(root, "Transfer", "test-Bank-Transfer") { BankActivity.open(this, "transfer") }
            addBankButton(root, "Payees", "test-Bank-Payees") { BankActivity.open(this, "payees") }
            addBankButton(root, "Pay a bill", "test-Bank-Bills") { BankActivity.open(this, "bills") }
            addBankButton(root, "Cards", "test-Bank-Cards") { BankActivity.open(this, "cards") }
            addBankButton(root, "Activity", "test-Bank-Activity") { BankActivity.open(this, "activity") }
        }
    }

    private fun addBankText(root: android.widget.LinearLayout, value: String, id: String) {
        root.addView(
            android.widget.TextView(this).apply {
                text = value
                contentDescription = id
                setTextColor(getColor(R.color.lebyy_text))
                textSize = 16f
                setPadding(0, 12, 0, 4)
            },
        )
    }

    private fun addBankButton(root: android.widget.LinearLayout, label: String, id: String, onClick: () -> Unit) {
        root.addView(
            android.widget.Button(this).apply {
                text = label
                contentDescription = id
                isAllCaps = false
                setTextColor(getColor(R.color.lebyy_bg))
                setBackgroundColor(getColor(R.color.lebyy_accent))
                setOnClickListener { onClick() }
            },
        )
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
                BankState.endSession()
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

    // MARK: - Embedded login

    private fun wireEmbeddedLogin(login: ActivityLoginBinding) {
        embeddedLogin = login
        handler.removeCallbacks(longPressRunnable)
        handler.removeCallbacks(resetDoubleTapRunnable)
        doubleTapCount = 0
        login.gestureResultRow.visibility = View.GONE
        login.gestureResult.text = ""

        login.buttonLogin.setOnClickListener {
            val user = login.inputUsername.text?.toString()?.trim().orEmpty()
            val pass = login.inputPassword.text?.toString().orEmpty()
            val role = BankState.authenticate(user, pass)
            if (role != null) {
                completeLogin(user, role)
            } else {
                login.loginError.visibility = View.VISIBLE
                login.loginError.text = getString(R.string.login_error)
            }
        }

        login.gestureResultDismiss.setOnClickListener {
            login.gestureResultRow.visibility = View.GONE
            login.gestureResult.text = ""
        }

        // Dedicated long-press target (2 seconds) — separate from double-tap to avoid conflicts.
        login.buttonLongPress.setOnTouchListener { view, event ->
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    view.isPressed = true
                    handler.removeCallbacks(longPressRunnable)
                    handler.postDelayed(longPressRunnable, LONG_PRESS_MS)
                    true
                }

                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    view.isPressed = false
                    handler.removeCallbacks(longPressRunnable)
                    true
                }

                else -> false
            }
        }

        // Custom double-tap window so MobileWright's two sequential taps still count.
        login.buttonDoubleTap.setOnClickListener {
            doubleTapCount += 1
            if (doubleTapCount >= 2) {
                handler.removeCallbacks(resetDoubleTapRunnable)
                doubleTapCount = 0
                showLoginGestureResult(R.string.login_double_tap_done)
            } else {
                handler.removeCallbacks(resetDoubleTapRunnable)
                handler.postDelayed(resetDoubleTapRunnable, DOUBLE_TAP_WINDOW_MS)
            }
        }
    }

    private fun showLoginGestureResult(messageRes: Int) {
        val login = embeddedLogin ?: return
        login.gestureResult.text = getString(messageRes)
        login.gestureResultRow.visibility = View.VISIBLE
    }

    private fun completeLogin(username: String, role: String) {
        val pendingHost = ShopState.pendingDeepLinkHost
        ShopState.resetSession()
        BankState.startSession(username, role)
        ShopState.displayName = BankState.sessionDisplayName()
        ShopState.loginSuccess()
        if (pendingHost != null) {
            ShopState.pendingDeepLinkHost = null
            navigateForDeepLinkHost(pendingHost)
        } else if (role == "manager") {
            selectTab(R.id.tabBank)
        } else {
            selectTab(R.id.tabShop)
        }
    }

    private companion object {
        const val LONG_PRESS_MS = 2000L
        const val DOUBLE_TAP_WINDOW_MS = 800L
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
        CatalogRowBinder.bind(
            binding = holder.binding,
            title = item.title,
            subtitle = item.subtitle,
            accessibilityId = item.accessibilityId,
            onOpen = item.open,
        )
    }

    override fun getItemCount(): Int = items.size
}
