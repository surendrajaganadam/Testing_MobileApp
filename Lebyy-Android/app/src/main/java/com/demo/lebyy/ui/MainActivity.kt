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
import android.widget.TextView
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
        if (BankState.exitBankToApp) {
            BankState.exitBankToApp = false
            BankState.closeBankFlow = false
            binding.bottomNav.visibility = View.VISIBLE
            selectTab(R.id.tabHome)
            return
        }
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
        binding.mainToolbar.visibility =
            if (id == R.id.tabHome || (id == R.id.tabBank && ShopState.isLoggedIn)) {
                View.GONE
            } else {
                View.VISIBLE
            }
        // Bank uses its own footer — hide the main app tab bar while inside bank.
        binding.bottomNav.visibility =
            if (id == R.id.tabBank && ShopState.isLoggedIn) View.GONE else View.VISIBLE
    }

    private fun exitBankToApp() {
        BankState.exitBankToApp = false
        BankState.closeBankFlow = false
        binding.bottomNav.visibility = View.VISIBLE
        selectTab(R.id.tabHome)
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

    private var bankShowPromo = true
    private var bankTopTab = "Accounts"
    private var bankFooterTab = "Accounts"

    private fun showBank() {
        val tab = TabBankBinding.inflate(layoutInflater, binding.tabContainer, true)
        if (!ShopState.isLoggedIn) {
            tab.bankGate.visibility = View.VISIBLE
            tab.bankDashboard.visibility = View.GONE
            tab.bankGoLogin.setOnClickListener { selectTab(R.id.tabAccount) }
            return
        }
        tab.bankGate.visibility = View.GONE
        tab.bankDashboard.visibility = View.VISIBLE
        tab.bankRoot.contentDescription = "test-BankHome"
        tab.bankDashboard.contentDescription = "test-BankHome"

        tab.bankExitBank.setOnClickListener { exitBankToApp() }
        tab.bankMenu.setOnClickListener { BankActivity.open(this, "menu") }
        tab.bankInbox.setOnClickListener { BankActivity.open(this, "inbox") }
        tab.bankProducts.setOnClickListener { BankActivity.open(this, "products") }
        tab.bankLogOut.setOnClickListener {
            ShopState.resetSession()
            BankState.endSession()
            binding.bottomNav.visibility = View.VISIBLE
            selectTab(R.id.tabAccount)
        }
        tab.bankFooterPayTransfer.setOnClickListener {
            bankFooterTab = "Pay & Transfer"
            paintBankFooter(tab)
            BankState.refreshPayDates()
            BankActivity.open(this, "payTransfer")
        }
        tab.bankFooterDeposit.setOnClickListener {
            bankFooterTab = "Deposit Checks"
            paintBankFooter(tab)
            BankActivity.open(this, "deposit")
        }
        tab.bankFooterInvest.setOnClickListener {
            bankFooterTab = "Invest"
            paintBankFooter(tab)
            BankActivity.open(this, "invest")
        }
        tab.bankFooterAccounts.setOnClickListener {
            bankFooterTab = "Accounts"
            bankTopTab = "Accounts"
            paintBankFooter(tab)
            paintBankTopTabs(tab)
            paintBankCenter(tab)
        }
        tab.bankTopTabAccounts.setOnClickListener {
            bankTopTab = "Accounts"
            paintBankTopTabs(tab)
            paintBankCenter(tab)
        }
        tab.bankTopTabDashboard.setOnClickListener {
            bankTopTab = "Dashboard"
            paintBankTopTabs(tab)
            paintBankCenter(tab)
        }
        paintBankTopTabs(tab)
        paintBankFooter(tab)
        paintBankCenter(tab)
    }

    private fun paintBankTopTabs(tab: TabBankBinding) {
        val accounts = bankTopTab == "Accounts"
        val selected = getColor(R.color.bank_tab_selected)
        val unselected = getColor(R.color.bank_tab_unselected)
        tab.bankTopTabAccountsLabel.setTextColor(if (accounts) selected else unselected)
        tab.bankTopTabDashboardLabel.setTextColor(if (accounts) unselected else selected)
        tab.bankTopTabAccountsLabel.setTypeface(null, android.graphics.Typeface.BOLD)
        tab.bankTopTabDashboardLabel.setTypeface(null, android.graphics.Typeface.BOLD)
        tab.bankTopTabAccountsUnderline.setBackgroundColor(
            if (accounts) selected else android.graphics.Color.TRANSPARENT,
        )
        tab.bankTopTabDashboardUnderline.setBackgroundColor(
            if (accounts) android.graphics.Color.TRANSPARENT else selected,
        )
    }

    private fun paintBankFooter(tab: TabBankBinding) {
        fun colorize(row: android.widget.LinearLayout, accentRes: Int, selected: Boolean) {
            val accent = getColor(accentRes)
            val label = if (selected) accent else getColor(R.color.bank_tab_unselected)
            val style = if (selected) android.graphics.Typeface.BOLD else android.graphics.Typeface.BOLD
            row.setBackgroundColor(
                if (selected) android.graphics.Color.argb(30, android.graphics.Color.red(accent), android.graphics.Color.green(accent), android.graphics.Color.blue(accent))
                else android.graphics.Color.TRANSPARENT,
            )
            for (i in 0 until row.childCount) {
                (row.getChildAt(i) as? TextView)?.apply {
                    // Icon line keeps accent; label dark when idle, accent when selected.
                    setTextColor(if (i == 0) accent else label)
                    setTypeface(null, style)
                }
            }
        }
        colorize(tab.bankFooterAccounts, R.color.bank_footer_accounts, bankFooterTab == "Accounts")
        colorize(tab.bankFooterPayTransfer, R.color.bank_footer_pay, bankFooterTab == "Pay & Transfer")
        colorize(tab.bankFooterDeposit, R.color.bank_footer_deposit, bankFooterTab == "Deposit Checks")
        colorize(tab.bankFooterInvest, R.color.bank_footer_invest, bankFooterTab == "Invest")
    }

    private fun paintBankCenter(tab: TabBankBinding) {
        val root = tab.bankCenter
        root.removeAllViews()
        if (bankTopTab == "Dashboard") {
            paintBankDashboardPanel(root)
            return
        }
        if (bankShowPromo) {
            root.addView(bankPromoCard())
        }
        root.addView(bankAssistantBar())
        root.addView(bankGreetingBlock())
        root.addView(bankRewardsRow())
        root.addView(bankBankingSection())
        root.addView(bankCardsSection())
    }

    private fun paintBankDashboardPanel(root: android.widget.LinearLayout) {
        addBankInk(root, "Dashboard", "test-BankDashboardTitle")
        addBankInk(root, "Spending snapshot and rewards for practice automation.", "test-BankDashboardBlurb")
        addBankInk(root, "This month spent  ₹12,450.00", "test-Dash-Spent")
        addBankInk(root, "Rewards points  2,480", "test-Dash-Points")
        addBankInk(root, "Upcoming bills  2", "test-Dash-Bills")
        root.contentDescription = "test-BankDashboardPanel"
    }

    private fun bankPromoCard(): View {
        val box = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.HORIZONTAL
            setBackgroundColor(0xFFF0F0F1.toInt())
            setPadding(dp(12), dp(12), dp(12), dp(12))
            contentDescription = "test-BankPromo"
        }
        val textCol = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            layoutParams = android.widget.LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        }
        textCol.addView(android.widget.TextView(this).apply {
            text = "Open a CD and watch your money grow. Start with as little as ₹1,000 and get a competitive, guaranteed rate of return."
            contentDescription = "test-BankPromoText"
            setTextColor(0xFF1A1F29.toInt())
            textSize = 13f
        })
        textCol.addView(android.widget.TextView(this).apply {
            text = "Compare options"
            contentDescription = "test-BankPromoCompare"
            setTextColor(0xFF0D66D9.toInt())
            textSize = 13f
            setPadding(0, dp(6), 0, 0)
            setOnClickListener { BankActivity.open(this@MainActivity, "products") }
        })
        box.addView(textCol)
        box.addView(android.widget.TextView(this).apply {
            text = "✕"
            contentDescription = "test-BankPromoDismiss"
            setTextColor(0xFF6B7280.toInt())
            setPadding(dp(8), 0, 0, 0)
            setOnClickListener {
                bankShowPromo = false
                selectTab(R.id.tabBank)
            }
        })
        return box
    }

    private fun bankAssistantBar(): View {
        val row = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.HORIZONTAL
            setBackgroundColor(0xFFFFFFFF.toInt())
            setPadding(dp(12), dp(10), dp(12), dp(10))
            contentDescription = "test-BankAssistantBar"
            layoutParams = android.widget.LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(12) }
        }
        row.addView(android.widget.EditText(this).apply {
            hint = "Hi, I'm Lebyy. How can I help?"
            contentDescription = "test-BankAssistant"
            setBackgroundColor(android.graphics.Color.TRANSPARENT)
            setTextColor(0xFF1A1F29.toInt())
            setHintTextColor(0xFF6B7280.toInt())
            layoutParams = android.widget.LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        })
        val badge = android.widget.FrameLayout(this)
        badge.addView(android.widget.TextView(this).apply {
            text = "L"
            contentDescription = "test-BankAssistantOpen"
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0xFFDB2626.toInt())
            setPadding(dp(10), dp(8), dp(10), dp(8))
            setOnClickListener { BankActivity.open(this@MainActivity, "assistant") }
        })
        badge.addView(android.widget.TextView(this).apply {
            text = "6"
            contentDescription = "test-BankAssistantBadge"
            setTextColor(0xFFFFFFFF.toInt())
            setBackgroundColor(0xFF0D66D9.toInt())
            textSize = 10f
            setPadding(dp(4), dp(2), dp(4), dp(2))
            layoutParams = android.widget.FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply {
                gravity = android.view.Gravity.TOP or android.view.Gravity.END
            }
        })
        row.addView(badge)
        return row
    }

    private fun bankGreetingBlock(): View {
        val col = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            contentDescription = "test-BankGreeting"
            setPadding(0, dp(12), 0, dp(4))
            setOnClickListener { BankActivity.open(this@MainActivity, "profile") }
        }
        val full = BankState.sessionDisplayName()
        val first = full.split(" ").firstOrNull().orEmpty()
        col.addView(android.widget.TextView(this).apply {
            text = "Hello, $first"
            setTextColor(0xFF1A1F29.toInt())
            textSize = 22f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        })
        col.addView(android.widget.TextView(this).apply {
            text = full
            contentDescription = "test-BankCustomerName"
            setTextColor(0xFF6B7280.toInt())
            textSize = 12f
        })
        col.addView(android.widget.TextView(this).apply {
            text = "Role: Customer"
            contentDescription = "test-BankRole"
            setTextColor(0xFF6B7280.toInt())
            textSize = 11f
        })
        col.addView(android.widget.TextView(this).apply {
            text = "Lebyy Rewards member"
            contentDescription = "test-BankRewardsMember"
            setTextColor(0xFF6B7280.toInt())
            textSize = 14f
        })
        return col
    }

    private fun bankRewardsRow(): View {
        return android.widget.TextView(this).apply {
            text = "Lebyy Rewards™  ›"
            contentDescription = "test-BankRewards"
            setTextColor(0xFF1A1F29.toInt())
            textSize = 17f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(0, dp(8), 0, dp(8))
            setOnClickListener { BankActivity.open(this@MainActivity, "rewards") }
        }
    }

    private fun bankBankingSection(): View {
        val box = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setBackgroundColor(0xFFFFFFFF.toInt())
            contentDescription = "test-BankingSection"
            layoutParams = android.widget.LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(8) }
        }
        box.addView(brandStripe())
        box.addView(android.widget.TextView(this).apply {
            text = "Banking"
            contentDescription = "test-BankingToggle"
            setTextColor(0xFF1A1F29.toInt())
            textSize = 20f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(dp(14), dp(12), dp(14), dp(8))
        })
        val brand = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.HORIZONTAL
            contentDescription = "test-BankBrand"
            setPadding(dp(14), 0, dp(14), dp(8))
        }
        brand.addView(android.widget.TextView(this).apply {
            text = "Lebyy Bank  "
            setTextColor(0xFF6B7280.toInt())
        })
        brand.addView(android.widget.TextView(this).apply {
            text = "FDIC"
            contentDescription = "test-BankFdic"
            setTextColor(0xFF6B7280.toInt())
            setTypeface(typeface, android.graphics.Typeface.BOLD)
        })
        box.addView(brand)
        val carousel = android.widget.HorizontalScrollView(this).apply {
            contentDescription = "test-BankAccountsCarousel"
            isHorizontalScrollBarEnabled = true
        }
        val carouselRow = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.HORIZONTAL
            setPadding(dp(8), dp(8), dp(8), dp(8))
        }
        BankState.currentCustomer()?.accounts?.forEach { account ->
            carouselRow.addView(android.widget.TextView(this).apply {
                text = "${account.name} - ${account.number.takeLast(4)}\n${BankState.money(account.balance)}\nSwipe left / right"
                contentDescription = "test-AccountCarousel-${account.name}"
                setTextColor(0xFF1A1F29.toInt())
                textSize = 14f
                setBackgroundColor(0xFFF6F7F9.toInt())
                setPadding(dp(16), dp(14), dp(16), dp(14))
                minWidth = dp(220)
                layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT,
                    android.widget.LinearLayout.LayoutParams.WRAP_CONTENT,
                ).apply { marginEnd = dp(10) }
            })
        }
        carousel.addView(carouselRow)
        box.addView(carousel)
        BankState.currentCustomer()?.accounts?.forEach { account ->
            val line = "${account.name} ${account.masked} · ${BankState.money(account.balance)}"
            box.addView(android.widget.TextView(this).apply {
                text = line
                contentDescription = "test-Account-${account.name}"
                setTextColor(0xFF1A1F29.toInt())
                textSize = 16f
                setPadding(dp(14), dp(14), dp(14), dp(14))
                setOnClickListener { BankActivity.open(this@MainActivity, "activity") }
            })
        }
        return box
    }

    private fun bankCardsSection(): View {
        val box = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setBackgroundColor(0xFFFFFFFF.toInt())
            contentDescription = "test-CreditCardsSection"
            layoutParams = android.widget.LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(12) }
        }
        box.addView(brandStripe())
        box.addView(android.widget.TextView(this).apply {
            text = "Credit cards"
            contentDescription = "test-CreditCardsToggle"
            setTextColor(0xFF1A1F29.toInt())
            textSize = 20f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(dp(14), dp(12), dp(14), dp(8))
        })
        val card = BankState.currentCustomer()?.card
        if (card != null) {
            box.addView(android.widget.TextView(this).apply {
                text = "${card.network} ending ${card.last4}"
                contentDescription = "test-HomeCard-${card.network}"
                setTextColor(0xFF1A1F29.toInt())
                textSize = 16f
                setPadding(dp(14), dp(14), dp(14), dp(14))
                setOnClickListener { BankActivity.open(this@MainActivity, "cards") }
            })
        }
        return box
    }

    private fun brandStripe(): View {
        val row = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.HORIZONTAL
            layoutParams = android.widget.LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(4),
            )
        }
        row.addView(View(this).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f)
            setBackgroundColor(0xFFDB2626.toInt())
        })
        row.addView(View(this).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.MATCH_PARENT, 1f)
            setBackgroundColor(0xFF0D4DB3.toInt())
        })
        return row
    }

    private fun addBankInk(root: android.widget.LinearLayout, value: String, id: String) {
        root.addView(
            android.widget.TextView(this).apply {
                text = value
                contentDescription = id
                setTextColor(0xFF1A1F29.toInt())
                textSize = 15f
                setPadding(0, dp(8), 0, dp(4))
            },
        )
    }

    private fun addBankAction(root: android.widget.LinearLayout, label: String, id: String, onClick: () -> Unit) {
        root.addView(
            android.widget.Button(this).apply {
                text = label
                contentDescription = id
                isAllCaps = false
                setTextColor(0xFFFFFFFF.toInt())
                setBackgroundColor(0xFF0D66D9.toInt())
                setOnClickListener { onClick() }
            },
        )
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

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
        } else {
            selectTab(R.id.tabBank)
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
