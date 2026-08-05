import SwiftUI

/// WebdriverIO-style bottom tabs. Practice (Components) needs no login.
struct TabRootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        TabView(selection: $store.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.systemImage) }
            .tag(AppTab.home)
            .accessibilityIdentifier(AppTab.home.accessibilityId)

            NavigationStack {
                ComponentsCatalogView()
            }
            .tabItem { Label(AppTab.components.title, systemImage: AppTab.components.systemImage) }
            .tag(AppTab.components)
            .accessibilityIdentifier(AppTab.components.accessibilityId)

            NavigationStack {
                ShopTabView()
            }
            .tabItem { Label(AppTab.shop.title, systemImage: AppTab.shop.systemImage) }
            .tag(AppTab.shop)
            .accessibilityIdentifier(AppTab.shop.accessibilityId)
            .badge(store.isLoggedIn && store.cartCount > 0 ? store.cartCount : 0)

            NavigationStack {
                AccountTabView()
            }
            .tabItem { Label(AppTab.account.title, systemImage: AppTab.account.systemImage) }
            .tag(AppTab.account)
            .accessibilityIdentifier(AppTab.account.accessibilityId)
        }
        .tint(LebyyTheme.primary)
        .accessibilityIdentifier("test-MainTabs")
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    Image("logo_lebyy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Lebyy")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(LebyyTheme.primary)
                            .accessibilityIdentifier("test-HomeBrand")
                        Text("Learn by yourself")
                            .foregroundStyle(LebyyTheme.muted)
                    }
                }
                .padding(.top, 8)

                Text("Welcome to Lebyy Practice App")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(LebyyTheme.accent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("test-HomeWelcome")
                    .accessibilityLabel("Welcome to Lebyy Practice App")

                Text("Use Components without login. Use Shop for the full login → checkout → logout E2E flow.")
                    .font(.subheadline)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-HomeBlurb")

                homeCard(
                    title: "Components",
                    body: "Browse categorized controls without logging in — alerts, forms, gestures, lists…",
                    cta: "Open Components",
                    id: "test-HomeOpenComponents"
                ) {
                    store.selectedTab = .components
                }

                homeCard(
                    title: "Shop E2E",
                    body: "Login → catalog → cart → checkout → orders → logout. Full commerce flow.",
                    cta: store.isLoggedIn ? "Go to Shop" : "Login to Shop",
                    id: "test-HomeOpenShop"
                ) {
                    store.selectedTab = store.isLoggedIn ? .shop : .account
                }

                homeCard(
                    title: "Account",
                    body: store.isLoggedIn ? "Signed in as \(store.displayName)" : "Sign in with demo_user / demo_pass",
                    cta: store.isLoggedIn ? "Open Account" : "Open Login",
                    id: "test-HomeOpenAccount"
                ) {
                    store.selectedTab = .account
                }

                if !store.lastDeepLink.isEmpty {
                    Text("Last deep link: \(store.lastDeepLink)")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-HomeDeepLink")
                }
            }
            .padding(20)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LebyyTheme.bg2, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .accessibilityIdentifier("test-HomeScreen")
    }

    private func homeCard(title: String, body: String, cta: String, id: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(LebyyTheme.primary)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(LebyyTheme.muted)
            Button(cta, action: action)
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier(id)
                .accessibilityLabel(cta)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LebyyTheme.surface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(LebyyTheme.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct ComponentsCatalogView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path = NavigationPath()

    var body: some View {
        List {
            Section {
                Text("Categorized practice demos. No login required.")
                    .font(.subheadline)
                    .foregroundStyle(LebyyTheme.muted)
                    .listRowBackground(Color.clear)
                    .accessibilityIdentifier("test-ComponentsHint")
            }

            Section("Categories") {
                ForEach(ComponentCategory.allCases) { category in
                    NavigationLink(value: category) {
                        HStack(spacing: 14) {
                            Image(systemName: category.systemImage)
                                .font(.title3)
                                .foregroundStyle(LebyyTheme.primary)
                                .frame(width: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.title)
                                    .foregroundStyle(LebyyTheme.text)
                                    .font(.body.weight(.semibold))
                                Text(category.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(LebyyTheme.muted)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier(category.accessibilityId)
                    .listRowBackground(LebyyTheme.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Components")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(LebyyTheme.bg2, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationDestination(for: ComponentCategory.self) { category in
            ComponentCategoryRouter(category: category)
        }
        .navigationDestination(for: FormControlTopic.self) { topic in
            FormControlTopicView(topic: topic)
        }
        .navigationDestination(for: String.self) { _ in EmptyView() }
        .accessibilityIdentifier("test-ComponentsScreen")
        .navigationDestination(isPresented: Binding(
            get: { store.pendingComponent != nil },
            set: { if !$0 { store.pendingComponent = nil } }
        )) {
            if let pending = store.pendingComponent {
                ComponentCategoryRouter(category: pending)
                    .onDisappear { store.pendingComponent = nil }
            }
        }
    }
}

struct ComponentCategoryRouter: View {
    let category: ComponentCategory

    var body: some View {
        Group {
            switch category {
            case .alerts:
                AlertsView()
                    .navigationTitle("Alerts & Dialogs")
            case .formControls:
                FormControlsHubView()
            case .swipes:
                SwipesHubView()
            case .gestures:
                GesturesView()
                    .navigationTitle("Gestures")
            case .lists:
                ListsPracticeView()
                    .navigationTitle("Lists")
            case .waits:
                WaitsPracticeView()
                    .navigationTitle("Waits")
            case .system:
                SystemPracticeView()
                    .navigationTitle("System")
            case .navigation:
                NavigationPracticeView()
                    .navigationTitle("Navigation")
            case .webview:
                WebBrowserView()
                    .navigationTitle("WebView")
            }
        }
        .toolbarBackground(LebyyTheme.bg2, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FormControlsHubView: View {
    var body: some View {
        List {
            Section {
                Text("Pick a control family — each screen shows multiple variants.")
                    .font(.subheadline)
                    .foregroundStyle(LebyyTheme.muted)
                    .listRowBackground(Color.clear)
            }
            Section("Form Controls") {
                ForEach(FormControlTopic.allCases) { topic in
                    NavigationLink(value: topic) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(topic.title)
                                .foregroundStyle(LebyyTheme.text)
                                .font(.body.weight(.semibold))
                            Text(topic.subtitle)
                                .font(.caption)
                                .foregroundStyle(LebyyTheme.muted)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier(topic.accessibilityId)
                    .listRowBackground(LebyyTheme.surface)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Form Controls")
        .accessibilityIdentifier("test-FormControlsHub")
    }
}

struct SwipesHubView: View {
    var body: some View {
        List {
            NavigationLink {
                SwipeHorizontalView()
                    .navigationTitle("Swipe Left / Right")
            } label: {
                row("Horizontal Carousel", "Swipe cards left & right", "test-SwipeNav-Horizontal")
            }
            .listRowBackground(LebyyTheme.surface)

            NavigationLink {
                SwipeVerticalView()
                    .navigationTitle("Swipe Up / Down")
            } label: {
                row("Vertical List", "Scroll a long list", "test-SwipeNav-Vertical")
            }
            .listRowBackground(LebyyTheme.surface)
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Swipes")
        .accessibilityIdentifier("test-SwipesHub")
    }

    private func row(_ title: String, _ subtitle: String, _ id: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).foregroundStyle(LebyyTheme.text).font(.body.weight(.semibold))
            Text(subtitle).font(.caption).foregroundStyle(LebyyTheme.muted)
        }
        .padding(.vertical, 4)
        .accessibilityIdentifier(id)
    }
}

struct ShopTabView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showCart = false

    var body: some View {
        Group {
            if store.isLoggedIn {
                ShopView()
                    .navigationTitle("Shop")
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Orders") { store.showOrders = true }
                                .accessibilityIdentifier("test-OpenOrders")
                                .accessibilityLabel("Orders")
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showCart = true
                            } label: {
                                Image(systemName: "cart")
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
                    .navigationDestination(isPresented: $showCart) { CartView() }
                    .navigationDestination(isPresented: $store.showOrders) { OrdersView() }
                    .navigationDestination(item: $store.orderDetailsToPresent) { orderId in
                        OrderDetailsView(orderId: orderId, fromCheckout: true)
                    }
                    .onChange(of: store.dismissCartAfterCheckout) { _, dismiss in
                        if dismiss {
                            showCart = false
                            store.dismissCartAfterCheckout = false
                        }
                    }
            } else {
                ShopLoginGateView()
            }
        }
        .toolbarBackground(LebyyTheme.bg2, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("test-ShopTab")
    }
}

struct ShopLoginGateView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart.fill")
                .font(.system(size: 48))
                .foregroundStyle(LebyyTheme.primary)
            Text("Shop needs login")
                .font(.title2.bold())
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-ShopLoginGateTitle")
            Text("Browse Components freely. Sign in to run the full cart → checkout → orders E2E.")
                .multilineTextAlignment(.center)
                .foregroundStyle(LebyyTheme.muted)
                .padding(.horizontal)
            Button("Go to Login") {
                store.selectedTab = .account
            }
            .buttonStyle(LebyyPrimaryButton())
            .accessibilityIdentifier("test-ShopGoLogin")
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Shop")
    }
}

struct AccountTabView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Group {
            if store.isLoggedIn {
                AccountLoggedInView()
            } else {
                LoginView()
                    .navigationTitle("Login")
            }
        }
        .toolbarBackground(LebyyTheme.bg2, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("test-AccountTab")
    }
}

struct AccountLoggedInView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        List {
            Section("Profile") {
                Text("Signed in")
                    .foregroundStyle(LebyyTheme.success)
                    .accessibilityIdentifier("test-AccountSignedIn")
                TextField("Display name", text: $store.displayName)
                    .accessibilityIdentifier("test-DisplayName")
                NavigationLink("Settings & Session") {
                    SettingsPracticeView()
                        .navigationTitle("Settings")
                }
                .accessibilityIdentifier("test-OpenSettings")
                .listRowBackground(LebyyTheme.surface)
            }
            .listRowBackground(LebyyTheme.surface)

            Section {
                Button("LOGOUT", role: .destructive) {
                    store.logout()
                }
                .accessibilityIdentifier("test-LOGOUT")
                .listRowBackground(LebyyTheme.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Account")
        .accessibilityIdentifier("test-AccountScreen")
    }
}
