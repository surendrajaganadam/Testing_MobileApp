import Foundation
import SwiftUI
import Combine

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

struct SampleCoupon: Identifiable, Hashable {
    var id: String { code }
    let code: String
    let title: String
    let percentOff: Int
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

enum ShopSort: String, CaseIterable, Identifiable {
    case nameAsc, nameDesc, priceLow, priceHigh
    var id: String { rawValue }

    var title: String {
        switch self {
        case .nameAsc: return "Name A–Z"
        case .nameDesc: return "Name Z–A"
        case .priceLow: return "Price Low–High"
        case .priceHigh: return "Price High–Low"
        }
    }

    var accessibilityId: String {
        switch self {
        case .nameAsc: return "test-Sort-NameAsc"
        case .nameDesc: return "test-Sort-NameDesc"
        case .priceLow: return "test-Sort-PriceLow"
        case .priceHigh: return "test-Sort-PriceHigh"
        }
    }
}

/// Main bottom tabs (WebdriverIO-style).
enum AppTab: String, CaseIterable, Identifiable {
    case home, components, shop, account
    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .components: return "Components"
        case .shop: return "Shop"
        case .account: return "Account"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .components: return "square.grid.2x2.fill"
        case .shop: return "cart.fill"
        case .account: return "person.fill"
        }
    }

    var accessibilityId: String {
        switch self {
        case .home: return "test-Tab-Home"
        case .components: return "test-Tab-Components"
        case .shop: return "test-Tab-Shop"
        case .account: return "test-Tab-Account"
        }
    }
}

/// UIKitCatalog-style practice categories (no login required).
enum ComponentCategory: String, CaseIterable, Identifiable, Hashable {
    case alerts, formControls, swipes, gestures, lists, waits, system, navigation, webview

    var id: String { rawValue }

    var title: String {
        switch self {
        case .alerts: return "Alerts & Dialogs"
        case .formControls: return "Form Controls"
        case .swipes: return "Swipes"
        case .gestures: return "Gestures"
        case .lists: return "Lists"
        case .waits: return "Waits"
        case .system: return "System"
        case .navigation: return "Navigation"
        case .webview: return "WebView"
        }
    }

    var subtitle: String {
        switch self {
        case .alerts: return "Alert, confirm, prompt, modal, sheet, toast"
        case .formControls: return "Text, switches, sliders, pickers, OTP…"
        case .swipes: return "Horizontal carousel & vertical scroll"
        case .gestures: return "Long press, drag, pinch, multi-touch…"
        case .lists: return "Refresh, swipe actions, nested, infinite"
        case .waits: return "Delayed load & network retry"
        case .system: return "Permissions, media, clipboard, orientation"
        case .navigation: return "Bottom tabs demo & deep links"
        case .webview: return "Hybrid browser & JS alerts"
        }
    }

    var systemImage: String {
        switch self {
        case .alerts: return "exclamationmark.bubble.fill"
        case .formControls: return "switch.2"
        case .swipes: return "hand.draw.fill"
        case .gestures: return "hand.tap.fill"
        case .lists: return "list.bullet.rectangle"
        case .waits: return "clock.fill"
        case .system: return "gearshape.fill"
        case .navigation: return "tab.badge"
        case .webview: return "globe"
        }
    }

    var accessibilityId: String {
        switch self {
        case .alerts: return "test-Components-Alerts"
        case .formControls: return "test-Components-Forms"
        case .swipes: return "test-Components-Swipes"
        case .gestures: return "test-Components-Gestures"
        case .lists: return "test-Components-Lists"
        case .waits: return "test-Components-Waits"
        case .system: return "test-Components-System"
        case .navigation: return "test-Components-Navigation"
        case .webview: return "test-Components-WebView"
        }
    }

    static func fromDeepLinkHost(_ host: String) -> (AppTab, ComponentCategory?)? {
        switch host.lowercased() {
        case "home": return (.home, nil)
        case "components", "catalog": return (.components, nil)
        case "shop": return (.shop, nil)
        case "account", "login": return (.account, nil)
        case "alerts": return (.components, .alerts)
        case "forms", "formcontrols": return (.components, .formControls)
        case "swipes", "swipeh", "swipev", "swipehorizontal", "swipevertical": return (.components, .swipes)
        case "gestures": return (.components, .gestures)
        case "lists": return (.components, .lists)
        case "waits": return (.components, .waits)
        case "system": return (.components, .system)
        case "navigation", "nav": return (.components, .navigation)
        case "webview", "web": return (.components, .webview)
        case "orders", "orderhistory": return (.shop, nil)
        case "settings": return (.account, nil)
        default: return nil
        }
    }
}

