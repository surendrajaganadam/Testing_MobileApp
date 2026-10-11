package com.demo.lebyy.data

import java.util.Locale

/**
 * In-memory practice bank. Customers survive logout so a manager-created
 * customer can sign in during the same app session. Data resets when the process dies.
 */
object BankState {
    const val MANAGER_USER = "manager_user"
    const val MANAGER_PASS = "manager_pass"
    const val MANAGER_NAME = "Branch Manager"
    const val APPROVAL_LIMIT = 10_000.0
    const val OTP_SUCCESS = "1234"

    var role: String? = null
    var sessionUsername: String = ""

    private val customers = mutableListOf<BankCustomer>()
    private val pending = mutableListOf<PendingTransfer>()
    private val decisions = mutableListOf<BankDecision>()
    private var txnSeq = 1001
    private var decisionSeq = 1
    private var payeeSeq = 1

    var draftFromAccountId: String = ""
    var draftPayeeName: String = ""
    var draftAmount: Double = 0.0
    var draftAmountText: String = ""
    var draftBillId: String = ""
    var lastReceipt: String = ""
    var lastResult: String = ""
    var closeBankFlow: Boolean = false

    var payFromAccountId: String = "checking"
    var payAmountMode: String = "other"
    var payAmount: Double = 0.0
    var payAmountText: String = ""
    var payRecurring: Boolean = false
    var payNote: String = ""
    var payDateLabel: String = "Today"
    var payDateDetail: String = ""
    var lastConfirmation: String = ""

    var acctFromId: String = ""
    var acctToId: String = ""
    var acctAmount: Double = 0.0
    var acctAmountText: String = ""
    var acctDateLabel: String = "Today"
    var acctDateDetail: String = ""

    private val payTransferHistory = mutableListOf<PayTransferHistoryItem>()
    private var confirmSeq = 1
    private var billPayeeSeq = 1

    private val billPayees = mutableListOf<BillPayee>()
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
    var closeToBillPay = false
    var closeToZellePay = false
    /** When true, leave bank stack and return MainActivity to Home (app tabs). */
    var exitBankToApp = false

    var depositAccountId = ""
    var depositAmountText = ""
    var depositFrontSource = ""
    var depositBackSource = ""
    var depositFrontReady = false
    var depositBackReady = false

    // Zelle
    /** Practice apps accept any 6-digit code (not a fixed OTP). */
    const val ZELLE_OTP_SUCCESS = "any 6-digit code"
    private val zelleRecipients = mutableListOf<ZelleRecipient>()
    private var zelleSeq = 1
    var zelleShowAddedBanner = false
    var zelleWhoType = "Person"
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
    var zelleSearchQuery = ""

    val usStateEntries: List<Pair<String, String>> = listOf(
        "Alabama" to "AL", "Alaska" to "AK", "Arizona" to "AZ", "Arkansas" to "AR", "California" to "CA",
        "Colorado" to "CO", "Connecticut" to "CT", "Delaware" to "DE", "Florida" to "FL", "Georgia" to "GA",
        "Hawaii" to "HI", "Idaho" to "ID", "Illinois" to "IL", "Indiana" to "IN", "Iowa" to "IA",
        "Kansas" to "KS", "Kentucky" to "KY", "Louisiana" to "LA", "Maine" to "ME", "Maryland" to "MD",
        "Massachusetts" to "MA", "Michigan" to "MI", "Minnesota" to "MN", "Mississippi" to "MS",
        "Missouri" to "MO", "Montana" to "MT", "Nebraska" to "NE", "Nevada" to "NV", "New Hampshire" to "NH",
        "New Jersey" to "NJ", "New Mexico" to "NM", "New York" to "NY", "North Carolina" to "NC",
        "North Dakota" to "ND", "Ohio" to "OH", "Oklahoma" to "OK", "Oregon" to "OR", "Pennsylvania" to "PA",
        "Rhode Island" to "RI", "South Carolina" to "SC", "South Dakota" to "SD", "Tennessee" to "TN",
        "Texas" to "TX", "Utah" to "UT", "Vermont" to "VT", "Virginia" to "VA", "Washington" to "WA",
        "West Virginia" to "WV", "Wisconsin" to "WI", "Wyoming" to "WY", "District of Columbia" to "DC",
    )

    val usStates: List<String> get() = usStateEntries.map { it.first }

