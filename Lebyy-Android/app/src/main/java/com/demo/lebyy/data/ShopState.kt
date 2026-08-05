package com.demo.lebyy.data

data class OrderItem(
    val productId: String,
    val name: String,
    val quantity: Int,
    val lineTotal: Double,
    val imageRes: Int,
)

enum class OrderStatus {
    PLACED,
    CANCELLED,
}

data class SavedAddress(
    val id: String,
    val label: String,
    val firstName: String,
    val lastName: String,
    val zipCode: String,
)

data class SampleCoupon(
    val code: String,
    val title: String,
    val percentOff: Int,
)

data class Order(
    val id: String,
    val placedAtMs: Long,
    val items: List<OrderItem>,
    val subtotal: Double,
    val discount: Double,
    val total: Double,
    val couponCode: String?,
    val firstName: String,
    val lastName: String,
    val zipCode: String,
    val cardLast4: String,
    var status: OrderStatus = OrderStatus.PLACED,
)

object ShopState {
    private val cartLines = linkedMapOf<String, CartLine>()
    private val orderHistory = mutableListOf<Order>()

    const val DEFAULT_COUPON_PERCENT = 10

    val savedAddresses: List<SavedAddress> = listOf(
        SavedAddress("home", "Home — Demo City", "Demo", "User", "560001"),
        SavedAddress("work", "Work — Lebyy Hub", "Surendra", "QA", "500081"),
        SavedAddress("lab", "Lab — Automation Park", "Mobile", "Wright", "94105"),
    )

    val sampleCoupons: List<SampleCoupon> = listOf(
        SampleCoupon("LEBYY10", "Lebyy starter — 10% off", 10),
        SampleCoupon("SAVE15", "Weekend deal — 15% off", 15),
        SampleCoupon("WELCOME20", "Welcome bonus — 20% off", 20),
        SampleCoupon("STUDENT25", "Student special — 25% off", 25),
    )

    var firstName: String = ""
    var lastName: String = ""
    var zipCode: String = ""
    var cardNumber: String = ""
    var cardExpiry: String = ""
    var cardCvv: String = ""
    var couponInput: String = ""
    var appliedCoupon: String? = null
    var appliedCouponPercent: Int = 0
    var lastPlacedOrderId: String? = null
    /** Set true after a successful place-order so checkout/cart activities pop themselves. */
    var exitCheckoutStack: Boolean = false

    // Shop extras / practice state
    var shopSearch: String = ""
    var shopSort: String = "nameAsc" // nameAsc, nameDesc, priceLow, priceHigh
    private val wishlist = mutableSetOf<String>()
    private val productRatings = mutableMapOf<String, Int>()
    var displayName: String = "Demo User"
    var sessionTimeoutEnabled: Boolean = false
    var sessionTimeoutSeconds: Int = 60
    var lastDeepLink: String = ""

    /**
     * Deep link host that arrived while logged out and still needs to be honoured once the
     * user signs in (mirrors iOS `applyPendingDeepLinkNavigation`).
     */
    var pendingDeepLinkHost: String? = null
    var forcePortraitOnly: Boolean = false
    var isLoggedIn: Boolean = false

    /** True for destinations that are only reachable with an active session. */
    fun destinationRequiresLogin(destination: String?): Boolean =
        destination == "shop" || destination == "orders" || destination == "settings"

    fun isWishlisted(productId: String): Boolean = wishlist.contains(productId)

    fun toggleWishlist(productId: String) {
        if (!wishlist.add(productId)) wishlist.remove(productId)
    }

    fun setRating(productId: String, stars: Int) {
        productRatings[productId] = stars.coerceIn(1, 5)
    }

    fun rating(productId: String): Int = productRatings[productId] ?: 0

    fun filteredProducts(all: List<Product>): List<Product> {
        val q = shopSearch.trim().lowercase()
        var list = if (q.isEmpty()) all else all.filter {
            it.name.lowercase().contains(q) || it.description.lowercase().contains(q)
        }
        list = when (shopSort) {
            "nameDesc" -> list.sortedByDescending { it.name }
            "priceLow" -> list.sortedBy { it.price }
            "priceHigh" -> list.sortedByDescending { it.price }
            else -> list.sortedBy { it.name }
        }
        return list
    }

    fun destinationFromDeepLinkHost(host: String): String? = when (host.lowercase()) {
        "shop" -> "shop"
        "orders", "orderhistory" -> "orders"
        "alerts" -> "alerts"
        "forms", "formcontrols" -> "forms"
        "swipes", "swipeh", "swipehorizontal" -> "swipe_h"
        "swipev", "swipevertical" -> "swipe_v"
        "gestures" -> "gestures"
        "lists" -> "lists"
        "waits" -> "waits"
        "system" -> "system"
        "navigation", "nav" -> "navigation"
        "settings" -> "settings"
        "webview", "web" -> "webview"
        else -> null
    }

