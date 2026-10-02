import SwiftUI

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
    case transfer, transferConfirm, otp, receipt
    case payees, addPayee
    case bills, billConfirm
    case cards, activity
    case pending, pendingDetail(String)
    case customers, customerForm(String?)
    case decisions
}

struct BankTabView: View {
    @EnvironmentObject private var store: AppStore
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if !store.isLoggedIn {
                    BankLoginGateView()
                } else if store.bank.isManager {
                    ManagerHomeView()
                } else {
                    CustomerBankHomeView()
                }
            }
            .navigationDestination(for: BankRoute.self) { route in
                switch route {
                case .transfer: TransferView()
                case .transferConfirm: TransferConfirmView()
                case .otp: BankOtpView()
                case .receipt: BankReceiptView()
                case .payees: PayeesView()
                case .addPayee: AddPayeeView()
                case .bills: BillsView()
                case .billConfirm: BillConfirmView()
                case .cards: CardsView()
                case .activity: BankActivityListView()
                case .pending: PendingListView()
                case .pendingDetail(let id): PendingDetailView(transferId: id)
                case .customers: CustomersView()
                case .customerForm(let username): CustomerFormView(editingUsername: username)
                case .decisions: DecisionsView()
                }
            }
        }
        .environment(\.popBankRoot, { path = NavigationPath() })
        .tint(LebyyTheme.primary)
        .accessibilityIdentifier("test-BankTab")
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
            Text("Sign in as a customer or as the branch manager.")
                .multilineTextAlignment(.center)
                .foregroundStyle(LebyyTheme.muted)
                .padding(.horizontal)
            Button("Go to Login") { store.selectedTab = .account }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-BankGoLogin")
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Bank")
    }
}

struct CustomerBankHomeView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let bank = store.bank
        let customer = bank.currentCustomer()
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(customer?.displayName ?? "")
                    .font(.title2.bold())
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-BankCustomerName")
                Text("Role: Customer")
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-BankRole")
                if let customer {
                    ForEach(customer.accounts, id: \.id) { account in
                        Text("\(account.name) \(account.masked) · \(bank.money(account.balance))")
                            .foregroundStyle(LebyyTheme.text)
                            .accessibilityIdentifier("test-Account-\(account.name)")
                    }
                }
                bankLink("Transfer", "test-Bank-Transfer", .transfer)
                bankLink("Payees", "test-Bank-Payees", .payees)
                bankLink("Pay a bill", "test-Bank-Bills", .bills)
                bankLink("Cards", "test-Bank-Cards", .cards)
                bankLink("Activity", "test-Bank-Activity", .activity)
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Bank")
        .accessibilityIdentifier("test-BankHome")
    }
}

struct ManagerHomeView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let bank = store.bank
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(BankStore.managerName)
                    .font(.title2.bold())
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-ManagerName")
                Text("Role: Manager")
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-BankRole")
                Text("Pending: \(bank.pendingTransfers().count)")
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-PendingCount")
                Text("Customers: \(bank.customers.count)")
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-CustomerCount")
                bankLink("Pending queue", "test-Bank-Pending", .pending)
                bankLink("Customers", "test-Bank-Customers", .customers)
                bankLink("Decision history", "test-Bank-Decisions", .decisions)
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Bank")
        .accessibilityIdentifier("test-ManagerHome")
    }
}

struct TransferView: View {
    @EnvironmentObject private var store: AppStore
    @State private var amount = ""
    @State private var goConfirm = false

