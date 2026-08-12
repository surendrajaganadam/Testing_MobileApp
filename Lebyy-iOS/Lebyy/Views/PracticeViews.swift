import SwiftUI
import WebKit

struct AlertsView: View {
    @State private var result = "Result: —"
    @State private var showAlert = false
    @State private var showConfirm = false
    @State private var showPrompt = false
    @State private var promptText = ""
    @State private var showCustomModal = false
    @State private var showBottomSheet = false
    @State private var toastMessage = ""
    @State private var toastVisible = false

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Practice native iOS alerts")
                        .foregroundStyle(LebyyTheme.muted)

                    Button("Show Alert") { showAlert = true }
                        .buttonStyle(LebyyPrimaryButton())
                        .accessibilityIdentifier("test-Alert")

                    Button("Show Confirm") { showConfirm = true }
                        .buttonStyle(LebyyCyanButton())
                        .accessibilityIdentifier("test-Confirm")

                    Button("Show Prompt") { showPrompt = true }
                        .buttonStyle(LebyyCyanButton())
                        .accessibilityIdentifier("test-Prompt")

                    Divider().overlay(LebyyTheme.line)

                    Text("Custom dialogs")
                        .font(.headline)
                        .foregroundStyle(LebyyTheme.primary)

                    Button("Show Custom Modal") { showCustomModal = true }
                        .buttonStyle(LebyyPrimaryButton())
                        .accessibilityIdentifier("test-CustomModal")

                    Button("Show Bottom Sheet") { showBottomSheet = true }
                        .buttonStyle(LebyyCyanButton())
                        .accessibilityIdentifier("test-BottomSheet")

                    Button("Show Toast") {
                        toastMessage = "Toast: Saved successfully"
                        withAnimation { toastVisible = true }
                        Task {
                            try? await Task.sleep(nanoseconds: 2_500_000_000)
                            await MainActor.run {
                                withAnimation { toastVisible = false }
                            }
                        }
                        result = "Result: Toast shown"
                    }
                    .buttonStyle(LebyyCyanButton())
                    .accessibilityIdentifier("test-Toast")

                    Text(result)
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-AlertResult")
                }
                .padding(20)
            }
            .background(LebyyTheme.bg.ignoresSafeArea())

            if toastVisible {
                Text(toastMessage)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(LebyyTheme.surface2)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(Capsule())
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .accessibilityIdentifier("test-ToastMessage")
                    .accessibilityLabel(toastMessage)
            }
        }
        .accessibilityIdentifier("test-AlertsScreen")
        .alert("Alert", isPresented: $showAlert) {
            Button("OK") { result = "Result: Alert OK" }
        } message: {
            Text("This is a simple Lebyy alert")
        }
        .alert("Confirm", isPresented: $showConfirm) {
            Button("OK") { result = "Result: Confirm OK" }
            Button("CANCEL", role: .cancel) { result = "Result: Confirm CANCEL" }
        } message: {
            Text("Do you want to continue?")
        }
        .alert("Prompt", isPresented: $showPrompt) {
            TextField("Enter text", text: $promptText)
                .accessibilityIdentifier("test-PromptInput")
            Button("OK") { result = "Result: Prompt \(promptText)" }
            Button("CANCEL", role: .cancel) { result = "Result: Prompt CANCEL" }
        } message: {
            Text("Please type something")
        }
        .sheet(isPresented: $showBottomSheet) {
            VStack(spacing: 16) {
                Text("Bottom Sheet")
                    .font(.title3.bold())
                    .foregroundStyle(LebyyTheme.primary)
                    .accessibilityIdentifier("test-BottomSheetTitle")
                Text("Practice sheet dismiss & actions")
                    .foregroundStyle(LebyyTheme.muted)
                Button("Confirm Sheet") {
                    result = "Result: Bottom Sheet Confirm"
                    showBottomSheet = false
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-BottomSheetConfirm")
                Button("Dismiss Sheet") {
                    result = "Result: Bottom Sheet Dismiss"
                    showBottomSheet = false
                }
                .buttonStyle(LebyyMutedButton())
                .accessibilityIdentifier("test-BottomSheetDismiss")
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LebyyTheme.bg)
            .presentationDetents([.medium])
            .accessibilityIdentifier("test-BottomSheetContent")
        }
        .overlay {
            if showCustomModal {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .accessibilityIdentifier("test-ModalBackdrop")
                    .onTapGesture {
                        result = "Result: Modal backdrop"
                        showCustomModal = false
                    }
                VStack(spacing: 14) {
                    Text("Custom Modal")
                        .font(.title3.bold())
                        .foregroundStyle(LebyyTheme.primary)
                        .accessibilityIdentifier("test-ModalTitle")
                    Text("Not a system alert — custom overlay")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-ModalBody")
                    Button("OK") {
                        result = "Result: Modal OK"
                        showCustomModal = false
                    }
                    .buttonStyle(LebyyPrimaryButton())
                    .accessibilityIdentifier("test-ModalOK")
                    Button("Cancel") {
                        result = "Result: Modal Cancel"
                        showCustomModal = false
                    }
                    .buttonStyle(LebyyMutedButton())
                    .accessibilityIdentifier("test-ModalCancel")
                }
                .padding(20)
                .background(LebyyTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(32)
                .accessibilityIdentifier("test-CustomModalContent")
            }
        }
    }
}

