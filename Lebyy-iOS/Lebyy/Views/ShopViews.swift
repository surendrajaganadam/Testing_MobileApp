import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Search courses", text: $store.shopSearch)
                    .padding(12)
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-ShopSearch")
                    .accessibilityLabel("Search courses")

                if !store.shopSearch.isEmpty {
                    Button("Clear Search") { store.shopSearch = "" }
                        .font(.caption.bold())
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-ClearSearch")
                        .accessibilityLabel("Clear Search")
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ShopSort.allCases) { sort in
                            Button(sort.title) {
                                store.shopSort = sort
                            }
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(store.shopSort == sort ? LebyyTheme.accent : LebyyTheme.surface)
                            .foregroundStyle(store.shopSort == sort ? LebyyTheme.bg : LebyyTheme.text)
                            .clipShape(Capsule())
                            .accessibilityIdentifier(sort.accessibilityId)
                            .accessibilityLabel(sort.title)
                            .accessibilityAddTraits(store.shopSort == sort ? .isSelected : [])
                        }
                    }
                }
                .accessibilityIdentifier("test-ShopSortBar")

                Text("Showing \(store.filteredProducts.count) courses")
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-ShopCount")
                    .accessibilityLabel("Showing \(store.filteredProducts.count) courses")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if store.filteredProducts.isEmpty {
                VStack(spacing: 12) {
                    Spacer(minLength: 40)
                    Text("No courses found")
                        .font(.headline)
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-ShopEmpty")
                    Text("Try another search term")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-ShopEmptyMessage")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(store.filteredProducts) { product in
                            ProductCard(product: product)
                                .accessibilityIdentifier("test-\(product.name)")
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-ShopScreen")
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
                        HStack {
                            Text(product.name).font(.headline).foregroundStyle(LebyyTheme.text)
                            Spacer()
                            Image(systemName: store.isWishlisted(product.id) ? "heart.fill" : "heart")
                                .foregroundStyle(LebyyTheme.accent)
                                .accessibilityHidden(true)
                        }
                        Text(String(format: "$%.2f", product.price)).foregroundStyle(LebyyTheme.accent)
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundStyle(LebyyTheme.muted)
                            .lineLimit(2)
                        if store.rating(for: product.id) > 0 {
                            Text("Rating: \(store.rating(for: product.id))/5")
                                .font(.caption)
                                .foregroundStyle(LebyyTheme.primary)
                                .accessibilityIdentifier("test-CardRating-\(product.id)")
                        }
                    }
                    .padding([.horizontal, .top], 16)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Button {
                    store.toggleWishlist(product.id)
                } label: {
                    Text(store.isWishlisted(product.id) ? "UNWISH" : "WISHLIST")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(LebyyTheme.surface2)
                        .foregroundStyle(LebyyTheme.text)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(store.isWishlisted(product.id) ? "test-UNWISH" : "test-WISHLIST")
                .accessibilityLabel(store.isWishlisted(product.id) ? "UNWISH" : "WISHLIST")

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
            }
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

                Text("Rating").font(.caption).foregroundStyle(LebyyTheme.muted)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            store.setRating(productId: product.id, stars: star)
                        } label: {
                            Image(systemName: store.rating(for: product.id) >= star ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundStyle(LebyyTheme.accent)
                                .frame(width: 40, height: 40)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("test-Rating-\(star)")
                        .accessibilityLabel("Rate \(star) stars")
                        .accessibilityAddTraits(store.rating(for: product.id) >= star ? .isSelected : [])
                    }
                }
                .accessibilityIdentifier("test-RatingBar")

                Text("Your rating: \(store.rating(for: product.id))/5")
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.primary)
                    .accessibilityIdentifier("test-RatingValue")
                    .accessibilityLabel("Your rating: \(store.rating(for: product.id))/5")

                Button {
                    store.toggleWishlist(product.id)
                } label: {
                    Text(store.isWishlisted(product.id) ? "REMOVE FROM WISHLIST" : "ADD TO WISHLIST")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LebyyTheme.surface2)
                        .foregroundStyle(LebyyTheme.text)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(store.isWishlisted(product.id) ? "test-REMOVE FROM WISHLIST" : "test-ADD TO WISHLIST")
                .accessibilityLabel(store.isWishlisted(product.id) ? "REMOVE FROM WISHLIST" : "ADD TO WISHLIST")

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
                        store.selectedTab = .shop
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

    private var canContinue: Bool {
        !store.firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !store.lastName.trimmingCharacters(in: .whitespaces).isEmpty
            && !store.zipCode.trimmingCharacters(in: .whitespaces).isEmpty
    }

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

            Section {
                NavigationLink {
                    PaymentView()
                } label: {
                    Text("CONTINUE")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canContinue ? LebyyTheme.accent : LebyyTheme.surface)
                        .foregroundStyle(canContinue ? LebyyTheme.bg : LebyyTheme.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .disabled(!canContinue)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("test-CONTINUE")
                .accessibilityLabel("CONTINUE")
            }
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Shipping")
    }
}

