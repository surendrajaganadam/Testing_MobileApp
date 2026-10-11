import SwiftUI

// MARK: - Hub

struct PayTransferHubView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goActivity = false

    var body: some View {
        VStack(spacing: 0) {
            hubHeader
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    assistantMini
                    actionGrid
                    activityBlock
                    Text("Legal info and disclosures")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BankDash.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .accessibilityIdentifier("test-PT-LegalLink")
                }
                .padding(16)
            }
            .background(BankDash.canvas)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-PayTransferScreen")
        .onAppear { store.bank.refreshPayDates() }
        .navigationDestination(isPresented: $goActivity) { BankActivityListView() }
    }

    private var hubHeader: some View {
        HStack {
            Button { dismiss() } label: {
                VStack(spacing: 2) {
                    Image(systemName: "line.3.horizontal")
                    Text("Menu").font(.system(size: 10))
                }
                .foregroundStyle(BankDash.ink)
            }
            .accessibilityIdentifier("test-PT-Menu")
            Spacer()
            Text("Pay & Transfer")
                .font(.headline)
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-PayTransferTitle")
            Spacer()
            HStack(spacing: 14) {
                Image(systemName: "envelope").accessibilityIdentifier("test-PT-Inbox")
                Image(systemName: "cart").accessibilityIdentifier("test-PT-Products")
                Button { store.logout() } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
                .accessibilityIdentifier("test-PT-LogOut")
            }
            .foregroundStyle(BankDash.ink)
        }
        .padding(12)
        .background(BankDash.paper)
    }

    private var assistantMini: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(BankDash.muted)
            Text("Hi, I'm Lebyy. How can I help?")
                .foregroundStyle(BankDash.muted)
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .topTrailing) {
                Circle().fill(BankDash.brandRed).frame(width: 32, height: 32)
                    .overlay(Text("L").foregroundStyle(.white).bold())
                Text("6").font(.system(size: 10).bold())
                    .padding(3).background(BankDash.accent).foregroundStyle(.white).clipShape(Circle())
                    .offset(x: 6, y: -4)
            }
        }
        .padding(10)
        .background(BankDash.paper)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(BankDash.line))
        .accessibilityIdentifier("test-PT-Assistant")
    }

    private var actionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
            gridLink("Transfer", "between my accounts", "arrow.left.arrow.right.circle", "test-PT-Transfer", .acctTransfer) {
                store.bank.resetAcctTransferDraft()
            }
            gridLink("Zelle", "send or receive", "z.circle.fill", "test-PT-Zelle", .zelle)
            gridLink("Pay Bills", "pay now or schedule", "dollarsign.circle", "test-PT-PayBills", .payBills) {
                store.bank.bpSelectedPayeeId = ""
                store.bank.lastResult = ""
            }
            gridLink("Wire", "U.S. or international", "globe", "test-PT-Wire", .wire)
        }
        .accessibilityIdentifier("test-PT-ActionGrid")
    }

    private func gridLink(
        _ title: String,
        _ subtitle: String,
        _ icon: String,
        _ id: String,
        _ route: BankRoute,
        prepare: (() -> Void)? = nil
    ) -> some View {
        NavigationLink(value: route) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundStyle(title == "Zelle" ? Color.purple : BankDash.accent)
                Text(title).font(.headline).foregroundStyle(BankDash.ink)
                Text(subtitle).font(.caption).foregroundStyle(BankDash.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
        .simultaneousGesture(TapGesture().onEnded { prepare?() })
    }

    private var activityBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.title3.bold())
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-PT-ActivityTitle")
            Text("ACTION NEEDED")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-PT-ActionNeededTitle")
            Text("There are no payment requests right now. To manage requests, go to Settings.")
                .font(.subheadline)
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-PT-ActionNeededBody")
            Text("HISTORY")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BankDash.muted)
                .padding(.top, 4)
                .accessibilityIdentifier("test-PT-HistoryTitle")
            ForEach(store.bank.payTransferHistory) { item in
                HStack(alignment: .top) {
                    Circle().fill(Color.purple.opacity(0.25)).frame(width: 40, height: 40)
                        .overlay(Text(String(item.title.prefix(1))).bold())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.subheadline.weight(.semibold)).foregroundStyle(BankDash.ink)
                        Text(item.subtitle).font(.caption).foregroundStyle(BankDash.muted)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(item.date).font(.caption).foregroundStyle(BankDash.muted)
                        Text(store.bank.money(item.amount)).font(.subheadline.weight(.bold)).foregroundStyle(BankDash.accent)
                        Text(item.status).font(.caption2).foregroundStyle(BankDash.muted)
                    }
                }
                .accessibilityIdentifier("test-PT-History-\(item.id)")
            }
            Button("MORE ACTIVITY") { goActivity = true }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(BankDash.accent)
                .accessibilityIdentifier("test-PT-MoreActivity")
        }
    }
}