struct FormsView: View {
    @State private var input = ""
    @State private var notifications = false
    @State private var dropdown = "Select an item..."
    @State private var checkA = false
    @State private var checkB = false
    @State private var radio = 1
    @State private var result = "Result: —"
    @State private var date = Date()
    @State private var time = Date()
    @State private var sliderValue: Double = 50
    @State private var validationName = ""
    @State private var validationEmail = ""
    @State private var validationErrors: [String] = []
    @State private var otpDigits = ["", "", "", ""]
    @FocusState private var otpFocus: Int?

    private let options = [
        "Select an item...",
        "surendra is awesome",
        "lebyy is awesome",
        "i love your content",
        "i refer this course to my friends",
    ]

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                TextField("Type something", text: $input)
                    .padding()
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-Input")
                    .accessibilityLabel("Type something")

                HStack {
                    Text("Enable notifications")
                        .foregroundStyle(LebyyTheme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture { notifications.toggle() }
                        .accessibilityHidden(true)

                    Toggle("Enable notifications", isOn: $notifications)
                        .labelsHidden()
                        .tint(LebyyTheme.primary)
                        .accessibilityLabel("Enable notifications")
                        .accessibilityIdentifier("test-Switch")
                        .accessibilityValue(notifications ? "1" : "0")
                }
                .onChange(of: notifications) { _, on in
                    result = "Result: Switch \(on ? "ON" : "OFF")"
                }

                Text("Switch status: \(notifications ? "ON" : "OFF")")
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier(notifications ? "test-SwitchStatus-ON" : "test-SwitchStatus-OFF")

                Menu {
                    ForEach(options.filter { $0 != "Select an item..." }, id: \.self) { option in
                        Button(option) { dropdown = option }
                    }
                } label: {
                    HStack {
                        Text(dropdown)
                            .foregroundStyle(LebyyTheme.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.down")
                            .foregroundStyle(LebyyTheme.muted)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(LebyyTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .contentShape(Rectangle())
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(dropdown == "Select an item..." ? "Dropdown" : dropdown)
                .accessibilityIdentifier("test-Dropdown")
                .accessibilityValue(dropdown)
                .onChange(of: dropdown) { _, value in
                    result = "Result: Dropdown \(value)"
                }

                Text("Checkboxes").font(.caption).foregroundStyle(LebyyTheme.muted)
                LebyyCheckbox(title: "Option A", isOn: $checkA, accessibilityId: "test-Checkbox-1")
                    .onChange(of: checkA) { _, _ in updateChecks() }
                LebyyCheckbox(title: "Option B", isOn: $checkB, accessibilityId: "test-Checkbox-2")
                    .onChange(of: checkB) { _, _ in updateChecks() }

                Text("Radio buttons").font(.caption).foregroundStyle(LebyyTheme.muted)
                Picker("Radio", selection: $radio) {
                    Text("Radio 1").tag(1)
                    Text("Radio 2").tag(2)
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("test-RadioGroup")
                .onChange(of: radio) { _, value in
                    result = "Result: Radio \(value)"
                }

                Button("Active") {
                    result = "Result: Active tapped (\(input))"
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-Active")

                Button("Inactive") {
                    result = "Result: Inactive tapped"
                }
                .buttonStyle(LebyyMutedButton())
                .accessibilityIdentifier("test-Inactive")

                Divider().overlay(LebyyTheme.line)

                Text("Date & Time").font(.headline).foregroundStyle(LebyyTheme.primary)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .tint(LebyyTheme.primary)
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-DatePicker")
                    .accessibilityLabel("Date")
                    .onChange(of: date) { _, value in
                        result = "Result: Date \(dateFormatter.string(from: value))"
                    }

                Text("Selected date: \(dateFormatter.string(from: date))")
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-DateValue")
                    .accessibilityLabel("Selected date: \(dateFormatter.string(from: date))")

                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                    .tint(LebyyTheme.primary)
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-TimePicker")
                    .accessibilityLabel("Time")
                    .onChange(of: time) { _, value in
                        result = "Result: Time \(timeFormatter.string(from: value))"
                    }

                Text("Selected time: \(timeFormatter.string(from: time))")
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-TimeValue")
                    .accessibilityLabel("Selected time: \(timeFormatter.string(from: time))")

                Text("Slider").font(.headline).foregroundStyle(LebyyTheme.primary)
                Slider(value: $sliderValue, in: 0...100, step: 1)
                    .tint(LebyyTheme.accent)
                    .accessibilityIdentifier("test-Slider")
                    .accessibilityLabel("Slider")
                    .accessibilityValue("\(Int(sliderValue))")
                    .onChange(of: sliderValue) { _, value in
                        result = "Result: Slider \(Int(value))"
                    }

                Text("Slider value: \(Int(sliderValue))")
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-SliderValue")
                    .accessibilityLabel("Slider value: \(Int(sliderValue))")

                Divider().overlay(LebyyTheme.line)

                Text("Validation Form").font(.headline).foregroundStyle(LebyyTheme.primary)
                TextField("Full name", text: $validationName)
                    .padding()
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-ValidationName")
                    .accessibilityLabel("Full name")

                TextField("Email", text: $validationEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-ValidationEmail")
                    .accessibilityLabel("Email")

                Button("Submit Validation") {
                    var errors: [String] = []
                    if validationName.trimmingCharacters(in: .whitespaces).isEmpty {
                        errors.append("Name is required")
                    }
                    if !validationEmail.contains("@") || !validationEmail.contains(".") {
                        errors.append("Email is invalid")
                    }
                    validationErrors = errors
                    if errors.isEmpty {
                        result = "Result: Validation OK"
                    } else {
                        result = "Result: Validation failed"
                    }
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-ValidationSubmit")

                if !validationErrors.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(validationErrors.enumerated()), id: \.offset) { idx, err in
                            Text(err)
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .accessibilityIdentifier("test-ValidationError-\(idx + 1)")
                                .accessibilityLabel(err)
                        }
                    }
                    .accessibilityIdentifier("test-ValidationErrors")
                } else if result == "Result: Validation OK" {
                    Text("Form looks good")
                        .foregroundStyle(LebyyTheme.success)
                        .accessibilityIdentifier("test-ValidationSuccess")
                }

                Divider().overlay(LebyyTheme.line)

                Text("OTP / PIN").font(.headline).foregroundStyle(LebyyTheme.primary)
                HStack(spacing: 10) {
                    ForEach(0..<4, id: \.self) { i in
                        TextField("", text: Binding(
                            get: { otpDigits[i] },
                            set: { newValue in
                                let digit = String(newValue.filter(\.isNumber).prefix(1))
                                otpDigits[i] = digit
                                if !digit.isEmpty, i < 3 { otpFocus = i + 1 }
                                result = "Result: OTP \(otpDigits.joined())"
                            }
                        ))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 56, height: 56)
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.text)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .focused($otpFocus, equals: i)
                        .accessibilityIdentifier("test-OTP-\(i + 1)")
                        .accessibilityLabel("OTP digit \(i + 1)")
                    }
                }
                .accessibilityIdentifier("test-OTPGroup")

                Text("OTP value: \(otpDigits.joined())")
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-OTPValue")
                    .accessibilityLabel("OTP value: \(otpDigits.joined())")

                Button("Verify OTP") {
                    let code = otpDigits.joined()
                    if code.count == 4 {
                        result = code == "1234" ? "Result: OTP success" : "Result: OTP wrong"
                    } else {
                        result = "Result: OTP incomplete"
                    }
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-OTPVerify")

                Text(result)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-FormsResult")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-FormsScreen")
    }

    private func updateChecks() {
        var parts: [String] = []
        if checkA { parts.append("A") }
        if checkB { parts.append("B") }
        result = "Result: Checkbox \(parts.isEmpty ? "none" : parts.joined(separator: ","))"
    }
}

struct CheckboxIOSToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // Prefer LebyyCheckbox for new UI. Kept for any remaining Toggle(.checkboxIOS) call sites.
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(LebyyTheme.primary)
                    .accessibilityHidden(true)
                configuration.label.foregroundStyle(LebyyTheme.text)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .accessibilityRemoveTraits(.isToggle)
        .accessibilityAddTraits(configuration.isOn ? [.isButton, .isSelected] : .isButton)
        .accessibilityValue(configuration.isOn ? "Checked" : "Unchecked")
    }
}

/// Checkbox control that is NOT a SwiftUI `Toggle` (those always expose as Switch in Accessibility Inspector).
struct LebyyCheckbox: View {
    let title: String
    @Binding var isOn: Bool
    var accessibilityId: String

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(LebyyTheme.primary)
                    .accessibilityHidden(true)
                Text(title)
                    .foregroundStyle(LebyyTheme.text)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(accessibilityId)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "Checked" : "Unchecked")
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
        .accessibilityRemoveTraits(.isToggle)
    }
}

