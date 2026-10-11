import SwiftUI

private struct PopBillPayKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var popBillPayHome: () -> Void {
        get { self[PopBillPayKey.self] }
        set { self[PopBillPayKey.self] = newValue }
    }
}

// MARK: - Bill Pay home (Pay Bills entry)

struct BillPayHomeView: View {
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
            .background(BankDash.paper)

            assistantBar
            tabBar

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if tab == 0 {
                        payTab
                    } else {
                        Text("No recent bill pay activity.")
                            .font(.subheadline)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-BillPay-ActivityEmpty")
                    }
                    legalFooter
                }
                .padding(16)
            }
            .background(BankDash.canvas)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-BillPayScreen")
        .environment(\.popBillPayHome, {
            goAdd = false
            goPay = false
            store.bank.lastResult = ""
            store.bank.objectWillChange.send()
        })
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
        .overlay(alignment: .bottom) {
            Rectangle().fill(BankDash.line).frame(height: 1)
        }
    }

    private func tabButton(_ title: String, _ index: Int, _ id: String) -> some View {
        Button {
            tab = index
        } label: {
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

    private var payTab: some View {
        VStack(alignment: .leading, spacing: 14) {
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

            HStack(spacing: 12) {
                Button("CANCEL") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(BankDash.accent, lineWidth: 1.5))
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-BillPay-Cancel")
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
                .accessibilityIdentifier("test-BillPay-Pay")
            }
            .padding(.top, 8)

            if !store.bank.lastResult.isEmpty {
                Text(store.bank.lastResult)
                    .font(.caption)
                    .foregroundStyle(BankDash.muted)
                    .accessibilityIdentifier("test-BillPay-Result")
            }
        }
    }

    private var legalFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legal info and disclosures")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-BillPay-LegalTitle")
            Text(billPayLegalBody)
                .font(.caption2)
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-BillPay-LegalBody")
        }
        .padding(.top, 12)
    }
}

// MARK: - Add Payee: who

