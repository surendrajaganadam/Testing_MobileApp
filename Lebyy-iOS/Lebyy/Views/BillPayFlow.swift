import SwiftUI

private struct PopToBillPayListKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var popToBillPayList: () -> Void {
        get { self[PopToBillPayListKey.self] }
        set { self[PopToBillPayListKey.self] = newValue }
    }
}

// MARK: - 1. Recipients (Pay Bills entry)

struct BillPayHomeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Close") { dismiss() }
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-Recipients-Close")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            Text("Recipients")
                .font(.largeTitle.bold())
                .foregroundStyle(BankDash.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                .accessibilityIdentifier("test-RecipientsTitle")

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    recipientsSection("Bank of America", payees: store.bank.billPayees.filter { $0.section == "Bank of America" })
                    recipientsSection("Other payees", payees: store.bank.billPayees.filter { $0.section != "Bank of America" })

                    NavigationLink(value: BankRoute.addPayeeWho) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(BankDash.accent)
                            Text("Add a new payee")
                                .font(.body)
                                .foregroundStyle(BankDash.ink)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(BankDash.muted)
                        }
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        store.bank.resetBillPayeeDraft()
                    })
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("test-Recipients-AddPayee")

                    NavigationLink(value: BankRoute.billPayList) {
                        Text("Go to Bill Pay")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(BankDash.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("test-Recipients-GoBillPay")
                }
                .padding(16)
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-RecipientsScreen")
    }

    private func recipientsSection(_ title: String, payees: [BillPayee]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-Recipients-Section-\(title.replacingOccurrences(of: " ", with: ""))")
            ForEach(payees) { payee in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: payee.kind == "person" ? "person.fill" : "building.columns.fill")
                                .foregroundStyle(BankDash.muted)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text(payee.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BankDash.ink)
                        Text("No recent payments available")
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(BankDash.muted)
                }
                .padding(.vertical, 6)
                .accessibilityIdentifier("test-Recipients-Payee-\(payee.id)")
            }
        }
    }
}

// MARK: - 2. Who do you want to add?

struct BillPayAddWhoView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goZelle = false

    var body: some View {
        VStack(spacing: 0) {
            navHeader(title: "Add Payee", back: { dismiss() }, step: 1, of: 3)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Who do you want to add?")
                        .font(.title2.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-AddPayee-WhoTitle")

                    whoRow("Company", subtitle: nil, id: "test-AddPayee-Company") {
                        store.bank.lastResult = "Result: Company add is not in this practice path — use Bill Pay person"
                        store.bank.objectWillChange.send()
                    }

                    Text("Person")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BankDash.muted)
                        .padding(.top, 4)
                        .accessibilityIdentifier("test-AddPayee-PersonLabel")

                    whoRow(
                        "Pay them with Zelle®",
                        subtitle: "Send money quickly using their US mobile # / email",
                        id: "test-AddPayee-Zelle"
                    ) {
                        store.bank.resetZelleAddDraft()
                        goZelle = true
                    }

                    NavigationLink(value: BankRoute.addPayeeForm) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pay them with Bill Pay").font(.body).foregroundStyle(BankDash.ink)
                                Text("Mail a check to their US address in 4-7 days")
                                    .font(.caption)
                                    .foregroundStyle(BankDash.muted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(BankDash.muted)
                        }
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        store.bank.resetBillPayeeDraft()
                    })
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("test-AddPayee-BillPayPerson")

                    Button("Learn when to use Zelle vs. Bill Pay") {}
                        .font(.subheadline)
                        .foregroundStyle(BankDash.accent)
                        .accessibilityIdentifier("test-AddPayee-LearnLink")

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-AddPayee-WhoResult")
                    }

                    legalBlock
                }
                .padding(16)
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AddPayeeWhoScreen")
        .navigationDestination(isPresented: $goZelle) { ZelleWhoAddingView() }
    }

    private func whoRow(_ title: String, subtitle: String?, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.body).foregroundStyle(BankDash.ink)
                    if let subtitle {
                        Text(subtitle).font(.caption).foregroundStyle(BankDash.muted)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(BankDash.muted)
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
    }
}

// MARK: - 3. Enter person's information (single form: name → phone + T&C)

