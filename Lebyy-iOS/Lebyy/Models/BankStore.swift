import Foundation
import Combine

/// In-memory practice bank. Customers survive logout so a manager-created
/// customer can sign in during the same app session.
final class BankStore: ObservableObject {
    static let managerUser = "manager_user"
    static let managerPass = "manager_pass"
    static let managerName = "Branch Manager"
    static let approvalLimit = 10_000.0
    static let otpSuccess = "1234"

    @Published var role: String?
    @Published var sessionUsername = ""
    @Published var customers: [BankCustomer] = []
    @Published var pending: [PendingTransfer] = []
    @Published var decisions: [BankDecision] = []
    @Published var lastReceipt = ""
    @Published var lastResult = ""
    var draftFromAccountId = ""
    var draftPayeeName = ""
    var draftAmount = 0.0
    var draftAmountText = ""
    var draftBillId = ""

    /// BofA-style Pay Bills / account Transfer drafts
    var payFromAccountId = "checking"
    var payAmountMode = "other" // balance | other
    var payAmount = 0.0
    var payAmountText = ""
    var payRecurring = false
    var payNote = ""
    var payDateLabel = "Today"
    var payDateDetail = ""
    var lastConfirmation = ""

    var acctFromId = ""
    var acctToId = ""
    var acctAmount = 0.0
    var acctAmountText = ""
    var acctDateLabel = "Today"
    var acctDateDetail = ""

    @Published var payTransferHistory: [PayTransferHistoryItem] = []
    @Published var billPayees: [BillPayee] = []

    // Add Payee draft
    var bpFirstName = ""
    var bpLastName = ""
    var bpNickname = ""
    var bpIdentifying = ""
    var bpAddress = ""
    var bpAddress2 = ""
    var bpCity = ""
    var bpState = ""
    var bpZip = ""
    var bpPhone = ""
    var bpTermsScrolledToEnd = false
    var bpSelectedPayeeId = ""
    var bpPayAmountText = ""
    var bpFrequency = "One Time"
    var bpDeliverBy = ""
    var bpMemoOn = false
    var bpMemo = ""
    /// Set true after Add Payee success DONE — Recipients/Bill Pay home opens the payee list.
    @Published var showBillPayListAfterAdd = false
    /// Set true to dismiss Bill Pay payment success and return to the payee list.
    @Published var closeBillPayPayment = false
    /// Set true to pop the whole bank NavigationStack back to the dashboard (Zelle / Deposit / Transfer DONE).
    @Published var closeBankFlow = false

    // Deposit Checks draft
    var depositAccountId = ""
    var depositAmountText = ""
    var depositFrontSource = ""
    var depositBackSource = ""
    var depositFrontReady = false
    var depositBackReady = false

    // Zelle
    @Published var zelleRecipients: [ZelleRecipient] = []
    var zelleShowAddedBanner = false
    var zelleWhoType = "Person" // Person | Business
    var zelleAddMethod = "Mobile number or email"
    var zelleContact = ""
    var zelleFirstName = ""
    var zelleLastName = ""
    var zelleNickname = ""
    var zelleAuthChannel = "Text message"
    var zelleAuthCode = ""
    var zelleSelectedRecipientId = ""
    var zelleFromAccountId = "checking"
    var zelleAmountText = ""
    var zelleMessage = ""
    var zelleDailyLimitLeft = 500.0

    private var txnSeq = 1001
    private var zelleSeq = 1
    private var decisionSeq = 1
    private var payeeSeq = 1
    private var confirmSeq = 1
    private var billPayeeSeq = 1

    init() {
        seed()
    }

    func money(_ amount: Double) -> String { String(format: "₹%.2f", amount) }

    var isManager: Bool { role == "manager" }
    var isCustomer: Bool { role == "customer" }

    func currentCustomer() -> BankCustomer? {
        customers.first { $0.username == sessionUsername }
    }

    func customer(_ username: String) -> BankCustomer? {
        customers.first { $0.username == username }
    }

    func pendingTransfers() -> [PendingTransfer] {
        pending.filter { $0.status == "Pending" }
    }

    func authenticate(username: String, password: String) -> String? {
        let user = username.trimmingCharacters(in: .whitespaces)
        if customers.contains(where: { $0.username == user && $0.password == password }) { return "customer" }
        return nil
    }

    func startSession(username: String, newRole: String) {
        role = newRole
        sessionUsername = username.trimmingCharacters(in: .whitespaces)
        lastResult = ""
        lastReceipt = ""
    }

    func endSession() {
        role = nil
        sessionUsername = ""
    }

    func sessionDisplayName() -> String {
        if role == "manager" { return Self.managerName }
        return currentCustomer()?.displayName ?? "Demo User"
    }