    fun addToCart(product: Product, quantity: Int = 1) {
        val qty = quantity.coerceAtLeast(1)
        val existing = cartLines[product.id]
        if (existing == null) {
            cartLines[product.id] = CartLine(product, qty)
        } else {
            existing.quantity += qty
        }
    }

    fun removeFromCart(productId: String) {
        cartLines.remove(productId)
    }

    fun setQuantity(productId: String, quantity: Int) {
        val line = cartLines[productId] ?: return
        if (quantity <= 0) {
            cartLines.remove(productId)
        } else {
            line.quantity = quantity
        }
    }

    fun cart(): List<CartLine> = cartLines.values.toList()

    fun cartCount(): Int = cartLines.values.sumOf { it.quantity }

    fun isInCart(productId: String): Boolean = cartLines.containsKey(productId)

    fun cartSubtotal(): Double = cartLines.values.sumOf { it.lineTotal }

    fun percentOff(forCode: String): Int {
        val normalized = forCode.trim().uppercase()
        return sampleCoupons.firstOrNull { it.code == normalized }?.percentOff
            ?: DEFAULT_COUPON_PERCENT
    }

    fun cartDiscount(): Double {
        if (appliedCoupon == null || appliedCouponPercent <= 0) return 0.0
        val rate = appliedCouponPercent / 100.0
        return Math.round(cartSubtotal() * rate * 100.0) / 100.0
    }

    fun cartTotal(): Double {
        val total = cartSubtotal() - cartDiscount()
        return Math.max(0.0, Math.round(total * 100.0) / 100.0)
    }

    fun cardLast4(): String {
        val digits = cardNumber.filter { it.isDigit() }
        return when {
            digits.length >= 4 -> digits.takeLast(4)
            digits.isEmpty() -> "****"
            else -> digits
        }
    }

    fun selectAddress(address: SavedAddress) {
        firstName = address.firstName
        lastName = address.lastName
        zipCode = address.zipCode
    }

    fun applyCoupon(): Boolean {
        val code = couponInput.trim()
        if (code.isEmpty()) {
            appliedCoupon = null
            appliedCouponPercent = 0
            return false
        }
        val normalized = code.uppercase()
        appliedCoupon = normalized
        appliedCouponPercent = percentOff(normalized)
        couponInput = normalized
        return true
    }

    fun applySampleCoupon(coupon: SampleCoupon): Boolean {
        couponInput = coupon.code
        return applyCoupon()
    }

    fun clearCoupon() {
        couponInput = ""
        appliedCoupon = null
        appliedCouponPercent = 0
    }

    fun orders(): List<Order> = orderHistory.toList()

    fun orderById(id: String): Order? = orderHistory.firstOrNull { it.id == id }

    /** Places cart as an order, or null if cart is empty (blocks duplicate place via back). */
    fun placeOrder(): Order? {
        if (cartLines.isEmpty()) return null
        val items = cart().map {
            OrderItem(
                productId = it.product.id,
                name = it.product.name,
                quantity = it.quantity,
                lineTotal = it.lineTotal,
                imageRes = it.product.imageRes,
            )
        }
        val order = Order(
            id = "LB-${System.currentTimeMillis() / 1000}",
            placedAtMs = System.currentTimeMillis(),
            items = items,
            subtotal = cartSubtotal(),
            discount = cartDiscount(),
            total = cartTotal(),
            couponCode = appliedCoupon,
            firstName = firstName,
            lastName = lastName,
            zipCode = zipCode,
            cardLast4 = cardLast4(),
            status = OrderStatus.PLACED,
        )
        orderHistory.add(0, order)
        lastPlacedOrderId = order.id
        cartLines.clear()
        clearCheckoutFields()
        exitCheckoutStack = true
        return order
    }

    fun cancelOrder(id: String): Boolean {
        val order = orderHistory.firstOrNull { it.id == id } ?: return false
        if (order.status != OrderStatus.PLACED) return false
        order.status = OrderStatus.CANCELLED
        return true
    }

    fun clearCheckoutFields() {
        firstName = ""
        lastName = ""
        zipCode = ""
        cardNumber = ""
        cardExpiry = ""
        cardCvv = ""
        clearCoupon()
    }

    fun clearCart() {
        cartLines.clear()
        clearCheckoutFields()
    }

    fun resetSession() {
        clearCart()
        shopSearch = ""
        isLoggedIn = false
        pendingDeepLinkHost = null
        // Keep order history for the session so automation can verify previous orders.
    }

    fun loginSuccess() {
        isLoggedIn = true
    }
}