// MARK: - Shared chrome bits

private struct FDICBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Lebyy deposit products")
                .font(.caption)
                .foregroundStyle(BankDash.muted)
            Text("FDIC  Member FDIC. Equal Housing Lender. Investment products are not FDIC-insured.")
                .font(.caption2)
                .foregroundStyle(BankDash.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .accessibilityIdentifier("test-PT-FdicBanner")
    }
}

private struct LegalBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Legal info and disclosures")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BankDash.muted)
            Text("Investment, insurance and annuity products:")
                .font(.caption)
                .foregroundStyle(BankDash.muted)
            ForEach([
                "Are Not FDIC Insured",
                "Are Not Bank Guaranteed",
                "May Lose Value",
                "Are Not Deposits",
                "Are Not Insured by Any Federal Government Agency",
                "Are Not a Condition to Any Banking Service or Activity",
            ], id: \.self) { line in
                Text("• \(line)")
                    .font(.caption2)
                    .foregroundStyle(BankDash.muted)
            }
        }
        .padding(.top, 12)
        .accessibilityIdentifier("test-PT-Legal")
    }
}

private struct FormRow: View {
    let label: String
    let value: String
    let subtitle: String
    let placeholder: String
    let id: String
    var showChevron: Bool = true

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(BankDash.ink)
                .frame(width: 70, alignment: .leading)
            VStack(alignment: .trailing, spacing: 2) {
                Text(value.isEmpty ? placeholder : value)
                    .foregroundStyle(value.isEmpty ? BankDash.accent : BankDash.ink)
                    .font(.subheadline.weight(value.isEmpty ? .regular : .semibold))
                    .multilineTextAlignment(.trailing)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .multilineTextAlignment(.trailing)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BankDash.muted)
            }
        }
        .padding(.vertical, 14)
        .accessibilityIdentifier(id)
        .accessibilityLabel("\(label) \(value.isEmpty ? placeholder : value)")
    }
}

private struct CloseBar: View {
    let title: String
    let titleId: String
    let onClose: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.headline)
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier(titleId)
            Spacer()
            Button("Close", action: onClose)
                .foregroundStyle(BankDash.accent)
                .accessibilityIdentifier("test-PT-Close")
        }
        .padding()
        .background(BankDash.paper)
    }
}

// MARK: - Account Transfer

