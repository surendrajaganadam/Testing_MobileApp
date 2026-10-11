import PhotosUI
import SwiftUI
import UIKit

// MARK: - Deposit Checks

struct DepositChecksView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    /// Side chosen for the current photo capture — kept until apply finishes
    /// (must NOT clear when the confirmation dialog dismisses).
    @State private var activeSide: CheckSide?
    @State private var showPickDialog = false
    @State private var showAccountPicker = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var galleryItem: PhotosPickerItem?
    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var amountText = ""
    @FocusState private var amountFocused: Bool
    @State private var goSuccess = false
    @State private var didResetDraft = false

    private enum CheckSide { case front, back }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    assistantBar
                    fdicBanner
                    Text("Sign and write \"for deposit only at Lebyy Bank\" on the back of your check.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BankDash.ink)
                        .accessibilityIdentifier("test-Deposit-Instruction")

                    HStack(spacing: 12) {
                        checkTile(
                            title: "Front of Check",
                            ready: store.bank.depositFrontReady,
                            image: frontImage,
                            source: store.bank.depositFrontSource,
                            id: "test-Deposit-Front"
                        ) {
                            activeSide = .front
                            showPickDialog = true
                        }
                        checkTile(
                            title: "Back of Check",
                            ready: store.bank.depositBackReady,
                            image: backImage,
                            source: store.bank.depositBackSource,
                            id: "test-Deposit-Back"
                        ) {
                            activeSide = .back
                            showPickDialog = true
                        }
                    }

                    Button {
                        showAccountPicker = true
                    } label: {
                        HStack {
                            Text("Deposit to").foregroundStyle(BankDash.ink)
                            Spacer()
                            Text(store.bank.depositAccountId.isEmpty
                                 ? "Select account"
                                 : store.bank.accountTitle(store.bank.depositAccountId))
                                .foregroundStyle(BankDash.accent)
                            Image(systemName: "chevron.down").foregroundStyle(BankDash.muted)
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("test-Deposit-Account")
                    Divider()

                    if showAccountPicker {
                        ForEach(store.bank.currentCustomer()?.accounts ?? [], id: \.id) { account in
                            Button {
                                store.bank.depositAccountId = account.id
                                store.bank.objectWillChange.send()
                                showAccountPicker = false
                            } label: {
                                HStack {
                                    Text("\(account.name) - \(account.number.suffix(4)) · \(store.bank.money(account.balance))")
                                        .foregroundStyle(BankDash.ink)
                                    Spacer()
                                    if store.bank.depositAccountId == account.id {
                                        Image(systemName: "checkmark").foregroundStyle(BankDash.accent)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .accessibilityIdentifier("test-Deposit-Account-\(account.id.capitalized)")
                        }
                        Divider()
                    }

                    // Whole row is tappable so the amount field focuses from anywhere.
                    HStack(spacing: 10) {
                        Text("Enter amount")
                            .foregroundStyle(BankDash.ink)
                        Text("₹")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(BankDash.ink)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(BankDash.ink)
                            .focused($amountFocused)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .trailing)
                            .accessibilityIdentifier("test-Deposit-Amount")
                            .onChange(of: amountText) { _, value in
                                store.bank.depositAmountText = value
                            }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { amountFocused = true }
                    .background(BankDash.canvas)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(amountFocused ? BankDash.accent : BankDash.line, lineWidth: amountFocused ? 1.5 : 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text(amountText.isEmpty
                         ? "₹0.00"
                         : store.bank.money(Double(amountText) ?? 0))
                        .font(.caption)
                        .foregroundStyle(BankDash.muted)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .accessibilityIdentifier("test-Deposit-AmountDisplay")
                    Divider()

                    HStack(spacing: 12) {
                        Button("CANCEL") { dismiss() }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(RoundedRectangle(cornerRadius: 28).stroke(BankDash.accent, lineWidth: 1.5))
                            .foregroundStyle(BankDash.accent)
                            .accessibilityIdentifier("test-Deposit-Cancel")
                        Button("NEXT") {
                            store.bank.depositAmountText = amountText
                            let msg = store.bank.confirmDeposit()
                            if msg.hasPrefix("Receipt:") {
                                goSuccess = true
                            } else {
                                store.bank.objectWillChange.send()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canNext ? BankDash.accent : BankDash.muted)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .disabled(!canNext)
                        .accessibilityIdentifier("test-Deposit-Next")
                    }

                    if !store.bank.lastResult.isEmpty {
                        Text(store.bank.lastResult)
                            .font(.caption)
                            .foregroundStyle(BankDash.muted)
                            .accessibilityIdentifier("test-Deposit-Result")
                    }

                    legalBlock
                }
                .padding(16)
            }
        }
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-BankDepositScreen")
        .onAppear {
            // Only reset once per visit — photo picker / keyboard must not wipe the draft.
            guard !didResetDraft else { return }
            didResetDraft = true
            store.bank.resetDepositDraft()
            frontImage = nil
            backImage = nil
            amountText = ""
        }
        .confirmationDialog(
            "Add check photo",
            isPresented: $showPickDialog,
            titleVisibility: .visible
        ) {
            Button("Take Photo") {
                showCamera = true
            }
            .accessibilityIdentifier("test-Deposit-TakePhoto")
            Button("Upload from Gallery") {
                showGallery = true
            }
            .accessibilityIdentifier("test-Deposit-UploadGallery")
            Button("Cancel", role: .cancel) {
                activeSide = nil
            }
            .accessibilityIdentifier("test-Deposit-DialogCancel")
        } message: {
            Text(activeSide == .back ? "Back of Check" : "Front of Check")
        }
        .photosPicker(isPresented: $showGallery, selection: $galleryItem, matching: .images)
        .onChange(of: galleryItem) { _, item in
            guard let item else { return }
            Task {
                let side = await MainActor.run { activeSide ?? .front }
                var image: UIImage?
                if let data = try? await item.loadTransferable(type: Data.self) {
                    image = UIImage(data: data)
                }
                await MainActor.run {
                    applyImage(image ?? placeholderCheckImage(side: side), source: "Gallery")
                    galleryItem = nil
                    showGallery = false
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                CameraCaptureView { image in
                    let side = activeSide ?? .front
                    applyImage(image ?? placeholderCheckImage(side: side), source: "Camera")
                    showCamera = false
                }
            } else {
                PracticeCameraFallback {
                    applyImage(placeholderCheckImage(side: activeSide ?? .front), source: "Camera")
                    showCamera = false
                } onCancel: {
                    showCamera = false
                    activeSide = nil
                }
            }
        }
        .navigationDestination(isPresented: $goSuccess) {
            DepositSuccessView {
                store.bank.requestCloseBankFlow()
            }
        }
    }

    private var canNext: Bool {
        store.bank.depositFrontReady
            && store.bank.depositBackReady
            && !store.bank.depositAccountId.isEmpty
            && (Double(amountText.trimmingCharacters(in: .whitespaces)) ?? 0) > 0
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                VStack(spacing: 2) {
                    Image(systemName: "line.3.horizontal")
                    Text("Menu").font(.system(size: 10))
                }
                .foregroundStyle(BankDash.ink)
            }
            .accessibilityIdentifier("test-Deposit-Menu")
            Spacer()
            Text("Deposit Checks")
                .font(.headline)
                .foregroundStyle(BankDash.ink)
                .accessibilityIdentifier("test-DepositTitle")
            Spacer()
            HStack(spacing: 14) {
                Image(systemName: "envelope").accessibilityIdentifier("test-Deposit-Inbox")
                Image(systemName: "cart").accessibilityIdentifier("test-Deposit-Products")
                Button { store.logout() } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
                .accessibilityIdentifier("test-Deposit-LogOut")
            }
            .foregroundStyle(BankDash.ink)
        }
        .padding(12)
        .background(BankDash.paper)
    }

    private var assistantBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundStyle(BankDash.muted)
            Text("Hi, I'm Erica. How can I help?")
                .foregroundStyle(BankDash.muted)
                .font(.subheadline)
            Spacer()
            Circle().fill(BankDash.brandRed).frame(width: 32, height: 32)
        }
        .padding(10)
        .background(BankDash.paper)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(BankDash.line))
        .accessibilityIdentifier("test-Deposit-Assistant")
    }

    private var fdicBanner: some View {
        Text("Lebyy deposit products. Member FDIC. Investment products are not FDIC-insured.")
            .font(.caption2)
            .foregroundStyle(BankDash.muted)
            .accessibilityIdentifier("test-Deposit-FdicBanner")
    }

    private func checkTile(
        title: String,
        ready: Bool,
        image: UIImage?,
        source: String,
        id: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(BankDash.line, lineWidth: 1.5)
                        .background(RoundedRectangle(cornerRadius: 8).fill(BankDash.canvas))
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(BankDash.muted)
                    }
                }
                .frame(height: 110)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BankDash.ink)
                Text(ready ? "Added · \(source)" : "Tap to add photo")
                    .font(.caption2)
                    .foregroundStyle(ready ? BankDash.accent : BankDash.muted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(id)
        .accessibilityLabel("\(title) \(ready ? "added from \(source)" : "tap to add")")
    }

    private func applyImage(_ image: UIImage, source: String) {
        guard let side = activeSide else { return }
        switch side {
        case .front:
            frontImage = image
            store.bank.depositFrontReady = true
            store.bank.depositFrontSource = source
        case .back:
            backImage = image
            store.bank.depositBackReady = true
            store.bank.depositBackSource = source
        }
        activeSide = nil
        store.bank.lastResult = "Result: \(side == .front ? "Front" : "Back") photo from \(source)"
        store.bank.objectWillChange.send()
    }

    private func placeholderCheckImage(side: CheckSide) -> UIImage {
        let size = CGSize(width: 320, height: 160)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(red: 0.93, green: 0.95, blue: 0.97, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor(red: 0.12, green: 0.27, blue: 0.53, alpha: 1).setStroke()
            let path = UIBezierPath(roundedRect: CGRect(x: 8, y: 8, width: 304, height: 144), cornerRadius: 6)
            path.lineWidth = 2
            path.stroke()
            let text = side == .front ? "FRONT" : "BACK"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor(red: 0.12, green: 0.27, blue: 0.53, alpha: 1),
            ]
            let ns = text as NSString
            let textSize = ns.size(withAttributes: attrs)
            ns.draw(
                at: CGPoint(x: (size.width - textSize.width) / 2, y: (size.height - textSize.height) / 2),
                withAttributes: attrs
            )
        }
    }
}