/// Nested form-control demos (UIKitCatalog Switches-style).
enum FormControlTopic: String, CaseIterable, Identifiable, Hashable {
    case textFields, switches, sliders, pickers, pickerView, selection, validation, otp, duplicates

    var id: String { rawValue }

    var title: String {
        switch self {
        case .textFields: return "Text Fields"
        case .switches: return "Switches"
        case .sliders: return "Sliders"
        case .pickers: return "Date & Time"
        case .pickerView: return "PickerView"
        case .selection: return "Selection Controls"
        case .validation: return "Validation"
        case .otp: return "OTP / PIN"
        case .duplicates: return "Duplicate Locators"
        }
    }

    var subtitle: String {
        switch self {
        case .textFields: return "Plain, secure, email, multiline"
        case .switches: return "Default, labeled, checkbox-style"
        case .sliders: return "Continuous & stepped values"
        case .pickers: return "Date picker & time picker"
        case .pickerView: return "Wheel picker & multi-column"
        case .selection: return "Dropdown, checkboxes, radios"
        case .validation: return "Inline errors on submit"
        case .otp: return "4-digit PIN entry"
        case .duplicates: return "Same id twice — use matching / boundBy / nth"
        }
    }

    var accessibilityId: String {
        "test-FormTopic-\(rawValue)"
    }
}