    var body: some View {
        let bank = store.bank
        let customer = bank.currentCustomer()
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let customer {
                    ForEach(customer.accounts, id: \.id) { account in
                        Button("\(account.name) \(account.masked) · \(bank.money(account.balance))") {
                            bank.objectWillChange.send()
                            bank.draftFromAccountId = account.id
                        }
                        .buttonStyle(LebyyPrimaryButton())
                        .accessibilityIdentifier("test-TransferFrom-\(account.name)")
                    }
                    Text("From: \(customer.accounts.first { $0.id == bank.draftFromAccountId }?.name ?? "")")
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-TransferFromValue")
                    ForEach(customer.payees) { payee in
                        Button("\(payee.name) · \(payee.accountNumber)") {
                            bank.objectWillChange.send()
                            bank.draftPayeeName = payee.name
                        }
                        .buttonStyle(LebyyCyanButton())
                        .accessibilityIdentifier("test-TransferPayee-\(payee.name)")
                    }
                    Text("Payee: \(bank.draftPayeeName)")
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-TransferPayeeValue")
                }
                BankField(title: "Amount", text: $amount, identifier: "test-TransferAmount")
                Button("Continue") {
                    bank.draftAmountText = amount
                    let message = bank.beginTransfer(
                        fromAccountId: bank.draftFromAccountId,
                        payeeName: bank.draftPayeeName,
                        amountText: amount
                    )
                    if message.isEmpty {
                        goConfirm = true
                    } else {
                        bank.lastResult = message
                    }
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-TransferContinue")
                .navigationDestination(isPresented: $goConfirm) {
                    TransferConfirmView()
                }
                if !bank.lastResult.isEmpty {
                    Text(bank.lastResult)
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-BankResult")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Transfer")
        .accessibilityIdentifier("test-BankTransferScreen")
        .onAppear {
            if bank.draftFromAccountId.isEmpty {
                bank.draftFromAccountId = customer?.accounts.first?.id ?? "checking"
            }
            if amount.isEmpty { amount = bank.draftAmountText }
        }
    }
}

struct TransferConfirmView: View {
    @EnvironmentObject private var store: AppStore
    @State private var goReceipt = false

    var body: some View {
        let bank = store.bank
        let from = bank.currentCustomer()?.accounts.first { $0.id == bank.draftFromAccountId }?.name ?? ""
        VStack(alignment: .leading, spacing: 16) {
            Text("\(from) → \(bank.draftPayeeName) \(bank.money(bank.draftAmount))")
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-TransferSummary")
            if bank.confirmTransferNeedsOtp() {
                NavigationLink(value: BankRoute.otp) {
                    Text("Confirm")
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-TransferConfirm")
            } else {
                Button("Confirm") {
                    _ = bank.queueLargeTransfer()
                    goReceipt = true
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-TransferConfirm")
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Confirm transfer")
        .accessibilityIdentifier("test-BankTransferConfirmScreen")
        .navigationDestination(isPresented: $goReceipt) {
            BankReceiptView()
        }
    }
}

struct BankOtpView: View {
    @EnvironmentObject private var store: AppStore
    @State private var digits = ["", "", "", ""]
    @State private var goReceipt = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter OTP 1234")
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityIdentifier("test-BankOtpHint")
            HStack {
                ForEach(0..<4, id: \.self) { index in
                    TextField("", text: $digits[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.text)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .accessibilityIdentifier("test-BankOTP-\(index + 1)")
                        .accessibilityLabel("test-BankOTP-\(index + 1)")
                        .onChange(of: digits[index]) { _, newValue in
                            digits[index] = String(newValue.prefix(1))
                        }
                }
            }
            Button("Verify") {
                let message = store.bank.completeTransferWithOtp(code: digits.joined())
                if message.hasPrefix("Receipt:") { goReceipt = true }
            }
            .buttonStyle(LebyyPrimaryButton())
            .accessibilityIdentifier("test-BankOTPVerify")
            .navigationDestination(isPresented: $goReceipt) {
                BankReceiptView()
            }
            if !store.bank.lastResult.isEmpty && !goReceipt {
                Text(store.bank.lastResult)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-BankResult")
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Transfer OTP")
        .accessibilityIdentifier("test-BankOtpScreen")
    }
}

struct BankReceiptView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.popBankRoot) private var popBankRoot

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(store.bank.lastReceipt)
                .font(.headline)
                .foregroundStyle(LebyyTheme.success)
                .accessibilityIdentifier("test-BankReceipt")
            Button("Done") { popBankRoot() }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-BankDone")
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Receipt")
        .accessibilityIdentifier("test-BankReceiptScreen")
    }
}

struct PayeesView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                NavigationLink(value: BankRoute.addPayee) { Text("Add payee") }
                    .buttonStyle(LebyyPrimaryButton())
                    .accessibilityIdentifier("test-AddPayee")
                if let customer = store.bank.currentCustomer() {
                    ForEach(customer.payees) { payee in
                        Text("\(payee.name) · \(payee.accountNumber)")
                            .foregroundStyle(LebyyTheme.text)
                            .accessibilityIdentifier("test-Payee-\(payee.name)")
                    }
                }
                if !store.bank.lastResult.isEmpty {
                    Text(store.bank.lastResult)
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-BankResult")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Payees")
        .accessibilityIdentifier("test-BankPayeesScreen")
    }
}

struct AddPayeeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var account = ""
    @State private var error = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            BankField(title: "Payee name", text: $name, identifier: "test-PayeeName")
            BankField(title: "Account number", text: $account, identifier: "test-PayeeAccount")
            Button("Save payee") {
                let message = store.bank.addPayee(name: name, accountNumber: account)
                if message == "Result: Payee saved" {
                    dismiss()
                } else {
                    error = message
                }
            }
            .buttonStyle(LebyyPrimaryButton())
            .accessibilityIdentifier("test-PayeeSave")
            if !error.isEmpty {
                Text(error)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-BankResult")
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Add payee")
        .accessibilityIdentifier("test-BankAddPayeeScreen")
    }
}