    val countries: List<String> = listOf(
        "United States", "Canada", "United Kingdom", "India", "Australia", "Germany", "France", "Japan",
        "Mexico", "Brazil", "China", "Singapore", "United Arab Emirates", "South Africa", "Italy", "Spain",
        "Netherlands", "Sweden", "Switzerland", "New Zealand", "Ireland", "Philippines", "Pakistan",
        "Bangladesh", "Nigeria", "Kenya", "Egypt", "Argentina", "Chile", "Colombia", "South Korea",
        "Indonesia", "Malaysia", "Thailand", "Vietnam", "Poland", "Portugal", "Greece", "Turkey",
        "Saudi Arabia", "Israel", "Norway", "Denmark", "Finland", "Austria", "Belgium", "Czech Republic",
        "Hungary", "Romania", "Ukraine",
    )

    val frequencies: List<String> = listOf(
        "One Time", "Weekly", "Every 2 Weeks", "Every 4 Weeks", "Twice a Month", "Monthly",
    )

    init {
        resetPracticeData()
    }

    fun money(amount: Double): String = "₹" + String.format(Locale.US, "%.2f", amount)

    fun isManager(): Boolean = role == "manager"
    fun isCustomer(): Boolean = role == "customer"

    fun currentCustomer(): BankCustomer? =
        customers.firstOrNull { it.username == sessionUsername }

    fun customers(): List<BankCustomer> = customers.toList()

    fun customer(username: String): BankCustomer? =
        customers.firstOrNull { it.username == username }

    fun pendingTransfers(): List<PendingTransfer> =
        pending.filter { it.status == "Pending" }

    fun pending(id: String): PendingTransfer? = pending.firstOrNull { it.id == id }

    fun decisions(): List<BankDecision> = decisions.toList()

    fun authenticate(username: String, password: String): String? {
        val user = username.trim()
        if (customers.any { it.username == user && it.password == password }) return "customer"
        return null
    }

    fun startSession(username: String, newRole: String) {
        role = newRole
        sessionUsername = username.trim()
        lastResult = ""
        lastReceipt = ""
    }

    fun endSession() {
        role = null
        sessionUsername = ""
    }

    fun sessionDisplayName(): String {
        if (role == "manager") return MANAGER_NAME
        return currentCustomer()?.displayName ?: "Demo User"
    }

    fun filteredCustomers(query: String): List<BankCustomer> {
        val q = query.trim().lowercase(Locale.US)
        if (q.isEmpty()) return customers.toList()
        return customers.filter {
            it.displayName.lowercase(Locale.US).contains(q) ||
                it.username.lowercase(Locale.US).contains(q)
        }
    }

    fun filteredActivity(customer: BankCustomer, query: String, filter: String): List<BankTxn> {
        val q = query.trim().lowercase(Locale.US)
        return customer.activity.filter { txn ->
            val kindOk = when (filter) {
                "Credit" -> txn.kind == "Credit"
                "Debit" -> txn.kind == "Debit"
                "Pending" -> txn.status == "Pending"
                else -> true
            }
            val textOk = q.isEmpty() ||
                txn.title.lowercase(Locale.US).contains(q) ||
                txn.id.lowercase(Locale.US).contains(q)
            kindOk && textOk
        }
    }

