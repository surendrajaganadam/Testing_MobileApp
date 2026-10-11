import SwiftUI

extension Notification.Name {
    static let lebyyOpenBillPayList = Notification.Name("lebyyOpenBillPayList")
    static let lebyyOpenZellePayList = Notification.Name("lebyyOpenZellePayList")
    static let lebyyPushBankRoute = Notification.Name("lebyyPushBankRoute")
}

private struct BankPopKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var popBankRoot: () -> Void {
        get { self[BankPopKey.self] }
        set { self[BankPopKey.self] = newValue }
    }
}

enum BankRoute: Hashable {
    case menu, inbox, products, rewards, profile
    case payTransfer, deposit, invest, assistant, activity
    case acctTransfer, payBills, billPayList, addPayeeWho, addPayeeForm, addPayeeSuccess
    case zelle, zellePay, zellePayDetails, zellePayReview, zellePaySuccess, wire
}

struct BankTabView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path = NavigationPath()

    var body: some View {
        VStack(spacing: 0) {
            // Persistent across every bank screen — returns to the main app (Home).
            BankExitBar()
            NavigationStack(path: $path) {
                Group {
                    if !store.isLoggedIn {
                        BankLoginGateView()
                    } else {
                        BankAccountsDashboard()
                    }
                }
                .navigationDestination(for: BankRoute.self) { route in
                    switch route {
                    case .menu:
                        BankSimpleScreen(title: "Menu", screenId: "test-BankMenuScreen", bodyText: "Result: Menu opened")
                    case .inbox:
                        BankSimpleScreen(title: "Inbox", screenId: "test-BankInboxScreen", bodyText: "Result: Inbox opened")
                    case .products:
                        BankSimpleScreen(title: "Products", screenId: "test-BankProductsScreen", bodyText: "Result: Products opened")
                    case .rewards:
                        BankSimpleScreen(title: "Lebyy Rewards", screenId: "test-BankRewardsScreen", bodyText: "Result: Rewards opened")
                    case .profile:
                        BankSimpleScreen(title: "Profile", screenId: "test-BankProfileScreen", bodyText: "Result: Profile opened")
                    case .payTransfer: PayTransferHubView()
                    case .deposit: DepositChecksView()
                    case .invest:
                        BankSimpleScreen(title: "Invest", screenId: "test-BankInvestScreen", bodyText: "Result: Invest opened")
                    case .assistant:
                        BankSimpleScreen(title: "Lebyy Assistant", screenId: "test-BankAssistantScreen", bodyText: "Result: Assistant opened")
                    case .activity: BankActivityListView()
                    case .acctTransfer: AcctTransferFormView()
                    case .payBills: BillPayHomeView()
                    case .billPayList: BillPayListView()
                    case .addPayeeWho: BillPayAddWhoView()
                    case .addPayeeForm: BillPayPersonInfoView()
                    case .addPayeeSuccess: BillPayAddSuccessView()
                    case .zelle: ZelleScreen()
                    case .zellePay: ZellePayScreen()
                    case .zellePayDetails: ZellePaymentDetailsView()
                    case .zellePayReview: ZelleReviewPaymentView()
                    case .zellePaySuccess: ZellePaymentSuccessView()
                    case .wire: WireScreen()
                    }
                }
            }
        }
        .environment(\.popBankRoot, {
            store.bank.requestCloseBankFlow()
        })
        .onChange(of: store.bank.closeBankFlow) { _, close in
            guard close else { return }
            store.bank.closeBankFlow = false
            path = NavigationPath()
        }
        .onReceive(NotificationCenter.default.publisher(for: .lebyyOpenBillPayList)) { _ in
            store.bank.showBillPayListAfterAdd = false
            store.bank.lastResult = ""
            // Rebuild root stack — nested isPresented pops are unreliable after Add Payee.
            path = NavigationPath()
            path.append(BankRoute.billPayList)
        }
        .onReceive(NotificationCenter.default.publisher(for: .lebyyOpenZellePayList)) { _ in
            store.bank.lastResult = ""
            // After Zelle add + OTP, land on the recipient list (not a nested pay screen).
            path = NavigationPath()
            path.append(BankRoute.zellePay)
        }
        .onReceive(NotificationCenter.default.publisher(for: .lebyyPushBankRoute)) { note in
            guard let route = note.object as? BankRoute else { return }
            path.append(route)
        }
        .tint(LebyyTheme.primary)
        .accessibilityIdentifier("test-BankTab")
    }
}