struct BillPayPersonInfoView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var showStatePicker = false
    @State private var fieldErrors: [String: String] = [:]

    var body: some View {
        VStack(spacing: 0) {
            navHeader(title: "Add Payee", back: { dismiss() }, step: 2, of: 3)
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Enter the person's information.")
                        .font(.subheadline)
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-AddPayee-PersonHint")

                    draftField(
                        "First Name",
                        text: bind(\.bpFirstName),
                        id: "test-AddPayee-FirstName",
                        error: fieldErrors["firstName"]
                    )
                    draftField(
                        "Last Name",
                        text: bind(\.bpLastName),
                        id: "test-AddPayee-LastName",
                        error: fieldErrors["lastName"]
                    )
                    draftField(
                        "Nickname (Optional)",
                        text: bind(\.bpNickname),
                        id: "test-AddPayee-Nickname",
                        placeholder: "Enter payee nickname"
                    )
                    draftField(
                        "Identifying Info (Optional)",
                        text: bind(\.bpIdentifying),
                        id: "test-AddPayee-Identifying",
                        placeholder: "Identifying Info"
                    )
                    draftField(
                        "Address",
                        text: bind(\.bpAddress),
                        id: "test-AddPayee-Address",
                        error: fieldErrors["address"]
                    )
                    draftField(
                        "Address Two (Optional)",
                        text: bind(\.bpAddress2),
                        id: "test-AddPayee-Address2",
                        placeholder: "Enter payee address..."
                    )
                    draftField(
                        "City",
                        text: bind(\.bpCity),
                        id: "test-AddPayee-City",
                        error: fieldErrors["city"]
                    )

                    stateRow

                    draftField(
                        "ZIP Code",
                        text: bind(\.bpZip),
                        id: "test-AddPayee-Zip",
                        keyboard: .numberPad,
                        error: fieldErrors["zip"]
                    )
                    draftField(
                        "Phone Number",
                        text: bind(\.bpPhone),
                        id: "test-AddPayee-Phone",
                        keyboard: .phonePad,
                        error: fieldErrors["phone"]
                    )

                    termsBlock

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.red)
                            .accessibilityIdentifier("test-AddPayee-PersonResult")
                        Text(store.bank.lastResult)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.red)
                            .accessibilityHidden(true)
                            .accessibilityIdentifier("test-AddPayee-AddressResult")
                            .frame(width: 0, height: 0)
                            .clipped()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            cancelSaveBar(
                cancelId: "test-AddPayee-PersonCancel",
                saveId: "test-AddPayee-Save",
                saveEnabled: true
            ) {
                dismiss()
            } onSave: {
                fieldErrors = store.bank.billPayeeFieldErrors()
                let msg = store.bank.saveBillPayee()
                if msg == "Result: Payee added" {
                    fieldErrors = [:]
                    NotificationCenter.default.post(name: .lebyyPushBankRoute, object: BankRoute.addPayeeSuccess)
                } else {
                    store.bank.objectWillChange.send()
                }
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AddPayeePersonScreen")
        // Keep legacy screen id present for older scripts that wait on address screen
        .background(
            Color.clear
                .accessibilityIdentifier("test-AddPayeeAddressScreen")
                .frame(width: 0, height: 0)
        )
        .sheet(isPresented: $showStatePicker) { BillPaySelectRegionView() }
    }

    private var stateRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("State")
                .font(.caption.weight(.semibold))
                .foregroundStyle(fieldErrors["state"] == nil ? BankDash.muted : Color.red)
            Button { showStatePicker = true } label: {
                HStack {
                    Text(store.bank.bpState.isEmpty ? "Select state" : store.bank.bpState)
                        .foregroundStyle(store.bank.bpState.isEmpty ? BankDash.muted : BankDash.ink)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(BankDash.muted)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .background(fieldErrors["state"] == nil ? BankDash.canvas : Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(fieldErrors["state"] == nil ? BankDash.line : Color.red, lineWidth: fieldErrors["state"] == nil ? 1 : 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-AddPayee-State")
            if let err = fieldErrors["state"] {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(Color.red)
                    .accessibilityIdentifier("test-AddPayee-StateError")
            }
        }
    }

    private var termsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Terms & Conditions")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(fieldErrors["terms"] == nil ? BankDash.ink : Color.red)
                .accessibilityIdentifier("test-AddPayee-TermsTitle")

            // Inline in the page ScrollView (no nested terms box).
            VStack(alignment: .leading, spacing: 12) {
                Text("Legal info and disclosures")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BankDash.ink)
                Text(billPayLegalBody)
                    .font(.caption)
                    .foregroundStyle(BankDash.muted)
                    .accessibilityIdentifier("test-AddPayee-TermsBody")
                Text(billPayLegalExtra)
                    .font(.caption)
                    .foregroundStyle(BankDash.muted)
                Text(billPayTermsFooter)
                    .font(.caption)
                    .foregroundStyle(BankDash.muted)
                Text("— End of Terms & Conditions —")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(BankDash.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .onAppear {
                        if !store.bank.bpTermsScrolledToEnd {
                            store.bank.bpTermsScrolledToEnd = true
                            fieldErrors.removeValue(forKey: "terms")
                            store.bank.objectWillChange.send()
                        }
                    }
                    .accessibilityIdentifier("test-AddPayee-TermsEnd")
            }
            .accessibilityIdentifier("test-AddPayee-TermsScroll")

            Text(store.bank.bpTermsScrolledToEnd
                ? "Result: Terms scrolled to end — Save enabled"
                : "Result: Scroll the page to the end of Terms & Conditions to enable Save")
                .font(.caption)
                .foregroundStyle(fieldErrors["terms"] == nil ? BankDash.muted : Color.red)
                .accessibilityIdentifier("test-AddPayee-TermsStatus")
        }
        .padding(.top, 4)
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<BankStore, String>) -> Binding<String> {
        Binding(
            get: { store.bank[keyPath: keyPath] },
            set: { store.bank[keyPath: keyPath] = $0; store.bank.objectWillChange.send() }
        )
    }
}