struct BillPayAddWhoView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goPerson = false

    var body: some View {
        VStack(spacing: 0) {
            navHeader(title: "Add Payee", back: { dismiss() }, step: 1, of: 3)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Who do you want to add?")
                        .font(.title2.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-AddPayee-WhoTitle")

                    row("Company", subtitle: nil, id: "test-AddPayee-Company") {
                        store.bank.lastResult = "Result: Company add is not in this practice path — use Bill Pay person"
                        store.bank.objectWillChange.send()
                    }

                    Text("Person")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BankDash.muted)
                        .padding(.top, 4)

                    row(
                        "Pay them with Zelle",
                        subtitle: "Send money quickly using their US mobile # / email.",
                        id: "test-AddPayee-Zelle"
                    ) {
                        store.bank.lastResult = "Result: Use Bill Pay for this practice path"
                        store.bank.objectWillChange.send()
                    }

                    row(
                        "Pay them with Bill Pay",
                        subtitle: "Mail a check to their US address in 4-7 days.",
                        id: "test-AddPayee-BillPayPerson"
                    ) {
                        store.bank.resetBillPayeeDraft()
                        goPerson = true
                    }

                    Button("Learn when to use Zelle vs. Bill Pay.") {}
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
        .navigationDestination(isPresented: $goPerson) { BillPayPersonInfoView() }
    }

    private func row(_ title: String, subtitle: String?, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.body.weight(.semibold)).foregroundStyle(BankDash.ink)
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

// MARK: - Person info (step 2)

struct BillPayPersonInfoView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goAddress = false

    var body: some View {
        VStack(spacing: 0) {
            navHeader(title: "Add Payee", back: { dismiss() }, step: 2, of: 3)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Enter the person's information.")
                        .font(.subheadline)
                        .foregroundStyle(BankDash.muted)
                        .padding(.bottom, 12)
                        .accessibilityIdentifier("test-AddPayee-PersonHint")

                    draftField("First Name", text: Binding(
                        get: { store.bank.bpFirstName },
                        set: { store.bank.bpFirstName = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-FirstName")
                    draftField("Last Name", text: Binding(
                        get: { store.bank.bpLastName },
                        set: { store.bank.bpLastName = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-LastName")
                    draftField("Nickname (Optional)", text: Binding(
                        get: { store.bank.bpNickname },
                        set: { store.bank.bpNickname = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-Nickname", placeholder: "Enter payee nickname")
                    draftField("Identifying Info (Optional)", text: Binding(
                        get: { store.bank.bpIdentifying },
                        set: { store.bank.bpIdentifying = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-Identifying", placeholder: "Identifying Info")
                    draftField("Address", text: Binding(
                        get: { store.bank.bpAddress },
                        set: { store.bank.bpAddress = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-Address")
                    draftField("Address Two (Optional)", text: Binding(
                        get: { store.bank.bpAddress2 },
                        set: { store.bank.bpAddress2 = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-Address2", placeholder: "Enter payee address...")
                    draftField("City", text: Binding(
                        get: { store.bank.bpCity },
                        set: { store.bank.bpCity = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-City")

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .padding(.top, 8)
                            .accessibilityIdentifier("test-AddPayee-PersonResult")
                    }
                }
                .padding(16)
            }
            HStack(spacing: 12) {
                Button("CANCEL") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(BankDash.accent, lineWidth: 1.5))
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-AddPayee-PersonCancel")
                Button("SAVE") {
                    let msg = store.bank.validateBillPayeeStep2()
                    if msg.isEmpty {
                        store.bank.lastResult = ""
                        goAddress = true
                    } else {
                        store.bank.lastResult = msg
                        store.bank.objectWillChange.send()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .accessibilityIdentifier("test-AddPayee-PersonSave")
            }
            .padding(16)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AddPayeePersonScreen")
        .navigationDestination(isPresented: $goAddress) { BillPayAddressTermsView() }
    }
}

// MARK: - Address + terms (step 3)

struct BillPayAddressTermsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goState = false
    @State private var goSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            navHeader(title: "Add Payee", back: { dismiss() }, step: 3, of: 4)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    readOnlyRow("City", store.bank.bpCity, "test-AddPayee-CityValue")
                    Button {
                        goState = true
                    } label: {
                        HStack {
                            Text("State").foregroundStyle(BankDash.ink)
                            Spacer()
                            Text(store.bank.bpState.isEmpty ? "Select" : store.bank.bpState)
                                .foregroundStyle(BankDash.accent)
                            Image(systemName: "chevron.right").foregroundStyle(BankDash.muted)
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("test-AddPayee-State")
                    Divider()
                    draftField("ZIP Code", text: Binding(
                        get: { store.bank.bpZip },
                        set: { store.bank.bpZip = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-Zip")
                    draftField("Phone Number", text: Binding(
                        get: { store.bank.bpPhone },
                        set: { store.bank.bpPhone = $0; store.bank.objectWillChange.send() }
                    ), id: "test-AddPayee-Phone", keyboard: .phonePad)

                    Text("Terms & Conditions")
                        .font(.headline)
                        .padding(.top, 20)
                        .accessibilityIdentifier("test-AddPayee-TermsTitle")

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            Text(billPayTermsBody)
                                .font(.caption)
                                .foregroundStyle(BankDash.ink)
                                .accessibilityIdentifier("test-AddPayee-TermsBody")
                            Text("— End of Terms —")
                                .font(.caption)
                                .foregroundStyle(BankDash.muted)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 24)
                                .onAppear {
                                    if !store.bank.bpTermsScrolledToEnd {
                                        store.bank.bpTermsScrolledToEnd = true
                                        store.bank.objectWillChange.send()
                                    }
                                }
                                .accessibilityIdentifier("test-AddPayee-TermsEnd")
                        }
                    }
                    .frame(maxHeight: 180)
                    .padding(10)
                    .background(BankDash.canvas)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(BankDash.line))
                    .accessibilityIdentifier("test-AddPayee-TermsScroll")

                    Text(store.bank.bpTermsScrolledToEnd
                        ? "Result: Terms scrolled to end — Save enabled"
                        : "Result: Scroll terms to the end to enable Save")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .padding(.top, 8)
                        .accessibilityIdentifier("test-AddPayee-TermsStatus")

                    legalBlock.padding(.top, 16)

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-AddPayee-AddressResult")
                    }
                }
                .padding(16)
            }
            HStack(spacing: 12) {
                Button("CANCEL") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(BankDash.accent, lineWidth: 1.5))
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-AddPayee-AddressCancel")
                Button("SAVE") {
                    let msg = store.bank.saveBillPayee()
                    if msg == "Result: Payee added" {
                        goSuccess = true
                    } else {
                        store.bank.objectWillChange.send()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(store.bank.bpTermsScrolledToEnd ? BankDash.accent : BankDash.muted)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .disabled(!store.bank.bpTermsScrolledToEnd)
                .accessibilityIdentifier("test-AddPayee-Save")
            }
            .padding(16)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AddPayeeAddressScreen")
        .navigationDestination(isPresented: $goState) { BillPaySelectRegionView() }
        .navigationDestination(isPresented: $goSuccess) { BillPayAddSuccessView() }
    }
}

// MARK: - Select state / country

struct BillPaySelectRegionView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                .accessibilityIdentifier("test-SelectState-Back")
                Spacer()
                Text("Select State")
                    .font(.headline)
                    .accessibilityIdentifier("test-SelectStateTitle")
                Spacer()
                Color.clear.frame(width: 24)
            }
            .padding(12)

            List {
                Section("US States") {
                    ForEach(BankStore.usStates, id: \.self) { region in
                        regionRow(region)
                    }
                }
                Section("Countries") {
                    ForEach(BankStore.countries, id: \.self) { region in
                        regionRow(region)
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

    private func regionRow(_ region: String) -> some View {
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

// MARK: - Add success

struct BillPayAddSuccessView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.popBillPayHome) private var popBillPayHome

    var body: some View {
        VStack(spacing: 16) {
            Text("Success")
                .font(.subheadline)
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-AddPayeeSuccessTitle")
            progressDots(filled: 3, total: 3)
            Text("\(store.bank.selectedBillPayee()?.name ?? "Payee") was added.")
                .font(.title2)
                .foregroundStyle(BankDash.muted)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("test-AddPayeeSuccessMessage")

            if let p = store.bank.selectedBillPayee() {
                detailRow("Name", p.name, "test-AddPayeeSuccess-Name")
                detailRow("Address", p.address, "test-AddPayeeSuccess-Address")
                detailRow("City", p.city, "test-AddPayeeSuccess-City")
                detailRow("State", p.state, "test-AddPayeeSuccess-State")
                detailRow("ZIP Code", p.zip, "test-AddPayeeSuccess-Zip")
            }

            Spacer()
            Button("DONE") { popBillPayHome() }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .accessibilityIdentifier("test-AddPayeeSuccess-Done")
                .padding(16)
        }
        .padding(.top, 24)
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-AddPayeeSuccessScreen")
    }
}

// MARK: - Payment details

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

                    Button {
                        showFreq.toggle()
                    } label: {
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
                                    Text(freq)
                                        .foregroundStyle(freq == store.bank.bpFrequency ? BankDash.accent : BankDash.ink)
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
                    .accessibilityIdentifier("test-PaymentDetails-MemoToggle")

                    if store.bank.bpMemoOn {
                        draftField("Memo", text: Binding(
                            get: { store.bank.bpMemo },
                            set: { store.bank.bpMemo = $0; store.bank.objectWillChange.send() }
                        ), id: "test-PaymentDetails-Memo")
                    }

                    Text("This payment will be sent by check. Please make sure you have sufficient funds in your account until the check is cashed or the money is withdrawn.")
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

            HStack(spacing: 12) {
                Button("CANCEL") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(BankDash.accent, lineWidth: 1.5))
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-PaymentDetails-Cancel")
                Button("PAY") {
                    let msg = store.bank.confirmBillPayment()
                    if msg.hasPrefix("Receipt:") {
                        goSuccess = true
                    } else {
                        store.bank.lastResult = msg
                        store.bank.objectWillChange.send()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .accessibilityIdentifier("test-PaymentDetails-Pay")
            }
            .padding(16)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-PaymentDetailsScreen")
        .navigationDestination(isPresented: $goSuccess) { BillPayPaymentSuccessView() }
    }
}

struct BillPayPaymentSuccessView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.popBillPayHome) private var popBillPayHome

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

                Button("DONE") { popBillPayHome() }
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
    VStack(spacing: 8) {
        HStack {
            Button(action: back) {
                Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
            }
            .accessibilityIdentifier("test-AddPayee-Back")
            Spacer()
            Text(title).font(.headline).foregroundStyle(BankDash.ink)
            Spacer()
            Color.clear.frame(width: 24)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        progressDots(filled: step, total: total)
    }
    .padding(.bottom, 8)
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

private func draftField(
    _ label: String,
    text: Binding<String>,
    id: String,
    placeholder: String = "",
    keyboard: UIKeyboardType = .default
) -> some View {
    VStack(spacing: 0) {
        HStack {
            Text(label).foregroundStyle(BankDash.ink)
            Spacer()
            TextField(placeholder.isEmpty ? label : placeholder, text: text)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(BankDash.accent)
                .keyboardType(keyboard)
                .accessibilityIdentifier(id)
        }
        .padding(.vertical, 14)
        Divider()
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

Investing involves risk, including the possible loss of principal. Asset allocation does not ensure a profit or protect against loss.
"""

private let billPayTermsBody = """
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