    fun beginTransfer(fromAccountId: String, payeeName: String, amountText: String): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        if (payeeName.isBlank()) return "Result: Select a payee"
        val amount = amountText.trim().toDoubleOrNull()
        if (amount == null || amount <= 0.0) return "Result: Amount is required"
        val account = customer.accounts.firstOrNull { it.id == fromAccountId }
            ?: return "Result: Select an account"
        if (amount > account.balance) return "Result: Insufficient funds"
        draftFromAccountId = fromAccountId
        draftPayeeName = payeeName
        draftAmount = amount
        lastResult = ""
        return ""
    }

    fun confirmTransferNeedsOtp(): Boolean = draftAmount <= APPROVAL_LIMIT

    fun queueLargeTransfer(): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val id = nextTxnId()
        pending.add(
            0,
            PendingTransfer(
                id = id,
                customerUsername = customer.username,
                fromAccountId = draftFromAccountId,
                payeeName = draftPayeeName,
                amount = draftAmount,
                status = "Pending",
            ),
        )
        customer.activity.add(
            0,
            BankTxn(
                id = id,
                title = "Transfer to ${draftPayeeName}",
                amount = draftAmount,
                kind = "Debit",
                status = "Pending",
            ),
        )
        lastReceipt = "Receipt: Pending approval $id"
        lastResult = lastReceipt
        return lastReceipt
    }

    fun completeTransferWithOtp(code: String): String {
        if (code != OTP_SUCCESS) {
            lastResult = "Result: OTP wrong"
            return lastResult
        }
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val account = customer.accounts.firstOrNull { it.id == draftFromAccountId }
            ?: return "Result: Select an account"
        if (draftAmount > account.balance) {
            lastResult = "Result: Insufficient funds"
            return lastResult
        }
        account.balance = roundMoney(account.balance - draftAmount)
        val id = nextTxnId()
        customer.activity.add(
            0,
            BankTxn(id, "Transfer to $draftPayeeName", draftAmount, "Debit", "Completed"),
        )
        lastReceipt = "Receipt: Transfer completed $id"
        lastResult = lastReceipt
        return lastReceipt
    }

    fun beginBill(billId: String): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val bill = customer.bills.firstOrNull { it.id == billId } ?: return "Result: Select a bill"
        val checking = customer.accounts.firstOrNull { it.id == "checking" }
            ?: return "Result: Select an account"
        if (bill.amountDue > checking.balance) return "Result: Insufficient funds"
        draftBillId = billId
        lastResult = ""
        return ""
    }

    fun payBill(): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val bill = customer.bills.firstOrNull { it.id == draftBillId } ?: return "Result: Select a bill"
        val checking = customer.accounts.firstOrNull { it.id == "checking" }
            ?: return "Result: Select an account"
        if (bill.amountDue > checking.balance) {
            lastResult = "Result: Insufficient funds"
            return lastResult
        }
        checking.balance = roundMoney(checking.balance - bill.amountDue)
        val id = nextTxnId()
        customer.activity.add(0, BankTxn(id, "Bill ${bill.name}", bill.amountDue, "Debit", "Completed"))
        lastReceipt = "Receipt: Bill paid $id"
        lastResult = lastReceipt
        return lastReceipt
    }

    fun addPayee(name: String, accountNumber: String): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val cleanName = name.trim()
        val cleanAccount = accountNumber.trim()
        if (cleanName.isEmpty()) return "Result: Name is required"
        if (cleanAccount.isEmpty()) return "Result: Account number is required"
        if (customer.payees.any { it.accountNumber == cleanAccount }) {
            return "Result: Payee already exists"
        }
        customer.payees.add(Payee("payee-${payeeSeq++}", cleanName, cleanAccount))
        lastResult = "Result: Payee saved"
        return lastResult
    }

    fun setCardFrozen(frozen: Boolean): String {
        val card = currentCustomer()?.card ?: return "Result: Not signed in"
        card.frozen = frozen
        lastResult = if (frozen) "Result: Card frozen" else "Result: Card active"
        return lastResult
    }

    fun saveCardLimit(limitText: String): String {
        val card = currentCustomer()?.card ?: return "Result: Not signed in"
        val limit = limitText.trim().toDoubleOrNull()
        if (limit == null || limit <= 0.0) return "Result: Limit is required"
        card.limit = limit
        lastResult = "Result: Limit saved"
        return lastResult
    }

    fun approve(transferId: String): String {
        val item = pending.firstOrNull { it.id == transferId && it.status == "Pending" }
            ?: return "Result: Request not found"
        val customer = customer(item.customerUsername) ?: return "Result: Customer not found"
        val account = customer.accounts.firstOrNull { it.id == item.fromAccountId }
            ?: return "Result: Select an account"
        if (item.amount > account.balance) return "Result: Insufficient funds"
        account.balance = roundMoney(account.balance - item.amount)
        item.status = "Approved"
        customer.activity.firstOrNull { it.id == item.id }?.status = "Completed"
        decisions.add(0, BankDecision("D-${decisionSeq++}", item.id, "Approved", MANAGER_NAME, ""))
        lastResult = "Result: Approved"
        return lastResult
    }

    fun reject(transferId: String, reason: String): String {
        val clean = reason.trim()
        if (clean.isEmpty()) return "Result: Reason is required"
        val item = pending.firstOrNull { it.id == transferId && it.status == "Pending" }
            ?: return "Result: Request not found"
        val customer = customer(item.customerUsername)
        item.status = "Rejected"
        item.rejectReason = clean
        customer?.activity?.firstOrNull { it.id == item.id }?.status = "Rejected"
        decisions.add(0, BankDecision("D-${decisionSeq++}", item.id, "Rejected", MANAGER_NAME, clean))
        lastResult = "Result: Rejected"
        return lastResult
    }

    fun saveCustomer(
        editingUsername: String?,
        displayName: String,
        username: String,
        password: String,
        balanceText: String,
    ): String {
        val name = displayName.trim()
        val user = username.trim()
        val pass = password
        if (name.isEmpty()) return "Result: Name is required"
        if (user.isEmpty()) return "Result: Username is required"
        if (user == MANAGER_USER) return "Result: Username already exists"
        val balance = balanceText.trim().toDoubleOrNull()
        if (balance == null || balance < 0.0) return "Result: Balance is required"

        if (editingUsername == null) {
            if (pass.isEmpty()) return "Result: Password is required"
            if (customers.any { it.username == user }) return "Result: Username already exists"
            customers.add(newCustomer(user, pass, name, balance, builtIn = false))
            lastResult = "Result: Customer created"
            return lastResult
        }

        val existing = customer(editingUsername) ?: return "Result: Customer not found"
        if (user != existing.username && customers.any { it.username == user }) {
            return "Result: Username already exists"
        }
        existing.displayName = name
        existing.username = user
        if (pass.isNotEmpty()) existing.password = pass
        existing.accounts.firstOrNull { it.id == "checking" }?.balance = balance
        if (sessionUsername == editingUsername) sessionUsername = user
        lastResult = "Result: Customer updated"
        return lastResult
    }

    fun deleteCustomer(username: String): String {
        val existing = customer(username) ?: return "Result: Customer not found"
        if (existing.builtIn) return "Result: Built-in customer cannot be deleted"
        customers.removeAll { it.username == username }
        pending.removeAll { it.customerUsername == username && it.status == "Pending" }
        lastResult = "Result: Customer deleted"
        return lastResult
    }

    private fun nextTxnId(): String = "TX-${txnSeq++}"

    private fun roundMoney(value: Double): Double = kotlin.math.round(value * 100.0) / 100.0

    private fun newCustomer(
        username: String,
        password: String,
        displayName: String,
        checkingBalance: Double,
        builtIn: Boolean,
    ): BankCustomer {
        return BankCustomer(
            username = username,
            password = password,
            displayName = displayName,
            builtIn = builtIn,
            accounts = mutableListOf(
                BankAccount(
                    "checking",
                    if (builtIn) "Adv SafeBalance Banking" else "Checking",
                    if (builtIn) "10001362" else "10010001",
                    checkingBalance,
                ),
                BankAccount("savings", "Savings", "10010002", if (builtIn) 12_000.0 else 0.0),
            ),
            payees = mutableListOf(
                Payee("payee-landlord", "Landlord", "445566"),
                Payee("payee-alex", "Alex", "778899"),
            ),
            bills = mutableListOf(
                Bill("electricity", "Electricity", 850.0),
                Bill("mobile", "Mobile", 499.0),
            ),
            card = BankCard("Visa", if (builtIn) "4242" else "1111", frozen = false, limit = 20_000.0, balance = if (builtIn) 7_751.46 else 0.0),
            activity = mutableListOf(),
        )
    }

    private fun resetPracticeData() {
        customers.clear()
        pending.clear()
        decisions.clear()
        val demo = newCustomer("demo_user", "demo_pass", "Demo User", 50_000.0, builtIn = true)
        demo.activity.add(BankTxn("TX-8001", "Salary", 20_000.0, "Credit", "Completed"))
        demo.activity.add(BankTxn("TX-8002", "Coffee", 120.0, "Debit", "Completed"))
        customers.add(demo)
        pending.clear()
        payTransferHistory.clear()
        payTransferHistory.add(
            PayTransferHistoryItem(
                id = "H-1",
                title = "Sujathapersonal NJ",
                subtitle = "Kavya amount",
                date = "Sep 28, 2026",
                amount = 500.0,
                status = "You paid",
            ),
        )
        billPayees.clear()
        billPayees.addAll(
            listOf(
                BillPayee(
                    "bp-boa",
                    "BankAmericard Platinum Plus Mastercard - 4683",
                    "",
                    "company",
                    section = "Bank of America",
                ),
                BillPayee("bp-amex", "American Express - 1005", "muraliamaxco", "company", section = "Other payees"),
                BillPayee("bp-chase", "Chase Credit Cards - 5059", "amazoncreditcard", "company", section = "Other payees"),
                BillPayee("bp-citi", "Citi Cards - 3318", "kittucitibankcreditcard", "company", section = "Other payees"),
                BillPayee("bp-macys", "Macy's - 8770", "muralimacy", "company", section = "Other payees"),
            ),
        )
        billPayeeSeq = 1
        zelleRecipients.clear()
        zelleRecipients.addAll(
            listOf(
                ZelleRecipient("z-1", "Sujatha", "personal NJ", "201-280-2017", enrolled = true),
                ZelleRecipient("z-2", "Kushal", "US Number", "rajpuduru@gmail.com", enrolled = true),
                ZelleRecipient("z-3", "keerthi", "yerragudi", "gourilabalaji@gmail.com", enrolled = true),
            ),
        )
        zelleSeq = 4
        zelleShowAddedBanner = false
        zelleSelectedRecipientId = ""
        zelleDailyLimitLeft = 500.0
        resetZelleAddDraft()
        resetZellePayDraft()
        refreshPayDates()
        bpDeliverBy = defaultDeliverBy()
    }

    fun payTransferHistory(): List<PayTransferHistoryItem> = payTransferHistory.toList()

    fun refreshPayDates() {
        val fmt = java.text.SimpleDateFormat("MMM d, yyyy", Locale.US)
        val detail = fmt.format(java.util.Date())
        payDateLabel = "Today"
        payDateDetail = detail
        acctDateLabel = "Today"
        acctDateDetail = detail
    }

    fun resetPayDraft() {
        payFromAccountId = "checking"
        payAmountMode = "other"
        payAmount = 0.0
        payAmountText = ""
        payRecurring = false
        payNote = ""
        lastResult = ""
        refreshPayDates()
    }

    fun resetAcctTransferDraft() {
        acctFromId = ""
        acctToId = ""
        acctAmount = 0.0
        acctAmountText = ""
        lastResult = ""
        refreshPayDates()
    }

    fun cardTitle(): String {
        val card = currentCustomer()?.card ?: return "Visa"
        return "Lebyy ${'$'}{card.network} - ${'$'}{card.last4}"
    }

    fun accountTitle(id: String): String {
        val account = currentCustomer()?.accounts?.firstOrNull { it.id == id } ?: return ""
        return "${'$'}{account.name} - ${'$'}{account.number.takeLast(4)}"
    }

    fun savePayAmount(mode: String, otherText: String): String {
        payAmountMode = mode
        if (mode == "balance") {
            payAmount = currentCustomer()?.card?.balance ?: 0.0
            payAmountText = String.format(Locale.US, "%.2f", payAmount)
            lastResult = "Result: Amount saved"
            return lastResult
        }
        val amount = otherText.trim().toDoubleOrNull()
        if (amount == null || amount <= 0.0) {
            lastResult = "Result: Amount is required"
            return lastResult
        }
        payAmount = amount
        payAmountText = String.format(Locale.US, "%.2f", amount)
        lastResult = "Result: Amount saved"
        return lastResult
    }

    fun payAmountDisplay(): String {
        if (payAmount <= 0.0) return ""
        return if (payAmountMode == "balance") {
            "Current balance - ${'$'}{money(payAmount)}"
        } else {
            "Other amount - ${'$'}{money(payAmount)}"
        }
    }

    fun validatePayForm(): String {
        if (currentCustomer() == null) return "Result: Not signed in"
        if (payFromAccountId.isBlank()) return "Result: Select From account"
        if (payAmount <= 0.0) return "Result: Choose amount"
        return ""
    }

    fun confirmCardPayment(): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val from = customer.accounts.firstOrNull { it.id == payFromAccountId }
            ?: return "Result: Select From account"
        if (payAmount <= 0.0) return "Result: Choose amount"
        if (payAmount > from.balance) return "Result: Insufficient funds"
        from.balance = roundMoney(from.balance - payAmount)
        customer.card.balance = maxOf(0.0, roundMoney(customer.card.balance - payAmount))
        val id = nextTxnId()
        val conf = nextConfirmation()
        lastConfirmation = conf
        customer.activity.add(0, BankTxn(id, "Card payment ${'$'}{customer.card.network}", payAmount, "Debit", "Completed"))
        payTransferHistory.add(
            0,
            PayTransferHistoryItem(conf, cardTitle(), if (payNote.isBlank()) "Card payment" else payNote, payDateDetail, payAmount, "You paid"),
        )
        lastReceipt = "Receipt: Payment confirmed $conf"
        lastResult = lastReceipt
        return lastReceipt
    }

    fun validateAcctTransfer(): String {
        if (acctFromId.isBlank() || acctToId.isBlank()) return "Result: Choose account"
        if (acctFromId == acctToId) return "Result: Accounts must differ"
        val amount = acctAmountText.trim().toDoubleOrNull()
        if (amount == null || amount <= 0.0) return "Result: Enter amount"
        acctAmount = amount
        return ""
    }

    fun confirmAcctTransfer(): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val message = validateAcctTransfer()
        if (message.isNotEmpty()) return message
        val from = customer.accounts.firstOrNull { it.id == acctFromId } ?: return "Result: Choose account"
        val to = customer.accounts.firstOrNull { it.id == acctToId } ?: return "Result: Choose account"
        if (acctAmount > from.balance) return "Result: Insufficient funds"
        from.balance = roundMoney(from.balance - acctAmount)
        to.balance = roundMoney(to.balance + acctAmount)
        val id = nextTxnId()
        val conf = nextConfirmation()
        lastConfirmation = conf
        customer.activity.add(0, BankTxn(id, "Transfer to ${'$'}{to.name}", acctAmount, "Debit", "Completed"))
        payTransferHistory.add(
            0,
            PayTransferHistoryItem(conf, "${'$'}{from.name} → ${'$'}{to.name}", "Between my accounts", acctDateDetail, acctAmount, "You transferred"),
        )
        lastReceipt = "Receipt: Transfer confirmed $conf"
        lastResult = lastReceipt
        return lastReceipt
    }

    private fun nextConfirmation(): String {
        val value = String.format(Locale.US, "z%07x", confirmSeq)
        confirmSeq += 1
        return value
    }

    fun billPayees(): List<BillPayee> = billPayees.toList()

    fun resetBillPayeeDraft() {
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

    fun resetBillPaymentDraft() {
        bpPayAmountText = ""
        bpFrequency = "One Time"
        bpDeliverBy = defaultDeliverBy()
        bpMemoOn = false
        bpMemo = ""
        lastResult = ""
    }

    fun defaultDeliverBy(): String {
        val cal = java.util.Calendar.getInstance()
        cal.add(java.util.Calendar.DAY_OF_YEAR, 8)
        return java.text.SimpleDateFormat("MMM d", Locale.US).format(cal.time)
    }

    fun validateBillPayeeStep2(): String {
        if (bpFirstName.trim().isEmpty()) return "Result: First name is required"
        if (bpLastName.trim().isEmpty()) return "Result: Last name is required"
        if (bpAddress.trim().isEmpty()) return "Result: Address is required"
        if (bpCity.trim().isEmpty()) return "Result: City is required"
        return ""
    }

    fun validateBillPayeeStep3(): String {
        if (bpState.isEmpty()) return "Result: State is required"
        if (bpZip.trim().isEmpty()) return "Result: ZIP Code is required"
        if (bpPhone.trim().isEmpty()) return "Result: Phone Number is required"
        if (!bpTermsScrolledToEnd) return "Result: Scroll terms to the end"
        return ""
    }

    fun billPayeeFieldErrors(): Map<String, String> {
        val errors = linkedMapOf<String, String>()
        if (bpFirstName.trim().isEmpty()) errors["firstName"] = "First name is required"
        if (bpLastName.trim().isEmpty()) errors["lastName"] = "Last name is required"
        if (bpAddress.trim().isEmpty()) errors["address"] = "Address is required"
        if (bpCity.trim().isEmpty()) errors["city"] = "City is required"
        if (bpState.isEmpty()) errors["state"] = "State is required"
        if (bpZip.trim().isEmpty()) errors["zip"] = "ZIP Code is required"
        if (bpPhone.trim().isEmpty()) errors["phone"] = "Phone Number is required"
        if (!bpTermsScrolledToEnd) errors["terms"] = "Scroll the page to the end of Terms & Conditions"
        return errors
    }

    fun saveBillPayee(): String {
        val fieldErrors = billPayeeFieldErrors()
        if (fieldErrors.isNotEmpty()) {
            lastResult = "Result: ${fieldErrors.values.first()}"
            return lastResult
        }
        val full = "${bpFirstName.trim()} ${bpLastName.trim()}"
        val id = "bp-$billPayeeSeq"
        billPayeeSeq += 1
        billPayees.add(
            BillPayee(
                id = id,
                name = full,
                nickname = bpNickname,
                kind = "person",
                section = "Other payees",
                address = bpAddress,
                city = bpCity,
                state = bpState,
                zip = bpZip,
                phone = bpPhone,
            ),
        )
        bpSelectedPayeeId = id
        lastResult = "Result: Payee added"
        return lastResult
    }

    fun selectedBillPayee(): BillPayee? = billPayees.firstOrNull { it.id == bpSelectedPayeeId }

    fun resetDepositDraft() {
        depositAccountId = ""
        depositAmountText = ""
        depositFrontSource = ""
        depositBackSource = ""
        depositFrontReady = false
        depositBackReady = false
        lastResult = ""
    }

    fun validateDeposit(): String {
        if (!depositFrontReady) return "Result: Capture front of check"
        if (!depositBackReady) return "Result: Capture back of check"
        if (depositAccountId.isBlank()) return "Result: Select account"
        val amount = depositAmountText.trim().toDoubleOrNull()
        if (amount == null || amount <= 0.0) return "Result: Enter amount"
        return ""
    }

    fun confirmDeposit(): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val message = validateDeposit()
        if (message.isNotEmpty()) {
            lastResult = message
            return message
        }
        val amount = depositAmountText.trim().toDoubleOrNull() ?: return "Result: Enter amount"
        val account = customer.accounts.firstOrNull { it.id == depositAccountId }
            ?: return "Result: Select account"
        account.balance = roundMoney(account.balance + amount)
        val conf = nextConfirmation()
        lastConfirmation = conf
        val id = nextTxnId()
        customer.activity.add(0, BankTxn(id, "Mobile check deposit", amount, "Credit", "Completed"))
        lastReceipt = "Receipt: Deposit submitted $conf"
        lastResult = lastReceipt
        return lastReceipt
    }

    fun confirmBillPayment(): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val payee = selectedBillPayee() ?: return "Result: Select a payee"
        val amount = bpPayAmountText.trim().toDoubleOrNull()
        if (amount == null || amount <= 0.0) return "Result: Enter amount"
        val from = customer.accounts.firstOrNull { it.id == "checking" } ?: return "Result: Select From account"
        if (amount > from.balance) return "Result: Insufficient funds"
        from.balance = roundMoney(from.balance - amount)
        val conf = "Z3PSN-" + String.format(Locale.US, "%05X", confirmSeq)
        confirmSeq += 1
        lastConfirmation = conf
        val id = nextTxnId()
        customer.activity.add(0, BankTxn(id, "Bill Pay ${payee.name}", amount, "Debit", "Completed"))
        payTransferHistory.add(
            0,
            PayTransferHistoryItem(conf, payee.name, bpFrequency, bpDeliverBy, amount, "You paid"),
        )
        lastReceipt = "Receipt: Payment scheduled $conf"
        lastResult = lastReceipt
        return lastReceipt
    }

    fun zelleRecipients(): List<ZelleRecipient> = zelleRecipients.toList()

    fun filteredZelleRecipients(): List<ZelleRecipient> {
        val q = zelleSearchQuery.trim().lowercase(Locale.US)
        if (q.isEmpty()) return zelleRecipients()
        return zelleRecipients.filter {
            it.displayName.lowercase(Locale.US).contains(q) ||
                it.contact.lowercase(Locale.US).contains(q)
        }
    }

    fun resetZelleAddDraft() {
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

    fun resetZellePayDraft() {
        zelleFromAccountId = "checking"
        zelleAmountText = ""
        zelleMessage = ""
        lastResult = ""
    }

    fun validateZelleRecipientInfo(): String {
        if (zelleContact.trim().isEmpty()) return "Result: Mobile number or email is required"
        if (zelleFirstName.trim().isEmpty()) return "Result: First name is required"
        if (zelleLastName.trim().isEmpty()) return "Result: Last name is required"
        return ""
    }

    fun submitZelleAuthCode(code: String): String {
        val trimmed = code.trim()
        if (trimmed.length != 6 || !trimmed.all { it.isDigit() }) {
            lastResult = "Result: Enter a 6-digit authorization code"
            return lastResult
        }
        val id = "z-$zelleSeq"
        zelleSeq += 1
        // Practice app: newly added recipients are enrolled so send-payment works immediately.
        val recipient = ZelleRecipient(
            id = id,
            firstName = zelleFirstName.trim(),
            lastName = zelleLastName.trim(),
            contact = zelleContact.trim(),
            nickname = zelleNickname,
            enrolled = true,
        )
        zelleRecipients.add(0, recipient)
        zelleSelectedRecipientId = id
        zelleShowAddedBanner = true
        lastResult = "Result: Recipient added"
        return lastResult
    }

    fun selectedZelleRecipient(): ZelleRecipient? =
        zelleRecipients.firstOrNull { it.id == zelleSelectedRecipientId }

    fun confirmZellePayment(): String {
        val customer = currentCustomer() ?: return "Result: Not signed in"
        val recipient = selectedZelleRecipient() ?: return "Result: Select recipient"
        val amount = zelleAmountText.trim().toDoubleOrNull()
        if (amount == null || amount <= 0.0) return "Result: Enter amount"
        if (amount > zelleDailyLimitLeft) return "Result: Exceeds daily limit"
        val from = customer.accounts.firstOrNull { it.id == zelleFromAccountId }
            ?: return "Result: Select From account"
        if (amount > from.balance) return "Result: Insufficient funds"
        from.balance = roundMoney(from.balance - amount)
        zelleDailyLimitLeft = roundMoney(zelleDailyLimitLeft - amount)
        val conf = nextConfirmation()
        lastConfirmation = conf
        val id = nextTxnId()
        customer.activity.add(0, BankTxn(id, "Zelle ${recipient.displayName}", amount, "Debit", "Completed"))
        payTransferHistory.add(
            0,
            PayTransferHistoryItem(conf, recipient.displayName, recipient.contact, "Today", amount, "You paid"),
        )
        zelleShowAddedBanner = false
        lastReceipt = "Receipt: Zelle payment $conf"
        lastResult = lastReceipt
        return lastReceipt
    }
}