/// Legacy address-only screen — redirects conceptually; kept for any old navigation.
struct BillPayAddressTermsView: View {
    var body: some View {
        BillPayPersonInfoView()
    }
}

// MARK: - 5. Select State

struct BillPaySelectRegionView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(BankDash.ink)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .accessibilityIdentifier("test-SelectState-Back")
                Text("Select State")
                    .font(.headline)
                    .foregroundStyle(BankDash.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("test-SelectStateTitle")
                Color.clear.frame(width: 32, height: 32)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)

            List {
                Section("US States") {
                    ForEach(BankStore.usStateEntries, id: \.code) { entry in
                        Button {
                            store.bank.bpState = entry.code
                            store.bank.objectWillChange.send()
                            dismiss()
                        } label: {
                            HStack {
                                Text(entry.name).foregroundStyle(BankDash.accent)
                                Spacer()
                                if store.bank.bpState == entry.code || store.bank.bpState == entry.name {
                                    Image(systemName: "checkmark").foregroundStyle(BankDash.accent)
                                }
                            }
                        }
                        .accessibilityIdentifier("test-SelectState-\(entry.name.replacingOccurrences(of: " ", with: ""))")
                    }
                }
                Section("Countries") {
                    ForEach(BankStore.countries, id: \.self) { region in
                        Button {
                            store.bank.bpState = region
                            store.bank.objectWillChange.send()
                            dismiss()
                        } label: {
                            HStack {
                                Text(region).foregroundStyle(BankDash.accent)
                                Spacer()
                                if store.bank.bpState == region {
                                    Image(systemName: "checkmark").foregroundStyle(BankDash.accent)
                                }
                            }
                        }
                        .accessibilityIdentifier("test-SelectState-\(region.replacingOccurrences(of: " ", with: ""))")
                    }
                }
            }
            .listStyle(.plain)
            .accessibilityIdentifier("test-SelectStateList")
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-SelectStateScreen")
    }
}

// MARK: - 6. Payee added success

struct BillPayAddSuccessView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Success")
                .font(.subheadline)
                .foregroundStyle(BankDash.muted)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("test-AddPayeeSuccessTitle")
            progressDots(filled: 3, total: 3)

            Text("\(store.bank.selectedBillPayee()?.name ?? "Payee") was added.")
                .font(.title2)
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-AddPayeeSuccessMessage")

            Divider()

            if let p = store.bank.selectedBillPayee() {
                HStack(spacing: 12) {
                    Circle().fill(Color.gray.opacity(0.2)).frame(width: 36, height: 36)
                        .overlay(Image(systemName: "person.fill").foregroundStyle(BankDash.muted))
                    Text(p.name).font(.subheadline.weight(.semibold))
                }
                detailRow("Name", p.name, "test-AddPayeeSuccess-Name")
                detailRow("Address", p.address, "test-AddPayeeSuccess-Address")
                detailRow("City", p.city, "test-AddPayeeSuccess-City")
                detailRow("State", p.state, "test-AddPayeeSuccess-State")
                detailRow("ZIP Code", p.zip, "test-AddPayeeSuccess-Zip")
            }

            Spacer()
            Button {
                store.bank.requestOpenBillPayList()
            } label: {
                Text("DONE")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BankDash.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .accessibilityIdentifier("test-AddPayeeSuccess-Done")
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AddPayeeSuccessScreen")
    }
}