struct BillsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var goConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let customer = store.bank.currentCustomer() {
                    ForEach(customer.bills) { bill in
                        Button("\(bill.name) · \(store.bank.money(bill.amountDue))") {
                            let message = store.bank.beginBill(billId: bill.id)
                            if message.isEmpty {
                                goConfirm = true
                            } else {
                                store.bank.lastResult = message
                            }
                        }
                        .buttonStyle(LebyyPrimaryButton())
                        .accessibilityIdentifier("test-Bill-\(bill.name)")
                    }
                }
                if !store.bank.lastResult.isEmpty {
                    Text(store.bank.lastResult)
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-BankResult")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Pay a bill")
        .accessibilityIdentifier("test-BankBillsScreen")
        .navigationDestination(isPresented: $goConfirm) {
            BillConfirmView()
        }
    }
}

struct BillConfirmView: View {
    @EnvironmentObject private var store: AppStore
    @State private var goReceipt = false

    var body: some View {
        let bill = store.bank.currentCustomer()?.bills.first { $0.id == store.bank.draftBillId }
        VStack(alignment: .leading, spacing: 16) {
            Text("\(bill?.name ?? "") \(store.bank.money(bill?.amountDue ?? 0)) from Checking")
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-BillSummary")
            Button("Pay") {
                _ = store.bank.payBill()
                goReceipt = true
            }
            .buttonStyle(LebyyPrimaryButton())
            .accessibilityIdentifier("test-BillPay")
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Confirm bill")
        .accessibilityIdentifier("test-BankBillConfirmScreen")
        .navigationDestination(isPresented: $goReceipt) {
            BankReceiptView()
        }
    }
}

struct CardsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var limit = ""

