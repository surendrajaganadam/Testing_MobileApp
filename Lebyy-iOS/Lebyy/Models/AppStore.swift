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

enum MenuDestination: String, CaseIterable, Identifiable {
    case shop, alerts, forms, swipeH, swipeV, gestures, webview
    var id: String { rawValue }

    var title: String {
        switch self {
        case .shop: return "Shop"
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
    var cartTotal: Double { cart.values.reduce(0) { $0 + $1.lineTotal } }

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

    func clearCart() {
        cart.removeAll()
        firstName = ""
        lastName = ""
        zipCode = ""
    }

    func logout() {
        isLoggedIn = false
        selected = .shop
        clearCart()
    }
}