// MARK: - 7. Bill Pay list (after add / Go to Bill Pay)

struct BillPayListView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var tab = 0
    @State private var goAdd = false
    @State private var goPay = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                .accessibilityIdentifier("test-BillPay-Back")
                Spacer()
                Text("Bill Pay")
                    .font(.headline)
                    .foregroundStyle(BankDash.ink)
                    .accessibilityIdentifier("test-BillPayTitle")
                Spacer()
                Color.clear.frame(width: 24, height: 24)
            }
            .padding(12)

            assistantBar
            tabBar

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if tab == 0 {
                        Text("MY EBILLS & REMINDERS")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-BillPay-EBillsTitle")
                        Text("You don't have any unpaid eBills or reminders right now.")
                            .font(.subheadline)
                            .foregroundStyle(BankDash.ink)
                            .accessibilityIdentifier("test-BillPay-EBillsEmpty")

                        HStack {
                            Text("PAYEES")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(BankDash.muted)
                                .accessibilityIdentifier("test-BillPay-PayeesTitle")
                            Spacer()
                            Button {
                                store.bank.resetBillPayeeDraft()
                                goAdd = true
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Add Payee").font(.subheadline.weight(.semibold)).foregroundStyle(BankDash.accent)
                                    Image(systemName: "plus.circle.fill").foregroundStyle(BankDash.accent)
                                }
                            }
                            .accessibilityIdentifier("test-BillPay-AddPayee")
                        }

                        ForEach(store.bank.billPayees) { payee in
                            Button {
                                store.bank.bpSelectedPayeeId = payee.id
                                store.bank.objectWillChange.send()
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: payee.kind == "person" ? "person.fill" : "building.2.fill")
                                                .foregroundStyle(BankDash.muted)
                                        )
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(payee.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(BankDash.accent)
                                        if !payee.nickname.isEmpty {
                                            Text(payee.nickname).font(.caption).foregroundStyle(BankDash.muted)
                                        }
                                        Text("No payment in last 60 days")
                                            .font(.caption2)
                                            .foregroundStyle(BankDash.muted)
                                    }
                                    Spacer()
                                    Image(systemName: store.bank.bpSelectedPayeeId == payee.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(store.bank.bpSelectedPayeeId == payee.id ? BankDash.accent : BankDash.muted)
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("test-BillPay-Payee-\(payee.id)")
                        }

                        Button("PAY") {
                            if store.bank.bpSelectedPayeeId.isEmpty {
                                store.bank.lastResult = "Result: Select a payee"
                                store.bank.objectWillChange.send()
                            } else {
                                store.bank.resetBillPaymentDraft()
                                goPay = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(BankDash.accent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(.top, 8)
                        .accessibilityIdentifier("test-BillPay-Pay")

                        if !store.bank.lastResult.isEmpty {
                            Text(store.bank.lastResult)
                                .font(.caption)
                                .foregroundStyle(BankDash.muted)
                                .accessibilityIdentifier("test-BillPay-Result")
                        }
                    } else {
                        Text("No recent bill pay activity.")
                            .font(.subheadline)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-BillPay-ActivityEmpty")
                    }
                }
                .padding(16)
            }
            .background(BankDash.canvas)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-BillPayScreen")
        .environment(\.popToBillPayList, {
            store.bank.requestCloseBillPayPayment()
        })
        .onChange(of: store.bank.closeBillPayPayment) { _, close in
            guard close else { return }
            store.bank.closeBillPayPayment = false
            store.bank.lastResult = ""
            goAdd = false
            goPay = false
        }
        .navigationDestination(isPresented: $goAdd) { BillPayAddWhoView() }
        .navigationDestination(isPresented: $goPay) { BillPayPaymentDetailsView() }
    }

    private var assistantBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(BankDash.muted)
            Text("Hi, I'm Erica. How can I help?")
                .foregroundStyle(BankDash.muted)
                .font(.subheadline)
            Spacer()
            ZStack(alignment: .topTrailing) {
                Circle().fill(BankDash.brandRed).frame(width: 32, height: 32)
                Text("6").font(.system(size: 10).bold())
                    .padding(3).background(BankDash.accent).foregroundStyle(.white).clipShape(Circle())
                    .offset(x: 6, y: -4)
            }
        }
        .padding(10)
        .background(BankDash.paper)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(BankDash.line))
        .padding(.horizontal, 12)
        .accessibilityIdentifier("test-BillPay-Assistant")
    }

    private var tabBar: some View {
        HStack(spacing: 24) {
            tabButton("Pay", 0, "test-BillPay-TabPay")
            tabButton("Activity", 1, "test-BillPay-TabActivity")
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .overlay(alignment: .bottom) { Rectangle().fill(BankDash.line).frame(height: 1) }
    }

    private func tabButton(_ title: String, _ index: Int, _ id: String) -> some View {
        Button { tab = index } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(tab == index ? .semibold : .regular))
                    .foregroundStyle(tab == index ? BankDash.ink : BankDash.muted)
                Rectangle()
                    .fill(tab == index ? BankDash.brandRed : Color.clear)
                    .frame(height: 3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
    }
}