struct DepositSuccessView: View {
    @EnvironmentObject private var store: AppStore
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Success")
                .font(.subheadline)
                .foregroundStyle(BankDash.muted)
                .accessibilityIdentifier("test-DepositSuccessTitle")
            Text("Your check deposit was submitted.")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("test-DepositSuccessMessage")

            detail("Deposit to", store.bank.accountTitle(store.bank.depositAccountId), "test-DepositSuccess-Account")
            detail("Amount", store.bank.money(Double(store.bank.depositAmountText) ?? 0), "test-DepositSuccess-Amount")
            detail("Front", store.bank.depositFrontSource, "test-DepositSuccess-Front")
            detail("Back", store.bank.depositBackSource, "test-DepositSuccess-Back")
            detail("Confirmation", store.bank.lastConfirmation, "test-DepositSuccess-Confirmation")

            Spacer()
            Button("DONE") { onDone() }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .accessibilityIdentifier("test-DepositSuccess-Done")
                .padding(16)
        }
        .padding(.top, 32)
        .padding(.horizontal, 16)
        .background(BankDash.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .accessibilityIdentifier("test-DepositSuccessScreen")
    }

    private func detail(_ label: String, _ value: String, _ id: String) -> some View {
        HStack {
            Text(label).foregroundStyle(BankDash.muted)
            Spacer()
            Text(value).foregroundStyle(BankDash.ink)
        }
        .font(.subheadline)
        .accessibilityIdentifier(id)
    }
}