    func filteredCustomers(query: String) -> [BankCustomer] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty { return customers }
        return customers.filter {
            $0.displayName.lowercased().contains(q) || $0.username.lowercased().contains(q)
        }
    }

    func filteredActivity(customer: BankCustomer, query: String, filter: String) -> [BankTxn] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return customer.activity.filter { txn in
            let kindOk: Bool
            switch filter {
            case "Credit": kindOk = txn.kind == "Credit"
            case "Debit": kindOk = txn.kind == "Debit"
            case "Pending": kindOk = txn.status == "Pending"
            default: kindOk = true
            }
            let textOk = q.isEmpty || txn.title.lowercased().contains(q) || txn.id.lowercased().contains(q)
            return kindOk && textOk
        }
    }

    func beginTransfer(fromAccountId: String, payeeName: String, amountText: String) -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        if payeeName.trimmingCharacters(in: .whitespaces).isEmpty { return "Result: Select a payee" }
        guard let amount = Double(amountText.trimmingCharacters(in: .whitespaces)), amount > 0 else {
            return "Result: Amount is required"
        }
        guard let account = customer.accounts.first(where: { $0.id == fromAccountId }) else {
            return "Result: Select an account"
        }
        if amount > account.balance { return "Result: Insufficient funds" }
        draftFromAccountId = fromAccountId
        draftPayeeName = payeeName
        draftAmount = amount
        lastResult = ""
        return ""
    }

    func confirmTransferNeedsOtp() -> Bool { draftAmount <= Self.approvalLimit }

    func queueLargeTransfer() -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        let id = nextTxnId()
        objectWillChange.send()
        pending.insert(
            PendingTransfer(
                id: id,
                customerUsername: customer.username,
                fromAccountId: draftFromAccountId,
                payeeName: draftPayeeName,
                amount: draftAmount,
                status: "Pending"
            ),
            at: 0
        )
        customer.activity.insert(
            BankTxn(id: id, title: "Transfer to \(draftPayeeName)", amount: draftAmount, kind: "Debit", status: "Pending"),
            at: 0
        )
        lastReceipt = "Receipt: Pending approval \(id)"
        lastResult = lastReceipt
        return lastReceipt
    }

    func completeTransferWithOtp(code: String) -> String {
        if code != Self.otpSuccess {
            lastResult = "Result: OTP wrong"
            return lastResult
        }
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        guard let account = customer.accounts.first(where: { $0.id == draftFromAccountId }) else {
            return "Result: Select an account"
        }
        if draftAmount > account.balance {
            lastResult = "Result: Insufficient funds"
            return lastResult
        }
        objectWillChange.send()
        account.balance = roundMoney(account.balance - draftAmount)
        let id = nextTxnId()
        customer.activity.insert(
            BankTxn(id: id, title: "Transfer to \(draftPayeeName)", amount: draftAmount, kind: "Debit", status: "Completed"),
            at: 0
        )
        lastReceipt = "Receipt: Transfer completed \(id)"
        lastResult = lastReceipt
        return lastReceipt
    }

    func beginBill(billId: String) -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        guard let bill = customer.bills.first(where: { $0.id == billId }) else { return "Result: Select a bill" }
        guard let checking = customer.accounts.first(where: { $0.id == "checking" }) else {
            return "Result: Select an account"
        }
        if bill.amountDue > checking.balance { return "Result: Insufficient funds" }
        draftBillId = billId
        lastResult = ""
        return ""
    }

    func payBill() -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        guard let bill = customer.bills.first(where: { $0.id == draftBillId }) else { return "Result: Select a bill" }
        guard let checking = customer.accounts.first(where: { $0.id == "checking" }) else {
            return "Result: Select an account"
        }
        if bill.amountDue > checking.balance {
            lastResult = "Result: Insufficient funds"
            return lastResult
        }
        objectWillChange.send()
        checking.balance = roundMoney(checking.balance - bill.amountDue)
        let id = nextTxnId()
        customer.activity.insert(BankTxn(id: id, title: "Bill \(bill.name)", amount: bill.amountDue, kind: "Debit", status: "Completed"), at: 0)
        lastReceipt = "Receipt: Bill paid \(id)"
        lastResult = lastReceipt
        return lastReceipt
    }

    func addPayee(name: String, accountNumber: String) -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        let cleanName = name.trimmingCharacters(in: .whitespaces)
        let cleanAccount = accountNumber.trimmingCharacters(in: .whitespaces)
        if cleanName.isEmpty { return "Result: Name is required" }
        if cleanAccount.isEmpty { return "Result: Account number is required" }
        if customer.payees.contains(where: { $0.accountNumber == cleanAccount }) {
            return "Result: Payee already exists"
        }
        objectWillChange.send()
        customer.payees.append(Payee(id: "payee-\(payeeSeq)", name: cleanName, accountNumber: cleanAccount))
        payeeSeq += 1
        lastResult = "Result: Payee saved"
        return lastResult
    }

    func setCardFrozen(_ frozen: Bool) -> String {
        guard let card = currentCustomer()?.card else { return "Result: Not signed in" }
        objectWillChange.send()
        card.frozen = frozen
        lastResult = frozen ? "Result: Card frozen" : "Result: Card active"
        return lastResult
    }

    func saveCardLimit(limitText: String) -> String {
        guard let card = currentCustomer()?.card else { return "Result: Not signed in" }
        guard let limit = Double(limitText.trimmingCharacters(in: .whitespaces)), limit > 0 else {
            lastResult = "Result: Limit is required"
            return lastResult
        }
        objectWillChange.send()
        card.limit = limit
        lastResult = "Result: Limit saved"
        return lastResult
    }

    func approve(transferId: String) -> String {
        guard let item = pending.first(where: { $0.id == transferId && $0.status == "Pending" }) else {
            return "Result: Request not found"
        }
        guard let customer = customer(item.customerUsername) else { return "Result: Customer not found" }
        guard let account = customer.accounts.first(where: { $0.id == item.fromAccountId }) else {
            return "Result: Select an account"
        }
        if item.amount > account.balance { return "Result: Insufficient funds" }
        objectWillChange.send()
        account.balance = roundMoney(account.balance - item.amount)
        item.status = "Approved"
        customer.activity.first { $0.id == item.id }?.status = "Completed"
        decisions.insert(BankDecision(id: "D-\(decisionSeq)", transferId: item.id, action: "Approved", managerName: Self.managerName, reason: ""), at: 0)
        decisionSeq += 1
        lastResult = "Result: Approved"
        return lastResult
    }

    func reject(transferId: String, reason: String) -> String {
        let clean = reason.trimmingCharacters(in: .whitespaces)
        if clean.isEmpty {
            lastResult = "Result: Reason is required"
            return lastResult
        }
        guard let item = pending.first(where: { $0.id == transferId && $0.status == "Pending" }) else {
            return "Result: Request not found"
        }
        objectWillChange.send()
        item.status = "Rejected"
        item.rejectReason = clean
        customer(item.customerUsername)?.activity.first { $0.id == item.id }?.status = "Rejected"
        decisions.insert(BankDecision(id: "D-\(decisionSeq)", transferId: item.id, action: "Rejected", managerName: Self.managerName, reason: clean), at: 0)
        decisionSeq += 1
        lastResult = "Result: Rejected"
        return lastResult
    }

    func saveCustomer(editingUsername: String?, displayName: String, username: String, password: String, balanceText: String) -> String {
        let name = displayName.trimmingCharacters(in: .whitespaces)
        let user = username.trimmingCharacters(in: .whitespaces)
        if name.isEmpty { return shown("Result: Name is required") }
        if user.isEmpty { return shown("Result: Username is required") }
        if user == Self.managerUser { return shown("Result: Username already exists") }
        guard let balance = Double(balanceText.trimmingCharacters(in: .whitespaces)), balance >= 0 else {
            return shown("Result: Balance is required")
        }
        objectWillChange.send()
        if editingUsername == nil {
            if password.isEmpty { return shown("Result: Password is required") }
            if customers.contains(where: { $0.username == user }) { return shown("Result: Username already exists") }
            customers.append(makeCustomer(username: user, password: password, displayName: name, checkingBalance: balance, builtIn: false))
            lastResult = "Result: Customer created"
            return lastResult
        }
        guard let existing = customer(editingUsername!) else { return "Result: Customer not found" }
        if user != existing.username && customers.contains(where: { $0.username == user }) {
            return shown("Result: Username already exists")
        }
        existing.displayName = name
        existing.username = user
        if !password.isEmpty { existing.password = password }
        existing.accounts.first { $0.id == "checking" }?.balance = balance
        if sessionUsername == editingUsername { sessionUsername = user }
        lastResult = "Result: Customer updated"
        return lastResult
    }

    func deleteCustomer(username: String) -> String {
        guard let existing = customer(username) else { return "Result: Customer not found" }
        if existing.builtIn { return shown("Result: Built-in customer cannot be deleted") }
        objectWillChange.send()
        customers.removeAll { $0.username == username }
        pending.removeAll { $0.customerUsername == username && $0.status == "Pending" }
        lastResult = "Result: Customer deleted"
        return lastResult
    }

    @discardableResult
    private func shown(_ message: String) -> String {
        lastResult = message
        return message
    }

    private func nextTxnId() -> String {
        let id = "TX-\(txnSeq)"
        txnSeq += 1
        return id
    }

    private func roundMoney(_ value: Double) -> Double { (value * 100).rounded() / 100 }

    private func makeCustomer(username: String, password: String, displayName: String, checkingBalance: Double, builtIn: Bool) -> BankCustomer {
        BankCustomer(
            username: username,
            password: password,
            displayName: displayName,
            builtIn: builtIn,
            accounts: [
                BankAccount(
                    id: "checking",
                    name: builtIn ? "Adv SafeBalance Banking" : "Checking",
                    number: builtIn ? "10001362" : "10010001",
                    balance: checkingBalance
                ),
                BankAccount(id: "savings", name: "Savings", number: "10010002", balance: builtIn ? 12_000 : 0),
            ],
            payees: [
                Payee(id: "payee-landlord", name: "Landlord", accountNumber: "445566"),
                Payee(id: "payee-alex", name: "Alex", accountNumber: "778899"),
            ],
            bills: [
                Bill(id: "electricity", name: "Electricity", amountDue: 850),
                Bill(id: "mobile", name: "Mobile", amountDue: 499),
            ],
            card: BankCard(network: "Visa", last4: builtIn ? "4242" : "1111", frozen: false, limit: 20_000, balance: builtIn ? 7_751.46 : 0),
            activity: []
        )
    }

    private func seed() {
        let demo = makeCustomer(username: "demo_user", password: "demo_pass", displayName: "Demo User", checkingBalance: 50_000, builtIn: true)
        demo.activity = [
            BankTxn(id: "TX-8001", title: "Salary", amount: 20_000, kind: "Credit", status: "Completed"),
            BankTxn(id: "TX-8002", title: "Coffee", amount: 120, kind: "Debit", status: "Completed"),
        ]
        customers = [demo]
        pending = []
        payTransferHistory = [
            PayTransferHistoryItem(
                id: "H-1",
                title: "Sujathapersonal NJ",
                subtitle: "Kavya amount",
                date: "Sep 28, 2026",
                amount: 500,
                status: "You paid"
            ),
        ]
        billPayees = [
            BillPayee(
                id: "bp-boa",
                name: "BankAmericard Platinum Plus Mastercard - 4683",
                nickname: "",
                kind: "company",
                section: "Bank of America"
            ),
            BillPayee(id: "bp-amex", name: "American Express - 1005", nickname: "muraliamaxco", kind: "company", section: "Other payees"),
            BillPayee(id: "bp-chase", name: "Chase Credit Cards - 5059", nickname: "amazoncreditcard", kind: "company", section: "Other payees"),
            BillPayee(id: "bp-citi", name: "Citi Cards - 3318", nickname: "kittucitibankcreditcard", kind: "company", section: "Other payees"),
            BillPayee(id: "bp-macys", name: "Macy's - 8770", nickname: "muralimacy", kind: "company", section: "Other payees"),
        ]
        zelleRecipients = [
            ZelleRecipient(id: "z-1", firstName: "Sujatha", lastName: "personal NJ", contact: "201-280-2017", enrolled: true),
            ZelleRecipient(id: "z-2", firstName: "Kushal", lastName: "US Number", contact: "rajpuduru@gmail.com", enrolled: true),
            ZelleRecipient(id: "z-3", firstName: "keerthi", lastName: "yerragudi", contact: "gourilabalaji@gmail.com", enrolled: true),
        ]
        zelleSeq = 4
        refreshPayDates()
        bpDeliverBy = defaultDeliverBy()
    }

    func refreshPayDates() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d, yyyy"
        let detail = formatter.string(from: Date())
        payDateLabel = "Today"
        payDateDetail = detail
        acctDateLabel = "Today"
        acctDateDetail = detail
    }

    func resetPayDraft() {
        payFromAccountId = "checking"
        payAmountMode = "other"
        payAmount = 0
        payAmountText = ""
        payRecurring = false
        payNote = ""
        lastResult = ""
        refreshPayDates()
    }

    func resetAcctTransferDraft() {
        acctFromId = ""
        acctToId = ""
        acctAmount = 0
        acctAmountText = ""
        lastResult = ""
        refreshPayDates()
    }

    func cardTitle() -> String {
        guard let card = currentCustomer()?.card else { return "Visa" }
        return "Lebyy \(card.network) - \(card.last4)"
    }

    func accountTitle(_ id: String) -> String {
        guard let account = currentCustomer()?.accounts.first(where: { $0.id == id }) else { return "" }
        return "\(account.name) - \(String(account.number.suffix(4)))"
    }

    func savePayAmount(mode: String, otherText: String) -> String {
        payAmountMode = mode
        if mode == "balance" {
            payAmount = currentCustomer()?.card.balance ?? 0
            payAmountText = String(format: "%.2f", payAmount)
            lastResult = "Result: Amount saved"
            return lastResult
        }
        guard let amount = Double(otherText.trimmingCharacters(in: .whitespaces)), amount > 0 else {
            lastResult = "Result: Amount is required"
            return lastResult
        }
        payAmount = amount
        payAmountText = String(format: "%.2f", amount)
        lastResult = "Result: Amount saved"
        return lastResult
    }

    func payAmountDisplay() -> String {
        if payAmount <= 0 { return "" }
        if payAmountMode == "balance" {
            return "Current balance - \(money(payAmount))"
        }
        return "Other amount - \(money(payAmount))"
    }

    func validatePayForm() -> String {
        guard currentCustomer() != nil else { return "Result: Not signed in" }
        if payFromAccountId.isEmpty { return "Result: Select From account" }
        if payAmount <= 0 { return "Result: Choose amount" }
        return ""
    }

    func confirmCardPayment() -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        guard let from = customer.accounts.first(where: { $0.id == payFromAccountId }) else {
            return "Result: Select From account"
        }
        if payAmount <= 0 { return "Result: Choose amount" }
        if payAmount > from.balance { return "Result: Insufficient funds" }
        objectWillChange.send()
        from.balance = roundMoney(from.balance - payAmount)
        customer.card.balance = max(0, roundMoney(customer.card.balance - payAmount))
        let id = nextTxnId()
        let conf = nextConfirmation()
        lastConfirmation = conf
        customer.activity.insert(
            BankTxn(id: id, title: "Card payment \(customer.card.network)", amount: payAmount, kind: "Debit", status: "Completed"),
            at: 0
        )
        payTransferHistory.insert(
            PayTransferHistoryItem(
                id: conf,
                title: cardTitle(),
                subtitle: payNote.isEmpty ? "Card payment" : payNote,
                date: payDateDetail,
                amount: payAmount,
                status: "You paid"
            ),
            at: 0
        )
        lastReceipt = "Receipt: Payment confirmed \(conf)"
        lastResult = lastReceipt
        return lastReceipt
    }

    func validateAcctTransfer() -> String {
        if acctFromId.isEmpty || acctToId.isEmpty { return "Result: Choose account" }
        if acctFromId == acctToId { return "Result: Accounts must differ" }
        guard let amount = Double(acctAmountText.trimmingCharacters(in: .whitespaces)), amount > 0 else {
            return "Result: Enter amount"
        }
        acctAmount = amount
        return ""
    }

    func confirmAcctTransfer() -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        let message = validateAcctTransfer()
        if !message.isEmpty { return message }
        guard let from = customer.accounts.first(where: { $0.id == acctFromId }),
              let to = customer.accounts.first(where: { $0.id == acctToId }) else {
            return "Result: Choose account"
        }
        if acctAmount > from.balance { return "Result: Insufficient funds" }
        objectWillChange.send()
        from.balance = roundMoney(from.balance - acctAmount)
        to.balance = roundMoney(to.balance + acctAmount)
        let id = nextTxnId()
        let conf = nextConfirmation()
        lastConfirmation = conf
        customer.activity.insert(
            BankTxn(id: id, title: "Transfer to \(to.name)", amount: acctAmount, kind: "Debit", status: "Completed"),
            at: 0
        )
        payTransferHistory.insert(
            PayTransferHistoryItem(
                id: conf,
                title: "\(from.name) → \(to.name)",
                subtitle: "Between my accounts",
                date: acctDateDetail,
                amount: acctAmount,
                status: "You transferred"
            ),
            at: 0
        )
        lastReceipt = "Receipt: Transfer confirmed \(conf)"
        lastResult = lastReceipt
        return lastReceipt
    }

    private func nextConfirmation() -> String {
        let value = String(format: "z%07x", confirmSeq)
        confirmSeq += 1
        return value
    }

    static let usStateEntries: [(name: String, code: String)] = [
        ("Alabama", "AL"), ("Alaska", "AK"), ("Arizona", "AZ"), ("Arkansas", "AR"), ("California", "CA"),
        ("Colorado", "CO"), ("Connecticut", "CT"), ("Delaware", "DE"), ("Florida", "FL"), ("Georgia", "GA"),
        ("Hawaii", "HI"), ("Idaho", "ID"), ("Illinois", "IL"), ("Indiana", "IN"), ("Iowa", "IA"),
        ("Kansas", "KS"), ("Kentucky", "KY"), ("Louisiana", "LA"), ("Maine", "ME"), ("Maryland", "MD"),
        ("Massachusetts", "MA"), ("Michigan", "MI"), ("Minnesota", "MN"), ("Mississippi", "MS"),
        ("Missouri", "MO"), ("Montana", "MT"), ("Nebraska", "NE"), ("Nevada", "NV"), ("New Hampshire", "NH"),
        ("New Jersey", "NJ"), ("New Mexico", "NM"), ("New York", "NY"), ("North Carolina", "NC"),
        ("North Dakota", "ND"), ("Ohio", "OH"), ("Oklahoma", "OK"), ("Oregon", "OR"), ("Pennsylvania", "PA"),
        ("Rhode Island", "RI"), ("South Carolina", "SC"), ("South Dakota", "SD"), ("Tennessee", "TN"),
        ("Texas", "TX"), ("Utah", "UT"), ("Vermont", "VT"), ("Virginia", "VA"), ("Washington", "WA"),
        ("West Virginia", "WV"), ("Wisconsin", "WI"), ("Wyoming", "WY"), ("District of Columbia", "DC"),
    ]

    static var usStates: [String] { usStateEntries.map(\.name) }

    static let countries: [String] = [
        "United States", "Canada", "United Kingdom", "India", "Australia", "Germany", "France", "Japan",
        "Mexico", "Brazil", "China", "Singapore", "United Arab Emirates", "South Africa", "Italy", "Spain",
        "Netherlands", "Sweden", "Switzerland", "New Zealand", "Ireland", "Philippines", "Pakistan",
        "Bangladesh", "Nigeria", "Kenya", "Egypt", "Argentina", "Chile", "Colombia", "South Korea",
        "Indonesia", "Malaysia", "Thailand", "Vietnam", "Poland", "Portugal", "Greece", "Turkey",
        "Saudi Arabia", "Israel", "Norway", "Denmark", "Finland", "Austria", "Belgium", "Czech Republic",
        "Hungary", "Romania", "Ukraine",
    ]

    static func stateCode(for name: String) -> String {
        usStateEntries.first { $0.name == name }?.code ?? name
    }

    static func stateName(for codeOrName: String) -> String {
        if let byCode = usStateEntries.first(where: { $0.code == codeOrName })?.name { return byCode }
        return codeOrName
    }

    static let frequencies = [
        "One Time", "Weekly", "Every 2 Weeks", "Every 4 Weeks", "Twice a Month", "Monthly",
    ]

    func resetBillPayeeDraft() {
        bpFirstName = ""
        bpLastName = ""
        bpNickname = ""
        bpIdentifying = ""
        bpAddress = ""
        bpAddress2 = ""
        bpCity = ""
        bpState = ""
        bpZip = ""
        bpPhone = ""
        bpTermsScrolledToEnd = false
        lastResult = ""
    }

    func resetBillPaymentDraft() {
        bpPayAmountText = ""
        bpFrequency = "One Time"
        bpDeliverBy = defaultDeliverBy()
        bpMemoOn = false
        bpMemo = ""
        lastResult = ""
    }

    func defaultDeliverBy() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM d"
        return formatter.string(from: Calendar.current.date(byAdding: .day, value: 8, to: Date()) ?? Date())
    }

    func validateBillPayeeStep2() -> String {
        if bpFirstName.trimmingCharacters(in: .whitespaces).isEmpty { return "Result: First name is required" }
        if bpLastName.trimmingCharacters(in: .whitespaces).isEmpty { return "Result: Last name is required" }
        if bpAddress.trimmingCharacters(in: .whitespaces).isEmpty { return "Result: Address is required" }
        if bpCity.trimmingCharacters(in: .whitespaces).isEmpty { return "Result: City is required" }
        return ""
    }

    func validateBillPayeeStep3() -> String {
        if bpState.isEmpty { return "Result: State is required" }
        if bpZip.trimmingCharacters(in: .whitespaces).isEmpty { return "Result: ZIP Code is required" }
        if bpPhone.trimmingCharacters(in: .whitespaces).isEmpty { return "Result: Phone Number is required" }
        if !bpTermsScrolledToEnd { return "Result: Scroll terms to the end" }
        return ""
    }

    /// Field-keyed errors for red highlights (empty = valid).
    func billPayeeFieldErrors() -> [String: String] {
        var errors: [String: String] = [:]
        if bpFirstName.trimmingCharacters(in: .whitespaces).isEmpty { errors["firstName"] = "First name is required" }
        if bpLastName.trimmingCharacters(in: .whitespaces).isEmpty { errors["lastName"] = "Last name is required" }
        if bpAddress.trimmingCharacters(in: .whitespaces).isEmpty { errors["address"] = "Address is required" }
        if bpCity.trimmingCharacters(in: .whitespaces).isEmpty { errors["city"] = "City is required" }
        if bpState.isEmpty { errors["state"] = "State is required" }
        if bpZip.trimmingCharacters(in: .whitespaces).isEmpty { errors["zip"] = "ZIP Code is required" }
        if bpPhone.trimmingCharacters(in: .whitespaces).isEmpty { errors["phone"] = "Phone Number is required" }
        if !bpTermsScrolledToEnd { errors["terms"] = "Scroll the page to the end of Terms & Conditions" }
        return errors
    }

    func saveBillPayee() -> String {
        let fieldErrors = billPayeeFieldErrors()
        if !fieldErrors.isEmpty {
            let first = fieldErrors.values.first ?? "Fix required fields"
            lastResult = "Result: \(first)"
            return lastResult
        }
        let full = "\(bpFirstName.trimmingCharacters(in: .whitespaces)) \(bpLastName.trimmingCharacters(in: .whitespaces))"
        let id = "bp-\(billPayeeSeq)"
        billPayeeSeq += 1
        objectWillChange.send()
        billPayees.append(
            BillPayee(
                id: id,
                name: full,
                nickname: bpNickname,
                kind: "person",
                section: "Other payees",
                address: bpAddress,
                city: bpCity,
                state: bpState,
                zip: bpZip,
                phone: bpPhone
            )
        )
        bpSelectedPayeeId = id
        lastResult = "Result: Payee added"
        return lastResult
    }

    func selectedBillPayee() -> BillPayee? {
        billPayees.first { $0.id == bpSelectedPayeeId }
    }

    func requestOpenBillPayList() {
        showBillPayListAfterAdd = true
        objectWillChange.send()
        NotificationCenter.default.post(name: .lebyyOpenBillPayList, object: nil)
    }

    func requestCloseBillPayPayment() {
        closeBillPayPayment = true
        objectWillChange.send()
    }

    func requestCloseBankFlow() {
        closeBankFlow = true
        objectWillChange.send()
    }

    func resetDepositDraft() {
        depositAccountId = ""
        depositAmountText = ""
        depositFrontSource = ""
        depositBackSource = ""
        depositFrontReady = false
        depositBackReady = false
        lastResult = ""
    }

    func validateDeposit() -> String {
        if !depositFrontReady { return "Result: Capture front of check" }
        if !depositBackReady { return "Result: Capture back of check" }
        if depositAccountId.isEmpty { return "Result: Select account" }
        guard let amount = Double(depositAmountText.trimmingCharacters(in: .whitespaces)), amount > 0 else {
            return "Result: Enter amount"
        }
        return ""
    }

    /// Practice apps accept any 6-digit code (not a fixed OTP).
    static let zelleOtpSuccess = "any 6-digit code"

    func resetZelleAddDraft() {
        zelleWhoType = "Person"
        zelleAddMethod = "Mobile number or email"
        zelleContact = ""
        zelleFirstName = ""
        zelleLastName = ""
        zelleNickname = ""
        zelleAuthChannel = "Text message"
        zelleAuthCode = ""
        lastResult = ""
    }

    func resetZellePayDraft() {
        zelleFromAccountId = "checking"
        zelleAmountText = ""
        zelleMessage = ""
        lastResult = ""
    }

    func validateZelleRecipientInfo() -> String {
        if zelleContact.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Result: Mobile number or email is required"
        }
        if zelleFirstName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Result: First name is required"
        }
        if zelleLastName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Result: Last name is required"
        }
        return ""
    }

    func submitZelleAuthCode(_ code: String) -> String {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard trimmed.count == 6, trimmed.allSatisfy(\.isNumber) else {
            lastResult = "Result: Enter a 6-digit authorization code"
            return lastResult
        }
        let id = "z-\(zelleSeq)"
        zelleSeq += 1
        objectWillChange.send()
        // Practice app: newly added recipients are enrolled so send-payment works immediately.
        let recipient = ZelleRecipient(
            id: id,
            firstName: zelleFirstName.trimmingCharacters(in: .whitespaces),
            lastName: zelleLastName.trimmingCharacters(in: .whitespaces),
            contact: zelleContact.trimmingCharacters(in: .whitespaces),
            nickname: zelleNickname,
            enrolled: true
        )
        zelleRecipients.insert(recipient, at: 0)
        zelleSelectedRecipientId = id
        zelleShowAddedBanner = true
        lastResult = "Result: Recipient added"
        return lastResult
    }

    func requestOpenZellePayList() {
        NotificationCenter.default.post(name: .lebyyOpenZellePayList, object: nil)
    }

    func selectedZelleRecipient() -> ZelleRecipient? {
        zelleRecipients.first { $0.id == zelleSelectedRecipientId }
    }

    func confirmZellePayment() -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        guard let recipient = selectedZelleRecipient() else { return "Result: Select recipient" }
        guard let amount = Double(zelleAmountText.trimmingCharacters(in: .whitespaces)), amount > 0 else {
            return "Result: Enter amount"
        }
        if amount > zelleDailyLimitLeft { return "Result: Exceeds daily limit" }
        guard let from = customer.accounts.first(where: { $0.id == zelleFromAccountId }) else {
            return "Result: Select From account"
        }
        if amount > from.balance { return "Result: Insufficient funds" }
        objectWillChange.send()
        from.balance = roundMoney(from.balance - amount)
        zelleDailyLimitLeft = roundMoney(zelleDailyLimitLeft - amount)
        let conf = nextConfirmation()
        lastConfirmation = conf
        let id = nextTxnId()
        customer.activity.insert(
            BankTxn(id: id, title: "Zelle \(recipient.displayName)", amount: amount, kind: "Debit", status: "Completed"),
            at: 0
        )
        payTransferHistory.insert(
            PayTransferHistoryItem(
                id: conf,
                title: recipient.displayName,
                subtitle: recipient.contact,
                date: "Today",
                amount: amount,
                status: "You paid"
            ),
            at: 0
        )
        zelleShowAddedBanner = false
        lastReceipt = "Receipt: Zelle payment \(conf)"
        lastResult = lastReceipt
        return lastReceipt
    }

    func confirmDeposit() -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        let message = validateDeposit()
        if !message.isEmpty {
            lastResult = message
            return message
        }
        guard let amount = Double(depositAmountText.trimmingCharacters(in: .whitespaces)) else {
            return "Result: Enter amount"
        }
        guard let account = customer.accounts.first(where: { $0.id == depositAccountId }) else {
            return "Result: Select account"
        }
        objectWillChange.send()
        account.balance = roundMoney(account.balance + amount)
        let conf = nextConfirmation()
        lastConfirmation = conf
        let id = nextTxnId()
        customer.activity.insert(
            BankTxn(id: id, title: "Mobile check deposit", amount: amount, kind: "Credit", status: "Completed"),
            at: 0
        )
        lastReceipt = "Receipt: Deposit submitted \(conf)"
        lastResult = lastReceipt
        return lastReceipt
    }

    func confirmBillPayment() -> String {
        guard let customer = currentCustomer() else { return "Result: Not signed in" }
        guard let payee = selectedBillPayee() else { return "Result: Select a payee" }
        guard let amount = Double(bpPayAmountText.trimmingCharacters(in: .whitespaces)), amount > 0 else {
            return "Result: Enter amount"
        }
        guard let from = customer.accounts.first(where: { $0.id == "checking" }) else {
            return "Result: Select From account"
        }
        if amount > from.balance { return "Result: Insufficient funds" }
        objectWillChange.send()
        from.balance = roundMoney(from.balance - amount)
        let conf = "Z3PSN-" + String(format: "%05X", confirmSeq)
        confirmSeq += 1
        lastConfirmation = conf
        let id = nextTxnId()
        customer.activity.insert(
            BankTxn(id: id, title: "Bill Pay \(payee.name)", amount: amount, kind: "Debit", status: "Completed"),
            at: 0
        )
        payTransferHistory.insert(
            PayTransferHistoryItem(
                id: conf,
                title: payee.name,
                subtitle: bpFrequency,
                date: bpDeliverBy,
                amount: amount,
                status: "You paid"
            ),
            at: 0
        )
        lastReceipt = "Receipt: Payment scheduled \(conf)"
        lastResult = lastReceipt
        return lastReceipt
    }
}

