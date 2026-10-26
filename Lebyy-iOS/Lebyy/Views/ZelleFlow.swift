import SwiftUI

// MARK: - Zelle home

struct ZelleScreen: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goPay = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                .accessibilityIdentifier("test-Zelle-Back")
                Spacer()
                Text("Zelle®")
                    .font(.headline)
                    .accessibilityIdentifier("test-ZelleTitle")
                Spacer()
                Color.clear.frame(width: 24)
            }
            .padding(12)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Send or receive money with Zelle®")
                        .font(.title3.bold())
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-Zelle-Heading")
                    Text("or send to other Lebyy accounts you've added")
                        .font(.subheadline)
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-Zelle-Subheading")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Keep contact info private")
                            .font(.subheadline.weight(.semibold))
                            .accessibilityIdentifier("test-Zelle-PrivacyTitle")
                        Text("You can send or request money to a Zelle® tag. Right now, only Business Banking clients can create and receive money to a Zelle® tag.")
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-Zelle-PrivacyBody")
                        Button("SEE THE LATEST SCAMS") {}
                            .font(.caption.weight(.bold))
                            .foregroundStyle(BankDash.accent)
                            .accessibilityIdentifier("test-Zelle-Scams")
                    }
                    .padding(12)
                    .background(BankDash.paper)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(BankDash.line))

                    HStack {
                        zelleAction("Pay", "arrow.up.right.square", "test-Zelle-Pay") { goPay = true }
                        zelleAction("Request", "arrow.down.left.square", "test-Zelle-Request") {
                            store.bank.lastResult = "Result: Request opened"
                            store.bank.objectWillChange.send()
                        }
                        zelleAction("Scan", "qrcode", "test-Zelle-Scan") {
                            store.bank.lastResult = "Result: Scan opened"
                            store.bank.objectWillChange.send()
                        }
                    }
                    .padding(12)
                    .background(BankDash.paper)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(BankDash.line))

                    Button("SETTINGS") {}
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(BankDash.accent)
                        .accessibilityIdentifier("test-Zelle-Settings")
                    Button("RECIPIENTS") { goPay = true }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(BankDash.accent)
                        .accessibilityIdentifier("test-Zelle-Recipients")

                    Text("Pay again")
                        .font(.headline)
                        .accessibilityIdentifier("test-Zelle-PayAgainTitle")
                    Text("RECENT")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-Zelle-RecentLabel")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(store.bank.zelleRecipients.prefix(6)) { r in
                                VStack(spacing: 6) {
                                    ZStack(alignment: .bottomTrailing) {
                                        Circle().fill(Color.gray.opacity(0.2)).frame(width: 56, height: 56)
                                            .overlay(Text(r.initials).font(.headline))
                                        Circle().fill(Color.purple).frame(width: 18, height: 18)
                                            .overlay(Text("Z").font(.system(size: 9).bold()).foregroundStyle(.white))
                                    }
                                    Text(r.displayName)
                                        .font(.caption2)
                                        .foregroundStyle(BankDash.accent)
                                        .lineLimit(1)
                                        .frame(width: 72)
                                }
                                .accessibilityIdentifier("test-Zelle-Recent-\(r.id)")
                            }
                        }
                    }

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-Zelle-Result")
                    }
                }
                .padding(16)
            }
        }
        .background(BankDash.canvas.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleScreen")
        .navigationDestination(isPresented: $goPay) { ZellePayScreen() }
    }

    private func zelleAction(_ title: String, _ icon: String, _ id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.title2).foregroundStyle(BankDash.accent)
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(BankDash.accent)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
    }
}

// MARK: - Pay / recipients