/// Card payment — 16-digit number (grouped), MM/YY expiry, CVV (practice app, no Luhn).
struct PaymentView: View {
    @EnvironmentObject private var store: AppStore

    private var cardDigits: String { store.cardNumber.filter(\.isNumber) }

    private var canContinue: Bool {
        cardDigits.count == 16 && store.cardExpiry.count == 5
    }

    var body: some View {
        Form {
            Section("Lebyy Pay — Card") {
                TextField("4242 4242 4242 4242", text: Binding(
                    get: { store.cardNumber },
                    set: { store.cardNumber = Self.formatCardNumber($0) }
                ))
                .keyboardType(.numberPad)
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("test-Card Number")
                .accessibilityLabel("Card Number")
                .accessibilityHint("16 digits, groups of 4")

                TextField("MM/YY", text: Binding(
                    get: { store.cardExpiry },
                    set: { store.cardExpiry = Self.formatExpiry($0) }
                ))
                .keyboardType(.numberPad)
                .accessibilityIdentifier("test-Card Expiry")
                .accessibilityLabel("Card Expiry")
                .accessibilityHint("MM/YY")

                SecureField("123", text: Binding(
                    get: { store.cardCvv },
                    set: { store.cardCvv = String($0.filter(\.isNumber).prefix(4)) }
                ))
                .keyboardType(.numberPad)
                .accessibilityIdentifier("test-Card CVV")
                .accessibilityLabel("Card CVV")

                VStack(alignment: .leading, spacing: 4) {
                    Text("Reference placeholders")
                        .font(.caption.bold())
                        .foregroundStyle(LebyyTheme.muted)
                    Text("Card: 4242 4242 4242 4242")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.primary)
                        .accessibilityIdentifier("test-CardPlaceholder")
                    Text("Expiry: MM/YY  ·  CVV: 123")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.primary)
                        .accessibilityIdentifier("test-ExpiryPlaceholder")
                }
            }

            Section {
                NavigationLink {
                    ReviewOrderView()
                } label: {
                    Text("CONTINUE TO REVIEW")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canContinue ? LebyyTheme.accent : LebyyTheme.surface)
                        .foregroundStyle(canContinue ? LebyyTheme.bg : LebyyTheme.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .disabled(!canContinue)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .accessibilityIdentifier("test-CONTINUE TO REVIEW")
                .accessibilityLabel("CONTINUE TO REVIEW")
            }
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Payment")
    }

    /// Groups up to 16 digits as `4242 4242 4242 4242`.
    static func formatCardNumber(_ raw: String) -> String {
        let digits = String(raw.filter(\.isNumber).prefix(16))
        return stride(from: 0, to: digits.count, by: 4).map { i in
            let start = digits.index(digits.startIndex, offsetBy: i)
            let end = digits.index(start, offsetBy: min(4, digits.count - i))
            return String(digits[start..<end])
        }.joined(separator: " ")
    }

    /// Formats as `MM/YY` while typing.
    static func formatExpiry(_ raw: String) -> String {
        let digits = String(raw.filter(\.isNumber).prefix(4))
        if digits.count <= 2 { return digits }
        let mm = digits.prefix(2)
        let yy = digits.dropFirst(2)
        return "\(mm)/\(yy)"
    }
}