extension ToggleStyle where Self == CheckboxIOSToggleStyle {
    static var checkboxIOS: CheckboxIOSToggleStyle { CheckboxIOSToggleStyle() }
}

struct SwipeHorizontalView: View {
    private let cards: [(String, String, String)] = [
        ("Playwright", "Swipe left for more Lebyy courses", "course_1"),
        ("Appium", "Mobile automation carousel card", "course_2"),
        ("API Testing", "Practice horizontal swipe here", "course_3"),
        ("Selenium", "Like WebdriverIO swipe demo", "course_4"),
        ("CI/CD for QA", "Keep swiping left / right", "course_5"),
        ("Mobilewright", "Last card — swipe right to go back", "course_6"),
    ]

    var body: some View {
        TabView {
            ForEach(Array(cards.enumerated()), id: \.offset) { _, card in
                VStack(alignment: .leading, spacing: 0) {
                    Image(card.2)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .padding(12)
                        .accessibilityLabel("course")
                        .accessibilityIdentifier("course")
                    Text(card.0)
                        .font(.title2.bold())
                        .foregroundStyle(LebyyTheme.primary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .accessibilityHidden(true)
                    Text(card.1)
                        .foregroundStyle(LebyyTheme.text)
                        .padding()
                        .accessibilityHidden(true)
                }
                .background(LebyyTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(16)
                .frame(maxHeight: 360)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("course")
                .accessibilityIdentifier("course")
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-SwipeCarousel")
    }
}

struct SwipeVerticalView: View {
    var body: some View {
        List(1...40, id: \.self) { i in
            Text("Views Item \(i)")
                .foregroundStyle(LebyyTheme.text)
                .listRowBackground(LebyyTheme.surface)
                .accessibilityIdentifier("test-Views Item \(i)")
        }
        .scrollContentBackground(.hidden)
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-SwipeVerticalList")
    }
}

struct GesturesView: View {
    @State private var result = "Result: —"
    @State private var dragOffset: CGSize = .zero
    @State private var dropped = false
    @State private var magnify: CGFloat = 1
    @State private var multiTapCount = 0
    @State private var contextOpen = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(result)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-GestureResult")
                    .accessibilityLabel(result)

                Text("Long press this box")
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.primary)
                    .font(.headline)
                    .onLongPressGesture(minimumDuration: 0.6) {
                        result = "Result: Long Pressed"
                    }
                    .accessibilityIdentifier("test-LongPress")
                    .accessibilityLabel("Long press this box")

                Text("Double tap this box")
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.primary)
                    .font(.headline)
                    .onTapGesture(count: 2) {
                        result = "Result: Double Tapped"
                    }
                    .accessibilityIdentifier("test-DoubleTap")
                    .accessibilityLabel("Double tap this box")

                Text("Drag & Drop")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(dropped ? LebyyTheme.success.opacity(0.3) : LebyyTheme.surface)
                        .frame(height: 140)
                        .overlay(
                            Text(dropped ? "Dropped!" : "Drop here")
                                .foregroundStyle(LebyyTheme.muted)
                        )
                        .accessibilityIdentifier("test-DropTarget")
                        .accessibilityLabel(dropped ? "Dropped" : "Drop here")

                    Text("Drag me")
                        .padding()
                        .background(LebyyTheme.accent)
                        .foregroundStyle(LebyyTheme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { dragOffset = $0.translation }
                                .onEnded { value in
                                    if abs(value.translation.height) < 80, abs(value.translation.width) < 120 {
                                        dropped = true
                                        result = "Result: Drag Dropped"
                                    } else {
                                        dropped = false
                                        result = "Result: Drag Missed"
                                    }
                                    withAnimation { dragOffset = .zero }
                                }
                        )
                        .accessibilityIdentifier("test-DragItem")
                        .accessibilityLabel("Drag me")
                }
                .frame(height: 160)

                Button("Reset Drag Drop") {
                    dropped = false
                    dragOffset = .zero
                    result = "Result: —"
                }
                .buttonStyle(LebyyMutedButton())
                .accessibilityIdentifier("test-ResetDragDrop")

                Text("Pinch / Zoom")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image("course_1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .scaleEffect(magnify)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { magnify = max(0.5, min(3, $0)) }
                            .onEnded { _ in
                                result = "Result: Pinch \(String(format: "%.2f", magnify))x"
                            }
                    )
                    .accessibilityIdentifier("test-PinchImage")
                    .accessibilityLabel("Pinch zoom image")
                    .accessibilityValue(String(format: "%.2f", magnify))

                Text("Zoom: \(String(format: "%.2f", magnify))x")
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-PinchValue")

                Button("Reset Zoom") {
                    magnify = 1
                    result = "Result: Pinch reset"
                }
                .buttonStyle(LebyyMutedButton())
                .accessibilityIdentifier("test-ResetPinch")

                Text("Multi-touch (2-finger tap)")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                MultiTouchBox {
                    multiTapCount += 1
                    result = "Result: Multi-touch \(multiTapCount)"
                }
                .frame(height: 120)
                .accessibilityIdentifier("test-MultiTouch")
                .accessibilityLabel("Multi-touch box")

                Button("Simulate 2-Finger Tap") {
                    multiTapCount += 1
                    result = "Result: Multi-touch \(multiTapCount)"
                }
                .buttonStyle(LebyyCyanButton())
                .accessibilityIdentifier("test-SimulateMultiTouch")

                Text("Context Menu")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Long-press for context menu")
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .contextMenu {
                        Button("Copy") {
                            result = "Result: Context Copy"
                            contextOpen = false
                        }
                        .accessibilityIdentifier("test-ContextCopy")
                        Button("Share") {
                            result = "Result: Context Share"
                        }
                        .accessibilityIdentifier("test-ContextShare")
                        Button("Delete", role: .destructive) {
                            result = "Result: Context Delete"
                        }
                        .accessibilityIdentifier("test-ContextDelete")
                    }
                    .accessibilityIdentifier("test-ContextMenuTarget")
                    .accessibilityLabel("Long-press for context menu")
            }
            .padding(20)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-GesturesScreen")
    }
}