struct ZellePayScreen: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goAdd = false
    @State private var search = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                .accessibilityIdentifier("test-ZellePay-Back")
                Spacer()
                Text("Pay").font(.headline).accessibilityIdentifier("test-ZellePayTitle")
                Spacer()
                Color.clear.frame(width: 24)
            }
            .padding(12)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if store.bank.zelleShowAddedBanner {
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your recipient is added")
                                    .font(.subheadline.weight(.bold))
                                    .accessibilityIdentifier("test-ZellePay-AddedTitle")
                                Text("Be sure to double-check the contact information of the Zelle® recipient before sending a payment.")
                                    .font(.caption)
                                    .foregroundStyle(BankDash.muted)
                                Button("Send a payment.") {
                                    store.bank.resetZellePayDraft()
                                    NotificationCenter.default.post(
                                        name: .lebyyPushBankRoute,
                                        object: BankRoute.zellePayDetails
                                    )
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(BankDash.accent)
                                .accessibilityIdentifier("test-ZellePay-SendPayment")
                            }
                            Spacer()
                            Button {
                                store.bank.zelleShowAddedBanner = false
                                store.bank.objectWillChange.send()
                            } label: {
                                Image(systemName: "xmark").foregroundStyle(BankDash.muted)
                            }
                            .accessibilityIdentifier("test-ZellePay-DismissBanner")
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.08))
                        .overlay(alignment: .bottom) { Color.green.frame(height: 3) }
                        .accessibilityIdentifier("test-ZellePay-AddedBanner")
                    }

                    Text("Who would you like to pay?")
                        .font(.title3.bold())
                        .accessibilityIdentifier("test-ZellePay-WhoTitle")

                    HStack {
                        Image(systemName: "magnifyingglass").foregroundStyle(BankDash.muted)
                        TextField("Add/search name, tag, contact", text: $search)
                            .accessibilityIdentifier("test-ZellePay-Search")
                        Image(systemName: "qrcode").foregroundStyle(BankDash.muted)
                    }
                    .padding(10)
                    Button("Apply search") { }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BankDash.accent)
                        .accessibilityIdentifier("test-ZellePay-SearchApply")
                    .background(BankDash.canvas)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filtered) { r in
                            Button {
                                store.bank.zelleSelectedRecipientId = r.id
                                store.bank.resetZellePayDraft()
                                store.bank.objectWillChange.send()
                                NotificationCenter.default.post(
                                    name: .lebyyPushBankRoute,
                                    object: BankRoute.zellePayDetails
                                )
                            } label: {
                                VStack(spacing: 6) {
                                    ZStack(alignment: .bottomTrailing) {
                                        Circle().fill(Color.gray.opacity(0.2)).frame(width: 56, height: 56)
                                            .overlay(Text(r.initials).font(.headline).foregroundStyle(BankDash.ink))
                                        Circle().fill(Color.purple).frame(width: 18, height: 18)
                                            .overlay(Text("Z").font(.system(size: 9).bold()).foregroundStyle(.white))
                                    }
                                    Text(r.displayName)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(BankDash.accent)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                    Text(r.contact)
                                        .font(.caption2)
                                        .foregroundStyle(BankDash.muted)
                                        .lineLimit(1)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("test-ZellePay-Recipient-\(r.id)")
                        }
                    }

                    Button("Add new person or company") {
                        store.bank.resetZelleAddDraft()
                        goAdd = true
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BankDash.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .accessibilityIdentifier("test-ZellePay-AddNew")

                    zelleLegal
                }
                .padding(16)
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZellePayScreen")
        .navigationDestination(isPresented: $goAdd) { ZelleWhoAddingView() }
    }

    private var filtered: [ZelleRecipient] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty { return store.bank.zelleRecipients }
        return store.bank.zelleRecipients.filter {
            $0.displayName.lowercased().contains(q) || $0.contact.lowercased().contains(q)
        }
    }
}

// MARK: - Add recipient steps

