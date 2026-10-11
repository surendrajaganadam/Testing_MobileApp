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
import android.widget.ScrollView
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
        if (BankState.closeToBillPay && screen != "payBills") {
            finish()
            return
        }
        if (BankState.closeToBillPay && screen == "payBills") {
            BankState.closeToBillPay = false
        }
        if (screen in listOf(
                "payees", "pending", "customers", "decisions", "activity", "cards", "bills",
                "acctTransfer", "payBills", "payTransfer", "billPayAddress", "billPayPayment",
            )
        ) {
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
            "payTransfer" -> renderPayTransfer(root)
            "acctTransfer" -> renderAcctTransfer(root)
            "acctTransferReview" -> renderAcctTransferReview(root)
            "acctTransferSuccess" -> renderPaySuccess(root, "Your transfer is confirmed", "test-AcctTransferSuccessScreen", account = true)
            "payBills" -> renderBillPayHome(root)
            "billPayAddWho" -> renderBillPayAddWho(root)
            "billPayPerson" -> renderBillPayPerson(root)
            "billPayAddress" -> renderBillPayAddress(root)
            "billPaySelectState" -> renderBillPaySelectState(root)
            "billPayAddSuccess" -> renderBillPayAddSuccess(root)
            "billPayPayment" -> renderBillPayPayment(root)
            "billPayPaySuccess" -> renderBillPayPaySuccess(root)
            "chooseAmount" -> renderChooseAmount(root)
            "payReview" -> renderPayReview(root)
            "paySuccess" -> renderPaySuccess(root, "Your payment is confirmed", "test-PaySuccessScreen", account = false)
            "chooseAccount" -> renderChooseAccount(root)
            "zelle" -> renderShell(root, "Zelle", "test-ZelleScreen", "Result: Zelle opened — send or receive practice screen")
            "wire" -> renderShell(root, "Wire", "test-WireScreen", "Result: Wire opened — U.S. or international practice screen")
            "menu" -> renderShell(root, "Menu", "test-BankMenuScreen", "Result: Menu opened")
            "inbox" -> renderShell(root, "Inbox", "test-BankInboxScreen", "Result: Inbox opened")
            "products" -> renderShell(root, "Products", "test-BankProductsScreen", "Result: Products opened")
            "rewards" -> renderShell(root, "Lebyy Rewards", "test-BankRewardsScreen", "Result: Rewards opened")
            "profile" -> renderShell(root, "Profile", "test-BankProfileScreen", "Result: Profile opened")
            "deposit" -> renderShell(root, "Deposit Checks", "test-BankDepositScreen", "Result: Deposit Checks opened")
            "invest" -> renderShell(root, "Invest", "test-BankInvestScreen", "Result: Invest opened")
            "assistant" -> renderShell(root, "Lebyy Assistant", "test-BankAssistantScreen", "Result: Assistant opened")
            else -> finish()
        }
    }

    private fun renderShell(root: LinearLayout, titleText: String, screenId: String, result: String) {
        title(titleText, screenId)
        text(result, "test-BankShellResult")
    }

    private fun renderPayTransfer(root: LinearLayout) {
        title("Pay & Transfer", "test-PayTransferScreen")
        text("Pay & Transfer", "test-PayTransferTitle")
        text("Hi, I'm Lebyy. How can I help?", "test-PT-Assistant")
        root.addView(button("Transfer\nbetween my accounts", "test-PT-Transfer") {
            BankState.resetAcctTransferDraft()
            open("acctTransfer")
        })
        root.addView(button("Zelle\nsend or receive", "test-PT-Zelle") { open("zelle") })
        root.addView(button("Pay Bills\npay now or schedule", "test-PT-PayBills") {
            BankState.bpSelectedPayeeId = ""
            BankState.lastResult = ""
            BankState.closeToBillPay = false
            open("payBills")
        })
        root.addView(button("Wire\nU.S. or international", "test-PT-Wire") { open("wire") })
        text("Activity", "test-PT-ActivityTitle")
        text("ACTION NEEDED", "test-PT-ActionNeededTitle")
        text(
            "There are no payment requests right now. To manage requests, go to Settings.",
            "test-PT-ActionNeededBody",
        )
        text("HISTORY", "test-PT-HistoryTitle")
        BankState.payTransferHistory().forEach { item ->
            text(
                "${item.title} · ${item.subtitle} · ${item.date} · ${BankState.money(item.amount)} · ${item.status}",
                "test-PT-History-${item.id}",
            )
        }
        root.addView(button("MORE ACTIVITY", "test-PT-MoreActivity") { open("activity") })
        text("Legal info and disclosures", "test-PT-LegalLink")
    }

    private fun renderAcctTransfer(root: LinearLayout) {
        title("Transfer", "test-AcctTransferScreen")
        text("Transfer", "test-AcctTransferTitle")
        text("Lebyy deposit products. FDIC Member. Investment products are not FDIC-insured.", "test-PT-FdicBanner")
        val fromValue = if (BankState.acctFromId.isBlank()) "Choose account" else BankState.accountTitle(BankState.acctFromId)
        val toValue = if (BankState.acctToId.isBlank()) "Choose account" else BankState.accountTitle(BankState.acctToId)
        val amountValue = if (BankState.acctAmount <= 0.0) "Enter amount" else BankState.money(BankState.acctAmount)
        root.addView(button("From  $fromValue", "test-AcctTransfer-From") {
            intent.putExtra(EXTRA_CHOOSE, "acctFrom")
            open("chooseAccount")
        })
        root.addView(button("To  $toValue", "test-AcctTransfer-To") {
            intent.putExtra(EXTRA_CHOOSE, "acctTo")
            open("chooseAccount")
        })
        val amountField = field("Amount", "test-AcctTransfer-AmountField", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        amountField.setText(BankState.acctAmountText)
        root.addView(amountField)
        text(amountValue, "test-AcctTransfer-Amount")
        root.addView(button("Save amount", "test-AcctTransfer-AmountSave") {
            BankState.acctAmountText = amountField.text.toString()
            val amount = BankState.acctAmountText.trim().toDoubleOrNull()
            if (amount == null || amount <= 0.0) {
                BankState.lastResult = "Result: Enter amount"
            } else {
                BankState.acctAmount = amount
                BankState.lastResult = ""
            }
            render()
        })
        text("${BankState.acctDateLabel}\n${BankState.acctDateDetail}", "test-AcctTransfer-Date")
        root.addView(button("Choose date: Today", "test-AcctTransfer-DateToday") {
            BankState.refreshPayDates()
            render()
        })
        root.addView(button("Sending a wire? Start here.", "test-AcctTransfer-WireHint") { open("wire") })
        legal(root)
        root.addView(button("CANCEL", "test-AcctTransfer-Cancel") { finish() })
        root.addView(button("NEXT", "test-AcctTransfer-Next") {
            BankState.acctAmountText = amountField.text.toString().ifBlank { BankState.acctAmountText }
            val message = BankState.validateAcctTransfer()
            if (message.isEmpty()) open("acctTransferReview") else {
                BankState.lastResult = message
                render()
            }
        })
        resultLine()
    }

    private fun renderAcctTransferReview(root: LinearLayout) {
        title("Review", "test-AcctTransferReviewScreen")
        text("Review transfer details", "test-AcctTransferReviewHeading")
        text("From ${BankState.accountTitle(BankState.acctFromId)}", "test-AcctReview-From")
        text("To ${BankState.accountTitle(BankState.acctToId)}", "test-AcctReview-To")
        text("Amount ${BankState.money(BankState.acctAmount)}", "test-AcctReview-Amount")
        text("Date ${BankState.acctDateLabel} ${BankState.acctDateDetail}", "test-AcctReview-Date")
        root.addView(button("EDIT", "test-AcctTransfer-Edit") { finish() })
        root.addView(button("TRANSFER", "test-AcctTransfer-Confirm") {
            val message = BankState.confirmAcctTransfer()
            if (message.startsWith("Receipt:")) open("acctTransferSuccess") else {
                BankState.lastResult = message
                render()
            }
        })
        resultLine()
    }

    private fun renderBillPayHome(root: LinearLayout) {
        title("Bill Pay", "test-BillPayScreen")
        text("Bill Pay", "test-BillPayTitle")
        text("Hi, I'm Erica. How can I help?", "test-BillPay-Assistant")
        text("Pay", "test-BillPay-TabPay")
        text("MY EBILLS & REMINDERS", "test-BillPay-EBillsTitle")
        text("You don't have any unpaid eBills or reminders right now.", "test-BillPay-EBillsEmpty")
        text("PAYEES", "test-BillPay-PayeesTitle")
        root.addView(button("Add Payee +", "test-BillPay-AddPayee") {
            BankState.resetBillPayeeDraft()
            open("billPayAddWho")
        })
        BankState.billPayees().forEach { payee ->
            val selected = payee.id == BankState.bpSelectedPayeeId
            val nick = if (payee.nickname.isBlank()) "" else "\n${payee.nickname}"
            root.addView(button(
                "${payee.name}$nick\nNo payment in last 60 days${if (selected) "\n✓ selected" else ""}",
                "test-BillPay-Payee-${payee.id}",
            ) {
                BankState.bpSelectedPayeeId = payee.id
                BankState.lastResult = ""
                render()
            })
        }
        root.addView(button("CANCEL", "test-BillPay-Cancel") { finish() })
        root.addView(button("PAY", "test-BillPay-Pay") {
            if (BankState.bpSelectedPayeeId.isBlank()) {
                BankState.lastResult = "Result: Select a payee"
                render()
            } else {
                BankState.resetBillPaymentDraft()
                open("billPayPayment")
            }
        })
        legal(root)
        resultLine()
    }

    private fun renderBillPayAddWho(root: LinearLayout) {
        title("Add Payee", "test-AddPayeeWhoScreen")
        text("Who do you want to add?", "test-AddPayee-WhoTitle")
        root.addView(button("Company", "test-AddPayee-Company") {
            BankState.lastResult = "Result: Company add is not in this practice path — use Bill Pay person"
            render()
        })
        root.addView(button(
            "Pay them with Zelle\nSend money quickly using their US mobile # / email.",
            "test-AddPayee-Zelle",
        ) {
            BankState.lastResult = "Result: Use Bill Pay for this practice path"
            render()
        })
        root.addView(button(
            "Pay them with Bill Pay\nMail a check to their US address in 4-7 days.",
            "test-AddPayee-BillPayPerson",
        ) {
            BankState.resetBillPayeeDraft()
            open("billPayPerson")
        })
        text("Learn when to use Zelle vs. Bill Pay.", "test-AddPayee-LearnLink")
        legal(root)
        resultLine()
    }

    private fun renderBillPayPerson(root: LinearLayout) {
        title("Add Payee", "test-AddPayeePersonScreen")
        text("Enter the person's information.", "test-AddPayee-PersonHint")
        val first = field("First Name", "test-AddPayee-FirstName", InputType.TYPE_CLASS_TEXT)
        first.setText(BankState.bpFirstName)
        root.addView(first)
        val last = field("Last Name", "test-AddPayee-LastName", InputType.TYPE_CLASS_TEXT)
        last.setText(BankState.bpLastName)
        root.addView(last)
        val nick = field("Nickname (Optional)", "test-AddPayee-Nickname", InputType.TYPE_CLASS_TEXT)
        nick.setText(BankState.bpNickname)
        root.addView(nick)
        val ident = field("Identifying Info (Optional)", "test-AddPayee-Identifying", InputType.TYPE_CLASS_TEXT)
        ident.setText(BankState.bpIdentifying)
        root.addView(ident)
        val addr = field("Address", "test-AddPayee-Address", InputType.TYPE_CLASS_TEXT)
        addr.setText(BankState.bpAddress)
        root.addView(addr)
        val addr2 = field("Address Two (Optional)", "test-AddPayee-Address2", InputType.TYPE_CLASS_TEXT)
        addr2.setText(BankState.bpAddress2)
        root.addView(addr2)
        val city = field("City", "test-AddPayee-City", InputType.TYPE_CLASS_TEXT)
        city.setText(BankState.bpCity)
        root.addView(city)
        root.addView(button("CANCEL", "test-AddPayee-PersonCancel") { finish() })
        root.addView(button("SAVE", "test-AddPayee-PersonSave") {
            BankState.bpFirstName = first.text.toString()
            BankState.bpLastName = last.text.toString()
            BankState.bpNickname = nick.text.toString()
            BankState.bpIdentifying = ident.text.toString()
            BankState.bpAddress = addr.text.toString()
            BankState.bpAddress2 = addr2.text.toString()
            BankState.bpCity = city.text.toString()
            val message = BankState.validateBillPayeeStep2()
            if (message.isEmpty()) {
                BankState.lastResult = ""
                open("billPayAddress")
            } else {
                BankState.lastResult = message
                render()
            }
        })
        resultLine()
    }

    private fun renderBillPayAddress(root: LinearLayout) {
        title("Add Payee", "test-AddPayeeAddressScreen")
        text("City ${BankState.bpCity}", "test-AddPayee-CityValue")
        root.addView(button(
            "State ${BankState.bpState.ifBlank { "Select" }}",
            "test-AddPayee-State",
        ) { open("billPaySelectState") })
        val zip = field("ZIP Code", "test-AddPayee-Zip", InputType.TYPE_CLASS_TEXT)
        zip.setText(BankState.bpZip)
        root.addView(zip)
        val phone = field("Phone Number", "test-AddPayee-Phone", InputType.TYPE_CLASS_PHONE)
        phone.setText(BankState.bpPhone)
        root.addView(phone)
        text("Terms & Conditions", "test-AddPayee-TermsTitle")
        val termsScroll = ScrollView(this).apply {
            contentDescription = "test-AddPayee-TermsScroll"
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                dp(180),
            )
            isFillViewport = false
            val inner = LinearLayout(this@BankActivity).apply {
                orientation = LinearLayout.VERTICAL
                setPadding(dp(8))
                addView(TextView(this@BankActivity).apply {
                    text = BILL_PAY_TERMS
                    contentDescription = "test-AddPayee-TermsBody"
                    setTextColor(getColor(R.color.lebyy_text))
                    textSize = 12f
                })
                addView(TextView(this@BankActivity).apply {
                    text = "— End of Terms —"
                    contentDescription = "test-AddPayee-TermsEnd"
                    setTextColor(getColor(R.color.lebyy_muted))
                    textSize = 12f
                    setPadding(0, dp(24), 0, 0)
                })
            }
            addView(inner)
            viewTreeObserver.addOnScrollChangedListener {
                val child = getChildAt(0) ?: return@addOnScrollChangedListener
                val atEnd = scrollY + height >= child.height - dp(8)
                if (atEnd && !BankState.bpTermsScrolledToEnd) {
                    BankState.bpTermsScrolledToEnd = true
                    BankState.lastResult = "Result: Terms scrolled to end — Save enabled"
                    (root.findViewWithTag("termsStatus") as? TextView)?.text = BankState.lastResult
                    (root.findViewWithTag("saveBtn") as? Button)?.isEnabled = true
                }
            }
        }
        root.addView(termsScroll)
        root.addView(TextView(this).apply {
            tag = "termsStatus"
            text = if (BankState.bpTermsScrolledToEnd) {
                "Result: Terms scrolled to end — Save enabled"
            } else {
                "Result: Scroll terms to the end to enable Save"
            }
            contentDescription = "test-AddPayee-TermsStatus"
            setTextColor(getColor(R.color.lebyy_muted))
            textSize = 12f
        })
        legal(root)
        root.addView(button("CANCEL", "test-AddPayee-AddressCancel") { finish() })
        val save = button("SAVE", "test-AddPayee-Save") {
            BankState.bpZip = zip.text.toString()
            BankState.bpPhone = phone.text.toString()
            val message = BankState.saveBillPayee()
            if (message == "Result: Payee added") open("billPayAddSuccess") else render()
        }.apply {
            tag = "saveBtn"
            isEnabled = BankState.bpTermsScrolledToEnd
        }
        root.addView(save)
        resultLine()
    }

    private fun renderBillPaySelectState(root: LinearLayout) {
        title("Select State", "test-SelectStateScreen")
        text("Select State", "test-SelectStateTitle")
        text("US States", "test-SelectState-USStates")
        BankState.usStates.forEach { region ->
            val mark = if (BankState.bpState == region) " ✓" else ""
            root.addView(button("$region$mark", "test-SelectState-${region.replace(" ", "")}") {
                BankState.bpState = region
                finish()
            })
        }
        text("Countries", "test-SelectState-Countries")
        BankState.countries.forEach { region ->
            val mark = if (BankState.bpState == region) " ✓" else ""
            root.addView(button("$region$mark", "test-SelectState-${region.replace(" ", "")}") {
                BankState.bpState = region
                finish()
            })
        }
    }

    private fun renderBillPayAddSuccess(root: LinearLayout) {
        title("Success", "test-AddPayeeSuccessScreen")
        text("Success", "test-AddPayeeSuccessTitle")
        val payee = BankState.selectedBillPayee()
        text("${payee?.name ?: "Payee"} was added.", "test-AddPayeeSuccessMessage")
        text("Name ${payee?.name.orEmpty()}", "test-AddPayeeSuccess-Name")
        text("Address ${payee?.address.orEmpty()}", "test-AddPayeeSuccess-Address")
        text("City ${payee?.city.orEmpty()}", "test-AddPayeeSuccess-City")
        text("State ${payee?.state.orEmpty()}", "test-AddPayeeSuccess-State")
        text("ZIP Code ${payee?.zip.orEmpty()}", "test-AddPayeeSuccess-Zip")
        root.addView(button("DONE", "test-AddPayeeSuccess-Done") {
            BankState.closeToBillPay = true
            finish()
        })
    }

    private fun renderBillPayPayment(root: LinearLayout) {
        title("Payment Details", "test-PaymentDetailsScreen")
        text("Payment Details", "test-PaymentDetailsTitle")
        text("Investment products are not FDIC-insured.", "test-PaymentDetails-FDIC")
        val payee = BankState.selectedBillPayee()
        text(payee?.name.orEmpty(), "test-PaymentDetails-Payee")
        val checking = BankState.currentCustomer()?.accounts?.firstOrNull { it.id == "checking" }
        text(
            "Pay From ${BankState.accountTitle("checking")}\nAvailable balance ${BankState.money(checking?.balance ?: 0.0)}",
            "test-PaymentDetails-PayFrom",
        )
        val amount = field("Enter amount", "test-PaymentDetails-Amount", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        amount.setText(BankState.bpPayAmountText)
        root.addView(amount)
        text("Frequency ${BankState.bpFrequency}", "test-PaymentDetails-Frequency")
        BankState.frequencies.forEach { freq ->
            root.addView(button(freq, "test-PaymentDetails-Freq-${freq.replace(" ", "")}") {
                BankState.bpFrequency = freq
                render()
            })
        }
        text(
            "Estimated Deliver by Date ${BankState.bpDeliverBy}\nEarliest Deliver by Date: ${BankState.bpDeliverBy}",
            "test-PaymentDetails-DeliverBy",
        )
        root.addView(button(
            if (BankState.bpMemoOn) "Add Memo/Note: ON" else "Add Memo/Note: OFF",
            "test-PaymentDetails-MemoToggle",
        ) {
            BankState.bpMemoOn = !BankState.bpMemoOn
            render()
        })
        val memo = field("Memo", "test-PaymentDetails-Memo", InputType.TYPE_CLASS_TEXT)
        memo.setText(BankState.bpMemo)
        if (BankState.bpMemoOn) root.addView(memo)
        text(
            "This payment will be sent by check. Please make sure you have sufficient funds.",
            "test-PaymentDetails-Note",
        )
        root.addView(button("CANCEL", "test-PaymentDetails-Cancel") { finish() })
        root.addView(button("PAY", "test-PaymentDetails-Pay") {
            BankState.bpPayAmountText = amount.text.toString()
            if (BankState.bpMemoOn) BankState.bpMemo = memo.text.toString()
            val message = BankState.confirmBillPayment()
            if (message.startsWith("Receipt:")) open("billPayPaySuccess") else {
                BankState.lastResult = message
                render()
            }
        })
        resultLine()
    }

    private fun renderBillPayPaySuccess(root: LinearLayout) {
        title("Success", "test-BillPaySuccessScreen")
        text("Success", "test-BillPaySuccessTitle")
        text("You've scheduled a payment.", "test-BillPaySuccessMessage")
        text("SAVE AS PDF", "test-BillPaySuccess-SavePdf")
        text("PRINT", "test-BillPaySuccess-Print")
        text("EMAIL", "test-BillPaySuccess-Email")
        text(BankState.selectedBillPayee()?.name.orEmpty(), "test-BillPaySuccess-Payee")
        text("Pay From ${BankState.accountTitle("checking")}", "test-BillPaySuccess-PayFrom")
        text(
            "Amount ${BankState.money(BankState.bpPayAmountText.toDoubleOrNull() ?: 0.0)}",
            "test-BillPaySuccess-Amount",
        )
        text("Deliver By (Estimated) ${BankState.bpDeliverBy}", "test-BillPaySuccess-DeliverBy")
        text("Frequency ${BankState.bpFrequency}", "test-BillPaySuccess-Frequency")
        text("Payment Type Check", "test-BillPaySuccess-Type")
        text("Confirmation ${BankState.lastConfirmation}", "test-BillPaySuccess-Confirmation")
        root.addView(button("DONE", "test-BillPaySuccess-Done") {
            BankState.closeToBillPay = true
            finish()
        })
    }

    private fun renderChooseAmount(root: LinearLayout) {
        title("Choose Amount", "test-ChooseAmountScreen")
        text("Choose Amount", "test-ChooseAmountTitle")
        text("No payment due at this time.", "test-ChooseAmount-Banner")
        text("* Response required", "test-PayBillsRequired")
        text("How much? *", "test-ChooseAmount-HowMuch")
        val balance = BankState.currentCustomer()?.card?.balance ?: 0.0
        root.addView(button(
            "Current balance - ${BankState.money(balance)}",
            "test-ChooseAmount-Balance",
        ) {
            BankState.payAmountMode = "balance"
            render()
        })
        root.addView(button("Other amount", "test-ChooseAmount-Other") {
            BankState.payAmountMode = "other"
            render()
        })
        val amount = field("Amount *", "test-ChooseAmount-Field", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        amount.setText(BankState.payAmountText.ifBlank { "1.00" })
        if (BankState.payAmountMode != "balance") root.addView(amount)
        legal(root)
        root.addView(button("SAVE", "test-ChooseAmount-Save") {
            val message = BankState.savePayAmount(
                BankState.payAmountMode,
                if (BankState.payAmountMode == "balance") "" else amount.text.toString(),
            )
            if (message == "Result: Amount saved") finish() else render()
        })
        root.addView(button("Close", "test-ChooseAmount-Close") { finish() })
        resultLine()
    }

    private fun renderPayReview(root: LinearLayout) {
        title("Review", "test-PayReviewScreen")
        text("Review payment details", "test-PayReviewHeading")
        val card = BankState.currentCustomer()?.card
        text(
            "To ${BankState.cardTitle()}\nCurrent balance ${BankState.money(card?.balance ?: 0.0)}",
            "test-PayReview-To",
        )
        text("From ${BankState.accountTitle(BankState.payFromAccountId)}", "test-PayReview-From")
        text("Amount ${BankState.payAmountDisplay()}", "test-PayReview-Amount")
        text("Date ${BankState.payDateLabel}\n${BankState.payDateDetail}", "test-PayReview-Date")
        root.addView(button("EDIT", "test-PayReview-Edit") { finish() })
        text(
            "Make sure your payment is made by the due date and that you have sufficient funds in the From account.",
            "test-PayReview-Disclaimer",
        )
        root.addView(button("PAY", "test-PayReview-Pay") {
            val message = BankState.confirmCardPayment()
            if (message.startsWith("Receipt:")) open("paySuccess") else {
                BankState.lastResult = message
                render()
            }
        })
        resultLine()
    }

    private fun renderPaySuccess(root: LinearLayout, heading: String, screenId: String, account: Boolean) {
        title("Success", screenId)
        text("Success", "test-PaySuccessTitle")
        text(heading, "test-PaySuccessHeading")
        root.addView(button("Print or Save", "test-PaySuccess-Print") {})
        if (account) {
            text("From ${BankState.accountTitle(BankState.acctFromId)}", "test-PaySuccess-From")
            text("To ${BankState.accountTitle(BankState.acctToId)}", "test-PaySuccess-To")
            text("Amount ${BankState.money(BankState.acctAmount)}", "test-PaySuccess-Amount")
            text("Date ${BankState.acctDateLabel}\n${BankState.acctDateDetail}", "test-PaySuccess-Date")
        } else {
            val card = BankState.currentCustomer()?.card
            text(
                "To ${BankState.cardTitle()}\nCurrent balance ${BankState.money(card?.balance ?: 0.0)}",
                "test-PaySuccess-To",
            )
            text("From ${BankState.accountTitle(BankState.payFromAccountId)}", "test-PaySuccess-From")
            text("Amount ${BankState.payAmountDisplay()}", "test-PaySuccess-Amount")
            text("Date ${BankState.payDateLabel}\n${BankState.payDateDetail}", "test-PaySuccess-Date")
        }
        text("Confirmation number ${BankState.lastConfirmation}", "test-PaySuccess-Confirmation")
        root.addView(button("DONE", "test-PaySuccess-Done") {
            BankState.closeBankFlow = true
            finish()
        })
    }

    private fun renderChooseAccount(root: LinearLayout) {
        title("Choose account", "test-ChooseAccountScreen")
        val mode = intent.getStringExtra(EXTRA_CHOOSE).orEmpty()
        BankState.currentCustomer()?.accounts?.forEach { account ->
            root.addView(button(
                "${account.name} - ${account.number.takeLast(4)} · ${BankState.money(account.balance)}",
                "test-ChooseAccount-${account.name}",
            ) {
                when (mode) {
                    "acctFrom" -> BankState.acctFromId = account.id
                    "acctTo" -> BankState.acctToId = account.id
                    "payFrom" -> BankState.payFromAccountId = account.id
                }
                finish()
            })
        }
        root.addView(button("Close", "test-ChooseClose") { finish() })
    }

    private fun legal(root: LinearLayout) {
        text("Legal info and disclosures", "test-PT-Legal")
        text("Are Not FDIC Insured", "test-PT-Legal-1")
        text("Are Not Bank Guaranteed", "test-PT-Legal-2")
        text("May Lose Value", "test-PT-Legal-3")
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
                putExtra(EXTRA_CHOOSE, intent.getStringExtra(EXTRA_CHOOSE))
            },
        )
        if (next == "receipt" || next == "paySuccess" || next == "acctTransferSuccess") {
            // leave prior form in back stack except when closing the whole flow via DONE
        }
    }

    private fun dp(value: Int): Int = (value * resources.displayMetrics.density).toInt()

    companion object {
        const val EXTRA_SCREEN = "screen"
        const val EXTRA_ID = "id"
        const val EXTRA_QUERY = "query"
        const val EXTRA_FILTER = "filter"
        const val EXTRA_CHOOSE = "choose"

        private const val BILL_PAY_TERMS = """
Bill Pay Terms & Conditions

1. By adding a payee, you authorize Lebyy Bank to mail checks or send electronic payments to the address you provide.

2. Payments may take 4–7 business days for delivery when sent by check. You are responsible for ensuring sufficient funds remain available until the check is cashed.

3. You agree to verify payee name and mailing address. Incorrect information may delay or prevent delivery.

4. Lebyy Bank is not responsible for delays caused by the postal service or the payee.

5. You may cancel a scheduled payment before the processing cut-off shown in Activity.

6. Fees may apply for rush delivery or returned checks as described in your account agreement.

7. These terms are for practice automation. Scroll to the end to acknowledge and enable Save.

8. End of Terms & Conditions — acknowledgement complete when this line is visible.
"""

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
