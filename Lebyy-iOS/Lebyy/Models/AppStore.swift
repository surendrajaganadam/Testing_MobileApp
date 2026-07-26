import Foundation
import SwiftUI

struct Product: Identifiable, Hashable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let imageName: String
}

struct CartLine: Identifiable {
    var id: String { product.id }
    let product: Product
    var quantity: Int
    var lineTotal: Double { product.price * Double(quantity) }
}

struct SavedAddress: Identifiable, Hashable {
    let id: String
    let label: String
    let firstName: String
    let lastName: String
    let zipCode: String
}

struct OrderItem: Identifiable, Hashable {
    var id: String { productId }
    let productId: String
    let name: String
    let quantity: Int
    let lineTotal: Double
    let imageName: String
}

enum OrderStatus: String, Hashable {
    case placed
    case cancelled
}

struct Order: Identifiable, Hashable {
    let id: String
    let placedAt: Date
    let items: [OrderItem]
    let subtotal: Double
    let discount: Double
    let total: Double
    let couponCode: String?
    let firstName: String
    let lastName: String
    let zipCode: String
    let cardLast4: String
    var status: OrderStatus
}

enum MenuDestination: String, CaseIterable, Identifiable {
    case shop, orders, alerts, forms, swipeH, swipeV, gestures, webview
    var id: String { rawValue }

    var title: String {
        switch self {
        case .shop: return "Shop"
        case .orders: return "My Orders"
        case .alerts: return "Alerts"
        case .forms: return "Forms"
        case .swipeH: return "Swipe Left / Right"
        case .swipeV: return "Swipe Up / Down"
        case .gestures: return "Gestures"
        case .webview: return "Web Browser"
        }
    }

    var accessibilityId: String {
        switch self {
        case .shop: return "test-Shop"
        case .orders: return "test-Orders"
        case .alerts: return "test-Alerts"
        case .forms: return "test-Forms"
        case .swipeH: return "test-SwipeHorizontal"
        case .swipeV: return "test-SwipeVertical"
        case .gestures: return "test-Gestures"
        case .webview: return "test-WEBVIEW"
        }
    }
}

final class AppStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var selected: MenuDestination = .shop
    @Published var cart: [String: CartLine] = [:]
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var zipCode = ""
    @Published var cardNumber = ""
    @Published var cardExpiry = ""
    @Published var cardCvv = ""
    @Published var couponInput = ""
    @Published var appliedCoupon: String?
    @Published var orders: [Order] = []
    @Published var lastPlacedOrderId: String?

    /// Any non-empty coupon code applies a flat 10% discount (practice app).
    static let couponDiscountRate = 0.10

    let savedAddresses: [SavedAddress] = [
        .init(id: "home", label: "Home — Demo City", firstName: "Demo", lastName: "User", zipCode: "560001"),
        .init(id: "work", label: "Work — Lebyy Hub", firstName: "Surendra", lastName: "QA", zipCode: "500081"),
        .init(id: "lab", label: "Lab — Automation Park", firstName: "Mobile", lastName: "Wright", zipCode: "94105"),
    ]

    let products: [Product] = [
        .init(id: "c1", name: "Playwright Mastery", price: 19.99, description: "End-to-end web automation with Playwright — real projects, locators, and CI pipelines.", imageName: "course_1"),
        .init(id: "c2", name: "Appium Mobile Testing", price: 24.99, description: "Android & iOS automation with Appium — gestures, hybrid apps, and device farms.", imageName: "course_2"),
        .init(id: "c3", name: "API Testing Bootcamp", price: 14.99, description: "REST API testing with assertions, auth flows, and contract checks.", imageName: "course_3"),
        .init(id: "c4", name: "Selenium WebDriver", price: 17.99, description: "Classic browser automation foundations with Selenium WebDriver.", imageName: "course_4"),
        .init(id: "c5", name: "CI/CD for QA", price: 12.99, description: "Wire tests into pipelines — GitHub Actions, reporting, and flake control.", imageName: "course_5"),
        .init(id: "c6", name: "Mobilewright Essentials", price: 21.99, description: "Native mobile UI automation with Mobilewright — locators, waits, and E2E flows.", imageName: "course_6"),
    ]

    var cartLines: [CartLine] { Array(cart.values) }
    var cartCount: Int { cart.values.reduce(0) { $0 + $1.quantity } }
    var cartSubtotal: Double { cart.values.reduce(0) { $0 + $1.lineTotal } }
    var cartDiscount: Double {
        guard appliedCoupon != nil else { return 0 }
        return (cartSubtotal * Self.couponDiscountRate * 100).rounded() / 100
    }
    var cartTotal: Double { max(0, ((cartSubtotal - cartDiscount) * 100).rounded() / 100) }

    var cardLast4: String {
        let digits = cardNumber.filter(\.isNumber)
        if digits.count >= 4 { return String(digits.suffix(4)) }
        if digits.isEmpty { return "****" }
        return digits
    }

    func login(username: String, password: String) -> Bool {
        username == "demo_user" && password == "demo_pass"
    }

    func addToCart(_ product: Product, qty: Int = 1) {
        let q = max(1, qty)
        if var existing = cart[product.id] {
            existing.quantity += q
            cart[product.id] = existing
        } else {
            cart[product.id] = CartLine(product: product, quantity: q)
        }
    }

    func removeFromCart(_ id: String) { cart.removeValue(forKey: id) }

    func selectAddress(_ address: SavedAddress) {
        firstName = address.firstName
        lastName = address.lastName
        zipCode = address.zipCode
    }

    @discardableResult
    func applyCoupon() -> Bool {
        let code = couponInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            appliedCoupon = nil
            return false
        }
        appliedCoupon = code.uppercased()
        return true
    }

    func clearCoupon() {
        couponInput = ""
        appliedCoupon = nil
    }

    func clearCartOnly() {
        cart.removeAll()
    }

    func clearCheckoutFields() {
        firstName = ""
        lastName = ""
        zipCode = ""
        cardNumber = ""
        cardExpiry = ""
        cardCvv = ""
        clearCoupon()
    }

    @discardableResult
    func placeOrder() -> Order {
        let items = cartLines.map {
            OrderItem(
                productId: $0.product.id,
                name: $0.product.name,
                quantity: $0.quantity,
                lineTotal: $0.lineTotal,
                imageName: $0.product.imageName
            )
        }
        let order = Order(
            id: "LB-\(Int(Date().timeIntervalSince1970))",
            placedAt: Date(),
            items: items,
            subtotal: cartSubtotal,
            discount: cartDiscount,
            total: cartTotal,
            couponCode: appliedCoupon,
            firstName: firstName,
            lastName: lastName,
            zipCode: zipCode,
            cardLast4: cardLast4,
            status: .placed
        )
        orders.insert(order, at: 0)
        lastPlacedOrderId = order.id
        clearCartOnly()
        clearCheckoutFields()
        return order
    }

    func order(byId id: String) -> Order? {
        orders.first { $0.id == id }
    }

    @discardableResult
    func cancelOrder(_ id: String) -> Bool {
        guard let idx = orders.firstIndex(where: { $0.id == id }) else { return false }
        guard orders[idx].status == .placed else { return false }
        orders[idx].status = .cancelled
        return true
    }

    func logout() {
        isLoggedIn = false
        selected = .shop
        clearCartOnly()
        clearCheckoutFields()
    }
}