struct ZelleWhoAddingView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goNext = false

    var body: some View {
        VStack(spacing: 0) {
            nav("Who are you adding?", back: { dismiss() })
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Who are you adding?*")
                        .font(.title3.bold())
                        .accessibilityIdentifier("test-ZelleWho-Title")
                    radio("Person", store.bank.zelleWhoType == "Person", "test-ZelleWho-Person") {
                        store.bank.zelleWhoType = "Person"
                        store.bank.objectWillChange.send()
                    }
                    radio("Business", store.bank.zelleWhoType == "Business", "test-ZelleWho-Business") {
                        store.bank.zelleWhoType = "Business"
                        store.bank.objectWillChange.send()
                    }
                    zelleLegal
                }
                .padding(16)
            }
            nextBar("test-ZelleWho-Next") {
                if store.bank.zelleWhoType == "Person" {
                    goNext = true
                } else {
                    store.bank.lastResult = "Result: Business add is not in this practice path — use Person"
                    store.bank.objectWillChange.send()
                }
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleWhoScreen")
        .navigationDestination(isPresented: $goNext) { ZelleHowAddingView() }
    }
}

struct ZelleHowAddingView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goNext = false

    var body: some View {
        VStack(spacing: 0) {
            nav("How are you adding them?", back: { dismiss() })
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How are you adding them?*")
                        .font(.title3.bold())
                        .accessibilityIdentifier("test-ZelleHow-Title")
                    radio("Mobile number or email", store.bank.zelleAddMethod == "Mobile number or email", "test-ZelleHow-MobileEmail") {
                        store.bank.zelleAddMethod = "Mobile number or email"
                        store.bank.objectWillChange.send()
                    }
                    radio("Lebyy account number", store.bank.zelleAddMethod == "Lebyy account number", "test-ZelleHow-Account") {
                        store.bank.zelleAddMethod = "Lebyy account number"
                        store.bank.objectWillChange.send()
                    }
                    zelleLegal
                }
                .padding(16)
            }
            nextBar("test-ZelleHow-Next") {
                if store.bank.zelleAddMethod == "Mobile number or email" {
                    goNext = true
                } else {
                    store.bank.lastResult = "Result: Use Mobile number or email for this practice path"
                    store.bank.objectWillChange.send()
                }
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleHowScreen")
        .navigationDestination(isPresented: $goNext) { ZelleEnterInfoView() }
    }
}

struct ZelleEnterInfoView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goReview = false

    var body: some View {
        VStack(spacing: 0) {
            nav("Enter their info", back: { dismiss() })
            Text("* Response required")
                .font(.caption)
                .foregroundStyle(BankDash.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Enter their info")
                        .font(.title3.bold())
                        .padding(.bottom, 12)
                        .accessibilityIdentifier("test-ZelleInfo-Title")
                    zelleField("Mobile number or email*", text: bind(\.zelleContact), id: "test-ZelleInfo-Contact")
                    zelleField("First name*", text: bind(\.zelleFirstName), id: "test-ZelleInfo-FirstName")
                    zelleField("Last name*", text: bind(\.zelleLastName), id: "test-ZelleInfo-LastName")
                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .padding(.top, 8)
                            .accessibilityIdentifier("test-ZelleInfo-Result")
                    }
                }
                .padding(16)
            }
            nextBar("test-ZelleInfo-Next") {
                let msg = store.bank.validateZelleRecipientInfo()
                if msg.isEmpty {
                    store.bank.lastResult = ""
                    goReview = true
                } else {
                    store.bank.lastResult = msg
                    store.bank.objectWillChange.send()
                }
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleInfoScreen")
        .navigationDestination(isPresented: $goReview) { ZelleReviewRecipientView() }
    }

    private func bind(_ keyPath: ReferenceWritableKeyPath<BankStore, String>) -> Binding<String> {
        Binding(
            get: { store.bank[keyPath: keyPath] },
            set: { store.bank[keyPath: keyPath] = $0; store.bank.objectWillChange.send() }
        )
    }
}