/// UIKit bridge so XCUITest / multi-finger gestures can hit a real multi-touch view.
struct MultiTouchBox: UIViewRepresentable {
    var onTwoFingerTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = MultiTouchUIView()
        view.backgroundColor = UIColor(LebyyTheme.surface)
        view.layer.cornerRadius = 12
        view.onTwoFingerTap = onTwoFingerTap
        let label = UILabel()
        label.text = "Two-finger tap here"
        label.textColor = UIColor(LebyyTheme.primary)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        view.isAccessibilityElement = true
        view.accessibilityIdentifier = "test-MultiTouchBox"
        view.accessibilityLabel = "Two-finger tap here"
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        (uiView as? MultiTouchUIView)?.onTwoFingerTap = onTwoFingerTap
    }
}

final class MultiTouchUIView: UIView {
    var onTwoFingerTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.numberOfTouchesRequired = 2
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func handleTap() {
        onTwoFingerTap?()
    }
}

struct WebBrowserView: View {
    @State private var urlText = "https://www.google.com"
    @State private var loadURL = URL(string: "about:blank")!
    @State private var webResult = "Web: —"

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("enter a https url here...", text: $urlText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(10)
                    .background(Color.white)
                    .foregroundStyle(Color(red: 0.06, green: 0.13, blue: 0.27))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityIdentifier("test-enter a https url here...")
                    .accessibilityLabel("enter a https url here...")

                Button("GO TO SITE") {
                    var value = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !value.hasPrefix("http") { value = "https://\(value)" }
                    if let url = URL(string: value) {
                        loadURL = url
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(LebyyTheme.accent)
                .foregroundStyle(LebyyTheme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("test-GO TO SITE")
                .accessibilityLabel("GO TO SITE")
            }
            .padding(12)
            .background(LebyyTheme.surface)

            HStack(spacing: 8) {
                Button("Load JS Alert Page") {
                    loadStarter(withJSAlert: true)
                    webResult = "Web: JS alert page"
                }
                .font(.caption.bold())
                .padding(8)
                .background(LebyyTheme.primary)
                .foregroundStyle(LebyyTheme.bg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("test-LoadJSAlertPage")

                Button("Load Starter") {
                    loadStarter(withJSAlert: false)
                    webResult = "Web: starter"
                }
                .font(.caption.bold())
                .padding(8)
                .background(LebyyTheme.surface2)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityIdentifier("test-LoadStarterPage")
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LebyyTheme.surface)

            Text(webResult)
                .font(.caption)
                .foregroundStyle(LebyyTheme.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
                .background(LebyyTheme.surface)
                .accessibilityIdentifier("test-WebResult")

            WebViewRepresentable(url: loadURL)
                .background(Color.white)
                .accessibilityIdentifier("test-WebView")
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-WebBrowserScreen")
        .onAppear { loadStarter(withJSAlert: false) }
    }

    private func loadStarter(withJSAlert: Bool) {
        let alertBlock = withJSAlert
            ? "<p><button id='jsAlertBtn' onclick=\"alert('Lebyy JS Alert')\">Show JS Alert</button></p><p><button id='jsConfirmBtn' onclick=\"var r=confirm('Continue?'); document.getElementById('jsOut').innerText='Confirm:'+r\">Show JS Confirm</button></p><p id='jsOut'>JS: —</p>"
            : "<p>Enter a URL above and tap <b>GO TO SITE</b>.</p><p><a href='https://www.google.com'>Open Google</a></p>"
        let html = """
        <html><head><meta name='viewport' content='width=device-width, initial-scale=1'></head>
        <body style='font-family:sans-serif;padding:16px;background:#fff;color:#0f2144'>
        <h1>Lebyy</h1><p>Learn by yourself</p>
        \(alertBlock)
        </body></html>
        """
        loadURL = URL(string: "data:text/html;charset=utf-8,\(html.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
    }
}

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let web = WKWebView(frame: .zero, configuration: config)
        web.isInspectable = true
        web.navigationDelegate = context.coordinator
        web.isAccessibilityElement = false
        web.accessibilityIdentifier = "test-WebViewInner"
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            let alert = UIAlertController(title: "JS Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
            topController()?.present(alert, animated: true)
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            let alert = UIAlertController(title: "JS Confirm", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
            topController()?.present(alert, animated: true)
        }

        private func topController() -> UIViewController? {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            let root = scene?.windows.first { $0.isKeyWindow }?.rootViewController
            var top = root
            while let presented = top?.presentedViewController { top = presented }
            return top
        }
    }
}

struct LebyyPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(LebyyTheme.accent.opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundStyle(LebyyTheme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LebyyCyanButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(LebyyTheme.primary.opacity(configuration.isPressed ? 0.8 : 1))
            .foregroundStyle(LebyyTheme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LebyyMutedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(LebyyTheme.surface.opacity(0.9))
            .foregroundStyle(LebyyTheme.muted)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(0.7)
    }
}