// MARK: - 8–9. Payment Details (+ frequency)

struct BillPayPaymentDetailsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var showFreq = false
    @State private var goSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                .accessibilityIdentifier("test-PaymentDetails-Back")
                Spacer()
                Text("Payment Details")
                    .font(.headline)
                    .accessibilityIdentifier("test-PaymentDetailsTitle")
                Spacer()
                Color.clear.frame(width: 24)
            }
            .padding(12)

            Text("Investment products are not FDIC-insured.")
                .font(.caption2)
                .foregroundStyle(BankDash.muted)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                .accessibilityIdentifier("test-PaymentDetails-FDIC")

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let payee = store.bank.selectedBillPayee() {
                        HStack(spacing: 12) {
                            Circle().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 40)
                                .overlay(Image(systemName: "person.fill").foregroundStyle(BankDash.muted))
                            Text(payee.name)
                                .font(.subheadline.weight(.semibold))
                                .accessibilityIdentifier("test-PaymentDetails-Payee")
                        }
                        .padding(.vertical, 12)
                        Divider()
                    }

                    readOnlyRow(
                        "Pay From",
                        store.bank.accountTitle("checking"),
                        "test-PaymentDetails-PayFrom",
                        subtitle: {
                            if let bal = store.bank.currentCustomer()?.accounts.first(where: { $0.id == "checking" })?.balance {
                                return "Available balance \(store.bank.money(bal))"
                            }
                            return nil
                        }()
                    )

                    draftField(
                        "Amount",
                        text: Binding(
                            get: { store.bank.bpPayAmountText },
                            set: { store.bank.bpPayAmountText = $0; store.bank.objectWillChange.send() }
                        ),
                        id: "test-PaymentDetails-Amount",
                        placeholder: "Enter amount",
                        keyboard: .decimalPad
                    )

                    Button { showFreq.toggle() } label: {
                        HStack {
                            Text("Frequency").foregroundStyle(BankDash.ink)
                            Spacer()
                            Text(store.bank.bpFrequency).foregroundStyle(BankDash.accent)
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("test-PaymentDetails-Frequency")

                    if showFreq {
                        ForEach(BankStore.frequencies, id: \.self) { freq in
                            Button {
                                store.bank.bpFrequency = freq
                                store.bank.objectWillChange.send()
                                showFreq = false
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(freq).foregroundStyle(freq == store.bank.bpFrequency ? BankDash.accent : BankDash.ink)
                                }
                                .padding(.vertical, 8)
                            }
                            .accessibilityIdentifier("test-PaymentDetails-Freq-\(freq.replacingOccurrences(of: " ", with: ""))")
                        }
                    }

                    readOnlyRow(
                        "Estimated Deliver by Date",
                        store.bank.bpDeliverBy,
                        "test-PaymentDetails-DeliverBy",
                        subtitle: "Earliest Deliver by Date: \(store.bank.bpDeliverBy)"
                    )

                    Toggle(isOn: Binding(
                        get: { store.bank.bpMemoOn },
                        set: { store.bank.bpMemoOn = $0; store.bank.objectWillChange.send() }
                    )) {
                        Text("Add Memo/Note")
                    }
                    .padding(.vertical, 8)
                    .accessibilityIdentifier("test-PaymentDetails-MemoToggle")

                    if store.bank.bpMemoOn {
                        draftField("Memo", text: Binding(
                            get: { store.bank.bpMemo },
                            set: { store.bank.bpMemo = $0; store.bank.objectWillChange.send() }
                        ), id: "test-PaymentDetails-Memo")
                    }

                    Text("This payment will be sent by check. Please make sure you have sufficient funds in your account until the check is cashed or the money is withdrawn, which may occur on, before or after the deliver-by date.")
                        .font(.caption2)
                        .foregroundStyle(BankDash.muted)
                        .padding(.vertical, 12)
                        .accessibilityIdentifier("test-PaymentDetails-Note")

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-PaymentDetails-Result")
                    }
                }
                .padding(16)
            }

            cancelSaveBar(
                cancelId: "test-PaymentDetails-Cancel",
                saveId: "test-PaymentDetails-Pay",
                saveEnabled: true,
                saveTitle: "PAY"
            ) {
                dismiss()
            } onSave: {
                let msg = store.bank.confirmBillPayment()
                if msg.hasPrefix("Receipt:") {
                    goSuccess = true
                } else {
                    store.bank.lastResult = msg
                    store.bank.objectWillChange.send()
                }
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-PaymentDetailsScreen")
        .navigationDestination(isPresented: $goSuccess) { BillPayPaymentSuccessView() }
    }
}