struct ZelleReviewRecipientView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goEdit = false
    @State private var goAuth = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                Spacer()
                Text("Review").font(.headline).accessibilityIdentifier("test-ZelleReviewTitle")
                Spacer()
                Button("Close") { store.bank.requestCloseBankFlow() }
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-ZelleReview-Close")
            }
            .padding(12)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Review").font(.title2.bold()).accessibilityIdentifier("test-ZelleReview-Heading")
                    row("Mobile number", store.bank.zelleContact, "test-ZelleReview-Contact")
                    row("First name", store.bank.zelleFirstName, "test-ZelleReview-FirstName")
                    row("Last name", store.bank.zelleLastName, "test-ZelleReview-LastName")
                    Button("EDIT") { goEdit = true }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Capsule())
                        .foregroundStyle(BankDash.accent)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("test-ZelleReview-Edit")
                    zelleLegal
                }
                .padding(16)
            }
            Button("ADD RECIPIENT") { goAuth = true }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(16)
                .accessibilityIdentifier("test-ZelleReview-AddRecipient")
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleReviewScreen")
        .navigationDestination(isPresented: $goEdit) { ZelleEditInfoView() }
        .navigationDestination(isPresented: $goAuth) { ZelleAuthSendView() }
    }

    private func row(_ label: String, _ value: String, _ id: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label).foregroundStyle(BankDash.ink)
                Spacer()
                Text(value).foregroundStyle(BankDash.ink)
            }
            .padding(.vertical, 12)
            .accessibilityIdentifier(id)
            Divider()
        }
    }
}

struct ZelleEditInfoView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            nav("Edit", back: { dismiss() })
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    zelleField("Mobile number or email*", text: Binding(
                        get: { store.bank.zelleContact },
                        set: { store.bank.zelleContact = $0; store.bank.objectWillChange.send() }
                    ), id: "test-ZelleEdit-Contact")
                    zelleField("First name*", text: Binding(
                        get: { store.bank.zelleFirstName },
                        set: { store.bank.zelleFirstName = $0; store.bank.objectWillChange.send() }
                    ), id: "test-ZelleEdit-FirstName")
                    zelleField("Last name*", text: Binding(
                        get: { store.bank.zelleLastName },
                        set: { store.bank.zelleLastName = $0; store.bank.objectWillChange.send() }
                    ), id: "test-ZelleEdit-LastName")
                    zelleField("Nickname", text: Binding(
                        get: { store.bank.zelleNickname },
                        set: { store.bank.zelleNickname = $0; store.bank.objectWillChange.send() }
                    ), id: "test-ZelleEdit-Nickname", placeholder: "Optional")
                }
                .padding(16)
            }
            nextBar("test-ZelleEdit-Next") {
                let msg = store.bank.validateZelleRecipientInfo()
                if msg.isEmpty { dismiss() } else {
                    store.bank.lastResult = msg
                    store.bank.objectWillChange.send()
                }
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleEditScreen")
    }
}

struct ZelleAuthSendView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var goEnter = false

    var body: some View {
        VStack(spacing: 0) {
            nav("Authorization Code", back: { dismiss() })
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Get authorization code")
                        .font(.title3.bold())
                        .accessibilityIdentifier("test-ZelleAuthSend-Title")
                    Text("To verify your identity, we need to send an authorization code to your phone")
                        .font(.subheadline)
                        .foregroundStyle(BankDash.muted)
                    Text("XXX-XXX-9193")
                        .font(.subheadline.weight(.semibold))
                        .accessibilityIdentifier("test-ZelleAuthSend-Phone")
                    Text("How would you like to receive it? *")
                        .font(.subheadline)
                    radio("Text message", store.bank.zelleAuthChannel == "Text message", "test-ZelleAuthSend-Text") {
                        store.bank.zelleAuthChannel = "Text message"
                        store.bank.objectWillChange.send()
                    }
                    radio("Phone call", store.bank.zelleAuthChannel == "Phone call", "test-ZelleAuthSend-Call") {
                        store.bank.zelleAuthChannel = "Phone call"
                        store.bank.objectWillChange.send()
                    }
                    Text("The code expires 10 minutes after you request it.")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                    Text("Practice: enter any 6-digit code")
                        .font(.caption)
                        .foregroundStyle(BankDash.accent)
                        .accessibilityIdentifier("test-ZelleAuthSend-Hint")
                }
                .padding(16)
            }
            HStack(spacing: 12) {
                Button("CANCEL") { dismiss() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(RoundedRectangle(cornerRadius: 28).stroke(BankDash.accent, lineWidth: 1.5))
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-ZelleAuthSend-Cancel")
                Button("SEND CODE") { goEnter = true }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BankDash.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .accessibilityIdentifier("test-ZelleAuthSend-Send")
            }
            .padding(16)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleAuthSendScreen")
        .navigationDestination(isPresented: $goEnter) { ZelleAuthEnterView() }
    }
}