class BankCustomer(
    var username: String,
    var password: String,
    var displayName: String,
    val builtIn: Boolean,
    val accounts: MutableList<BankAccount>,
    val payees: MutableList<Payee>,
    val bills: MutableList<Bill>,
    var card: BankCard,
    val activity: MutableList<BankTxn>,
)

class BankAccount(
    val id: String,
    val name: String,
    val number: String,
    var balance: Double,
) {
    val masked: String get() = "••" + number.takeLast(4)
}

class Payee(val id: String, val name: String, val accountNumber: String)

class Bill(val id: String, val name: String, val amountDue: Double)

class BankCard(
    val network: String,
    val last4: String,
    var frozen: Boolean,
    var limit: Double,
    var balance: Double = 0.0,
)

class PayTransferHistoryItem(
    val id: String,
    val title: String,
    val subtitle: String,
    val date: String,
    val amount: Double,
    val status: String,
)

class BillPayee(
    val id: String,
    var name: String,
    var nickname: String,
    var kind: String,
    var section: String = "Other payees",
    var address: String = "",
    var city: String = "",
    var state: String = "",
    var zip: String = "",
    var phone: String = "",
)

class ZelleRecipient(
    val id: String,
    var firstName: String,
    var lastName: String,
    var contact: String,
    var nickname: String = "",
    var enrolled: Boolean = true,
) {
    val displayName: String
        get() {
            val nick = nickname.trim()
            return if (nick.isNotEmpty()) {
                "$nick $lastName".trim()
            } else {
                "$firstName $lastName".trim()
            }
        }

    val initials: String
        get() {
            val a = firstName.firstOrNull()?.uppercaseChar()?.toString().orEmpty()
            val b = lastName.firstOrNull()?.uppercaseChar()?.toString().orEmpty()
            return a + b
        }
}

class BankTxn(
    val id: String,
    val title: String,
    val amount: Double,
    val kind: String,
    var status: String,
) {
    fun label(): String = "$kind · $title · ${BankState.money(amount)} · $status"
}

class PendingTransfer(
    val id: String,
    val customerUsername: String,
    val fromAccountId: String,
    val payeeName: String,
    val amount: Double,
    var status: String,
    var rejectReason: String = "",
) {
    fun label(): String =
        "$id · $customerUsername → $payeeName · ${BankState.money(amount)}"
}

class BankDecision(
    val id: String,
    val transferId: String,
    val action: String,
    val managerName: String,
    val reason: String,
) {
    fun label(): String {
        val extra = if (reason.isBlank()) "" else " · $reason"
        return "$action $transferId by $managerName$extra"
    }
}