final class BankCustomer {
    var username: String
    var password: String
    var displayName: String
    let builtIn: Bool
    var accounts: [BankAccount]
    var payees: [Payee]
    var bills: [Bill]
    var card: BankCard
    var activity: [BankTxn]

    init(username: String, password: String, displayName: String, builtIn: Bool, accounts: [BankAccount], payees: [Payee], bills: [Bill], card: BankCard, activity: [BankTxn]) {
        self.username = username
        self.password = password
        self.displayName = displayName
        self.builtIn = builtIn
        self.accounts = accounts
        self.payees = payees
        self.bills = bills
        self.card = card
        self.activity = activity
    }
}

final class BankAccount {
    let id: String
    let name: String
    let number: String
    var balance: Double
    var masked: String { "••" + String(number.suffix(4)) }

    init(id: String, name: String, number: String, balance: Double) {
        self.id = id
        self.name = name
        self.number = number
        self.balance = balance
    }
}

struct Payee: Identifiable {
    let id: String
    let name: String
    let accountNumber: String
}

struct Bill: Identifiable {
    let id: String
    let name: String
    let amountDue: Double
}

final class BankCard {
    let network: String
    let last4: String
    var frozen: Bool
    var limit: Double
    var balance: Double

    init(network: String, last4: String, frozen: Bool, limit: Double, balance: Double = 0) {
        self.network = network
        self.last4 = last4
        self.frozen = frozen
        self.limit = limit
        self.balance = balance
    }
}