struct ZelleAuthEnterView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""

    var body: some View {
        VStack(spacing: 0) {
            nav("Authorization Code", back: { dismiss() })
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("* Response required").font(.caption).foregroundStyle(BankDash.muted)
                    Text("Enter authorization code")
                        .font(.title3.bold())
                        .accessibilityIdentifier("test-ZelleAuthEnter-Title")
                    Text("We sent a code to your phone: XXX-XXX-9193")
                        .font(.subheadline)
                        .foregroundStyle(BankDash.muted)
                    zelleField("Code *", text: $code, id: "test-ZelleAuthEnter-Code", placeholder: "XXXXXX")
                    Text("The code expires 10 minutes after you request it.")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                    Button("Get a new code") { code = "" }
                        .font(.subheadline)
                        .foregroundStyle(BankDash.accent)
                        .accessibilityIdentifier("test-ZelleAuthEnter-Resend")
                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-ZelleAuthEnter-Result")
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
                    .accessibilityIdentifier("test-ZelleAuthEnter-Cancel")
                Button("SUBMIT") {
                    let msg = store.bank.submitZelleAuthCode(code)
                    if msg == "Result: Recipient added" {
                        store.bank.requestOpenZellePayList()
                    } else {
                        store.bank.objectWillChange.send()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .accessibilityIdentifier("test-ZelleAuthEnter-Submit")
            }
            .padding(16)
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleAuthEnterScreen")
    }
}

// MARK: - Payment

struct ZellePaymentDetailsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                .accessibilityIdentifier("test-ZellePayDetails-Back")
                Spacer()
                Text("Pay").font(.headline).accessibilityIdentifier("test-ZellePayDetailsTitle")
                Spacer()
                Button("Close") { store.bank.requestCloseBankFlow() }
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-ZellePayDetails-Close")
            }
            .padding(12)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("* Response required").font(.caption).foregroundStyle(BankDash.muted)
                    Text("You have \(store.bank.money(store.bank.zelleDailyLimitLeft)) left of your daily limit to send to this recipient.")
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .accessibilityIdentifier("test-ZellePayDetails-Limit")

                    if let r = store.bank.selectedZelleRecipient() {
                        Text("To*")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BankDash.ink)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.displayName)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BankDash.ink)
                                Text(r.contact).font(.caption).foregroundStyle(BankDash.muted)
                            }
                            Spacer()
                            Circle().fill(Color.gray.opacity(0.2)).frame(width: 40, height: 40)
                                .overlay(Text(r.initials).font(.caption.bold()).foregroundStyle(BankDash.ink))
                        }
                        .accessibilityIdentifier("test-ZellePayDetails-To")
                        if !r.enrolled {
                            Label("\(r.contact) isn't enrolled with Zelle®", systemImage: "bell.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .accessibilityIdentifier("test-ZellePayDetails-NotEnrolled")
                        }
                    }

                    Divider()
                    Text("From*")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BankDash.ink)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.bank.accountTitle(store.bank.zelleFromAccountId))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(BankDash.ink)
                        if let bal = store.bank.currentCustomer()?.accounts.first(where: { $0.id == store.bank.zelleFromAccountId })?.balance {
                            Text("Available balance \(store.bank.money(bal))")
                                .font(.caption)
                                .foregroundStyle(BankDash.muted)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("test-ZellePayDetails-From")

                    ForEach(store.bank.currentCustomer()?.accounts ?? [], id: \.id) { account in
                        Button {
                            store.bank.zelleFromAccountId = account.id
                            store.bank.objectWillChange.send()
                        } label: {
                            Text("\(account.name) - \(account.number.suffix(4))")
                                .foregroundStyle(BankDash.accent)
                        }
                        .accessibilityIdentifier("test-ZellePayDetails-Account-\(account.id.capitalized)")
                    }

                    Divider()
                    // Clear amount field — labels were inheriting a light tint and looked invisible.
                    Text("Amount*")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BankDash.ink)
                    HStack {
                        Text("₹")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(BankDash.ink)
                        TextField("Enter amount", text: Binding(
                            get: { store.bank.zelleAmountText },
                            set: { store.bank.zelleAmountText = $0 }
                        ))
                        .keyboardType(.decimalPad)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-ZellePayDetails-Amount")
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BankDash.canvas)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(BankDash.line, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    HStack {
                        Text("Date*")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(BankDash.ink)
                        Spacer()
                        Text("Today").foregroundStyle(BankDash.muted)
                    }
                    .accessibilityIdentifier("test-ZellePayDetails-Date")

                    zelleField("Add a message", text: Binding(
                        get: { store.bank.zelleMessage },
                        set: { store.bank.zelleMessage = String($0.prefix(140)); store.bank.objectWillChange.send() }
                    ), id: "test-ZellePayDetails-Message", placeholder: "Optional")
                    Text("\(140 - store.bank.zelleMessage.count) characters remaining.")
                        .font(.caption2)
                        .foregroundStyle(BankDash.muted)

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.red)
                            .accessibilityIdentifier("test-ZellePayDetails-Result")
                    }
                    zelleLegal
                }
                .padding(16)
            }
            nextBar("test-ZellePayDetails-Next") {
                if store.bank.selectedZelleRecipient() == nil {
                    store.bank.lastResult = "Result: Select recipient"
                    store.bank.objectWillChange.send()
                    return
                }
                let amount = Double(store.bank.zelleAmountText.trimmingCharacters(in: .whitespacesAndNewlines))
                if amount == nil || (amount ?? 0) <= 0 {
                    store.bank.lastResult = "Result: Enter amount"
                    store.bank.objectWillChange.send()
                    return
                }
                store.bank.lastResult = ""
                store.bank.objectWillChange.send()
                NotificationCenter.default.post(name: .lebyyPushBankRoute, object: BankRoute.zellePayReview)
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZellePayDetailsScreen")
    }
}