// MARK: - 10. Payment success

struct BillPayPaymentSuccessView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Success")
                    .font(.subheadline)
                    .foregroundStyle(BankDash.muted)
                    .accessibilityIdentifier("test-BillPaySuccessTitle")
                Text("You've scheduled a payment.")
                    .font(.title2.bold())
                    .accessibilityIdentifier("test-BillPaySuccessMessage")

                HStack(spacing: 10) {
                    pill("SAVE AS PDF", "test-BillPaySuccess-SavePdf")
                    pill("PRINT", "test-BillPaySuccess-Print")
                    pill("EMAIL", "test-BillPaySuccess-Email")
                }

                if let payee = store.bank.selectedBillPayee() {
                    HStack(spacing: 12) {
                        Circle().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 40)
                        Text(payee.name).font(.subheadline.weight(.semibold))
                    }
                    .accessibilityIdentifier("test-BillPaySuccess-Payee")
                }

                detailRow("Pay From", store.bank.accountTitle("checking"), "test-BillPaySuccess-PayFrom")
                detailRow("Amount", store.bank.money(Double(store.bank.bpPayAmountText) ?? 0), "test-BillPaySuccess-Amount")
                detailRow("Deliver By (Estimated)", store.bank.bpDeliverBy, "test-BillPaySuccess-DeliverBy")
                detailRow("Frequency", store.bank.bpFrequency, "test-BillPaySuccess-Frequency")
                detailRow("Payment Type", "Check", "test-BillPaySuccess-Type")
                detailRow("Confirmation", store.bank.lastConfirmation, "test-BillPaySuccess-Confirmation")

                Button("DONE") { store.bank.requestCloseBillPayPayment() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BankDash.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .accessibilityIdentifier("test-BillPaySuccess-Done")
                    .padding(.top, 12)
            }
            .padding(16)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-BillPaySuccessScreen")
    }

    private func pill(_ title: String, _ id: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .overlay(Capsule().stroke(BankDash.ink))
            .accessibilityIdentifier(id)
    }
}

// MARK: - Shared chrome

