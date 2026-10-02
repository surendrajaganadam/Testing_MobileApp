package com.demo.lebyy.ui

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.setPadding
import com.demo.lebyy.R
import com.demo.lebyy.data.BankCustomer
import com.demo.lebyy.data.BankState
import com.demo.lebyy.databinding.ActivityBankBinding

class BankActivity : AppCompatActivity() {
    private lateinit var binding: ActivityBankBinding
    private var screen: String = "transfer"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityBankBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.bankToolbar)
        binding.bankToolbar.setNavigationOnClickListener { finish() }
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        screen = intent.getStringExtra(EXTRA_SCREEN) ?: "transfer"
        render()
    }

    override fun onResume() {
        super.onResume()
        if (BankState.closeBankFlow) {
            finish()
            return
        }
        if (screen in listOf("payees", "pending", "customers", "decisions", "activity", "cards", "bills")) {
            render()
        }
    }

    private fun render() {
        val root = binding.bankScreen
        root.removeAllViews()
        when (screen) {
            "transfer" -> renderTransfer(root)
            "transferConfirm" -> renderTransferConfirm(root)
            "otp" -> renderOtp(root)
            "receipt" -> renderReceipt(root)
            "payees" -> renderPayees(root)
            "addPayee" -> renderAddPayee(root)
            "bills" -> renderBills(root)
            "billConfirm" -> renderBillConfirm(root)
            "cards" -> renderCards(root)
            "activity" -> renderActivity(root)
            "pending" -> renderPending(root)
            "pendingDetail" -> renderPendingDetail(root)
            "customers" -> renderCustomers(root)
            "customerForm" -> renderCustomerForm(root)
            "decisions" -> renderDecisions(root)
            else -> finish()
        }
    }

    private fun renderTransfer(root: LinearLayout) {
        title("Transfer", "test-BankTransferScreen")
        val customer = BankState.currentCustomer() ?: return
        if (BankState.draftFromAccountId.isBlank()) {
            BankState.draftFromAccountId = customer.accounts.firstOrNull()?.id ?: "checking"
        }
        val fromId = BankState.draftFromAccountId
        customer.accounts.forEach { account ->
            root.addView(
                button("${account.name} ${account.masked} · ${BankState.money(account.balance)}", "test-TransferFrom-${account.name}") {
                    BankState.draftFromAccountId = account.id
                    render()
                },
            )
        }
        text("From: ${customer.accounts.firstOrNull { it.id == fromId }?.name ?: ""}", "test-TransferFromValue")
        customer.payees.forEach { payee ->
            root.addView(
                button("${payee.name} · ${payee.accountNumber}", "test-TransferPayee-${payee.name}") {
                    BankState.draftPayeeName = payee.name
                    render()
                },
            )
        }
        val selectedPayee = BankState.draftPayeeName
        text("Payee: $selectedPayee", "test-TransferPayeeValue")
        val amount = field("Amount", "test-TransferAmount", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        amount.setText(BankState.draftAmountText)
        amount.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) = Unit
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) = Unit
            override fun afterTextChanged(s: Editable?) {
                BankState.draftAmountText = s?.toString().orEmpty()
            }
        })
        root.addView(amount)
        root.addView(
            button("Continue", "test-TransferContinue") {
                BankState.draftAmountText = amount.text.toString()
                val message = BankState.beginTransfer(fromId, selectedPayee, amount.text.toString())
                if (message.isEmpty()) {
                    open("transferConfirm")
                } else {
                    BankState.lastResult = message
                    render()
                }
            },
        )
        resultLine()
    }

    private fun renderTransferConfirm(root: LinearLayout) {
        title("Confirm transfer", "test-BankTransferConfirmScreen")
        val customer = BankState.currentCustomer()
        val from = customer?.accounts?.firstOrNull { it.id == BankState.draftFromAccountId }?.name ?: ""
        text(
            "$from → ${BankState.draftPayeeName} ${BankState.money(BankState.draftAmount)}",
            "test-TransferSummary",
        )
        root.addView(
            button("Confirm", "test-TransferConfirm") {
                if (BankState.confirmTransferNeedsOtp()) {
                    open("otp")
                } else {
                    BankState.queueLargeTransfer()
                    open("receipt")
                }
            },
        )
    }

    private fun renderOtp(root: LinearLayout) {
        title("Transfer OTP", "test-BankOtpScreen")
        text("Enter OTP 1234", "test-BankOtpHint")
        val digits = (1..4).map { index ->
            field("", "test-BankOTP-$index", InputType.TYPE_CLASS_NUMBER).apply {
                filters = arrayOf(android.text.InputFilter.LengthFilter(1))
            }
        }
        val row = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL }
        digits.forEach { row.addView(it, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)) }
        root.addView(row)
        root.addView(
            button("Verify", "test-BankOTPVerify") {
                val code = digits.joinToString("") { it.text.toString() }
                val message = BankState.completeTransferWithOtp(code)
                if (message.startsWith("Receipt:")) open("receipt") else render()
            },
        )
        resultLine()
    }

    private fun renderReceipt(root: LinearLayout) {
        title("Receipt", "test-BankReceiptScreen")
        text(BankState.lastReceipt, "test-BankReceipt")
        root.addView(
            button("Done", "test-BankDone") {
                BankState.closeBankFlow = true
                finish()
            },
        )
    }

    private fun renderPayees(root: LinearLayout) {
        title("Payees", "test-BankPayeesScreen")
        root.addView(button("Add payee", "test-AddPayee") { open("addPayee") })
        BankState.currentCustomer()?.payees?.forEach { payee ->
            text("${payee.name} · ${payee.accountNumber}", "test-Payee-${payee.name}")
        }
        resultLine()
    }

    private fun renderAddPayee(root: LinearLayout) {
        title("Add payee", "test-BankAddPayeeScreen")
        val name = field("Payee name", "test-PayeeName", InputType.TYPE_CLASS_TEXT)
        val account = field("Account number", "test-PayeeAccount", InputType.TYPE_CLASS_NUMBER)
        root.addView(name)
        root.addView(account)
        root.addView(
            button("Save payee", "test-PayeeSave") {
                BankState.lastResult = BankState.addPayee(name.text.toString(), account.text.toString())
                if (BankState.lastResult == "Result: Payee saved") {
                    finish()
                } else {
                    render()
                }
            },
        )
        resultLine()
    }

    private fun renderBills(root: LinearLayout) {
        title("Pay a bill", "test-BankBillsScreen")
        BankState.currentCustomer()?.bills?.forEach { bill ->
            root.addView(
                button("${bill.name} · ${BankState.money(bill.amountDue)}", "test-Bill-${bill.name}") {
                    val message = BankState.beginBill(bill.id)
                    if (message.isEmpty()) open("billConfirm") else {
                        BankState.lastResult = message
                        render()
                    }
                },
            )
        }
        resultLine()
    }

    private fun renderBillConfirm(root: LinearLayout) {
        title("Confirm bill", "test-BankBillConfirmScreen")
        val bill = BankState.currentCustomer()?.bills?.firstOrNull { it.id == BankState.draftBillId }
        text("${bill?.name} ${BankState.money(bill?.amountDue ?: 0.0)} from Checking", "test-BillSummary")
        root.addView(
            button("Pay", "test-BillPay") {
                BankState.payBill()
                open("receipt")
            },
        )
    }

    private fun renderCards(root: LinearLayout) {
        title("Cards", "test-BankCardsScreen")
        val card = BankState.currentCustomer()?.card ?: return
        text("${card.network} ••${card.last4}", "test-Card-${card.network}")
        text(if (card.frozen) "Card status: Frozen" else "Card status: Active", "test-CardStatus")
        root.addView(
            button(if (card.frozen) "Unfreeze" else "Freeze", "test-CardFreeze") {
                BankState.setCardFrozen(!card.frozen)
                render()
            },
        )
        val limit = field("Spending limit", "test-CardLimit", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        limit.setText(String.format(java.util.Locale.US, "%.0f", card.limit))
        root.addView(limit)
        root.addView(
            button("Save limit", "test-CardSaveLimit") {
                BankState.saveCardLimit(limit.text.toString())
                render()
            },
        )
        resultLine()
    }

    private fun renderActivity(root: LinearLayout) {
        title("Activity", "test-BankActivityScreen")
        val customer = BankState.currentCustomer() ?: return
        val search = field("Search activity", "test-ActivitySearch", InputType.TYPE_CLASS_TEXT)
        search.setText(intent.getStringExtra(EXTRA_QUERY).orEmpty())
        root.addView(search)
        val filter = intent.getStringExtra(EXTRA_FILTER) ?: "All"
        listOf("All", "Credit", "Debit", "Pending").forEach { name ->
            root.addView(
                button(name, "test-ActivityFilter-$name") {
                    intent.putExtra(EXTRA_FILTER, name)
                    intent.putExtra(EXTRA_QUERY, search.text.toString())
                    render()
                },
            )
        }
        val rows = BankState.filteredActivity(customer, search.text.toString(), filter)
        text("Showing ${rows.size}", "test-ActivityCount")
        text("Filter: $filter", "test-ActivityFilterValue")
        rows.forEach { txn -> text(txn.label(), "test-Activity-${txn.id}") }
        root.addView(
            button("Apply search", "test-ActivitySearchApply") {
                intent.putExtra(EXTRA_QUERY, search.text.toString())
                render()
            },
        )
    }

    private fun renderPending(root: LinearLayout) {
        title("Pending approvals", "test-BankPendingScreen")
        text("Pending: ${BankState.pendingTransfers().size}", "test-PendingCount")
        BankState.pendingTransfers().forEach { item ->
            root.addView(button(item.label(), "test-Pending-${item.id}") {
                intent.putExtra(EXTRA_ID, item.id)
                screen = "pendingDetail"
                render()
            })
        }
    }

    private fun renderPendingDetail(root: LinearLayout) {
        title("Review request", "test-BankPendingDetailScreen")
        val id = intent.getStringExtra(EXTRA_ID).orEmpty()
        val item = BankState.pending(id)
        text(item?.label() ?: "Missing", "test-PendingSummary")
        val reason = field("Reject reason", "test-PendingRejectReason", InputType.TYPE_CLASS_TEXT)
        root.addView(reason)
        root.addView(button("Approve", "test-PendingApprove") {
            BankState.lastResult = BankState.approve(id)
            render()
        })
        root.addView(button("Reject", "test-PendingReject") {
            BankState.lastResult = BankState.reject(id, reason.text.toString())
            render()
        })
        resultLine()
    }

    private fun renderCustomers(root: LinearLayout) {
        title("Customers", "test-BankCustomersScreen")
        val search = field("Search customers", "test-CustomerSearch", InputType.TYPE_CLASS_TEXT)
        search.setText(intent.getStringExtra(EXTRA_QUERY).orEmpty())
        root.addView(search)
        root.addView(button("Search", "test-CustomerSearchApply") {
            intent.putExtra(EXTRA_QUERY, search.text.toString())
            render()
        })
        root.addView(button("Create customer", "test-CustomerCreate") {
            intent.removeExtra(EXTRA_ID)
            screen = "customerForm"
            render()
        })
        val rows = BankState.filteredCustomers(search.text.toString())
        text("Customers: ${rows.size}", "test-CustomerCount")
        rows.forEach { customer ->
            root.addView(button(customerLine(customer), "test-Customer-${customer.username}") {
                intent.putExtra(EXTRA_ID, customer.username)
                screen = "customerForm"
                render()
            })
        }
        resultLine()
    }

    private fun renderCustomerForm(root: LinearLayout) {
        val editing = intent.getStringExtra(EXTRA_ID)?.let { BankState.customer(it) }
        title(if (editing == null) "Create customer" else "Customer", "test-BankCustomerFormScreen")
        if (editing != null) {
            root.addView(View(this).apply {
                contentDescription = "test-BankCustomerLookupScreen"
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
            })
            editing.accounts.forEach { account ->
                text("${account.name} ${account.masked} · ${BankState.money(account.balance)}", "test-Lookup-${account.name}")
            }
            text("Recent activity", "test-LookupActivityTitle")
            editing.activity.take(5).forEach { txn ->
                text(txn.label(), "test-Lookup-${txn.id}")
            }
        }
        val name = field("Display name", "test-CustomerName", InputType.TYPE_CLASS_TEXT)
        val username = field("Username", "test-CustomerUsername", InputType.TYPE_CLASS_TEXT)
        val password = field("Password", "test-CustomerPassword", InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_PASSWORD)
        val balance = field("Checking balance", "test-CustomerBalance", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        if (editing != null) {
            name.setText(editing.displayName)
            username.setText(editing.username)
            balance.setText(String.format(java.util.Locale.US, "%.2f", editing.accounts.first { it.id == "checking" }.balance))
        }
        root.addView(name)
        root.addView(username)
        root.addView(password)
        root.addView(balance)
        root.addView(
            button("Save customer", "test-CustomerSave") {
                BankState.lastResult = BankState.saveCustomer(
                    editing?.username,
                    name.text.toString(),
                    username.text.toString(),
                    password.text.toString(),
                    balance.text.toString(),
                )
                if (BankState.lastResult == "Result: Customer created" || BankState.lastResult == "Result: Customer updated") {
                    if (BankState.lastResult == "Result: Customer updated") {
                        intent.putExtra(EXTRA_ID, username.text.toString().trim())
                    }
                    render()
                } else {
                    render()
                }
            },
        )
        if (editing != null) {
            root.addView(
                button("Delete customer", "test-CustomerDelete") {
                    BankState.lastResult = BankState.deleteCustomer(editing.username)
                    if (BankState.lastResult == "Result: Customer deleted") {
                        screen = "customers"
                        intent.removeExtra(EXTRA_ID)
                    }
                    render()
                },
            )
        }
        resultLine()
    }

    private fun renderDecisions(root: LinearLayout) {
        title("Decision history", "test-BankDecisionsScreen")
        val rows = BankState.decisions()
        text("Decisions: ${rows.size}", "test-DecisionCount")
        rows.forEach { decision -> text(decision.label(), "test-Decision-${decision.id}") }
    }

    private fun title(title: String, screenId: String) {
        binding.bankToolbar.title = title
        binding.bankScreen.contentDescription = screenId
    }

    private fun resultLine() {
        if (BankState.lastResult.isNotBlank()) {
            text(BankState.lastResult, "test-BankResult")
        }
    }

    private fun text(value: String, id: String) {
        binding.bankScreen.addView(
            TextView(this).apply {
                text = value
                contentDescription = id
                setTextColor(getColor(R.color.lebyy_text))
                textSize = 16f
                setPadding(dp(4))
            },
        )
    }

    private fun field(hint: String, id: String, inputType: Int): EditText {
        return EditText(this).apply {
            this.hint = hint
            contentDescription = id
            this.inputType = inputType
            setTextColor(getColor(R.color.lebyy_text))
            setHintTextColor(getColor(R.color.lebyy_muted))
            setBackgroundColor(getColor(R.color.lebyy_surface))
            setPadding(dp(12))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(8) }
        }
    }

    private fun button(label: String, id: String, onClick: () -> Unit): Button {
        return Button(this).apply {
            text = label
            contentDescription = id
            isAllCaps = false
            setTextColor(getColor(R.color.lebyy_bg))
            setBackgroundColor(getColor(R.color.lebyy_accent))
            setOnClickListener { onClick() }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply { topMargin = dp(8) }
        }
    }

    private fun open(next: String) {
        startActivity(
            Intent(this, BankActivity::class.java).apply {
                putExtra(EXTRA_SCREEN, next)
                putExtra(EXTRA_ID, intent.getStringExtra(EXTRA_ID))
            },
        )
        if (next == "receipt") finish()
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    companion object {
        const val EXTRA_SCREEN = "screen"
        const val EXTRA_ID = "id"
        const val EXTRA_QUERY = "query"
        const val EXTRA_FILTER = "filter"

        fun customerLine(customer: BankCustomer): String =
            "${customer.displayName} · ${customer.username}"

        fun open(activity: AppCompatActivity, screen: String) {
            BankState.closeBankFlow = false
            if (screen == "transfer") {
                BankState.draftFromAccountId = ""
                BankState.draftPayeeName = ""
                BankState.draftAmountText = ""
                BankState.lastResult = ""
            }
            activity.startActivity(
                Intent(activity, BankActivity::class.java).putExtra(EXTRA_SCREEN, screen),
            )
        }
    }
}