struct ZelleReviewPaymentView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var confirmSend = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
                }
                Spacer()
                Text("Review").font(.headline).accessibilityIdentifier("test-ZellePayReviewTitle")
                Spacer()
                Button("Close") { store.bank.requestCloseBankFlow() }
                    .foregroundStyle(BankDash.accent)
                    .accessibilityIdentifier("test-ZellePayReview-Close")
            }
            .padding(12)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Review payment details")
                        .font(.title3.bold())
                        .accessibilityIdentifier("test-ZellePayReview-Heading")
                    if let r = store.bank.selectedZelleRecipient() {
                        detail("To", "\(r.displayName)\n\(r.contact)", "test-ZellePayReview-To")
                        if !r.enrolled {
                            Label("\(r.contact) isn't enrolled with Zelle®", systemImage: "bell.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    detail("From", store.bank.accountTitle(store.bank.zelleFromAccountId), "test-ZellePayReview-From")
                    detail("Amount", store.bank.money(Double(store.bank.zelleAmountText) ?? 0), "test-ZellePayReview-Amount")
                    detail("Date", "Today", "test-ZellePayReview-Date")
                    Button("EDIT") { dismiss() }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.12))
                        .clipShape(Capsule())
                        .foregroundStyle(BankDash.accent)
                        .frame(maxWidth: .infinity)
                        .accessibilityIdentifier("test-ZellePayReview-Edit")
                    Text("Make sure you're sending to someone you trust, and their information is correct. Money is typically available in their account in minutes.")
                        .font(.caption)
                        .foregroundStyle(BankDash.ink)
                    Text("Once you've sent money, you can't cancel it.")
                        .font(.caption)
                        .foregroundStyle(BankDash.ink)
                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-ZellePayReview-Result")
                    }
                }
                .padding(16)
            }
            Button("PAY") { confirmSend = true }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(BankDash.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding(16)
            .accessibilityIdentifier("test-ZellePayReview-Pay")
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZellePayReviewScreen")
        .alert("Send this Zelle® payment?", isPresented: $confirmSend) {
            Button("Send") {
                let msg = store.bank.confirmZellePayment()
                if msg.hasPrefix("Receipt:") {
                    NotificationCenter.default.post(
                        name: .lebyyPushBankRoute,
                        object: BankRoute.zellePaySuccess
                    )
                } else {
                    store.bank.lastResult = msg
                    store.bank.objectWillChange.send()
                }
            }
            .accessibilityIdentifier("test-Zelle-SendConfirm")
            Button("Cancel", role: .cancel) {}
                .accessibilityIdentifier("test-Zelle-SendCancel")
        } message: {
            Text("\(store.bank.selectedZelleRecipient()?.displayName ?? "Recipient")  \(store.bank.money(Double(store.bank.zelleAmountText) ?? 0))")
        }
    }

    private func detail(_ label: String, _ value: String, _ id: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(BankDash.ink)
            Spacer()
            Text(value).multilineTextAlignment(.trailing).foregroundStyle(BankDash.ink)
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier(id)
    }
}

