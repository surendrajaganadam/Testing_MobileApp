package com.lebyy.app.data

object ShopState {
    private val cartLines = linkedMapOf<String, CartLine>()

    var firstName: String = ""
    var lastName: String = ""
    var zipCode: String = ""

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

    fun clearCart() {
        cartLines.clear()
        firstName = ""
        lastName = ""
        zipCode = ""
    }

    fun resetSession() {
        clearCart()
    }
}
