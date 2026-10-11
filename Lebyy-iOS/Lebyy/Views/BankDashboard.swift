import SwiftUI

/// Light “Accounts” dashboard shell (header / center / footer), Lebyy-branded.
enum BankDash {
    static let paper = Color.white
    static let canvas = Color(red: 0.965, green: 0.969, blue: 0.976) // #F6F7F9
    static let ink = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let muted = Color(red: 0.42, green: 0.45, blue: 0.50)
    static let line = Color(red: 0.86, green: 0.88, blue: 0.91)
    static let brandRed = Color(red: 0.86, green: 0.15, blue: 0.15)
    static let brandBlue = Color(red: 0.05, green: 0.30, blue: 0.70)
    static let accent = Color(red: 0.05, green: 0.40, blue: 0.85)
    static let banner = Color(red: 0.94, green: 0.94, blue: 0.95)
    /// High-contrast selected / unselected for Accounts·Dashboard + footer.
    static let tabSelected = Color(red: 0.04, green: 0.28, blue: 0.72) // #0A47B8
    static let tabUnselected = Color(red: 0.18, green: 0.22, blue: 0.28) // dark, readable on white
    static let footerAccounts = Color(red: 0.05, green: 0.35, blue: 0.85)
    static let footerPay = Color(red: 0.42, green: 0.18, blue: 0.78)
    static let footerDeposit = Color(red: 0.0, green: 0.52, blue: 0.55)
    static let footerInvest = Color(red: 0.90, green: 0.42, blue: 0.08)
}

struct BankAccountsDashboard: View {
    @EnvironmentObject private var store: AppStore
    @State private var topTab = "Accounts"
    @State private var footerTab = "Accounts"
    @State private var showPromo = true
    @State private var bankingExpanded = true
    @State private var cardsExpanded = true
    @State private var assistantText = ""