struct AcctTransferFormView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goReview = false
    @State private var pick: String? // from | to | amount | date

    var body: some View {
        VStack(spacing: 0) {
            CloseBar(title: "Transfer", titleId: "test-AcctTransferTitle") { dismiss() }
            FDICBanner()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button { pick = "from" } label: {
                        FormRow(
                            label: "From",
                            value: store.bank.acctFromId.isEmpty ? "" : store.bank.accountTitle(store.bank.acctFromId),
                            subtitle: subtitle(store.bank.acctFromId),
                            placeholder: "Choose account",
                            id: "test-AcctTransfer-From"
                        )
                    }
                    Divider()
                    Button { pick = "to" } label: {
                        FormRow(
                            label: "To",
                            value: store.bank.acctToId.isEmpty ? "" : store.bank.accountTitle(store.bank.acctToId),
                            subtitle: subtitle(store.bank.acctToId),
                            placeholder: "Choose account",
                            id: "test-AcctTransfer-To"
                        )
                    }
                    Divider()
                    Button { pick = "amount" } label: {
                        FormRow(
                            label: "Amount",
                            value: store.bank.acctAmount > 0 ? store.bank.money(store.bank.acctAmount) : "",
                            subtitle: "",
                            placeholder: "Enter amount",
                            id: "test-AcctTransfer-Amount"
                        )
                    }
                    Divider()
                    Button { pick = "date" } label: {
                        FormRow(
                            label: "Date",
                            value: store.bank.acctDateLabel,
                            subtitle: store.bank.acctDateDetail,
                            placeholder: "Choose date",
                            id: "test-AcctTransfer-Date"
                        )
                    }
                    Divider()
                    NavigationLink(value: BankRoute.wire) {
                        HStack {
                            Image(systemName: "lightbulb")
                            Text("Sending a wire? Start here.")
                                .foregroundStyle(BankDash.ink)
                        }
                    }
                    .padding(.vertical, 14)
                    .accessibilityIdentifier("test-AcctTransfer-WireHint")
                    LegalBlock()
                }
                .padding(.horizontal, 16)
            }
            HStack(spacing: 12) {
                Button("CANCEL") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(BankDash.brandBlue))
                    .foregroundStyle(BankDash.brandBlue)
                    .accessibilityIdentifier("test-AcctTransfer-Cancel")
                Button("NEXT") {
                    let message = store.bank.validateAcctTransfer()
                    if message.isEmpty { goReview = true } else { store.bank.lastResult = message }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(BankDash.brandBlue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .accessibilityIdentifier("test-AcctTransfer-Next")
            }
            .padding()
            if !store.bank.lastResult.isEmpty && !goReview {
                Text(store.bank.lastResult)
                    .foregroundStyle(BankDash.brandRed)
                    .accessibilityIdentifier("test-BankResult")
                    .padding(.bottom, 8)
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AcctTransferScreen")
        .navigationDestination(isPresented: $goReview) { AcctTransferReviewView() }
        .sheet(item: Binding(
            get: { pick.map { PickSheet(id: $0) } },
            set: { pick = $0?.id }
        )) { sheet in
            pickSheet(sheet.id)
        }
    }

    private func subtitle(_ id: String) -> String {
        guard let account = store.bank.currentCustomer()?.accounts.first(where: { $0.id == id }) else { return "" }
        return "Available balance \(store.bank.money(account.balance))"
    }

    @ViewBuilder
    private func pickSheet(_ kind: String) -> some View {
        NavigationStack {
            List {
                if kind == "from" || kind == "to" {
                    ForEach(store.bank.currentCustomer()?.accounts ?? [], id: \.id) { account in
                        Button("\(account.name) - \(String(account.number.suffix(4)))") {
                            if kind == "from" { store.bank.acctFromId = account.id }
                            else { store.bank.acctToId = account.id }
                            pick = nil
                        }
                        .accessibilityIdentifier("test-ChooseAccount-\(account.name)")
                    }
                } else if kind == "amount" {
                    TextField("Amount", text: Binding(
                        get: { store.bank.acctAmountText },
                        set: { store.bank.acctAmountText = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("test-AcctTransfer-AmountField")
                    Button("Save") {
                        if let value = Double(store.bank.acctAmountText), value > 0 {
                            store.bank.acctAmount = value
                            pick = nil
                        } else {
                            store.bank.lastResult = "Result: Enter amount"
                        }
                    }
                    .accessibilityIdentifier("test-AcctTransfer-AmountSave")
                } else {
                    Button("Today") {
                        store.bank.refreshPayDates()
                        pick = nil
                    }
                    .accessibilityIdentifier("test-AcctTransfer-DateToday")
                }
            }
            .navigationTitle(kind == "amount" ? "Enter amount" : (kind == "date" ? "Choose date" : "Choose account"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { pick = nil }.accessibilityIdentifier("test-ChooseClose")
                }
            }
            .accessibilityIdentifier(
                kind == "from" || kind == "to" ? "test-ChooseAccountScreen" : "test-AcctTransferPickSheet"
            )
        }
        .presentationDetents([.medium, .large])
    }
}

private struct PickSheet: Identifiable {
    let id: String
}

struct AcctTransferReviewView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            CloseBar(title: "Review", titleId: "test-AcctTransferReviewTitle") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Review transfer details")
                        .font(.title2.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-AcctTransferReviewHeading")
                    reviewLine("From", store.bank.accountTitle(store.bank.acctFromId), subtitle(store.bank.acctFromId), "test-AcctReview-From")
                    reviewLine("To", store.bank.accountTitle(store.bank.acctToId), subtitle(store.bank.acctToId), "test-AcctReview-To")
                    reviewLine("Amount", store.bank.money(store.bank.acctAmount), "", "test-AcctReview-Amount")
                    reviewLine("Date", store.bank.acctDateLabel, store.bank.acctDateDetail, "test-AcctReview-Date")
                    Button("EDIT") { dismiss() }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(Capsule().stroke(BankDash.brandBlue))
                        .foregroundStyle(BankDash.brandBlue)
                        .accessibilityIdentifier("test-AcctTransfer-Edit")
                    Text("Ensure sufficient funds are available in the From account before you continue.")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                }
                .padding(16)
            }
            Button("TRANSFER") {
                let message = store.bank.confirmAcctTransfer()
                if message.hasPrefix("Receipt:") { goSuccess = true }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(BankDash.brandBlue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding()
            .accessibilityIdentifier("test-AcctTransfer-Confirm")
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AcctTransferReviewScreen")
        .navigationDestination(isPresented: $goSuccess) {
            PaymentSuccessView(
                title: "Your transfer is confirmed",
                screenId: "test-AcctTransferSuccessScreen",
                kind: .accountTransfer
            )
        }
    }

    private func subtitle(_ id: String) -> String {
        guard let account = store.bank.currentCustomer()?.accounts.first(where: { $0.id == id }) else { return "" }
        return "Available balance \(store.bank.money(account.balance))"
    }

    private func reviewLine(_ label: String, _ value: String, _ sub: String, _ id: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(BankDash.ink)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(BankDash.ink)
                if !sub.isEmpty {
                    Text(sub).font(.caption).foregroundStyle(BankDash.muted)
                }
            }
        }
        .accessibilityIdentifier(id)
    }
}

