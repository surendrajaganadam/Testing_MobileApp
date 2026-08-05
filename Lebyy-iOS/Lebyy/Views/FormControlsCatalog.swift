import SwiftUI

/// UIKitCatalog-style form topics — each screen shows multiple variants.
struct FormControlTopicView: View {
    let topic: FormControlTopic
    @State private var result = "Result: —"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(result)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-FormsResult")
                    .accessibilityLabel(result)

                switch topic {
                case .textFields: textFieldsSection
                case .switches: switchesSection
                case .sliders: slidersSection
                case .pickers: pickersSection
                case .selection: selectionSection
                case .validation: validationSection
                case .otp: otpSection
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("test-FormTopicScreen-\(topic.rawValue)")
    }

    // MARK: Text Fields

    @State private var plain = ""
    @State private var secure = ""
    @State private var email = ""
    @State private var multiline = ""

    private var textFieldsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Plain text field")
            TextField("Type something", text: $plain)
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-Input")
                .accessibilityLabel("Type something")
                .onChange(of: plain) { _, v in result = "Result: Plain \(v)" }

            sectionHeader("Secure field")
            SecureField("Password", text: $secure)
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-SecureInput")
                .accessibilityLabel("Password")

            sectionHeader("Email field")
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-EmailInput")
                .accessibilityLabel("Email")