private func navHeader(title: String, back: @escaping () -> Void, step: Int, of total: Int) -> some View {
    VStack(spacing: 6) {
        HStack(spacing: 8) {
            Button(action: back) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(BankDash.ink)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier("test-AddPayee-Back")
            Text(title)
                .font(.headline)
                .foregroundStyle(BankDash.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Color.clear.frame(width: 32, height: 32)
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
        progressDots(filled: step, total: total)
    }
    .padding(.bottom, 4)
    .background(BankDash.paper)
}

private func progressDots(filled: Int, total: Int) -> some View {
    HStack(spacing: 0) {
        ForEach(0..<total, id: \.self) { i in
            Circle()
                .fill(i < filled ? BankDash.accent : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            if i < total - 1 {
                Rectangle()
                    .fill(i < filled - 1 ? BankDash.accent : Color.gray.opacity(0.3))
                    .frame(height: 2)
            }
        }
    }
    .padding(.horizontal, 40)
    .accessibilityIdentifier("test-AddPayee-Progress")
}

@ViewBuilder
private func cancelSaveBar(
    cancelId: String,
    saveId: String,
    saveEnabled: Bool,
    saveTitle: String = "SAVE",
    onCancel: @escaping () -> Void,
    onSave: @escaping () -> Void
) -> some View {
    HStack(spacing: 12) {
        Button("CANCEL", action: onCancel)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(BankDash.accent, lineWidth: 1.5))
            .foregroundStyle(BankDash.accent)
            .accessibilityIdentifier(cancelId)
        Button(saveTitle, action: onSave)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(saveEnabled ? BankDash.accent : BankDash.muted)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .disabled(!saveEnabled)
            .accessibilityIdentifier(saveId)
    }
    .padding(16)
}

private func draftField(
    _ label: String,
    text: Binding<String>,
    id: String,
    placeholder: String = "",
    keyboard: UIKeyboardType = .default,
    error: String? = nil
) -> some View {
    let hasError = error != nil && !(error?.isEmpty ?? true)
    return VStack(alignment: .leading, spacing: 4) {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(hasError ? Color.red : BankDash.muted)
        TextField(placeholder.isEmpty ? label : placeholder, text: text)
            .foregroundStyle(BankDash.ink)
            .keyboardType(keyboard)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(hasError ? Color.red.opacity(0.08) : BankDash.canvas)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasError ? Color.red : BankDash.line, lineWidth: hasError ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityIdentifier(id)
        if let error, !error.isEmpty {
            Text(error)
                .font(.caption)
                .foregroundStyle(Color.red)
                .accessibilityIdentifier("\(id)-Error")
        }
    }
}

private func readOnlyRow(_ label: String, _ value: String, _ id: String, subtitle: String? = nil) -> some View {
    VStack(spacing: 0) {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(BankDash.ink)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value).foregroundStyle(BankDash.ink).multilineTextAlignment(.trailing)
                if let subtitle {
                    Text(subtitle).font(.caption).foregroundStyle(BankDash.muted)
                }
            }
        }
        .padding(.vertical, 14)
        .accessibilityIdentifier(id)
        Divider()
    }
}

private func detailRow(_ label: String, _ value: String, _ id: String) -> some View {
    HStack(alignment: .top) {
        Text(label).foregroundStyle(BankDash.muted)
        Spacer()
        Text(value).foregroundStyle(BankDash.ink).multilineTextAlignment(.trailing)
    }
    .font(.subheadline)
    .padding(.vertical, 6)
    .accessibilityIdentifier(id)
}

private var legalBlock: some View {
    VStack(alignment: .leading, spacing: 8) {
        Text("Legal info and disclosures")
            .font(.subheadline.weight(.semibold))
            .accessibilityIdentifier("test-AddPayee-LegalTitle")
        Text(billPayLegalBody)
            .font(.caption2)
            .foregroundStyle(BankDash.muted)
            .accessibilityIdentifier("test-AddPayee-LegalBody")
    }
    .padding(.top, 12)
}

private let billPayLegalBody = """
Investment, insurance and annuity products:
• Are Not FDIC Insured
• Are Not Bank Guaranteed
• May Lose Value
• Are Not Deposits
• Are Not Insured by Any Federal Government Agency
• Are Not a Condition to Any Banking Service or Activity
"""

private let billPayLegalExtra = """
Investing involves risk. There is always the potential of losing money when you invest in securities. Asset allocation, diversification, and rebalancing do not ensure a profit or protect against loss in declining markets.
"""

private let billPayTermsFooter = """
Bill Pay Terms & Conditions

1. You authorize Lebyy Bank to mail checks or send payments to the address you provide.
2. Check payments may take 4–7 business days. Keep sufficient funds until the check is cashed.
3. You are responsible for accurate payee name and mailing address.
4. You may cancel a scheduled payment before the processing cut-off in Activity.
5. Scroll to the end of these Terms & Conditions to enable Save.
"""