struct ReviewOrderView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showCoupons = false

    private var canPlace: Bool { !store.cartLines.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Order items").font(.headline).foregroundStyle(LebyyTheme.text)
                if store.cartLines.isEmpty {
                    Text("Cart is empty — order already placed. Open Order History for details.")
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-ReviewEmpty")
                }
                ForEach(store.cartLines) { line in
                    Text(String(format: "• %@ x%d — $%.2f", line.product.name, line.quantity, line.lineTotal))
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-ReviewItem")
                }

                Text("Coupon").font(.headline).foregroundStyle(LebyyTheme.text)

                Button {
                    showCoupons.toggle()
                } label: {
                    Text(showCoupons ? "HIDE COUPONS" : "VIEW COUPONS")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("test-VIEW COUPONS")
                .accessibilityLabel(showCoupons ? "HIDE COUPONS" : "VIEW COUPONS")

                if showCoupons {
                    VStack(spacing: 10) {
                        ForEach(store.sampleCoupons) { coupon in
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(coupon.code)
                                        .font(.headline)
                                        .foregroundStyle(LebyyTheme.primary)
                                    Text(coupon.title)
                                        .font(.caption)
                                        .foregroundStyle(LebyyTheme.muted)
                                }
                                Spacer(minLength: 8)
                                Button("APPLY") {
                                    if store.applySampleCoupon(coupon) {
                                        showCoupons = false
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(LebyyTheme.primary)
                                .foregroundStyle(LebyyTheme.bg)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .accessibilityIdentifier("test-ApplyCoupon-\(coupon.code)")
                                .accessibilityLabel("APPLY \(coupon.code)")
                            }
                            .padding(12)
                            .background(LebyyTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .accessibilityIdentifier("test-SampleCoupon-\(coupon.code)")
                        }
                    }
                    .accessibilityIdentifier("test-CouponList")
                }

                if store.appliedCoupon == nil {
                    Text("Or enter a code")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)

                    HStack(spacing: 10) {
                        TextField("", text: $store.couponInput, prompt: Text("Coupon code"))
                            .textInputAutocapitalization(.characters)
                            .foregroundStyle(LebyyTheme.text)
                            .padding(12)
                            .background(LebyyTheme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .accessibilityIdentifier("test-Coupon")
                            .accessibilityLabel("test-Coupon")
                        Button("APPLY") {
                            if store.applyCoupon() {
                                showCoupons = false
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(LebyyTheme.primary)
                        .foregroundStyle(LebyyTheme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("test-APPLY COUPON")
                        .accessibilityLabel("APPLY COUPON")
                    }
                    Text("Pick a sample coupon or type any code (custom codes = 10% off).")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)
                }

                if let code = store.appliedCoupon {
                    // Keep code visible after apply (not only status text).
                    TextField("", text: .constant(code), prompt: Text("Coupon code"))
                        .disabled(true)
                        .foregroundStyle(LebyyTheme.text)
                        .padding(12)
                        .background(LebyyTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("test-Coupon")
                        .accessibilityLabel("test-Coupon")
                        .accessibilityValue(code)

                    Text("Coupon applied: \(code) (−\(store.appliedCouponPercent)%)")
                        .font(.subheadline.bold())
                        .foregroundStyle(LebyyTheme.success)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(LebyyTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("test-CouponApplied")
                        .accessibilityLabel("test-CouponApplied")
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
                    _ = store.placeOrder()
                } label: {
                    Text("PLACE ORDER")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canPlace ? LebyyTheme.accent : LebyyTheme.surface)
                        .foregroundStyle(canPlace ? LebyyTheme.bg : LebyyTheme.muted)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!canPlace)
                .padding(.top, 12)
                .accessibilityIdentifier("test-PLACE ORDER")
                .accessibilityLabel("PLACE ORDER")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Review Order")
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
                    Text("Complete a checkout to see order history here. Tap an order to view or cancel it.")
                        .font(.subheadline)
                        .foregroundStyle(LebyyTheme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.orders) { order in
                    NavigationLink {
                        OrderDetailsView(orderId: order.id, fromCheckout: false)
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
                    // Stable attr for every row — use .first() / .nth() (no dynamic order id).
                    .accessibilityIdentifier("test-Order")
                    .accessibilityLabel("test-Order")
                    .listRowBackground(LebyyTheme.surface)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Order History")
    }
}

struct OrderDetailsView: View {
    @EnvironmentObject private var store: AppStore
    let orderId: String
    /// After checkout: hide back, show Order History button instead.
    var fromCheckout: Bool = false

    private var order: Order? { store.order(byId: orderId) }

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
                        .accessibilityLabel("test-OrderId")

                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-OrderDate")
                        .accessibilityLabel("test-OrderDate")

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

                    Button {
                        store.orderDetailsToPresent = nil
                        store.showOrders = true
                    } label: {
                        Text("ORDER HISTORY")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LebyyTheme.primary)
                            .foregroundStyle(LebyyTheme.bg)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .accessibilityIdentifier("test-ORDER HISTORY")
                    .accessibilityLabel("ORDER HISTORY")
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
        .navigationBarBackButtonHidden(fromCheckout)
    }
}
