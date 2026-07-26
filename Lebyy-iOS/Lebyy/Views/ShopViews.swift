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
            TextField("First Name", text: $store.firstName)
                .accessibilityIdentifier("test-First Name")
            TextField("Last Name", text: $store.lastName)
                .accessibilityIdentifier("test-Last Name")
            TextField("Zip/Postal Code", text: $store.zipCode)
                .accessibilityIdentifier("test-Zip/Postal Code")

            NavigationLink("CONTINUE") {
                CheckoutOverviewView()
            }
            .disabled(store.firstName.isEmpty || store.lastName.isEmpty || store.zipCode.isEmpty)
            .accessibilityIdentifier("test-CONTINUE")
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Checkout Info")
    }
}

struct CheckoutOverviewView: View {
    @EnvironmentObject private var store: AppStore
    @State private var goComplete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(store.cartLines) { line in
                    Text(String(format: "• %@ x%d — $%.2f", line.product.name, line.quantity, line.lineTotal))
                        .foregroundStyle(LebyyTheme.text)
                }
                Text("Payment Information").font(.headline).foregroundStyle(LebyyTheme.text)
                Text("Lebyy Card **** 4242").foregroundStyle(LebyyTheme.muted)
                Text("Shipping Information").font(.headline).foregroundStyle(LebyyTheme.text)
                Text("\(store.firstName) \(store.lastName)\n\(store.zipCode)").foregroundStyle(LebyyTheme.muted)
                Text(String(format: "Total: $%.2f", store.cartTotal))
                    .font(.title3.bold())
                    .foregroundStyle(LebyyTheme.primary)

                Spacer(minLength: 120)

                Button("FINISH") {
                    store.clearCart()
                    goComplete = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(LebyyTheme.accent)
                .foregroundStyle(LebyyTheme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("test-FINISH")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Checkout Overview")
        .navigationDestination(isPresented: $goComplete) {
            OrderCompleteView()
        }
    }
}

struct OrderCompleteView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 24) {
            Image("logo_lebyy").resizable().scaledToFit().frame(width: 72, height: 72)
            Text("Thank you for your order!")
                .font(.title2.bold())
                .foregroundStyle(LebyyTheme.primary)
                .multilineTextAlignment(.center)
            Button("BACK HOME") {
                store.selected = .shop
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(LebyyTheme.accent)
            .foregroundStyle(LebyyTheme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityIdentifier("test-BACK HOME")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Order Complete")
        .navigationBarBackButtonHidden(true)
    }
}