    var body: some View {
        let card = store.bank.currentCustomer()?.card
        VStack(alignment: .leading, spacing: 12) {
            if let card {
                Text("\(card.network) ••\(card.last4)")
                    .font(.title3.bold())
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-Card-\(card.network)")
                Text(card.frozen ? "Card status: Frozen" : "Card status: Active")
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-CardStatus")
                Button(card.frozen ? "Unfreeze" : "Freeze") {
                    _ = store.bank.setCardFrozen(!card.frozen)
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-CardFreeze")
                BankField(title: "Spending limit", text: $limit, identifier: "test-CardLimit")
                Button("Save limit") {
                    _ = store.bank.saveCardLimit(limitText: limit)
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-CardSaveLimit")
            }
            if !store.bank.lastResult.isEmpty {
                Text(store.bank.lastResult)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-BankResult")
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Cards")
        .accessibilityIdentifier("test-BankCardsScreen")
        .onAppear {
            if limit.isEmpty, let card = store.bank.currentCustomer()?.card {
                limit = String(format: "%.0f", card.limit)
            }
        }
    }
}

struct BankActivityListView: View {
    @EnvironmentObject private var store: AppStore
    @State private var query = ""
    @State private var applied = ""
    @State private var filter = "All"

    var body: some View {
        let customer = store.bank.currentCustomer()
        let rows = customer.map { store.bank.filteredActivity(customer: $0, query: applied, filter: filter) } ?? []
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                BankField(title: "Search activity", text: $query, identifier: "test-ActivitySearch")
                Button("Apply search") { applied = query }
                    .buttonStyle(LebyyCyanButton())
                    .accessibilityIdentifier("test-ActivitySearchApply")
                ForEach(["All", "Credit", "Debit", "Pending"], id: \.self) { name in
                    Button(name) { filter = name }
                        .buttonStyle(LebyyPrimaryButton())
                        .opacity(filter == name ? 1 : 0.55)
                        .accessibilityIdentifier("test-ActivityFilter-\(name)")
                }
                Text("Showing \(rows.count)")
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-ActivityCount")
                Text("Filter: \(filter)")
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-ActivityFilterValue")
                ForEach(rows) { txn in
                    Text(txn.label(money: store.bank.money))
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-Activity-\(txn.id)")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Activity")
        .accessibilityIdentifier("test-BankActivityScreen")
    }
}

struct PendingListView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let items = store.bank.pendingTransfers()
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Pending: \(items.count)")
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-PendingCount")
                ForEach(items) { item in
                    NavigationLink(value: BankRoute.pendingDetail(item.id)) {
                        Text(item.label(money: store.bank.money))
                    }
                    .buttonStyle(LebyyPrimaryButton())
                    .accessibilityIdentifier("test-Pending-\(item.id)")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Pending approvals")
        .accessibilityIdentifier("test-BankPendingScreen")
    }
}

struct PendingDetailView: View {
    @EnvironmentObject private var store: AppStore
    let transferId: String
    @State private var reason = ""

    var body: some View {
        let item = store.bank.pending.first { $0.id == transferId }
        VStack(alignment: .leading, spacing: 12) {
            Text(item?.label(money: store.bank.money) ?? "Missing")
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-PendingSummary")
            BankField(title: "Reject reason", text: $reason, identifier: "test-PendingRejectReason")
            Button("Approve") { _ = store.bank.approve(transferId: transferId) }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-PendingApprove")
            Button("Reject") { _ = store.bank.reject(transferId: transferId, reason: reason) }
                .buttonStyle(LebyyMutedButton())
                .accessibilityIdentifier("test-PendingReject")
            if !store.bank.lastResult.isEmpty {
                Text(store.bank.lastResult)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-BankResult")
            }
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Review request")
        .accessibilityIdentifier("test-BankPendingDetailScreen")
    }
}

struct CustomersView: View {
    @EnvironmentObject private var store: AppStore
    @State private var query = ""
    @State private var applied = ""

    var body: some View {
        let rows = store.bank.filteredCustomers(query: applied)
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                BankField(title: "Search customers", text: $query, identifier: "test-CustomerSearch")
                Button("Search") { applied = query }
                    .buttonStyle(LebyyCyanButton())
                    .accessibilityIdentifier("test-CustomerSearchApply")
                NavigationLink(value: BankRoute.customerForm(nil)) { Text("Create customer") }
                    .buttonStyle(LebyyPrimaryButton())
                    .accessibilityIdentifier("test-CustomerCreate")
                Text("Customers: \(rows.count)")
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-CustomerCount")
                ForEach(rows, id: \.username) { customer in
                    NavigationLink(value: BankRoute.customerForm(customer.username)) {
                        Text("\(customer.displayName) · \(customer.username)")
                    }
                    .buttonStyle(LebyyPrimaryButton())
                    .accessibilityIdentifier("test-Customer-\(customer.username)")
                }
                if !store.bank.lastResult.isEmpty {
                    Text(store.bank.lastResult)
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-BankResult")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Customers")
        .accessibilityIdentifier("test-BankCustomersScreen")
    }
}

struct CustomerFormView: View {
    @EnvironmentObject private var store: AppStore
    let editingUsername: String?
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var balance = ""
    @State private var loaded = false

    var body: some View {
        let editing = editingUsername.flatMap { store.bank.customer($0) } ?? store.bank.customer(username)
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let editing {
                    Color.clear.frame(width: 1, height: 1)
                        .accessibilityIdentifier("test-BankCustomerLookupScreen")
                    ForEach(editing.accounts, id: \.id) { account in
                        Text("\(account.name) \(account.masked) · \(store.bank.money(account.balance))")
                            .foregroundStyle(LebyyTheme.text)
                            .accessibilityIdentifier("test-Lookup-\(account.name)")
                    }
                    Text("Recent activity")
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-LookupActivityTitle")
                    ForEach(Array(editing.activity.prefix(5))) { txn in
                        Text(txn.label(money: store.bank.money))
                            .foregroundStyle(LebyyTheme.text)
                            .accessibilityIdentifier("test-Lookup-\(txn.id)")
                    }
                }
                BankField(title: "Display name", text: $name, identifier: "test-CustomerName")
                BankField(title: "Username", text: $username, identifier: "test-CustomerUsername")
                BankField(title: "Password", text: $password, identifier: "test-CustomerPassword")
                BankField(title: "Checking balance", text: $balance, identifier: "test-CustomerBalance")
                Button("Save customer") {
                    _ = store.bank.saveCustomer(
                        editingUsername: editing?.username ?? editingUsername,
                        displayName: name,
                        username: username,
                        password: password,
                        balanceText: balance
                    )
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-CustomerSave")
                if editing != nil {
                    Button("Delete customer") {
                        _ = store.bank.deleteCustomer(username: editing?.username ?? username)
                    }
                    .buttonStyle(LebyyMutedButton())
                    .accessibilityIdentifier("test-CustomerDelete")
                }
                if !store.bank.lastResult.isEmpty {
                    Text(store.bank.lastResult)
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-BankResult")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle(editingUsername == nil ? "Create customer" : "Customer")
        .accessibilityIdentifier("test-BankCustomerFormScreen")
        .onAppear {
            guard !loaded, let editing else { return }
            name = editing.displayName
            username = editing.username
            balance = String(format: "%.2f", editing.accounts.first { $0.id == "checking" }?.balance ?? 0)
            loaded = true
        }
    }
}

struct DecisionsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        let rows = store.bank.decisions
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Decisions: \(rows.count)")
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-DecisionCount")
                ForEach(rows) { decision in
                    Text(decision.label())
                        .foregroundStyle(LebyyTheme.text)
                        .accessibilityIdentifier("test-Decision-\(decision.id)")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle("Decision history")
        .accessibilityIdentifier("test-BankDecisionsScreen")
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

@ViewBuilder
private func bankLink(_ title: String, _ identifier: String, _ route: BankRoute) -> some View {
    NavigationLink(value: route) {
        Text(title)
            .font(.headline)
    }
    .buttonStyle(LebyyPrimaryButton())
    .accessibilityIdentifier(identifier)
}