final class AppStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var selectedTab: AppTab = .home
    @Published var pendingComponent: ComponentCategory?
    @Published var pendingFormTopic: FormControlTopic?
    @Published var showOrders = false

    @Published var cart: [String: CartLine] = [:]
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var zipCode = ""
    @Published var cardNumber = ""
    @Published var cardExpiry = ""
    @Published var cardCvv = ""
    @Published var couponInput = ""
    @Published var appliedCoupon: String?
    @Published var appliedCouponPercent = 0
    @Published var orders: [Order] = []
    @Published var lastPlacedOrderId: String?
    @Published var orderDetailsToPresent: String?
    @Published var dismissCartAfterCheckout = false

    @Published var shopSearch = ""
    @Published var shopSort: ShopSort = .nameAsc
    @Published var wishlist: Set<String> = []
    @Published var productRatings: [String: Int] = [:]

    @Published var displayName = "Demo User"
    @Published var sessionTimeoutEnabled = false
    @Published var sessionTimeoutSeconds = 60
    @Published var sessionSecondsRemaining = 0
    @Published var forcePortraitOnly = false
    @Published var lastDeepLink = ""

    static let defaultCouponPercent = 10
    private var sessionTimer: AnyCancellable?

    let savedAddresses: [SavedAddress] = [
        .init(id: "home", label: "Home — Demo City", firstName: "Demo", lastName: "User", zipCode: "560001"),
        .init(id: "work", label: "Work — Lebyy Hub", firstName: "Surendra", lastName: "QA", zipCode: "500081"),
        .init(id: "lab", label: "Lab — Automation Park", firstName: "Mobile", lastName: "Wright", zipCode: "94105"),
    ]

    let sampleCoupons: [SampleCoupon] = [
        .init(code: "LEBYY10", title: "Lebyy starter — 10% off", percentOff: 10),
        .init(code: "SAVE15", title: "Weekend deal — 15% off", percentOff: 15),
        .init(code: "WELCOME20", title: "Welcome bonus — 20% off", percentOff: 20),
        .init(code: "STUDENT25", title: "Student special — 25% off", percentOff: 25),
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
        guard appliedCoupon != nil, appliedCouponPercent > 0 else { return 0 }
        let rate = Double(appliedCouponPercent) / 100
        return (cartSubtotal * rate * 100).rounded() / 100
    }
    var cartTotal: Double { max(0, ((cartSubtotal - cartDiscount) * 100).rounded() / 100) }

    var filteredProducts: [Product] {
        let q = shopSearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var list = products
        if !q.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(q) || $0.description.lowercased().contains(q)
            }
        }
        switch shopSort {
        case .nameAsc: return list.sorted { $0.name < $1.name }
        case .nameDesc: return list.sorted { $0.name > $1.name }
        case .priceLow: return list.sorted { $0.price < $1.price }
        case .priceHigh: return list.sorted { $0.price > $1.price }
        }
    }

    func percentOff(for code: String) -> Int {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if let sample = sampleCoupons.first(where: { $0.code == normalized }) {
            return sample.percentOff
        }
        return Self.defaultCouponPercent
    }

    var cardLast4: String {
        let digits = cardNumber.filter(\.isNumber)
        if digits.count >= 4 { return String(digits.suffix(4)) }
        if digits.isEmpty { return "****" }
        return digits
    }

    func login(username: String, password: String) -> Bool {
        username == "demo_user" && password == "demo_pass"
    }

    func loginSuccess() {
        isLoggedIn = true
        if selectedTab == .account {
            selectedTab = .shop
        }
        applyPendingDeepLinkNavigation()
        restartSessionTimerIfNeeded()
    }

    func toggleWishlist(_ productId: String) {
        if wishlist.contains(productId) { wishlist.remove(productId) }
        else { wishlist.insert(productId) }
    }

    func isWishlisted(_ productId: String) -> Bool { wishlist.contains(productId) }

    func setRating(productId: String, stars: Int) {
        productRatings[productId] = min(5, max(1, stars))
    }

    func rating(for productId: String) -> Int { productRatings[productId] ?? 0 }

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
            appliedCouponPercent = 0
            return false
        }
        let normalized = code.uppercased()
        appliedCoupon = normalized
        appliedCouponPercent = percentOff(for: normalized)
        couponInput = normalized
        return true
    }

    @discardableResult
    func applySampleCoupon(_ coupon: SampleCoupon) -> Bool {
        couponInput = coupon.code
        return applyCoupon()
    }

    func clearCoupon() {
        couponInput = ""
        appliedCoupon = nil
        appliedCouponPercent = 0
    }

    func clearCartOnly() { cart.removeAll() }

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
    func placeOrder() -> Order? {
        guard !cart.isEmpty else { return nil }
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
        dismissCartAfterCheckout = true
        showOrders = true
        orderDetailsToPresent = order.id
        return order
    }

    func order(byId id: String) -> Order? { orders.first { $0.id == id } }

    @discardableResult
    func cancelOrder(_ id: String) -> Bool {
        guard let idx = orders.firstIndex(where: { $0.id == id }) else { return false }
        guard orders[idx].status == .placed else { return false }
        orders[idx].status = .cancelled
        return true
    }

    func handleDeepLink(_ url: URL) {
        lastDeepLink = url.absoluteString
        let host = url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let mapped = ComponentCategory.fromDeepLinkHost(host) else { return }
        selectedTab = mapped.0
        pendingComponent = mapped.1
        if mapped.0 == .account || host.lowercased() == "settings" {
            // stay on account
        }
        if !isLoggedIn, mapped.0 == .shop, host.lowercased().contains("order") {
            selectedTab = .account
        }
    }

    func applyPendingDeepLinkNavigation() {
        guard !lastDeepLink.isEmpty, let url = URL(string: lastDeepLink) else { return }
        handleDeepLink(url)
    }

    func setSessionTimeout(enabled: Bool, seconds: Int? = nil) {
        sessionTimeoutEnabled = enabled
        if let seconds { sessionTimeoutSeconds = max(10, seconds) }
        if isLoggedIn { restartSessionTimerIfNeeded() }
    }

    func touchSession() {
        guard isLoggedIn, sessionTimeoutEnabled else { return }
        sessionSecondsRemaining = sessionTimeoutSeconds
    }

    private func restartSessionTimerIfNeeded() {
        sessionTimer?.cancel()
        sessionTimer = nil
        guard isLoggedIn, sessionTimeoutEnabled else {
            sessionSecondsRemaining = 0
            return
        }
        sessionSecondsRemaining = sessionTimeoutSeconds
        sessionTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                guard self.isLoggedIn, self.sessionTimeoutEnabled else { return }
                if self.sessionSecondsRemaining <= 1 {
                    self.logout()
                } else {
                    self.sessionSecondsRemaining -= 1
                }
            }
    }

    func logout() {
        sessionTimer?.cancel()
        sessionTimer = nil
        sessionSecondsRemaining = 0
        isLoggedIn = false
        selectedTab = .account
        clearCartOnly()
        clearCheckoutFields()
        shopSearch = ""
        showOrders = false
    }
}