struct PayTransferHistoryItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let date: String
    let amount: Double
    let status: String
}

struct BillPayee: Identifiable, Hashable {
    let id: String
    var name: String
    var nickname: String
    var kind: String
    var section: String = "Other payees"
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zip: String = ""
    var phone: String = ""
}

struct ZelleRecipient: Identifiable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var contact: String
    var nickname: String = ""
    var enrolled: Bool = true

    var displayName: String {
        let nick = nickname.trimmingCharacters(in: .whitespaces)
        if !nick.isEmpty { return "\(nick) \(lastName)".trimmingCharacters(in: .whitespaces) }
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var initials: String {
        let a = firstName.first.map(String.init) ?? ""
        let b = lastName.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }
}

final class BankTxn: Identifiable {
    let id: String
    let title: String
    let amount: Double
    let kind: String
    var status: String

    init(id: String, title: String, amount: Double, kind: String, status: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.kind = kind
        self.status = status
    }

    func label(money: (Double) -> String) -> String {
        "\(kind) · \(title) · \(money(amount)) · \(status)"
    }
}

final class PendingTransfer: Identifiable {
    let id: String
    let customerUsername: String
    let fromAccountId: String
    let payeeName: String
    let amount: Double
    var status: String
    var rejectReason: String

    init(id: String, customerUsername: String, fromAccountId: String, payeeName: String, amount: Double, status: String, rejectReason: String = "") {
        self.id = id
        self.customerUsername = customerUsername
        self.fromAccountId = fromAccountId
        self.payeeName = payeeName
        self.amount = amount
        self.status = status
        self.rejectReason = rejectReason
    }

    func label(money: (Double) -> String) -> String {
        "\(id) · \(customerUsername) → \(payeeName) · \(money(amount))"
    }
}

struct BankDecision: Identifiable {
    let id: String
    let transferId: String
    let action: String
    let managerName: String
    let reason: String

    func label() -> String {
        let extra = reason.isEmpty ? "" : " · \(reason)"
        return "\(action) \(transferId) by \(managerName)\(extra)"
    }
}