    private var fullName: String {
        store.bank.currentCustomer()?.displayName ?? store.displayName
    }
    private var firstName: String {
        fullName.split(separator: " ").first.map(String.init) ?? fullName
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            accountsDashboardTabs
            Divider().overlay(BankDash.line)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if topTab == "Accounts" {
                        accountsCenter
                    } else {
                        dashboardCenter
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .background(BankDash.canvas)

            footerBar
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-BankHome")
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .center) {
            headerIconButton(system: "line.3.horizontal", label: "Menu", id: "test-BankMenu") {
                BankRoute.menu
            }
            Spacer()
            HStack(spacing: 18) {
                headerIconButton(system: "envelope", label: "Inbox", id: "test-BankInbox") { .inbox }
                headerIconButton(system: "cart", label: "Products", id: "test-BankProducts") { .products }
                Button {
                    store.logout()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Log Out")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(BankDash.ink)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("test-BankLogOut")
                .accessibilityLabel("Log Out")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(BankDash.paper)
        .accessibilityIdentifier("test-BankHeader")
    }

    private func headerIconButton(system: String, label: String, id: String, route: () -> BankRoute) -> some View {
        NavigationLink(value: route()) {
            VStack(spacing: 2) {
                Image(systemName: system)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(BankDash.ink)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
        .accessibilityLabel(label)
    }

    // MARK: - Top tabs

    private var accountsDashboardTabs: some View {
        HStack(spacing: 0) {
            topTabButton("Accounts", id: "test-BankTopTab-Accounts")
            topTabButton("Dashboard", id: "test-BankTopTab-Dashboard")
        }
        .background(BankDash.paper)
        .accessibilityIdentifier("test-BankTopTabs")
    }

    private func topTabButton(_ title: String, id: String) -> some View {
        let selected = topTab == title
        return Button {
            topTab = title
        } label: {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: selected ? .bold : .semibold))
                    .foregroundStyle(selected ? BankDash.tabSelected : BankDash.tabUnselected)
                    .frame(maxWidth: .infinity)
                Rectangle()
                    .fill(selected ? BankDash.tabSelected : BankDash.line)
                    .frame(height: selected ? 4 : 2)
            }
            .padding(.top, 10)
            .background(selected ? BankDash.tabSelected.opacity(0.08) : Color.clear)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: - Center

    @ViewBuilder
    private var accountsCenter: some View {
        if showPromo {
            promoBanner
        }
        assistantBar
        greetingBlock
        rewardsRow
        bankingSection
        creditCardsSection
    }

    private var dashboardCenter: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dashboard")
                .font(.title3.bold())
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-BankDashboardTitle")
            Text("Spending snapshot and rewards for practice automation.")
                .font(.subheadline)
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-BankDashboardBlurb")
            dashCard(title: "This month spent", value: "₹12,450.00", id: "test-Dash-Spent")
            dashCard(title: "Rewards points", value: "2,480", id: "test-Dash-Points")
            dashCard(title: "Upcoming bills", value: "2", id: "test-Dash-Bills")
        }
        .accessibilityIdentifier("test-BankDashboardPanel")
    }

    private func dashCard(title: String, value: String, id: String) -> some View {
        HStack {
            Text(title).foregroundStyle(BankDash.muted)
            Spacer()
            Text(value).bold().foregroundStyle(BankDash.ink)
        }
        .padding(14)
        .background(BankDash.paper)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(BankDash.line, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityIdentifier(id)
    }

    private var promoBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(BankDash.accent)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text("Open a CD and watch your money grow. Start with as little as ₹1,000 and get a competitive, guaranteed rate of return.")
                    .font(.system(size: 13))
                    .foregroundStyle(BankDash.ink)
                    .accessibilityIdentifier("test-BankPromoText")
                NavigationLink(value: BankRoute.products) {
                    Text("Compare options")
                        .font(.system(size: 13, weight: .semibold))
                        .underline()
                        .foregroundStyle(BankDash.accent)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("test-BankPromoCompare")
            }
            Button {
                showPromo = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(BankDash.muted)
                    .padding(4)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-BankPromoDismiss")
            .accessibilityLabel("Dismiss promo")
        }
        .padding(12)
        .background(BankDash.banner)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("test-BankPromo")
    }

    private var assistantBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(BankDash.muted)
            TextField("Hi, I'm Lebyy. How can I help?", text: $assistantText)
                .textInputAutocapitalization(.never)
                .accessibilityIdentifier("test-BankAssistant")
                .accessibilityLabel("Hi, I'm Lebyy. How can I help?")
            NavigationLink(value: BankRoute.assistant) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(BankDash.brandRed)
                        .frame(width: 34, height: 34)
                        .overlay(
                            Text("L")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        )
                    Text("6")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(4)
                        .background(BankDash.accent)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                        .accessibilityIdentifier("test-BankAssistantBadge")
                }
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-BankAssistantOpen")
            .accessibilityLabel("Lebyy assistant")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(BankDash.paper)
        .overlay(Capsule().stroke(BankDash.line, lineWidth: 1))
        .clipShape(Capsule())
        .accessibilityIdentifier("test-BankAssistantBar")
    }