// MARK: - Pay Bills

struct PayBillsFormView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goAmount = false
    @State private var goReview = false
    @State private var pickFrom = false
    @State private var pickDate = false
    @State private var pickNote = false

    var body: some View {
        let bank = store.bank
        let card = bank.currentCustomer()?.card
        VStack(spacing: 0) {
            CloseBar(title: "Pay", titleId: "test-PayBillsTitle") { dismiss() }
            FDICBanner()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Pay")
                        .font(.largeTitle.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-PayBillsHeading")
                    Text("* Response required")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .padding(.bottom, 8)
                        .accessibilityIdentifier("test-PayBillsRequired")
                    FormRow(
                        label: "To",
                        value: bank.cardTitle(),
                        subtitle: "Current balance \(bank.money(card?.balance ?? 0))",
                        placeholder: "",
                        id: "test-PayBills-To",
                        showChevron: false
                    )
                    Divider()
                    Button { pickFrom = true } label: {
                        FormRow(
                            label: "From *",
                            value: bank.accountTitle(bank.payFromAccountId),
                            subtitle: fromSubtitle,
                            placeholder: "Choose account",
                            id: "test-PayBills-From"
                        )
                    }
                    Divider()
                    Toggle(isOn: Binding(
                        get: { bank.payRecurring },
                        set: { bank.payRecurring = $0; bank.objectWillChange.send() }
                    )) {
                        Text("Make payment recurring").foregroundStyle(BankDash.ink)
                    }
                    .padding(.vertical, 10)
                    .accessibilityIdentifier("test-PayBills-Recurring")
                    Text("How much?")
                        .font(.title3.bold())
                        .foregroundStyle(BankDash.ink)
                        .padding(.top, 8)
                        .accessibilityIdentifier("test-PayBills-HowMuch")
                    Button { goAmount = true } label: {
                        FormRow(
                            label: "Amount *",
                            value: bank.payAmountDisplay(),
                            subtitle: "",
                            placeholder: "Choose amount",
                            id: "test-PayBills-Amount"
                        )
                    }
                    if bank.payAmount > 0 {
                        Divider()
                        Button { pickDate = true } label: {
                            FormRow(
                                label: "Date *",
                                value: bank.payDateLabel,
                                subtitle: bank.payDateDetail,
                                placeholder: "Choose date",
                                id: "test-PayBills-Date"
                            )
                        }
                        Divider()
                        Button { pickNote = true } label: {
                            FormRow(
                                label: "Note to self",
                                value: bank.payNote,
                                subtitle: "\(140 - bank.payNote.count) characters remaining",
                                placeholder: "Enter note",
                                id: "test-PayBills-Note"
                            )
                        }
                    }
                    LegalBlock()
                }
                .padding(.horizontal, 16)
            }
            if bank.payAmount > 0 {
                Button("NEXT") {
                    let message = bank.validatePayForm()
                    if message.isEmpty { goReview = true } else { bank.lastResult = message }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(BankDash.brandBlue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding()
                .accessibilityIdentifier("test-PayBills-Next")
            }
            if !bank.lastResult.isEmpty && !goReview {
                Text(bank.lastResult)
                    .foregroundStyle(BankDash.brandRed)
                    .accessibilityIdentifier("test-BankResult")
                    .padding(.bottom, 8)
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-PayBillsScreen")
        .navigationDestination(isPresented: $goAmount) { ChooseAmountView() }
        .navigationDestination(isPresented: $goReview) { PayBillsReviewView() }
        .sheet(isPresented: $pickFrom) {
            NavigationStack {
                List {
                    ForEach(bank.currentCustomer()?.accounts ?? [], id: \.id) { account in
                        Button("\(account.name) - \(String(account.number.suffix(4)))") {
                            bank.payFromAccountId = account.id
                            bank.objectWillChange.send()
                            pickFrom = false
                        }
                        .accessibilityIdentifier("test-ChooseAccount-\(account.name)")
                    }
                }
                .navigationTitle("Choose account")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { pickFrom = false }
                    }
                }
            }
        }
        .sheet(isPresented: $pickDate) {
            NavigationStack {
                List {
                    Button("Today") {
                        bank.refreshPayDates()
                        pickDate = false
                    }
                    .accessibilityIdentifier("test-PayBills-DateToday")
                }
                .navigationTitle("Choose date")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { pickDate = false } } }
            }
        }
        .sheet(isPresented: $pickNote) {
            NavigationStack {
                Form {
                    TextField("Enter note", text: Binding(
                        get: { bank.payNote },
                        set: { bank.payNote = String($0.prefix(140)); bank.objectWillChange.send() }
                    ))
                    .accessibilityIdentifier("test-PayBills-NoteField")
                }
                .navigationTitle("Note to self")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { pickNote = false }.accessibilityIdentifier("test-PayBills-NoteSave")
                    }
                }
            }
        }
    }

    private var fromSubtitle: String {
        let id = store.bank.payFromAccountId
        guard let account = store.bank.currentCustomer()?.accounts.first(where: { $0.id == id }) else { return "" }
        return "Available balance \(store.bank.money(account.balance))"
    }
}