struct ZellePaymentSuccessView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(spacing: 16) {
            Text("Success")
                .font(.subheadline)
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-ZelleSuccessTitle")
            Text("Your Zelle® payment was sent.")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("test-ZelleSuccessMessage")
            if let r = store.bank.selectedZelleRecipient() {
                Text(r.displayName).font(.headline).accessibilityIdentifier("test-ZelleSuccess-To")
            }
            Text("Amount \(store.bank.money(Double(store.bank.zelleAmountText) ?? 0))")
                .accessibilityIdentifier("test-ZelleSuccess-Amount")
            Text("Confirmation \(store.bank.lastConfirmation)")
                .accessibilityIdentifier("test-ZelleSuccess-Confirmation")
            Spacer()
            Button("DONE") { store.bank.requestCloseBankFlow() }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(16)
                .accessibilityIdentifier("test-ZelleSuccess-Done")
        }
        .padding(.top, 32)
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-ZelleSuccessScreen")
    }
}

// MARK: - Shared

private func nav(_ title: String, back: @escaping () -> Void) -> some View {
    HStack {
        Button(action: back) {
            Image(systemName: "chevron.left").foregroundStyle(BankDash.ink)
        }
        .accessibilityIdentifier("test-Zelle-NavBack")
        Spacer()
        Text(title).font(.headline).foregroundStyle(BankDash.ink)
        Spacer()
        Color.clear.frame(width: 24)
    }
    .padding(12)
}

private func nextBar(_ id: String, action: @escaping () -> Void) -> some View {
    Button("NEXT", action: action)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(BankDash.accent)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .padding(16)
        .accessibilityIdentifier(id)
}

private func radio(_ title: String, _ selected: Bool, _ id: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        HStack {
            Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                .foregroundStyle(BankDash.accent)
            Text(title).foregroundStyle(BankDash.ink)
            Spacer()
        }
        .padding(.vertical, 8)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(id)
}

private func zelleField(
    _ label: String,
    text: Binding<String>,
    id: String,
    placeholder: String = ""
) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(label).font(.caption).foregroundStyle(BankDash.ink)
        TextField(placeholder.isEmpty ? label : placeholder, text: text)
            .foregroundStyle(BankDash.accent)
            .accessibilityIdentifier(id)
        Divider()
    }
    .padding(.vertical, 8)
}

private var zelleLegal: some View {
    VStack(alignment: .leading, spacing: 6) {
        Text("Legal info and disclosures")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(BankDash.muted)
            .accessibilityIdentifier("test-Zelle-Legal")
        Text("""
        Investment, insurance and annuity products:
        • Are Not FDIC Insured
        • Are Not Bank Guaranteed
        • May Lose Value
        • Are Not Deposits
        """)
        .font(.caption2)
        .foregroundStyle(BankDash.muted)
        .accessibilityIdentifier("test-Zelle-LegalBody")
    }
    .padding(.top, 12)
}
