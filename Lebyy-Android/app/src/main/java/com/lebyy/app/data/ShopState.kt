package com.lebyy.app.data

data class OrderItem(
    val productId: String,
    val name: String,
    val quantity: Int,
    val lineTotal: Double,
    val imageRes: Int,
)

data class Order(
    val id: String,
    val placedAtMs: Long,
    val items: List<OrderItem>,
    val total: Double,
    val firstName: String,
    val lastName: String,
    val zipCode: String,
    val cardLast4: String,
)

object ShopState {
    private val cartLines = linkedMapOf<String, CartLine>()
    private val orderHistory = mutableListOf<Order>()

    var firstName: String = ""
    var lastName: String = ""
    var zipCode: String = ""
    var cardNumber: String = ""
    var cardExpiry: String = ""
    var cardCvv: String = ""
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

    fun cartTotal(): Double = cartLines.values.sumOf { it.lineTotal }

    fun cardLast4(): String {
        val digits = cardNumber.filter { it.isDigit() }
        return when {
            digits.length >= 4 -> digits.takeLast(4)
            digits.isEmpty() -> "****"
            else -> digits
        }
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
            total = cartTotal(),
            firstName = firstName,
            lastName = lastName,
            zipCode = zipCode,
            cardLast4 = cardLast4(),
        )
        orderHistory.add(0, order)
        lastPlacedOrderId = order.id
        cartLines.clear()
        clearCheckoutFields()
        return order
    }

    fun clearCheckoutFields() {
        firstName = ""
        lastName = ""
        zipCode = ""
        cardNumber = ""
        cardExpiry = ""
        cardCvv = ""
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