            sectionHeader("Multiline")
            TextField("Notes", text: $multiline, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-MultilineInput")
                .accessibilityLabel("Notes")
        }
    }

    // MARK: Switches (multiple types — UIKitCatalog style)

    @State private var switchDefault = false
    @State private var switchLabeled = true
    @State private var switchDisabled = false
    @State private var checkA = false
    @State private var checkB = false

    private var switchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Default switch")
            Toggle("Default", isOn: $switchDefault)
                .tint(LebyyTheme.primary)
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-Switch")
                .accessibilityLabel("Default")
                .accessibilityValue(switchDefault ? "1" : "0")
                .onChange(of: switchDefault) { _, on in
                    result = "Result: Switch \(on ? "ON" : "OFF")"
                }
            Text("Switch status: \(switchDefault ? "ON" : "OFF")")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityIdentifier(switchDefault ? "test-SwitchStatus-ON" : "test-SwitchStatus-OFF")

            sectionHeader("Labeled switch (tap label or knob)")
            HStack {
                Text("Enable notifications")
                    .foregroundStyle(LebyyTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { switchLabeled.toggle() }
                    .accessibilityHidden(true)
                Toggle("Enable notifications", isOn: $switchLabeled)
                    .labelsHidden()
                    .tint(LebyyTheme.accent)
                    .accessibilityIdentifier("test-Switch-Labeled")
                    .accessibilityLabel("Enable notifications")
                    .accessibilityValue(switchLabeled ? "1" : "0")
            }
            .onChange(of: switchLabeled) { _, on in
                result = "Result: Labeled Switch \(on ? "ON" : "OFF")"
            }

            sectionHeader("Disabled switch")
            Toggle("Disabled", isOn: $switchDisabled)
                .disabled(true)
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityIdentifier("test-Switch-Disabled")
                .accessibilityLabel("Disabled")

            sectionHeader("Checkbox-style toggles")
            Toggle("Option A", isOn: $checkA)
                .toggleStyle(.checkboxIOS)
                .accessibilityIdentifier("test-Checkbox-1")
                .onChange(of: checkA) { _, _ in updateChecks() }
            Toggle("Option B", isOn: $checkB)
                .toggleStyle(.checkboxIOS)
                .accessibilityIdentifier("test-Checkbox-2")
                .onChange(of: checkB) { _, _ in updateChecks() }
        }
    }

    private func updateChecks() {
        var parts: [String] = []
        if checkA { parts.append("A") }
        if checkB { parts.append("B") }
        result = "Result: Checkbox \(parts.isEmpty ? "none" : parts.joined(separator: ","))"
    }

    // MARK: Sliders

    @State private var sliderContinuous: Double = 50
    @State private var sliderStepped: Double = 3

    private var slidersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Continuous (0–100)")
            Slider(value: $sliderContinuous, in: 0...100)
                .tint(LebyyTheme.accent)
                .accessibilityIdentifier("test-Slider")
                .accessibilityLabel("Slider")
                .accessibilityValue("\(Int(sliderContinuous))")
                .onChange(of: sliderContinuous) { _, v in
                    result = "Result: Slider \(Int(v))"
                }
            Text("Slider value: \(Int(sliderContinuous))")
                .foregroundStyle(LebyyTheme.accent)
                .accessibilityIdentifier("test-SliderValue")

            sectionHeader("Stepped (1–5)")
            Slider(value: $sliderStepped, in: 1...5, step: 1)
                .tint(LebyyTheme.primary)
                .accessibilityIdentifier("test-Slider-Stepped")
                .accessibilityLabel("Stepped slider")
                .accessibilityValue("\(Int(sliderStepped))")
                .onChange(of: sliderStepped) { _, v in
                    result = "Result: Stepped \(Int(v))"
                }
            Text("Stepped value: \(Int(sliderStepped))")
                .foregroundStyle(LebyyTheme.accent)
                .accessibilityIdentifier("test-SliderSteppedValue")
        }
    }

    // MARK: Pickers

    @State private var date = Date()
    @State private var time = Date()

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

    private var pickersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Date picker")
            DatePicker("Date", selection: $date, displayedComponents: .date)
                .tint(LebyyTheme.primary)
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-DatePicker")
                .onChange(of: date) { _, v in
                    result = "Result: Date \(dateFormatter.string(from: v))"
                }
            Text("Selected date: \(dateFormatter.string(from: date))")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityIdentifier("test-DateValue")

            sectionHeader("Time picker")
            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                .tint(LebyyTheme.primary)
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-TimePicker")
                .onChange(of: time) { _, v in
                    result = "Result: Time \(timeFormatter.string(from: v))"
                }
            Text("Selected time: \(timeFormatter.string(from: time))")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityIdentifier("test-TimeValue")
        }
    }

    // MARK: Selection

    @State private var dropdown = "Select an item..."
    @State private var radio = 1

    private let options = [
        "Select an item...",
        "surendra is awesome",
        "lebyy is awesome",
        "i love your content",
        "i refer this course to my friends",
    ]

    private var selectionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Dropdown / menu")
            Menu {
                ForEach(options.filter { $0 != "Select an item..." }, id: \.self) { option in
                    Button(option) { dropdown = option }
                }
            } label: {
                HStack {
                    Text(dropdown).foregroundStyle(LebyyTheme.text).lineLimit(2)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundStyle(LebyyTheme.muted)
                }
                .padding()
                .background(LebyyTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .accessibilityIdentifier("test-Dropdown")
            .accessibilityValue(dropdown)
            .onChange(of: dropdown) { _, v in result = "Result: Dropdown \(v)" }

            sectionHeader("Radio / segmented")
            Picker("Radio", selection: $radio) {
                Text("Radio 1").tag(1)
                Text("Radio 2").tag(2)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("test-RadioGroup")
            .onChange(of: radio) { _, v in result = "Result: Radio \(v)" }

            sectionHeader("Buttons")
            Button("Active") { result = "Result: Active tapped (\(plain))" }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-Active")
            Button("Inactive") { result = "Result: Inactive tapped" }
                .buttonStyle(LebyyMutedButton())
                .accessibilityIdentifier("test-Inactive")
        }
    }

    // MARK: Validation

    @State private var validationName = ""
    @State private var validationEmail = ""
    @State private var validationErrors: [String] = []

    private var validationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("Full name", text: $validationName)
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-ValidationName")

            TextField("Email", text: $validationEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-ValidationEmail")

            Button("Submit Validation") {
                var errors: [String] = []
                if validationName.trimmingCharacters(in: .whitespaces).isEmpty {
                    errors.append("Name is required")
                }
                if !validationEmail.contains("@") || !validationEmail.contains(".") {
                    errors.append("Email is invalid")
                }
                validationErrors = errors
                result = errors.isEmpty ? "Result: Validation OK" : "Result: Validation failed"
            }
            .buttonStyle(LebyyPrimaryButton())
            .accessibilityIdentifier("test-ValidationSubmit")

            ForEach(Array(validationErrors.enumerated()), id: \.offset) { idx, err in
                Text(err)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .accessibilityIdentifier("test-ValidationError-\(idx + 1)")
            }
            if validationErrors.isEmpty && result == "Result: Validation OK" {
                Text("Form looks good")
                    .foregroundStyle(LebyyTheme.success)
                    .accessibilityIdentifier("test-ValidationSuccess")
            }
        }
    }

    // MARK: OTP

    @State private var otpDigits = ["", "", "", ""]
    @FocusState private var otpFocus: Int?

    private var otpSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Enter 1234 for success")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
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
                }
            }
            .accessibilityIdentifier("test-OTPGroup")

            Text("OTP value: \(otpDigits.joined())")
                .foregroundStyle(LebyyTheme.accent)
                .accessibilityIdentifier("test-OTPValue")

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
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(LebyyTheme.primary)
            .accessibilityAddTraits(.isHeader)
            .padding(.top, 4)
    }
}