    private var greetingBlock: some View {
        NavigationLink(value: BankRoute.profile) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hello, \(firstName)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(BankDash.ink)
                    Text(fullName)
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-BankCustomerName")
                        .accessibilityLabel(fullName)
                    Text("Role: Customer")
                        .font(.caption2)
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-BankRole")
                    Text("Lebyy Rewards member")
                        .font(.subheadline)
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-BankRewardsMember")
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BankDash.muted)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("test-BankGreeting")
    }

    private var rewardsRow: some View {
        NavigationLink(value: BankRoute.rewards) {
            HStack {
                Text("Lebyy Rewards™")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(BankDash.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(BankDash.muted)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("test-BankRewards")
        .accessibilityLabel("Lebyy Rewards")
    }

    private var bankingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            brandStripe
            Button {
                bankingExpanded.toggle()
            } label: {
                HStack {
                    Text("Banking")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(BankDash.ink)
                    Spacer()
                    Image(systemName: bankingExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(BankDash.muted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-BankingToggle")

            if bankingExpanded {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [BankDash.brandRed, BankDash.brandBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 22, height: 14)
                    Text("Lebyy Bank")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BankDash.ink)
                    Text("FDIC")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-BankFdic")
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
                .accessibilityIdentifier("test-BankBrand")

                if let customer = store.bank.currentCustomer() {
                    ForEach(customer.accounts, id: \.id) { account in
                        let line = "\(account.name) \(account.masked) · \(store.bank.money(account.balance))"
                        NavigationLink(value: BankRoute.activity) {
                            accountRowContent(
                                title: "\(account.name) - \(String(account.number.suffix(4)))",
                                balance: store.bank.money(account.balance)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("test-Account-\(account.name)")
                        .accessibilityLabel(line)
                        if account.id != customer.accounts.last?.id {
                            Divider().padding(.leading, 14)
                        }
                    }
                }
            }
        }
        .background(BankDash.paper)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(BankDash.line, lineWidth: 1))
        .accessibilityIdentifier("test-BankingSection")
    }

    private var creditCardsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            brandStripe
            Button {
                cardsExpanded.toggle()
            } label: {
                HStack {
                    Text("Credit cards")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(BankDash.ink)
                    Spacer()
                    Image(systemName: cardsExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(BankDash.muted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-CreditCardsToggle")

            if cardsExpanded, let card = store.bank.currentCustomer()?.card {
                NavigationLink(value: BankRoute.payTransfer) {
                    accountRowContent(
                        title: "\(card.network) ending \(card.last4)",
                        balance: card.frozen ? "Frozen" : store.bank.money(card.limit)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("test-HomeCard-\(card.network)")
                .accessibilityLabel("\(card.network) ••\(card.last4)")
            }
        }
        .background(BankDash.paper)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(BankDash.line, lineWidth: 1))
        .accessibilityIdentifier("test-CreditCardsSection")
    }

    private var brandStripe: some View {
        HStack(spacing: 0) {
            BankDash.brandRed.frame(maxWidth: .infinity, maxHeight: 4)
            BankDash.brandBlue.frame(maxWidth: .infinity, maxHeight: 4)
        }
    }

    private func accountRow(title: String, balance: String, id: String, a11yLabel: String) -> some View {
        accountRowContent(title: title, balance: balance)
            .accessibilityElement(children: .ignore)
            .accessibilityIdentifier(id)
            .accessibilityLabel(a11yLabel)
    }

    private func accountRowContent(title: String, balance: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(BankDash.ink)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(balance)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(BankDash.ink)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(BankDash.muted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    // MARK: - Footer

    private var footerBar: some View {
        HStack(spacing: 4) {
            footerItem("Accounts", "dollarsign.circle", "test-BankFooter-Accounts", accent: BankDash.footerAccounts) {
                footerTab = "Accounts"
                topTab = "Accounts"
            }
            footerItem("Pay & Transfer", "arrow.left.arrow.right.circle", "test-BankFooter-PayTransfer", accent: BankDash.footerPay) {
                footerTab = "Pay & Transfer"
            } destination: { .payTransfer }
            footerItem("Deposit Checks", "camera.viewfinder", "test-BankFooter-Deposit", accent: BankDash.footerDeposit) {
                footerTab = "Deposit Checks"
            } destination: { .deposit }
            footerItem("Invest", "chart.pie", "test-BankFooter-Invest", accent: BankDash.footerInvest) {
                footerTab = "Invest"
            } destination: { .invest }
        }
        .padding(.horizontal, 6)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(BankDash.canvas)
        .overlay(alignment: .top) { BankDash.line.frame(height: 1) }
        .accessibilityIdentifier("test-BankFooter")
    }

    @ViewBuilder
    private func footerItem(
        _ title: String,
        _ system: String,
        _ id: String,
        accent: Color,
        select: @escaping () -> Void,
        destination: (() -> BankRoute)? = nil
    ) -> some View {
        let selected = footerTab == title
        Group {
            if let destination {
                NavigationLink(value: destination()) {
                    footerLabel(title, system, selected: selected, accent: accent)
                }
                .simultaneousGesture(TapGesture().onEnded { select() })
            } else {
                Button(action: select) {
                    footerLabel(title, system, selected: selected, accent: accent)
                }
            }
        }
        .buttonStyle(.plain)
        .tint(accent)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier(id)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func footerLabel(_ title: String, _ system: String, selected: Bool, accent: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: system)
                .font(.system(size: 22, weight: .semibold))
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(accent)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(selected ? accent.opacity(0.22) : accent.opacity(0.10))
                )
                .overlay(
                    Circle()
                        .stroke(accent, lineWidth: selected ? 2 : 0)
                )
            Text(title)
                .font(.system(size: 10, weight: selected ? .bold : .semibold))
                .foregroundStyle(selected ? accent : BankDash.tabUnselected)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(selected ? accent.opacity(0.12) : Color.clear)
        )
    }
}

// MARK: - Secondary shell screens

struct BankSimpleScreen: View {
    let title: String
    let screenId: String
    let bodyText: String
    let resultId: String = "test-BankShellResult"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(bodyText)
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier(resultId)
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(screenId)
    }
}
