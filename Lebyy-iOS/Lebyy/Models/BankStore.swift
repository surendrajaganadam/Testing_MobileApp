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
    var closeBankFlow = false

    private var txnSeq = 1001
    private var decisionSeq = 1
    private var payeeSeq = 1

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
        if user == Self.managerUser && password == Self.managerPass { return "manager" }
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
                BankAccount(id: "checking", name: "Checking", number: "10010001", balance: checkingBalance),
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
            card: BankCard(network: "Visa", last4: builtIn ? "4242" : "1111", frozen: false, limit: 20_000),
            activity: []
        )
    }

    private func seed() {
        let demo = makeCustomer(username: "demo_user", password: "demo_pass", displayName: "Demo User", checkingBalance: 50_000, builtIn: true)
        demo.activity = [
            BankTxn(id: "TX-9001", title: "Transfer to Landlord", amount: 15_000, kind: "Debit", status: "Pending"),
            BankTxn(id: "TX-8001", title: "Salary", amount: 20_000, kind: "Credit", status: "Completed"),
            BankTxn(id: "TX-8002", title: "Coffee", amount: 120, kind: "Debit", status: "Completed"),
        ]
        customers = [demo]
        pending = [
            PendingTransfer(
                id: "TX-9001",
                customerUsername: "demo_user",
                fromAccountId: "checking",
                payeeName: "Landlord",
                amount: 15_000,
                status: "Pending"
            ),
        ]
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

    init(network: String, last4: String, frozen: Bool, limit: Double) {
        self.network = network
        self.last4 = last4
        self.frozen = frozen
        self.limit = limit
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
