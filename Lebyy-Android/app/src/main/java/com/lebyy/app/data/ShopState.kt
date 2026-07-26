package com.lebyy.app.data

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

    const val COUPON_DISCOUNT_RATE = 0.10

    val savedAddresses: List<SavedAddress> = listOf(
        SavedAddress("home", "Home — Demo City", "Demo", "User", "560001"),
        SavedAddress("work", "Work — Lebyy Hub", "Surendra", "QA", "500081"),
        SavedAddress("lab", "Lab — Automation Park", "Mobile", "Wright", "94105"),
    )

    var firstName: String = ""
    var lastName: String = ""
    var zipCode: String = ""
    var cardNumber: String = ""
    var cardExpiry: String = ""
    var cardCvv: String = ""
    var couponInput: String = ""
    var appliedCoupon: String? = null
    var lastPlacedOrderId: String? = null

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

    fun cartDiscount(): Double {
        if (appliedCoupon == null) return 0.0
        return Math.round(cartSubtotal() * COUPON_DISCOUNT_RATE * 100.0) / 100.0
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
            return false
        }
        appliedCoupon = code.uppercase()
        return true
    }

    fun clearCoupon() {
        couponInput = ""
        appliedCoupon = null
    }

    fun orders(): List<Order> = orderHistory.toList()

    fun orderById(id: String): Order? = orderHistory.firstOrNull { it.id == id }

    fun placeOrder(): Order {
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
        // Keep order history for the session so automation can verify previous orders.
    }
}
