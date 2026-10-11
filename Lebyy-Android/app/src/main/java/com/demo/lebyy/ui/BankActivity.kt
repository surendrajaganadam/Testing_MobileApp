package com.demo.lebyy.ui

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.text.Editable
import android.text.InputType
import android.text.TextWatcher
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.setPadding
import com.demo.lebyy.R
import com.demo.lebyy.data.BankCustomer
import com.demo.lebyy.data.BankState
import com.demo.lebyy.databinding.ActivityBankBinding
import com.google.android.material.dialog.MaterialAlertDialogBuilder

class BankActivity : AppCompatActivity() {
    private lateinit var binding: ActivityBankBinding
    private var screen: String = "transfer"
    private var pendingCheckSide: String? = null
    private var depositFrontUri: Uri? = null
    private var depositBackUri: Uri? = null

    private val pickCheckGallery = registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        if (uri != null) {
            applyCheckPhoto(uri, "Gallery")
        }
        pendingCheckSide = null
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityBankBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setSupportActionBar(binding.bankToolbar)
        binding.bankToolbar.setNavigationOnClickListener { finish() }
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        binding.bankToolbar.menu.clear()
        val exitBank = TextView(this).apply {
            text = "Exit Bank"
            contentDescription = "test-ExitBank"
            setTextColor(0xFFFFFFFF.toInt())
            textSize = 13f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setBackgroundColor(0xFFDB2626.toInt())
            setPadding(36, 20, 36, 20)
            setOnClickListener {
                BankState.exitBankToApp = true
                BankState.closeBankFlow = true
                finish()
            }
        }
        binding.bankToolbar.menu.add(0, MENU_EXIT_BANK, 0, "Exit Bank").apply {
            actionView = exitBank
            setShowAsAction(android.view.MenuItem.SHOW_AS_ACTION_ALWAYS)
        }
        screen = intent.getStringExtra(EXTRA_SCREEN) ?: "transfer"
        if (screen == "deposit") BankState.resetDepositDraft()
        render()
    }

    override fun onResume() {
        super.onResume()
        if (BankState.closeBankFlow) {
            finish()
            return
        }
        if (BankState.closeToBillPay && screen != "billPayList" && screen != "payBills") {
            finish()
            return
        }
        if (BankState.closeToBillPay && screen == "payBills") {
            // After add-payee success, jump from Recipients stack into Bill Pay list
            BankState.closeToBillPay = false
            open("billPayList")
            return
        }
        if (BankState.closeToBillPay && screen == "billPayList") {
            BankState.closeToBillPay = false
        }
        if (BankState.closeToZellePay) {
            when (screen) {
                "zellePay" -> {
                    BankState.closeToZellePay = false
                    render()
                }
                // Hub screens under the add stack — open the recipient list.
                "zelle", "payTransfer", "payBills" -> {
                    BankState.closeToZellePay = false
                    open("zellePay")
                }
                else -> finish()
            }
            return
        }
        if (screen in listOf(
                "payees", "pending", "customers", "decisions", "activity", "cards", "bills",
                "acctTransfer", "payBills", "payTransfer", "billPayAddress", "billPayPayment",
                "billPayList",
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
            "payBills" -> renderRecipients(root)
            "billPayList" -> renderBillPayList(root)
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
            "zelle" -> renderZelleHome(root)
            "zellePay" -> renderZellePay(root)
            "zelleWho" -> renderZelleWho(root)
            "zelleHow" -> renderZelleHow(root)
            "zelleInfo" -> renderZelleInfo(root)
            "zelleReview" -> renderZelleReview(root)
            "zelleEdit" -> renderZelleEdit(root)
            "zelleAuthSend" -> renderZelleAuthSend(root)
            "zelleAuthEnter" -> renderZelleAuthEnter(root)
            "zellePayDetails" -> renderZellePayDetails(root)
            "zellePayReview" -> renderZellePayReview(root)
            "zelleSuccess" -> renderZelleSuccess(root)
            "wire" -> renderShell(root, "Wire", "test-WireScreen", "Result: Wire opened — U.S. or international practice screen")
            "menu" -> renderShell(root, "Menu", "test-BankMenuScreen", "Result: Menu opened")
            "inbox" -> renderShell(root, "Inbox", "test-BankInboxScreen", "Result: Inbox opened")
            "products" -> renderShell(root, "Products", "test-BankProductsScreen", "Result: Products opened")
            "rewards" -> renderShell(root, "Lebyy Rewards", "test-BankRewardsScreen", "Result: Rewards opened")
            "profile" -> renderShell(root, "Profile", "test-BankProfileScreen", "Result: Profile opened")
            "deposit" -> renderDepositChecks(root)
            "depositSuccess" -> renderDepositSuccess(root)
            "invest" -> renderShell(root, "Invest", "test-BankInvestScreen", "Result: Invest opened")
            "assistant" -> renderShell(root, "Lebyy Assistant", "test-BankAssistantScreen", "Result: Assistant opened")
            else -> finish()
        }
    }

    private fun renderShell(root: LinearLayout, titleText: String, screenId: String, result: String) {
        title(titleText, screenId)
        text(result, "test-BankShellResult")
    }

    private fun renderZelleHome(root: LinearLayout) {
        title("Zelle®", "test-ZelleScreen")
        text("Zelle®", "test-ZelleTitle")
        text("Send or receive money with Zelle®", "test-Zelle-Heading")
        text("or send to other Lebyy accounts you've added", "test-Zelle-Subheading")
        text("Keep contact info private", "test-Zelle-PrivacyTitle")
        text(
            "You can send or request money to a Zelle® tag. Right now, only Business Banking clients can create and receive money to a Zelle® tag.",
            "test-Zelle-PrivacyBody",
        )
        root.addView(button("SEE THE LATEST SCAMS", "test-Zelle-Scams") {})
        root.addView(button("Pay", "test-Zelle-Pay") { open("zellePay") })
        root.addView(button("Request", "test-Zelle-Request") {
            BankState.lastResult = "Result: Request opened"
            render()
        })
        root.addView(button("Scan", "test-Zelle-Scan") {
            BankState.lastResult = "Result: Scan opened"
            render()
        })
        root.addView(button("SETTINGS", "test-Zelle-Settings") {})
        root.addView(button("RECIPIENTS", "test-Zelle-Recipients") { open("zellePay") })
        text("Pay again", "test-Zelle-PayAgainTitle")
        text("RECENT", "test-Zelle-RecentLabel")
        BankState.zelleRecipients().take(6).forEach { r ->
            text(r.displayName, "test-Zelle-Recent-${r.id}")
        }
        if (BankState.lastResult.isNotBlank()) {
            text(BankState.lastResult, "test-Zelle-Result")
        }
        resultLine()
    }

    private fun renderZellePay(root: LinearLayout) {
        title("Pay", "test-ZellePayScreen")
        text("Pay", "test-ZellePayTitle")
        if (BankState.zelleShowAddedBanner) {
            text("Recipient added", "test-ZellePay-AddedTitle")
            text(
                "Be sure to double-check the contact information of the Zelle® recipient before sending a payment.",
                "test-ZellePay-AddedBanner",
            )
            root.addView(button("Send a payment", "test-ZellePay-SendPayment") {
                BankState.resetZellePayDraft()
                open("zellePayDetails")
            })
            root.addView(button("Dismiss", "test-ZellePay-DismissBanner") {
                BankState.zelleShowAddedBanner = false
                render()
            })
        }
        text("Who are you paying?", "test-ZellePay-WhoTitle")
        val search = field("Search", "test-ZellePay-Search", InputType.TYPE_CLASS_TEXT)
        search.setText(BankState.zelleSearchQuery)
        root.addView(search)
        root.addView(button("Apply search", "test-ZellePay-SearchApply") {
            BankState.zelleSearchQuery = search.text.toString()
            render()
        })
        BankState.filteredZelleRecipients().forEach { r ->
            val selected = r.id == BankState.zelleSelectedRecipientId
            root.addView(button(
                "${r.displayName}\n${r.contact}${if (selected) "\n✓ selected" else ""}",
                "test-ZellePay-Recipient-${r.id}",
            ) {
                BankState.zelleSelectedRecipientId = r.id
                BankState.resetZellePayDraft()
                open("zellePayDetails")
            })
        }
        root.addView(button("Add new recipient", "test-ZellePay-AddNew") {
            BankState.resetZelleAddDraft()
            open("zelleWho")
        })
        zelleLegal(root)
        resultLine()
    }

    private fun renderZelleWho(root: LinearLayout) {
        title("Who are you adding?", "test-ZelleWhoScreen")
        text("Who are you adding?", "test-ZelleWho-Title")
        root.addView(button(
            "Person${if (BankState.zelleWhoType == "Person") " ✓" else ""}",
            "test-ZelleWho-Person",
        ) {
            BankState.zelleWhoType = "Person"
            render()
        })
        root.addView(button(
            "Business${if (BankState.zelleWhoType == "Business") " ✓" else ""}",
            "test-ZelleWho-Business",
        ) {
            BankState.zelleWhoType = "Business"
            render()
        })
        zelleLegal(root)
        root.addView(button("NEXT", "test-ZelleWho-Next") {
            if (BankState.zelleWhoType == "Person") {
                open("zelleHow")
            } else {
                BankState.lastResult = "Result: Business add is not in this practice path"
                render()
            }
        })
        resultLine()
    }

    private fun renderZelleHow(root: LinearLayout) {
        title("How are you adding them?", "test-ZelleHowScreen")
        text("How are you adding them?", "test-ZelleHow-Title")
        root.addView(button(
            "Mobile number or email${if (BankState.zelleAddMethod == "Mobile number or email") " ✓" else ""}",
            "test-ZelleHow-MobileEmail",
        ) {
            BankState.zelleAddMethod = "Mobile number or email"
            render()
        })
        root.addView(button(
            "Lebyy account number${if (BankState.zelleAddMethod == "Lebyy account number") " ✓" else ""}",
            "test-ZelleHow-Account",
        ) {
            BankState.zelleAddMethod = "Lebyy account number"
            render()
        })
        zelleLegal(root)
        root.addView(button("NEXT", "test-ZelleHow-Next") {
            if (BankState.zelleAddMethod == "Mobile number or email") {
                open("zelleInfo")
            } else {
                BankState.lastResult = "Result: Account number add is not in this practice path"
                render()
            }
        })
        resultLine()
    }

    private fun renderZelleInfo(root: LinearLayout) {
        title("Enter their info", "test-ZelleInfoScreen")
        text("Enter their info", "test-ZelleInfo-Title")
        val contact = field("Mobile number or email*", "test-ZelleInfo-Contact", InputType.TYPE_CLASS_TEXT)
        contact.setText(BankState.zelleContact)
        root.addView(contact)
        val first = field("First name*", "test-ZelleInfo-FirstName", InputType.TYPE_CLASS_TEXT)
        first.setText(BankState.zelleFirstName)
        root.addView(first)
        val last = field("Last name*", "test-ZelleInfo-LastName", InputType.TYPE_CLASS_TEXT)
        last.setText(BankState.zelleLastName)
        root.addView(last)
        root.addView(button("NEXT", "test-ZelleInfo-Next") {
            BankState.zelleContact = contact.text.toString()
            BankState.zelleFirstName = first.text.toString()
            BankState.zelleLastName = last.text.toString()
            val msg = BankState.validateZelleRecipientInfo()
            if (msg.isEmpty()) {
                BankState.lastResult = ""
                open("zelleReview")
            } else {
                BankState.lastResult = msg
                render()
            }
        })
        if (BankState.lastResult.isNotBlank()) {
            text(BankState.lastResult, "test-ZelleInfo-Result")
        }
        resultLine()
    }

    private fun renderZelleReview(root: LinearLayout) {
        title("Review", "test-ZelleReviewScreen")
        text("Review", "test-ZelleReviewTitle")
        text("Review", "test-ZelleReview-Heading")
        text(BankState.zelleContact, "test-ZelleReview-Contact")
        text(BankState.zelleFirstName, "test-ZelleReview-FirstName")
        text(BankState.zelleLastName, "test-ZelleReview-LastName")
        root.addView(button("Edit", "test-ZelleReview-Edit") { open("zelleEdit") })
        zelleLegal(root)
        root.addView(button("Add recipient", "test-ZelleReview-AddRecipient") { open("zelleAuthSend") })
        root.addView(button("Close", "test-ZelleReview-Close") {
            BankState.closeBankFlow = true
            finish()
        })
    }

    private fun renderZelleEdit(root: LinearLayout) {
        title("Edit info", "test-ZelleEditScreen")
        val contact = field("Mobile number or email*", "test-ZelleEdit-Contact", InputType.TYPE_CLASS_TEXT)
        contact.setText(BankState.zelleContact)
        root.addView(contact)
        val first = field("First name*", "test-ZelleEdit-FirstName", InputType.TYPE_CLASS_TEXT)
        first.setText(BankState.zelleFirstName)
        root.addView(first)
        val last = field("Last name*", "test-ZelleEdit-LastName", InputType.TYPE_CLASS_TEXT)
        last.setText(BankState.zelleLastName)
        root.addView(last)
        val nick = field("Nickname (Optional)", "test-ZelleEdit-Nickname", InputType.TYPE_CLASS_TEXT)
        nick.setText(BankState.zelleNickname)
        root.addView(nick)
        root.addView(button("NEXT", "test-ZelleEdit-Next") {
            BankState.zelleContact = contact.text.toString()
            BankState.zelleFirstName = first.text.toString()
            BankState.zelleLastName = last.text.toString()
            BankState.zelleNickname = nick.text.toString()
            val msg = BankState.validateZelleRecipientInfo()
            if (msg.isEmpty()) {
                BankState.lastResult = ""
                finish()
            } else {
                BankState.lastResult = msg
                render()
            }
        })
        resultLine()
    }

    private fun renderZelleAuthSend(root: LinearLayout) {
        title("Authorize", "test-ZelleAuthSendScreen")
        text("We'll send a code to verify it's you", "test-ZelleAuthSend-Title")
        text("••• •• ••67", "test-ZelleAuthSend-Phone")
        root.addView(button(
            "Text message${if (BankState.zelleAuthChannel == "Text message") " ✓" else ""}",
            "test-ZelleAuthSend-Text",
        ) {
            BankState.zelleAuthChannel = "Text message"
            render()
        })
        root.addView(button(
            "Phone call${if (BankState.zelleAuthChannel == "Phone call") " ✓" else ""}",
            "test-ZelleAuthSend-Call",
        ) {
            BankState.zelleAuthChannel = "Phone call"
            render()
        })
        text("Practice: enter any 6-digit code", "test-ZelleAuthSend-Hint")
        root.addView(button("Cancel", "test-ZelleAuthSend-Cancel") { finish() })
        root.addView(button("Send", "test-ZelleAuthSend-Send") { open("zelleAuthEnter") })
    }

    private fun renderZelleAuthEnter(root: LinearLayout) {
        title("Enter code", "test-ZelleAuthEnterScreen")
        text("Enter the code we sent you", "test-ZelleAuthEnter-Title")
        val code = field("Code *", "test-ZelleAuthEnter-Code", InputType.TYPE_CLASS_NUMBER)
        root.addView(code)
        root.addView(button("Resend code", "test-ZelleAuthEnter-Resend") {
            BankState.lastResult = "Result: Code resent"
            render()
        })
        root.addView(button("Cancel", "test-ZelleAuthEnter-Cancel") { finish() })
        root.addView(button("Submit", "test-ZelleAuthEnter-Submit") {
            val msg = BankState.submitZelleAuthCode(code.text.toString())
            if (msg == "Result: Recipient added") {
                // Pop add/OTP stack back to the Zelle recipient list.
                BankState.closeToZellePay = true
                finish()
            } else {
                render()
            }
        })
        if (BankState.lastResult.isNotBlank()) {
            text(BankState.lastResult, "test-ZelleAuthEnter-Result")
        }
        resultLine()
    }

    private fun renderZellePayDetails(root: LinearLayout) {
        title("Pay", "test-ZellePayDetailsScreen")
        text("Pay", "test-ZellePayDetailsTitle")
        text(
            "You have ${BankState.money(BankState.zelleDailyLimitLeft)} left of your daily limit to send to this recipient.",
            "test-ZellePayDetails-Limit",
        )
        val recipient = BankState.selectedZelleRecipient()
        if (recipient != null) {
            text("${recipient.displayName}\n${recipient.contact}", "test-ZellePayDetails-To")
            if (!recipient.enrolled) {
                text("${recipient.contact} isn't enrolled with Zelle®", "test-ZellePayDetails-NotEnrolled")
            }
        }
        text(BankState.accountTitle(BankState.zelleFromAccountId), "test-ZellePayDetails-From")
        BankState.currentCustomer()?.accounts?.forEach { account ->
            root.addView(button(
                "${account.name}${if (account.id == BankState.zelleFromAccountId) " ✓" else ""}",
                "test-ZellePayDetails-Account-${account.id.replaceFirstChar { it.uppercase() }}",
            ) {
                BankState.zelleFromAccountId = account.id
                render()
            })
        }
        val amount = field("Amount", "test-ZellePayDetails-Amount", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        amount.setText(BankState.zelleAmountText)
        root.addView(amount)
        text("Today", "test-ZellePayDetails-Date")
        val message = field("Add a message (Optional)", "test-ZellePayDetails-Message", InputType.TYPE_CLASS_TEXT)
        message.setText(BankState.zelleMessage)
        root.addView(message)
        zelleLegal(root)
        root.addView(button("NEXT", "test-ZellePayDetails-Next") {
            BankState.zelleAmountText = amount.text.toString()
            BankState.zelleMessage = message.text.toString().take(140)
            when {
                BankState.selectedZelleRecipient() == null -> {
                    BankState.lastResult = "Result: Select recipient"
                    render()
                }
                BankState.zelleAmountText.toDoubleOrNull() == null ||
                    (BankState.zelleAmountText.toDoubleOrNull() ?: 0.0) <= 0.0 -> {
                    BankState.lastResult = "Result: Enter amount"
                    render()
                }
                else -> {
                    BankState.lastResult = ""
                    open("zellePayReview")
                }
            }
        })
        root.addView(button("Close", "test-ZellePayDetails-Close") {
            BankState.closeBankFlow = true
            finish()
        })
        if (BankState.lastResult.isNotBlank()) {
            text(BankState.lastResult, "test-ZellePayDetails-Result")
        }
        resultLine()
    }

    private fun renderZellePayReview(root: LinearLayout) {
        title("Review", "test-ZellePayReviewScreen")
        text("Review", "test-ZellePayReviewTitle")
        text("Review your payment", "test-ZellePayReview-Heading")
        val recipient = BankState.selectedZelleRecipient()
        if (recipient != null) {
            text("${recipient.displayName}\n${recipient.contact}", "test-ZellePayReview-To")
        }
        text(BankState.accountTitle(BankState.zelleFromAccountId), "test-ZellePayReview-From")
        text(BankState.money(BankState.zelleAmountText.toDoubleOrNull() ?: 0.0), "test-ZellePayReview-Amount")
        text("Today", "test-ZellePayReview-Date")
        root.addView(button("Edit", "test-ZellePayReview-Edit") { finish() })
        root.addView(button("Pay", "test-ZellePayReview-Pay") {
            val msg = BankState.confirmZellePayment()
            if (msg.startsWith("Receipt:")) {
                open("zelleSuccess")
            } else {
                BankState.lastResult = msg
                render()
            }
        })
        root.addView(button("Close", "test-ZellePayReview-Close") {
            BankState.closeBankFlow = true
            finish()
        })
        if (BankState.lastResult.isNotBlank()) {
            text(BankState.lastResult, "test-ZellePayReview-Result")
        }
        resultLine()
    }

    private fun renderZelleSuccess(root: LinearLayout) {
        title("Success", "test-ZelleSuccessScreen")
        text("Success", "test-ZelleSuccessTitle")
        text("Your Zelle® payment was sent.", "test-ZelleSuccessMessage")
        BankState.selectedZelleRecipient()?.let {
            text(it.displayName, "test-ZelleSuccess-To")
        }
        text("Amount ${BankState.money(BankState.zelleAmountText.toDoubleOrNull() ?: 0.0)}", "test-ZelleSuccess-Amount")
        text("Confirmation ${BankState.lastConfirmation}", "test-ZelleSuccess-Confirmation")
        root.addView(button("DONE", "test-ZelleSuccess-Done") {
            BankState.closeBankFlow = true
            finish()
        })
    }

    private fun zelleLegal(root: LinearLayout) {
        text("Legal info and disclosures", "test-Zelle-Legal")
        text(
            "Investment, insurance and annuity products:\n• Are Not FDIC Insured\n• Are Not Bank Guaranteed\n• May Lose Value\n• Are Not Deposits",
            "test-Zelle-LegalBody",
        )
    }

    private fun renderDepositChecks(root: LinearLayout) {
        title("Deposit Checks", "test-BankDepositScreen")
        chromeRow(
            menuId = "test-Deposit-Menu",
            titleText = "Deposit Checks",
            titleId = "test-DepositTitle",
            inboxId = "test-Deposit-Inbox",
            productsId = "test-Deposit-Products",
            logOutId = "test-Deposit-LogOut",
        )
        text("Hi, I'm Erica. How can I help?", "test-Deposit-Assistant")
        text(
            "Lebyy deposit products. Member FDIC. Investment products are not FDIC-insured.",
            "test-Deposit-FdicBanner",
        )
        text(
            "Sign and write \"for deposit only at Lebyy Bank\" on the back of your check.",
            "test-Deposit-Instruction",
        )

        val tiles = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            )
        }
        tiles.addView(checkTile("Front of Check", BankState.depositFrontReady, BankState.depositFrontSource, "test-Deposit-Front", depositFrontUri) {
            showCheckPhotoOptions("front")
        })
        tiles.addView(checkTile("Back of Check", BankState.depositBackReady, BankState.depositBackSource, "test-Deposit-Back", depositBackUri) {
            showCheckPhotoOptions("back")
        })
        root.addView(tiles)

        val accountLabel = if (BankState.depositAccountId.isBlank()) {
            "Select account"
        } else {
            BankState.accountTitle(BankState.depositAccountId)
        }
        root.addView(button("Deposit to  $accountLabel", "test-Deposit-Account") {
            val accounts = BankState.currentCustomer()?.accounts.orEmpty()
            val labels = accounts.map { "${it.name} - ${it.number.takeLast(4)}" }.toTypedArray()
            MaterialAlertDialogBuilder(this)
                .setTitle("Select account")
                .setItems(labels) { _, which ->
                    BankState.depositAccountId = accounts[which].id
                    render()
                }
                .show()
        })
        accountsForDepositButtons(root)

        val amount = field("Enter amount", "test-Deposit-Amount", InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_DECIMAL)
        amount.setText(BankState.depositAmountText)
        root.addView(amount)
        text(
            if (BankState.depositAmountText.isBlank()) "₹0.00"
            else BankState.money(BankState.depositAmountText.toDoubleOrNull() ?: 0.0),
            "test-Deposit-AmountDisplay",
        )

        root.addView(button("CANCEL", "test-Deposit-Cancel") { finish() })
        val next = button("NEXT", "test-Deposit-Next") {
            BankState.depositAmountText = amount.text.toString()
            val message = BankState.confirmDeposit()
            if (message.startsWith("Receipt:")) open("depositSuccess") else render()
        }
        next.isEnabled = BankState.validateDeposit().isEmpty()
        root.addView(next)
        legal(root, titleId = "test-Deposit-LegalTitle", bodyId = "test-Deposit-LegalBody")
        resultLine("test-Deposit-Result")
    }

    private fun accountsForDepositButtons(root: LinearLayout) {
        BankState.currentCustomer()?.accounts?.forEach { account ->
            root.addView(button(
                "${account.name} - ${account.number.takeLast(4)} · ${BankState.money(account.balance)}",
                "test-Deposit-Account-${account.id.replaceFirstChar { it.uppercase() }}",
            ) {
                BankState.depositAccountId = account.id
                render()
            })
        }
    }

    private fun checkTile(
        titleText: String,
        ready: Boolean,
        source: String,
        id: String,
        uri: Uri?,
        onClick: () -> Unit,
    ): LinearLayout {
        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            contentDescription = id
            setPadding(dp(8))
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            setOnClickListener { onClick() }
            addView(ImageView(this@BankActivity).apply {
                layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(110))
                scaleType = ImageView.ScaleType.CENTER_CROP
                setBackgroundColor(getColor(R.color.lebyy_surface))
                if (uri != null) {
                    setImageURI(uri)
                } else if (ready) {
                    setImageResource(R.drawable.course_1)
                } else {
                    setImageResource(android.R.drawable.ic_menu_camera)
                }
            })
            addView(TextView(this@BankActivity).apply {
                text = titleText
                setTextColor(getColor(R.color.lebyy_text))
                textSize = 12f
            })
            addView(TextView(this@BankActivity).apply {
                text = if (ready) "Added · $source" else "Tap to add photo"
                setTextColor(getColor(R.color.lebyy_muted))
                textSize = 11f
            })
        }
    }

    private fun showCheckPhotoOptions(side: String) {
        pendingCheckSide = side
        val panel = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16), dp(8), dp(16), dp(8))
        }
        panel.addView(button("Take Photo", "test-Deposit-TakePhoto") {
            applyCheckPhoto(null, "Camera")
        })
        panel.addView(button("Upload from Gallery", "test-Deposit-UploadGallery") {
            pickCheckGallery.launch("image/*")
        })
        panel.addView(button("Cancel", "test-Deposit-DialogCancel") {
            pendingCheckSide = null
        })
        val dialog = MaterialAlertDialogBuilder(this)
            .setTitle(if (side == "front") "Front of Check" else "Back of Check")
            .setView(panel)
            .setOnCancelListener { pendingCheckSide = null }
            .create()
        // Re-wire buttons so they dismiss the dialog after action
        (panel.getChildAt(0) as Button).setOnClickListener {
            dialog.dismiss()
            applyCheckPhoto(null, "Camera")
        }
        (panel.getChildAt(1) as Button).setOnClickListener {
            dialog.dismiss()
            pickCheckGallery.launch("image/*")
        }
        (panel.getChildAt(2) as Button).setOnClickListener {
            pendingCheckSide = null
            dialog.dismiss()
        }
        dialog.show()
    }

    private fun applyCheckPhoto(uri: Uri?, source: String) {
        val side = pendingCheckSide ?: return
        when (side) {
            "front" -> {
                BankState.depositFrontReady = true
                BankState.depositFrontSource = source
                depositFrontUri = uri
            }
            "back" -> {
                BankState.depositBackReady = true
                BankState.depositBackSource = source
                depositBackUri = uri
            }
        }
        BankState.lastResult = "Result: ${side.replaceFirstChar { it.uppercase() }} photo from $source"
        pendingCheckSide = null
        if (screen == "deposit") render()
    }

    private fun renderDepositSuccess(root: LinearLayout) {
        title("Success", "test-DepositSuccessScreen")
        text("Success", "test-DepositSuccessTitle")
        text("Your check deposit was submitted.", "test-DepositSuccessMessage")
        text("Deposit to ${BankState.accountTitle(BankState.depositAccountId)}", "test-DepositSuccess-Account")
        text(
            "Amount ${BankState.money(BankState.depositAmountText.toDoubleOrNull() ?: 0.0)}",
            "test-DepositSuccess-Amount",
        )
        text("Front ${BankState.depositFrontSource}", "test-DepositSuccess-Front")
        text("Back ${BankState.depositBackSource}", "test-DepositSuccess-Back")
        text("Confirmation ${BankState.lastConfirmation}", "test-DepositSuccess-Confirmation")
        root.addView(button("DONE", "test-DepositSuccess-Done") {
            BankState.closeBankFlow = true
            finish()
        })
    }

    private fun renderPayTransfer(root: LinearLayout) {
        title("Pay & Transfer", "test-PayTransferScreen")
        chromeRow(
            menuId = "test-PT-Menu",
            titleText = "Pay & Transfer",
            titleId = "test-PayTransferTitle",
            inboxId = "test-PT-Inbox",
            productsId = "test-PT-Products",
            logOutId = "test-PT-LogOut",
        )
        text("Hi, I'm Lebyy. How can I help?", "test-PT-Assistant")
        val grid = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            contentDescription = "test-PT-ActionGrid"
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
        }
        grid.addView(button("Transfer\nbetween my accounts", "test-PT-Transfer") {
            BankState.resetAcctTransferDraft()
            open("acctTransfer")
        })
        grid.addView(button("Zelle\nsend or receive", "test-PT-Zelle") { open("zelle") })
        grid.addView(button("Pay Bills\npay now or schedule", "test-PT-PayBills") {
            BankState.bpSelectedPayeeId = ""
            BankState.lastResult = ""
            BankState.closeToBillPay = false
            open("payBills")
        })
        grid.addView(button("Wire\nU.S. or international", "test-PT-Wire") { open("wire") })
        root.addView(grid)
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

    private fun renderRecipients(root: LinearLayout) {
        title("Recipients", "test-RecipientsScreen")
        text("Recipients", "test-RecipientsTitle")
        root.addView(button("Close", "test-Recipients-Close") { finish() })
        text("Bank of America", "test-Recipients-Section-BankofAmerica")
        BankState.billPayees().filter { it.section == "Bank of America" }.forEach { payee ->
            text(
                "${payee.name}\nNo recent payments available",
                "test-Recipients-Payee-${payee.id}",
            )
        }
        text("Other payees", "test-Recipients-Section-Otherpayees")
        BankState.billPayees().filter { it.section != "Bank of America" }.forEach { payee ->
            text(
                "${payee.name}\nNo recent payments available",
                "test-Recipients-Payee-${payee.id}",
            )
        }
        root.addView(button("Add a new payee", "test-Recipients-AddPayee") {
            BankState.resetBillPayeeDraft()
            open("billPayAddWho")
        })
        root.addView(button("Go to Bill Pay", "test-Recipients-GoBillPay") {
            open("billPayList")
        })
        resultLine()
    }

    private fun renderBillPayList(root: LinearLayout) {
        title("Bill Pay", "test-BillPayScreen")
        root.addView(button("Back", "test-BillPay-Back") { finish() })
        text("Bill Pay", "test-BillPayTitle")
        text("Hi, I'm Erica. How can I help?", "test-BillPay-Assistant")
        val tab = intent.getStringExtra("billPayTab") ?: "Pay"
        root.addView(button("Pay${if (tab == "Pay") " ✓" else ""}", "test-BillPay-TabPay") {
            intent.putExtra("billPayTab", "Pay")
            render()
        })
        root.addView(button("Activity${if (tab == "Activity") " ✓" else ""}", "test-BillPay-TabActivity") {
            intent.putExtra("billPayTab", "Activity")
            render()
        })
        if (tab == "Activity") {
            text("No recent Bill Pay activity.", "test-BillPay-ActivityEmpty")
            resultLine("test-BillPay-Result")
            return
        }
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
        root.addView(button("PAY", "test-BillPay-Pay") {
            if (BankState.bpSelectedPayeeId.isBlank()) {
                BankState.lastResult = "Result: Select a payee"
                render()
            } else {
                BankState.resetBillPaymentDraft()
                open("billPayPayment")
            }
        })
        resultLine("test-BillPay-Result")
    }

    private fun renderBillPayAddWho(root: LinearLayout) {
        title("Add Payee", "test-AddPayeeWhoScreen")
        root.addView(button("Back", "test-AddPayee-Back") { finish() })
        text("Who do you want to add?", "test-AddPayee-WhoTitle")
        root.addView(button("Company", "test-AddPayee-Company") {
            BankState.lastResult = "Result: Company add is not in this practice path — use Bill Pay person"
            render()
        })
        text("Person", "test-AddPayee-PersonLabel")
        root.addView(button(
            "Pay them with Zelle®\nSend money quickly using their US mobile # / email",
            "test-AddPayee-Zelle",
        ) {
            BankState.resetZelleAddDraft()
            open("zelleWho")
        })
        root.addView(button(
            "Pay them with Bill Pay\nMail a check to their US address in 4-7 days",
            "test-AddPayee-BillPayPerson",
        ) {
            BankState.resetBillPayeeDraft()
            open("billPayPerson")
        })
        text("Learn when to use Zelle vs. Bill Pay", "test-AddPayee-LearnLink")
        legal(root, titleId = "test-AddPayee-LegalTitle", bodyId = "test-AddPayee-LegalBody")
        resultLine("test-AddPayee-WhoResult")
    }

    private fun renderBillPayPerson(root: LinearLayout) {
        title("Add Payee", "test-AddPayeePersonScreen")
        // Legacy wait target — same form now includes address fields
        root.addView(View(this).apply {
            contentDescription = "test-AddPayeeAddressScreen"
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
            layoutParams = LinearLayout.LayoutParams(1, 1)
        })
        text("Enter the person's information.", "test-AddPayee-PersonHint")
        val errors = BankState.billPayeeFieldErrors().toMutableMap()
        // Only show errors after a failed save attempt
        val showErrors = BankState.lastResult.startsWith("Result:") &&
            BankState.lastResult != "Result: Terms scrolled to end — Save enabled" &&
            BankState.lastResult != "Result: Payee added"

        fun labeledField(
            label: String,
            id: String,
            value: String,
            inputType: Int,
            errorKey: String? = null,
        ): EditText {
            text(label, "$id-Label")
            val edit = field(label, id, inputType)
            edit.setText(value)
            val err = if (showErrors) errorKey?.let { errors[it] } else null
            if (err != null) {
                edit.setBackgroundColor(0x22FF0000)
                edit.setHintTextColor(0xFFCC0000.toInt())
            }
            root.addView(edit)
            if (err != null) {
                root.addView(TextView(this).apply {
                    text = err
                    setTextColor(0xFFCC0000.toInt())
                    textSize = 12f
                    contentDescription = "$id-Error"
                    setPadding(dp(4), 0, dp(4), dp(6))
                })
            }
            return edit
        }

        val first = labeledField("First Name", "test-AddPayee-FirstName", BankState.bpFirstName, InputType.TYPE_CLASS_TEXT, "firstName")
        val last = labeledField("Last Name", "test-AddPayee-LastName", BankState.bpLastName, InputType.TYPE_CLASS_TEXT, "lastName")
        val nick = labeledField("Nickname (Optional)", "test-AddPayee-Nickname", BankState.bpNickname, InputType.TYPE_CLASS_TEXT)
        val ident = labeledField("Identifying Info (Optional)", "test-AddPayee-Identifying", BankState.bpIdentifying, InputType.TYPE_CLASS_TEXT)
        val addr = labeledField("Address", "test-AddPayee-Address", BankState.bpAddress, InputType.TYPE_CLASS_TEXT, "address")
        val addr2 = labeledField("Address Two (Optional)", "test-AddPayee-Address2", BankState.bpAddress2, InputType.TYPE_CLASS_TEXT)
        val city = labeledField("City", "test-AddPayee-City", BankState.bpCity, InputType.TYPE_CLASS_TEXT, "city")

        text("State", "test-AddPayee-StateLabel")
        val stateErr = if (showErrors) errors["state"] else null
        root.addView(button(
            "State  ${BankState.bpState.ifBlank { "Select state" }}",
            "test-AddPayee-State",
        ) {
            persistPersonDraft(first, last, nick, ident, addr, addr2, city, null, null)
            open("billPaySelectState")
        }.apply {
            if (stateErr != null) setBackgroundColor(0xFFCC0000.toInt())
        })
        if (stateErr != null) {
            root.addView(TextView(this).apply {
                text = stateErr
                setTextColor(0xFFCC0000.toInt())
                textSize = 12f
                contentDescription = "test-AddPayee-StateError"
            })
        }

        val zip = labeledField("ZIP Code", "test-AddPayee-Zip", BankState.bpZip, InputType.TYPE_CLASS_NUMBER, "zip")
        val phone = labeledField("Phone Number", "test-AddPayee-Phone", BankState.bpPhone, InputType.TYPE_CLASS_PHONE, "phone")

        text("Terms & Conditions", "test-AddPayee-TermsTitle")
        // Inline in the page ScrollView (no nested terms box).
        val termsBlock = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            contentDescription = "test-AddPayee-TermsScroll"
            addView(TextView(this@BankActivity).apply {
                text = BILL_PAY_LEGAL
                contentDescription = "test-AddPayee-TermsBody"
                setTextColor(getColor(R.color.lebyy_muted))
                textSize = 12f
            })
            addView(TextView(this@BankActivity).apply {
                text = "— End of Terms & Conditions —"
                contentDescription = "test-AddPayee-TermsEnd"
                tag = "termsEnd"
                setTextColor(getColor(R.color.lebyy_muted))
                textSize = 12f
                setPadding(0, dp(28), 0, 0)
            })
        }
        root.addView(termsBlock)
        root.addView(TextView(this).apply {
            tag = "termsStatus"
            text = if (BankState.bpTermsScrolledToEnd) {
                "Result: Terms scrolled to end — Save enabled"
            } else {
                "Result: Scroll the page to the end of Terms & Conditions to enable Save"
            }
            contentDescription = "test-AddPayee-TermsStatus"
            setTextColor(
                if (showErrors && errors["terms"] != null) 0xFFCC0000.toInt()
                else getColor(R.color.lebyy_muted),
            )
            textSize = 12f
        })
        // Page ScrollView: mark terms complete when the end marker is visible.
        val pageScroll = root.parent as? ScrollView
        pageScroll?.viewTreeObserver?.addOnScrollChangedListener {
            val end = root.findViewWithTag("termsEnd") ?: return@addOnScrollChangedListener
            val visible = android.graphics.Rect()
            val shown = end.getGlobalVisibleRect(visible)
            if (shown && !BankState.bpTermsScrolledToEnd) {
                BankState.bpTermsScrolledToEnd = true
                BankState.lastResult = "Result: Terms scrolled to end — Save enabled"
                (root.findViewWithTag("termsStatus") as? TextView)?.apply {
                    text = BankState.lastResult
                    setTextColor(getColor(R.color.lebyy_muted))
                }
            }
        }
        if (showErrors && errors["terms"] != null) {
            root.addView(TextView(this).apply {
                text = errors["terms"]
                setTextColor(0xFFCC0000.toInt())
                textSize = 12f
                contentDescription = "test-AddPayee-TermsError"
            })
        }

        root.addView(button("CANCEL", "test-AddPayee-PersonCancel") { finish() })
        root.addView(button("CANCEL", "test-AddPayee-AddressCancel") { finish() }.apply {
            visibility = View.GONE
        })
        root.addView(button("SAVE", "test-AddPayee-Save") {
            persistPersonDraft(first, last, nick, ident, addr, addr2, city, zip, phone)
            val message = BankState.saveBillPayee()
            if (message == "Result: Payee added") open("billPayAddSuccess") else render()
        })
        // Alias for older scripts
        root.addView(View(this).apply {
            contentDescription = "test-AddPayee-PersonSave"
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
            layoutParams = LinearLayout.LayoutParams(1, 1)
        })
        if (BankState.lastResult.isNotBlank() && showErrors) {
            root.addView(TextView(this).apply {
                text = BankState.lastResult
                setTextColor(0xFFCC0000.toInt())
                textSize = 13f
                contentDescription = "test-AddPayee-PersonResult"
                setPadding(dp(4), dp(8), dp(4), dp(4))
            })
            root.addView(TextView(this).apply {
                text = BankState.lastResult
                setTextColor(0xFFCC0000.toInt())
                textSize = 1f
                contentDescription = "test-AddPayee-AddressResult"
                layoutParams = LinearLayout.LayoutParams(1, 1)
            })
        }
    }

    private fun persistPersonDraft(
        first: EditText,
        last: EditText,
        nick: EditText,
        ident: EditText,
        addr: EditText,
        addr2: EditText,
        city: EditText,
        zip: EditText?,
        phone: EditText?,
    ) {
        BankState.bpFirstName = first.text.toString()
        BankState.bpLastName = last.text.toString()
        BankState.bpNickname = nick.text.toString()
        BankState.bpIdentifying = ident.text.toString()
        BankState.bpAddress = addr.text.toString()
        BankState.bpAddress2 = addr2.text.toString()
        BankState.bpCity = city.text.toString()
        if (zip != null) BankState.bpZip = zip.text.toString()
        if (phone != null) BankState.bpPhone = phone.text.toString()
    }

    private fun renderBillPayAddress(root: LinearLayout) {
        // Address fields live on the person form now
        screen = "billPayPerson"
        renderBillPayPerson(root)
    }

    private fun renderBillPaySelectState(root: LinearLayout) {
        title("Select State", "test-SelectStateScreen")
        root.addView(button("Back", "test-SelectState-Back") { finish() })
        text("Select State", "test-SelectStateTitle")
        val list = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            contentDescription = "test-SelectStateList"
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
        }
        list.addView(TextView(this).apply {
            text = "US States"
            contentDescription = "test-SelectState-USStates"
            setTextColor(getColor(R.color.lebyy_text))
            textSize = 16f
            setPadding(dp(4), dp(4), dp(4), dp(4))
        })
        BankState.usStateEntries.forEach { (name, code) ->
            val mark = if (BankState.bpState == code || BankState.bpState == name) " ✓" else ""
            list.addView(button("$name$mark", "test-SelectState-${name.replace(" ", "")}") {
                BankState.bpState = code
                finish()
            })
        }
        list.addView(TextView(this).apply {
            text = "Countries"
            contentDescription = "test-SelectState-Countries"
            setTextColor(getColor(R.color.lebyy_text))
            textSize = 16f
            setPadding(dp(4), dp(4), dp(4), dp(4))
        })
        BankState.countries.forEach { region ->
            val mark = if (BankState.bpState == region) " ✓" else ""
            list.addView(button("$region$mark", "test-SelectState-${region.replace(" ", "")}") {
                BankState.bpState = region
                finish()
            })
        }
        root.addView(list)
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
            // Land on Bill Pay list (shows newly added payee); cascade-finish add stack via onResume
            startActivity(
                Intent(this, BankActivity::class.java).apply {
                    putExtra(EXTRA_SCREEN, "billPayList")
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                },
            )
            finish()
        })
    }

    private fun renderBillPayPayment(root: LinearLayout) {
        title("Payment Details", "test-PaymentDetailsScreen")
        root.addView(button("Back", "test-PaymentDetails-Back") { finish() })
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
        resultLine("test-PaymentDetails-Result")
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

    private fun legal(
        root: LinearLayout,
        titleId: String = "test-PT-Legal",
        bodyId: String = "test-PT-LegalBody",
    ) {
        text("Legal info and disclosures", titleId)
        text(
            "Investment, insurance and annuity products:\n• Are Not FDIC Insured\n• Are Not Bank Guaranteed\n• May Lose Value\n• Are Not Deposits",
            bodyId,
        )
    }

    private fun chromeRow(
        menuId: String,
        titleText: String,
        titleId: String,
        inboxId: String,
        productsId: String,
        logOutId: String,
    ) {
        val row = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(dp(4), dp(4), dp(4), dp(4))
        }
        row.addView(button("Menu", menuId) { open("menu") }.apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginEnd = dp(4)
            }
        })
        row.addView(TextView(this).apply {
            text = titleText
            contentDescription = titleId
            setTextColor(getColor(R.color.lebyy_text))
            textSize = 16f
            gravity = android.view.Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 2f)
        })
        row.addView(button("Inbox", inboxId) { open("inbox") }.apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginEnd = dp(4)
            }
        })
        row.addView(button("Products", productsId) { open("products") }.apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginEnd = dp(4)
            }
        })
        row.addView(button("Log Out", logOutId) {
            BankState.endSession()
            finish()
        }.apply {
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
        })
        binding.bankScreen.addView(row)
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
        binding.bankToolbar.navigationContentDescription = when (screenId) {
            "test-ZelleScreen" -> "test-Zelle-Back"
            "test-ZellePayScreen" -> "test-ZellePay-Back"
            "test-BillPayScreen" -> "test-BillPay-Back"
            "test-PaymentDetailsScreen" -> "test-PaymentDetails-Back"
            "test-SelectStateScreen" -> "test-SelectState-Back"
            "test-AddPayeeWhoScreen", "test-AddPayeePersonScreen", "test-AddPayeeAddressScreen" -> "test-AddPayee-Back"
            "test-BankDepositScreen" -> "test-Deposit-Cancel"
            "test-PayTransferScreen" -> "test-PT-Menu"
            else -> if (screenId.startsWith("test-Zelle")) "test-Zelle-NavBack" else "Navigate up"
        }
    }

    private fun resultLine(id: String = "test-BankResult") {
        if (BankState.lastResult.isNotBlank()) {
            text(BankState.lastResult, id)
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
        private const val MENU_EXIT_BANK = 91001
        const val EXTRA_SCREEN = "screen"
        const val EXTRA_ID = "id"
        const val EXTRA_QUERY = "query"
        const val EXTRA_FILTER = "filter"
        const val EXTRA_CHOOSE = "choose"

        private const val BILL_PAY_LEGAL = """
Legal info and disclosures

Investment, insurance and annuity products:
• Are Not FDIC Insured
• Are Not Bank Guaranteed
• May Lose Value
• Are Not Deposits
• Are Not Insured by Any Federal Government Agency
• Are Not a Condition to Any Banking Service or Activity

Investing involves risk. There is always the potential of losing money when you invest in securities. Asset allocation, diversification, and rebalancing do not ensure a profit or protect against loss in declining markets.

Bill Pay Terms & Conditions

1. You authorize Lebyy Bank to mail checks or send payments to the address you provide.
2. Check payments may take 4–7 business days. Keep sufficient funds until the check is cashed.
3. You are responsible for accurate payee name and mailing address.
4. You may cancel a scheduled payment before the processing cut-off in Activity.
5. Scroll to the end of these Terms & Conditions to enable Save.
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