/// Leaves the bank shell and restores the main app tabs (Home).
struct BankExitBar: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        HStack {
            Text("Bank")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-BankExitBarTitle")
            Spacer()
            Button {
                store.bank.requestCloseBankFlow()
                store.selectedTab = .home
            } label: {
                Text("Exit Bank")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(BankDash.brandRed)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-ExitBank")
            .accessibilityLabel("Exit Bank")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(BankDash.canvas)
        .overlay(alignment: .bottom) { BankDash.line.frame(height: 1) }
        .accessibilityIdentifier("test-BankExitBar")
    }
}

struct BankLoginGateView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 48))
                .foregroundStyle(LebyyTheme.primary)
            Text("Bank needs login")
                .font(.title2.bold())
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-BankLoginGateTitle")
            Text("Sign in with demo_user / demo_pass to use bank practice flows.")
                .multilineTextAlignment(.center)
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityIdentifier("test-BankLoginGateBlurb")
            Button("Go to login") {
                store.selectedTab = .account
            }
            .buttonStyle(LebyyPrimaryButton())
            .accessibilityIdentifier("test-BankGoLogin")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Bank")
        .accessibilityIdentifier("test-BankLoginGate")
    }
}

/// Customer activity list (shared ids with Android `test-BankActivityScreen`).
struct BankActivityListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var query = ""
    @State private var filter = "All"

    private var rows: [BankTxn] {
        let activity = store.bank.currentCustomer()?.activity ?? []
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return activity.filter { txn in
            let matchFilter: Bool = {
                switch filter {
                case "Credit": return txn.kind == "Credit"
                case "Debit": return txn.kind == "Debit"
                case "Pending": return txn.status == "Pending"
                default: return true
                }
            }()
            if !matchFilter { return false }
            if q.isEmpty { return true }
            let line = txn.label(money: store.bank.money).lowercased()
            return line.contains(q) || txn.id.lowercased().contains(q)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Search activity", text: $query)
                .textInputAutocapitalization(.never)
                .padding(10)
                .background(LebyyTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("test-ActivitySearch")
            HStack {
                ForEach(["All", "Credit", "Debit", "Pending"], id: \.self) { name in
                    Button(name) { filter = name }
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(filter == name ? BankDash.accent.opacity(0.15) : Color.clear)
                        .clipShape(Capsule())
                        .accessibilityIdentifier("test-ActivityFilter-\(name)")
                }
            }
            Text("Filter: \(filter)")
                .font(.caption)
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-ActivityFilterValue")
            Text("Showing \(rows.count)")
                .font(.caption)
                .accessibilityIdentifier("test-ActivityCount")
            Button("Apply search") { }
                .accessibilityIdentifier("test-ActivitySearchApply")
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(rows) { txn in
                        Text(txn.label(money: store.bank.money))
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(BankDash.paper)
                            .accessibilityIdentifier("test-Activity-\(txn.id)")
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BankDash.canvas.ignoresSafeArea())
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("test-BankActivityScreen")
    }
}

struct BankField: View {
    let title: String
    @Binding var text: String
    let identifier: String

    var body: some View {
        TextField(title, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding()
            .background(LebyyTheme.surface)
            .foregroundStyle(LebyyTheme.text)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityIdentifier(identifier)
            .accessibilityLabel(identifier)
    }
}
