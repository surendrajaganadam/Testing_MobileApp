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
        ZStack {
            LinearGradient(
                colors: [LebyyTheme.bg2, LebyyTheme.bg, Color.black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 36)

                VStack(spacing: 26) {
                    Image("logo_lebyy")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 210, height: 180)
                        .shadow(color: LebyyTheme.primary.opacity(0.35), radius: 24, y: 8)
                        .accessibilityIdentifier("test-HomeLogo")
                        .accessibilityLabel("Lebyy logo")

                    HStack(spacing: 12) {
                        Text("LEBYY")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .tracking(4)
                            .foregroundStyle(LebyyTheme.primary)
                            .accessibilityIdentifier("test-HomeBrand")

                        Text("APP")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(LebyyTheme.bg)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 9)
                            .background(LebyyTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }

                    Text("Welcome to Lebyy Practice App")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(LebyyTheme.accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("test-HomeWelcome")
                        .accessibilityLabel("Welcome to Lebyy Practice App")

                    Text("Demo app for mobile automation practice")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(LebyyTheme.text)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("test-HomeBlurb")

                    HStack(spacing: 44) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundStyle(LebyyTheme.primary)
                            .accessibilityIdentifier("test-HomeIcon-iOS")
                            .accessibilityLabel("iOS")

                        Image(systemName: "smartphone")
                            .font(.system(size: 46, weight: .semibold))
                            .foregroundStyle(LebyyTheme.primary)
                            .accessibilityIdentifier("test-HomeIcon-Android")
                            .accessibilityLabel("Android")
                    }
                    .padding(.top, 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

                Spacer()

                if !store.lastDeepLink.isEmpty {
                    Text("Last deep link: \(store.lastDeepLink)")
                        .font(.caption)
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-HomeDeepLink")
                        .padding(.bottom, 28)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-HomeScreen")
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
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.title)
                                    .foregroundStyle(LebyyTheme.text)
                                    .font(.body.weight(.semibold))
                                    .accessibilityIdentifier(category.accessibilityId)
                                    .accessibilityLabel(category.title)
                                    .accessibilityAddTraits(.isButton)
                                Text(category.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(LebyyTheme.muted)
                                    .accessibilityLabel(category.subtitle)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityElement(children: .contain)
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
                                .accessibilityIdentifier(topic.accessibilityId)
                                .accessibilityLabel(topic.title)
                                .accessibilityAddTraits(.isButton)
                            Text(topic.subtitle)
                                .font(.caption)
                                .foregroundStyle(LebyyTheme.muted)
                                .accessibilityLabel(topic.subtitle)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityElement(children: .contain)
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
            Text(title)
                .foregroundStyle(LebyyTheme.text)
                .font(.body.weight(.semibold))
                .accessibilityIdentifier(id)
                .accessibilityLabel(title)
                .accessibilityAddTraits(.isButton)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityLabel(subtitle)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
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