// MARK: - Camera

private struct PracticeCameraFallback: View {
    var onCapture: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Camera preview")
                .font(.headline)
                .accessibilityIdentifier("test-Deposit-CameraFallbackTitle")
            Text("No device camera available. Use a practice capture for automation.")
                .multilineTextAlignment(.center)
                .foregroundStyle(BankDash.muted)
                .padding()
            Button("Capture Photo") { onCapture() }
                .frame(maxWidth: .infinity)
                .padding()
                .background(BankDash.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier("test-Deposit-CameraCapture")
            Button("Cancel") { onCancel() }
                .accessibilityIdentifier("test-Deposit-CameraCancel")
        }
        .padding(24)
        .background(BankDash.paper.ignoresSafeArea())
    }
}

private struct CameraCaptureView: UIViewControllerRepresentable {
    var onFinish: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onFinish: onFinish) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onFinish: (UIImage?) -> Void
        init(onFinish: @escaping (UIImage?) -> Void) { self.onFinish = onFinish }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onFinish(nil)
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            onFinish(info[.originalImage] as? UIImage)
        }
    }
}

private var legalBlock: some View {
    VStack(alignment: .leading, spacing: 8) {
        Text("Legal info and disclosures")
            .font(.subheadline.weight(.semibold))
            .accessibilityIdentifier("test-Deposit-LegalTitle")
        Text("""
        Investment, insurance and annuity products:
        • Are Not FDIC Insured
        • Are Not Bank Guaranteed
        • May Lose Value
        """)
        .font(.caption2)
        .foregroundStyle(BankDash.muted)
        .accessibilityIdentifier("test-Deposit-LegalBody")
    }
    .padding(.top, 8)
}