struct ChooseAmountView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var mode = "other"
    @State private var other = "1.00"
    @State private var showDueBanner = true

    var body: some View {
        let balance = store.bank.currentCustomer()?.card.balance ?? 0
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityIdentifier("test-ChooseAmount-Back")
                Spacer()
                Text("Choose Amount").font(.headline)
                    .accessibilityIdentifier("test-ChooseAmountTitle")
                Spacer()
                Button("Close") { dismiss() }
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-ChooseAmount-Close")
            }
            .padding()
            if showDueBanner {
                HStack {
                    Image(systemName: "info.circle.fill").foregroundStyle(BankDash.accent)
                    Text("No payment due at this time.")
                        .font(.subheadline)
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-ChooseAmount-Banner")
                    Spacer()
                    Button { showDueBanner = false } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityIdentifier("test-ChooseAmount-BannerDismiss")
                }
                .padding(10)
                .background(Color(red: 0.93, green: 0.95, blue: 0.98))
            }
            Rectangle().fill(BankDash.accent).frame(height: 3)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("* Response required").font(.caption).foregroundStyle(BankDash.muted)
                    Text("How much? *")
                        .font(.title2.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-ChooseAmount-HowMuch")
                    Button {
                        mode = "balance"
                    } label: {
                        HStack {
                            Image(systemName: mode == "balance" ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(BankDash.accent)
                            Text("Current balance - \(store.bank.money(balance))")
                                .foregroundStyle(BankDash.ink)
                            Spacer()
                        }
                    }
                    .accessibilityIdentifier("test-ChooseAmount-Balance")
                    Button {
                        mode = "other"
                    } label: {
                        HStack {
                            Image(systemName: mode == "other" ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(BankDash.accent)
                            Text("Other amount").foregroundStyle(BankDash.ink)
                            Spacer()
                        }
                    }
                    .accessibilityIdentifier("test-ChooseAmount-Other")
                    if mode == "other" {
                        HStack {
                            Text("Amount *").foregroundStyle(BankDash.ink)
                            Spacer()
                            TextField("0.00", text: $other)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(BankDash.accent)
                                .accessibilityIdentifier("test-ChooseAmount-Field")
                        }
                        .padding(.vertical, 8)
                        Text("Other amount")
                            .font(.subheadline.weight(.semibold))
                        Text("This option allows you to choose a customized payment amount.")
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                    }
                    LegalBlock()
                }
                .padding(16)
            }
            Button("SAVE") {
                let message = store.bank.savePayAmount(mode: mode, otherText: other)
                if message == "Result: Amount saved" { dismiss() }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(BankDash.brandBlue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding()
            .accessibilityIdentifier("test-ChooseAmount-Save")
            if store.bank.lastResult == "Result: Amount is required" {
                Text(store.bank.lastResult)
                    .foregroundStyle(BankDash.brandRed)
                    .accessibilityIdentifier("test-BankResult")
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ChooseAmountScreen")
        .onAppear {
            mode = store.bank.payAmountMode
            if !store.bank.payAmountText.isEmpty { other = store.bank.payAmountText }
        }
    }
}

struct PayBillsReviewView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goSuccess = false

    var body: some View {
        let bank = store.bank
        VStack(spacing: 0) {
            CloseBar(title: "Review", titleId: "test-PayReviewTitle") { dismiss() }
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Review payment details")
                        .font(.title2.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-PayReviewHeading")
                    review("To", bank.cardTitle(), "Current balance \(bank.money(bank.currentCustomer()?.card.balance ?? 0))", "test-PayReview-To")
                    review("From", bank.accountTitle(bank.payFromAccountId), fromSub, "test-PayReview-From")
                    review("Amount", bank.payAmountDisplay(), "", "test-PayReview-Amount")
                    review("Date", bank.payDateLabel, bank.payDateDetail, "test-PayReview-Date")
                    Button("EDIT") { dismiss() }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(Capsule().stroke(BankDash.brandBlue))
                        .foregroundStyle(BankDash.brandBlue)
                        .accessibilityIdentifier("test-PayReview-Edit")
                    Text("Make sure your payment is made by the due date and that you have sufficient funds in the From account.")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-PayReview-Disclaimer")
                }
                .padding(16)
            }
            Button("PAY") {
                let message = bank.confirmCardPayment()
                if message.hasPrefix("Receipt:") { goSuccess = true }
                else { bank.lastResult = message }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(BankDash.brandBlue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .padding()
            .accessibilityIdentifier("test-PayReview-Pay")
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-PayReviewScreen")
        .navigationDestination(isPresented: $goSuccess) {
            PaymentSuccessView(
                title: "Your payment is confirmed",
                screenId: "test-PaySuccessScreen",
                kind: .cardPay
            )
        }
    }

    private var fromSub: String {
        let id = store.bank.payFromAccountId
        guard let account = store.bank.currentCustomer()?.accounts.first(where: { $0.id == id }) else { return "" }
        return "Available balance \(store.bank.money(account.balance))"
    }

    private func review(_ label: String, _ value: String, _ sub: String, _ id: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(BankDash.ink)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(BankDash.ink)
                if !sub.isEmpty { Text(sub).font(.caption).foregroundStyle(BankDash.muted) }
            }
        }
        .accessibilityIdentifier(id)
    }
}

enum PaySuccessKind {
    case cardPay, accountTransfer
}

struct PaymentSuccessView: View {
    @EnvironmentObject private var store: AppStore
    let title: String
    let screenId: String
    var kind: PaySuccessKind = .cardPay

    var body: some View {
        let bank = store.bank
        VStack(spacing: 0) {
            Text("Success")
                .font(.headline)
                .foregroundStyle(BankDash.muted)
                .padding()
                .accessibilityIdentifier("test-PaySuccessTitle")
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                        .accessibilityIdentifier("test-PaySuccessIcon")
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-PaySuccessHeading")
                    HStack {
                        Spacer()
                        Button("Print or Save") {}
                            .foregroundStyle(BankDash.accent)
                            .accessibilityIdentifier("test-PaySuccess-Print")
                    }
                    if kind == .cardPay {
                        detail("To", bank.cardTitle(), "Current balance \(bank.money(bank.currentCustomer()?.card.balance ?? 0))", "test-PaySuccess-To")
                        detail("From", bank.accountTitle(bank.payFromAccountId), "", "test-PaySuccess-From")
                        detail("Amount", bank.payAmountDisplay(), "", "test-PaySuccess-Amount")
                        detail("Date", bank.payDateLabel, bank.payDateDetail, "test-PaySuccess-Date")
                    } else {
                        detail("From", bank.accountTitle(bank.acctFromId), "", "test-PaySuccess-From")
                        detail("To", bank.accountTitle(bank.acctToId), "", "test-PaySuccess-To")
                        detail("Amount", bank.money(bank.acctAmount), "", "test-PaySuccess-Amount")
                        detail("Date", bank.acctDateLabel, bank.acctDateDetail, "test-PaySuccess-Date")
                    }
                    detail("Confirmation number", bank.lastConfirmation, "", "test-PaySuccess-Confirmation")
                    Text("Payments may take time to appear. Credit is given for the date the payment was submitted.")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
            }
            Button("DONE") { store.bank.requestCloseBankFlow() }
                .frame(maxWidth: .infinity)
                .padding()
                .background(BankDash.brandBlue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding()
                .accessibilityIdentifier("test-PaySuccess-Done")
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier(screenId)
    }

    private func detail(_ label: String, _ value: String, _ sub: String, _ id: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(BankDash.ink)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value).font(.subheadline.weight(.semibold)).multilineTextAlignment(.trailing)
                if !sub.isEmpty { Text(sub).font(.caption).foregroundStyle(BankDash.muted) }
            }
        }
        .accessibilityIdentifier(id)
    }
}

struct WireScreen: View {
    var body: some View {
        BankSimpleScreen(
            title: "Wire",
            screenId: "test-WireScreen",
            bodyText: "Result: Wire opened — U.S. or international practice screen"
        )
    }
}
