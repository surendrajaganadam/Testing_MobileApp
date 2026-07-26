import SwiftUI

struct MainShellView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showMenu = false
    @State private var showCart = false

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(store.selected.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(LebyyTheme.bg2, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showMenu = true
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(LebyyTheme.text)
                        }
                        .accessibilityIdentifier("test-Menu")
                        .accessibilityLabel("Menu")
                    }
                    if store.selected == .shop {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showCart = true
                            } label: {
                                Image(systemName: "cart")
                                    .foregroundStyle(LebyyTheme.text)
                                    .overlay(alignment: .topTrailing) {
                                        if store.cartCount > 0 {
                                            Text("\(store.cartCount)")
                                                .font(.caption2.bold())
                                                .padding(4)
                                                .background(LebyyTheme.accent)
                                                .clipShape(Circle())
                                                .offset(x: 8, y: -8)
                                                .accessibilityIdentifier("test-CartCount")
                                        }
                                    }
                            }
                            .accessibilityIdentifier("test-Cart")
                            .accessibilityLabel("Cart")
                        }
                    }
                }
                .sheet(isPresented: $showMenu) {
                    SideMenuView(isPresented: $showMenu)
                        .presentationDetents([.medium, .large])
                }
                .navigationDestination(isPresented: $showCart) {
                    CartView()
                }
                .navigationDestination(item: $store.orderDetailsToPresent) { orderId in
                    OrderDetailsView(orderId: orderId, fromCheckout: true)
                }
                .onChange(of: store.dismissCartAfterCheckout) { _, dismiss in
                    if dismiss {
                        showCart = false
                        store.dismissCartAfterCheckout = false
                    }
                }
        }
        .tint(LebyyTheme.primary)
    }

    @ViewBuilder
    private var content: some View {
        switch store.selected {
        case .shop: ShopView()
        case .orders: OrdersView()
        case .alerts: AlertsView()
        case .forms: FormsView()
        case .swipeH: SwipeHorizontalView()
        case .swipeV: SwipeVerticalView()
        case .gestures: GesturesView()
        case .webview: WebBrowserView()
        }
    }
}

struct SideMenuView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image("logo_lebyy").resizable().scaledToFit().frame(width: 44, height: 44)
                        VStack(alignment: .leading) {
                            Text("Lebyy").font(.headline).foregroundStyle(LebyyTheme.primary)
                            Text("Learn by yourself").font(.caption).foregroundStyle(LebyyTheme.muted)
                        }
                    }
                    .listRowBackground(LebyyTheme.surface)
                }
                Section {
                    ForEach(MenuDestination.allCases) { item in
                        Button {
                            store.selected = item
                            isPresented = false
                        } label: {
                            Text(item.title)
                                .foregroundStyle(store.selected == item ? LebyyTheme.accent : LebyyTheme.text)
                        }
                        .accessibilityIdentifier(item.accessibilityId)
                        .listRowBackground(LebyyTheme.surface)
                    }
                }
                Section {
                    Button(role: .destructive) {
                        isPresented = false
                        store.logout()
                    } label: {
                        Text("LOGOUT").foregroundStyle(LebyyTheme.accent)
                    }
                    .accessibilityIdentifier("test-LOGOUT")
                    .listRowBackground(LebyyTheme.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(LebyyTheme.bg)
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}
