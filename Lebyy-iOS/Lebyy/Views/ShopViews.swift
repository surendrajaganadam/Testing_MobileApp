import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(store.products) { product in
                    ProductCard(product: product)
                        .accessibilityIdentifier("test-\(product.name)")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
    }
}

struct ProductCard: View {
    @EnvironmentObject private var store: AppStore
    let product: Product

    private var inCart: Bool { store.cart[product.id] != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Product body → details. Cart button stays outside so add/remove works on home.
            NavigationLink {
                ProductDetailView(product: product)
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    Image(product.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .clipped()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.name).font(.headline).foregroundStyle(LebyyTheme.text)
                        Text(String(format: "$%.2f", product.price)).foregroundStyle(LebyyTheme.accent)
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundStyle(LebyyTheme.muted)
                            .lineLimit(2)
                    }
                    .padding([.horizontal, .top], 16)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                if inCart {
                    store.removeFromCart(product.id)
                } else {
                    store.addToCart(product, qty: 1)
                }
            } label: {
                Text(inCart ? "REMOVE" : "ADD TO CART")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(inCart ? LebyyTheme.surface2 : LebyyTheme.accent)
                    .foregroundStyle(inCart ? LebyyTheme.text : LebyyTheme.bg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(inCart ? LebyyTheme.line : Color.clear, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(inCart ? "test-REMOVE" : "test-ADD TO CART")
            .accessibilityLabel(inCart ? "REMOVE" : "ADD TO CART")
            .padding(16)
        }
        .background(LebyyTheme.surface)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(LebyyTheme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ProductDetailView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let product: Product
    @State private var qty = 1

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()

                Text(product.name)
                    .font(.title2.bold())
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-ProductName")

                Text(String(format: "$%.2f", product.price))
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-ProductPrice")

                Text(product.description)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-ProductDesc")

                Text("Quantity").font(.caption).foregroundStyle(LebyyTheme.muted)

                HStack(spacing: 16) {
                    Button("-") { if qty > 1 { qty -= 1 } }
                        .frame(width: 48, height: 48)
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityIdentifier("test-QtyMinus")

                    Text("\(qty)")
                        .font(.title3.bold())
                        .foregroundStyle(LebyyTheme.text)
                        .frame(width: 40)
                        .accessibilityIdentifier("test-QtyValue")

                    Button("+") { qty += 1 }
                        .frame(width: 48, height: 48)
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityIdentifier("test-QtyPlus")
                }

                Button {
                    store.addToCart(product, qty: qty)
                    dismiss()
                } label: {
                    Text("ADD TO CART")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LebyyTheme.accent)
                        .foregroundStyle(LebyyTheme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("test-ADD TO CART")
                .accessibilityLabel("ADD TO CART")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CartView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if store.cartLines.isEmpty {
                Spacer(minLength: 40)
                VStack(spacing: 18) {
                    Image(systemName: "cart")
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(LebyyTheme.primary)
                        .accessibilityHidden(true)

                    Text("Your cart is empty")
                        .font(.title2.bold())
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-CartEmptyTitle")

                    Text("Browse courses on Shop and tap ADD TO CART — no need to open product details first.")
                        .font(.subheadline)
                        .foregroundStyle(LebyyTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .accessibilityIdentifier("test-CartEmptyMessage")

                    Button {
                        store.selected = .shop
                        dismiss()
                    } label: {
                        Text("CONTINUE SHOPPING")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LebyyTheme.accent)
                            .foregroundStyle(LebyyTheme.bg)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .accessibilityIdentifier("test-CONTINUE SHOPPING")
                    .accessibilityLabel("CONTINUE SHOPPING")
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List {
                    ForEach(store.cartLines) { line in
                        HStack(spacing: 12) {
                            Image(line.product.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            VStack(alignment: .leading) {
                                Text(line.product.name).foregroundStyle(LebyyTheme.text)
                                Text(String(format: "Qty: %d | $%.2f", line.quantity, line.lineTotal))
                                    .font(.caption)
                                    .foregroundStyle(LebyyTheme.muted)
                                    .accessibilityIdentifier("test-CartQty")
                                Button("REMOVE") { store.removeFromCart(line.product.id) }
                                    .font(.caption)
                                    .foregroundStyle(LebyyTheme.primary)
                                    .accessibilityIdentifier("test-REMOVE")
                            }
                        }
                        .listRowBackground(LebyyTheme.surface)
                    }
                }
                .scrollContentBackground(.hidden)

                Text(String(format: "Total: $%.2f", store.cartTotal))
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.text)
                    .padding()

                NavigationLink("CHECKOUT") {
                    CheckoutInfoView()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(LebyyTheme.accent)
                .foregroundStyle(LebyyTheme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .accessibilityIdentifier("test-CHECKOUT")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Your Cart")
    }
}

struct CheckoutInfoView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Form {
            Section("Saved addresses") {
                ForEach(store.savedAddresses) { address in
                    Button {
                        store.selectAddress(address)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(address.label)
                                .foregroundStyle(LebyyTheme.primary)
                            Text("\(address.firstName) \(address.lastName) · \(address.zipCode)")
                                .font(.caption)
                                .foregroundStyle(LebyyTheme.muted)
                        }
                    }
                    .accessibilityIdentifier("test-SavedAddress-\(address.id)")
                    .accessibilityLabel(address.label)
                }
            }

            Section("Or enter manually") {
                TextField("First Name", text: $store.firstName)
                    .accessibilityIdentifier("test-First Name")
                TextField("Last Name", text: $store.lastName)
                    .accessibilityIdentifier("test-Last Name")
                TextField("Zip/Postal Code", text: $store.zipCode)
                    .accessibilityIdentifier("test-Zip/Postal Code")
            }

            NavigationLink("CONTINUE") {
                PaymentView()
            }
            .disabled(store.firstName.isEmpty || store.lastName.isEmpty || store.zipCode.isEmpty)
            .accessibilityIdentifier("test-CONTINUE")
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Shipping")
    }
}

/// Card-only payment step (any digits accepted — practice app, no Luhn/rules).
struct PaymentView: View {
    @EnvironmentObject private var store: AppStore

    private var canContinue: Bool {
        !store.cardNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section("Lebyy Pay — Card") {
                TextField("Card Number", text: $store.cardNumber)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier("test-Card Number")
                    .accessibilityLabel("Card Number")
                TextField("Expiry (MM/YY)", text: $store.cardExpiry)
                    .accessibilityIdentifier("test-Card Expiry")
                    .accessibilityLabel("Card Expiry")
                SecureField("CVV", text: $store.cardCvv)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("test-Card CVV")
                    .accessibilityLabel("Card CVV")
                Text("Any numbers accepted — no validation rules for practice automation.")
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.muted)
            }

            NavigationLink("CONTINUE TO REVIEW") {
                ReviewOrderView()
            }
            .disabled(!canContinue)
            .accessibilityIdentifier("test-CONTINUE TO REVIEW")
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Payment")
    }
}

struct ReviewOrderView: View {
    @EnvironmentObject private var store: AppStore
    @State private var placedOrderId: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Order items").font(.headline).foregroundStyle(LebyyTheme.text)
                ForEach(store.cartLines) { line in
                    Text(String(format: "• %@ x%d — $%.2f", line.product.name, line.quantity, line.lineTotal))
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-ReviewItem")
                }

                Text("Coupon").font(.headline).foregroundStyle(LebyyTheme.text)
                HStack(spacing: 10) {
                    TextField("Coupon code", text: $store.couponInput)
                        .textInputAutocapitalization(.characters)
                        .padding(12)
                        .background(LebyyTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("test-Coupon")
                        .accessibilityLabel("Coupon code")
                    Button("APPLY") {
                        _ = store.applyCoupon()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(LebyyTheme.primary)
                    .foregroundStyle(LebyyTheme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-APPLY COUPON")
                    .accessibilityLabel("APPLY COUPON")
                }
                if let code = store.appliedCoupon {
                    Text("Applied: \(code) (−10%)")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.success)
                        .accessibilityIdentifier("test-CouponApplied")
                } else {
                    Text("Any non-empty code gives 10% off.")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)
                }

                Text("Shipping").font(.headline).foregroundStyle(LebyyTheme.text)
                Text("\(store.firstName) \(store.lastName)\n\(store.zipCode)")
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-ReviewShipping")

                Text("Payment").font(.headline).foregroundStyle(LebyyTheme.text)
                Text("Card ending \(store.cardLast4)")
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-ReviewPayment")

                Text(String(format: "Subtotal: $%.2f", store.cartSubtotal))
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-ReviewSubtotal")
                if store.cartDiscount > 0 {
                    Text(String(format: "Discount: −$%.2f", store.cartDiscount))
                        .foregroundStyle(LebyyTheme.success)
                        .accessibilityIdentifier("test-ReviewDiscount")
                }
                Text(String(format: "Total: $%.2f", store.cartTotal))
                    .font(.title3.bold())
                    .foregroundStyle(LebyyTheme.primary)
                    .accessibilityIdentifier("test-ReviewTotal")

                Button {
                    let order = store.placeOrder()
                    placedOrderId = order.id
                } label: {
                    Text("PLACE ORDER")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LebyyTheme.accent)
                        .foregroundStyle(LebyyTheme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                .accessibilityIdentifier("test-PLACE ORDER")
                .accessibilityLabel("PLACE ORDER")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Review Order")
        .navigationDestination(item: $placedOrderId) { orderId in
            OrderDetailsView(orderId: orderId, showPreviousOrders: true)
        }
    }
}

struct OrdersView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Group {
            if store.orders.isEmpty {
                VStack(spacing: 12) {
                    Text("No orders yet")
                        .font(.title3.bold())
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-OrdersEmpty")
                    Text("Complete a checkout to see order history here.")
                        .font(.subheadline)
                        .foregroundStyle(LebyyTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.orders) { order in
                    NavigationLink {
                        OrderDetailsView(orderId: order.id, showPreviousOrders: false)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(order.id)
                                    .font(.headline)
                                    .foregroundStyle(LebyyTheme.primary)
                                if order.status == .cancelled {
                                    Text("CANCELLED")
                                        .font(.caption2.bold())
                                        .foregroundStyle(LebyyTheme.accent)
                                        .accessibilityIdentifier("test-OrderStatus-Cancelled")
                                }
                            }
                            Text(String(format: "$%.2f · %d item(s)", order.total, order.items.count))
                                .font(.caption)
                                .foregroundStyle(LebyyTheme.muted)
                        }
                    }
                    .accessibilityIdentifier("test-Order-\(order.id)")
                    .listRowBackground(LebyyTheme.surface)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("My Orders")
    }
}

struct OrderDetailsView: View {
    @EnvironmentObject private var store: AppStore
    let orderId: String
    var showPreviousOrders: Bool = true

    private var order: Order? { store.order(byId: orderId) }
    private var previousOrders: [Order] {
        store.orders.filter { $0.id != orderId }
    }

    private var dateText: String {
        guard let order else { return "" }
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: order.placedAt)
    }

    var body: some View {
        ScrollView {
            if let order {
                VStack(alignment: .leading, spacing: 14) {
                    Text(order.status == .cancelled ? "Order cancelled" : "Order confirmed")
                        .font(.title2.bold())
                        .foregroundStyle(order.status == .cancelled ? LebyyTheme.accent : LebyyTheme.primary)
                        .accessibilityIdentifier(order.status == .cancelled ? "test-OrderCancelled" : "test-OrderConfirmed")

                    Text(order.id)
                        .font(.headline)
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-OrderId")

                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-OrderDate")

                    Text("Items").font(.headline).foregroundStyle(LebyyTheme.text)
                    ForEach(order.items) { item in
                        Text(String(format: "• %@ x%d — $%.2f", item.name, item.quantity, item.lineTotal))
                            .foregroundStyle(LebyyTheme.text)
                            .accessibilityIdentifier("test-OrderItem")
                    }

                    Text("Ship to").font(.headline).foregroundStyle(LebyyTheme.text)
                    Text("\(order.firstName) \(order.lastName)\n\(order.zipCode)")
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-OrderShipping")

                    Text("Paid with").font(.headline).foregroundStyle(LebyyTheme.text)
                    Text("Card ending \(order.cardLast4)")
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-OrderPayment")

                    if order.discount > 0 {
                        Text(String(format: "Subtotal: $%.2f", order.subtotal))
                            .foregroundStyle(LebyyTheme.muted)
                            .accessibilityIdentifier("test-OrderSubtotal")
                        Text(String(format: "Discount (%@): −$%.2f", order.couponCode ?? "coupon", order.discount))
                            .foregroundStyle(LebyyTheme.success)
                            .accessibilityIdentifier("test-OrderDiscount")
                    }

                    Text(String(format: "Total: $%.2f", order.total))
                        .font(.title3.bold())
                        .foregroundStyle(LebyyTheme.primary)
                        .accessibilityIdentifier("test-OrderTotal")

                    if order.status == .placed {
                        Button {
                            _ = store.cancelOrder(order.id)
                        } label: {
                            Text("CANCEL ORDER")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LebyyTheme.accent)
                                .foregroundStyle(LebyyTheme.bg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        .accessibilityIdentifier("test-CANCEL ORDER")
                        .accessibilityLabel("CANCEL ORDER")
                    }

                    if showPreviousOrders {
                        Divider().overlay(LebyyTheme.line).padding(.vertical, 8)
                        Text("Previous orders")
                            .font(.headline)
                            .foregroundStyle(LebyyTheme.text)
                            .accessibilityIdentifier("test-PreviousOrdersTitle")

                        if previousOrders.isEmpty {
                            Text("No previous orders yet.")
                                .foregroundStyle(LebyyTheme.muted)
                                .accessibilityIdentifier("test-PreviousOrdersEmpty")
                        } else {
                            ForEach(previousOrders) { prev in
                                NavigationLink {
                                    OrderDetailsView(orderId: prev.id, showPreviousOrders: false)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(prev.id).foregroundStyle(LebyyTheme.primary)
                                            Text(String(format: "$%.2f", prev.total))
                                                .font(.caption)
                                                .foregroundStyle(LebyyTheme.muted)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(LebyyTheme.muted)
                                    }
                                    .padding(12)
                                    .background(LebyyTheme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("test-PreviousOrder-\(prev.id)")
                            }
                        }
                    }
                }
                .padding(16)
            } else {
                Text("Order not found")
                    .foregroundStyle(LebyyTheme.muted)
                    .padding()
            }
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
