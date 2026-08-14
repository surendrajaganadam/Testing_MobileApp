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
                case .pickerView: pickerViewSection
                case .selection: selectionSection
                case .validation: validationSection
                case .otp: otpSection
                case .duplicates: duplicatesSection
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("test-FormTopicScreen-\(topic.rawValue)")
    }

    // MARK: Duplicate locators (XCUITest matching / boundBy practice)

    @State private var duplicateFieldA = ""
    @State private var duplicateFieldB = ""

    /// Two text fields share `test-DuplicateField`; two buttons share `test-DuplicateButton`.
    /// XCUITest: `app.textFields["test-DuplicateField"].element(boundBy: 0)`
    /// MobileWright: `screen.getByTestId('test-DuplicateField').nth(0)`
    private var duplicatesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Both fields use the same accessibility id/label. Pick by index (boundBy / nth).")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
                .accessibilityIdentifier("test-DuplicateHint")

            sectionHeader("Field A — boundBy: 0 / nth(0)")
            TextField("", text: $duplicateFieldA, prompt: Text("Duplicate Field"))
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-DuplicateField")
                .accessibilityLabel("test-DuplicateField")
                .onChange(of: duplicateFieldA) { _, v in
                    result = "Result: FieldA \(v)"
                }

            sectionHeader("Field B — boundBy: 1 / nth(1)")
            TextField("", text: $duplicateFieldB, prompt: Text("Duplicate Field"))
                .padding()
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.text)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier("test-DuplicateField")
                .accessibilityLabel("test-DuplicateField")
                .onChange(of: duplicateFieldB) { _, v in
                    result = "Result: FieldB \(v)"
                }

            sectionHeader("Buttons — same id (boundBy 0 then 1)")
            Button {
                result = "Result: DuplicateButton boundBy:0"
            } label: {
                Text("DUPLICATE ACTION")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LebyyTheme.primary)
                    .foregroundStyle(LebyyTheme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-DuplicateButton")
            .accessibilityLabel("test-DuplicateButton")

            Button {
                result = "Result: DuplicateButton boundBy:1"
            } label: {
                Text("DUPLICATE ACTION")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LebyyTheme.accent)
                    .foregroundStyle(LebyyTheme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("test-DuplicateButton")
            .accessibilityLabel("test-DuplicateButton")
        }
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
            // Custom checkboxes (not Switch). iOS has no public Checkbox a11y type;
            // XCUITest sees these as Buttons with value Checked/Unchecked.
            LebyyCheckbox(title: "Option A", isOn: $checkA, accessibilityId: "test-Checkbox-1")
                .onChange(of: checkA) { _, _ in updateChecks() }
            LebyyCheckbox(title: "Option B", isOn: $checkB, accessibilityId: "test-Checkbox-2")
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

    // MARK: PickerView (wheel / UIPickerView)

    @State private var wheelFruit = "Apple"
    @State private var multiColor = 0
    @State private var multiSize = 1

    private let fruits = ["Apple", "Banana", "Cherry", "Dragonfruit", "Elderberry", "Fig", "Grape"]
    private let pickerColors = ["Red", "Green", "Blue", "Yellow", "Purple"]
    private let pickerSizes = ["S", "M", "L", "XL"]

    private var pickerViewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Single wheel (PickerView)")
            Text("Use app.pickerWheels in XCUITest / Appium")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)

            Picker("Fruit", selection: $wheelFruit) {
                ForEach(fruits, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .frame(height: 148)
            .accessibilityIdentifier("test-PickerView")
            .accessibilityLabel("Fruit picker")
            .onChange(of: wheelFruit) { _, v in
                result = "Result: PickerView \(v)"
            }

            Text("Selected: \(wheelFruit)")
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-PickerViewValue")
                .accessibilityLabel("Selected: \(wheelFruit)")

            sectionHeader("Multi-column UIPickerView")
            MultiColumnPickerRepresentable(
                colors: pickerColors,
                sizes: pickerSizes,
                colorIndex: $multiColor,
                sizeIndex: $multiSize
            ) {
                let value = "\(pickerColors[multiColor]) / \(pickerSizes[multiSize])"
                result = "Result: PickerView \(value)"
            }
            .frame(maxWidth: .infinity)
            .frame(height: 148)
            .accessibilityIdentifier("test-PickerView-Multi")

            Text("Selected: \(pickerColors[multiColor]) / \(pickerSizes[multiSize])")
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-PickerViewMultiValue")
                .accessibilityLabel(
                    "Selected: \(pickerColors[multiColor]) / \(pickerSizes[multiSize])"
                )
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

            sectionHeader("Nil value (assert value == nil)")
            Text("XCUITest: XCTAssertNil(app.buttons[\"test-NilValue\"].value)")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
            NilValueButton {
                result = "Result: Nil value tapped"
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
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

/// UIButton with identifier + label, but `accessibilityValue` left unset so XCUITest `.value` is nil.
struct NilValueButton: UIViewRepresentable {
    var onTap: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    func makeUIView(context: Context) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = "NIL VALUE"
        config.baseBackgroundColor = UIColor(LebyyTheme.surface2)
        config.baseForegroundColor = UIColor(LebyyTheme.text)
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.accessibilityIdentifier = "test-NilValue"
        button.accessibilityLabel = "Nil value"
        button.accessibilityValue = nil
        button.addTarget(context.coordinator, action: #selector(Coordinator.tapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ button: UIButton, context: Context) {
        context.coordinator.onTap = onTap
        button.accessibilityValue = nil
    }

    final class Coordinator: NSObject {
        var onTap: () -> Void
        init(onTap: @escaping () -> Void) { self.onTap = onTap }
        @objc func tapped() { onTap() }
    }
}

/// Classic UIPickerView (multi-column) so XCUITest sees `app.pickerWheels`.
struct MultiColumnPickerRepresentable: UIViewRepresentable {
    let colors: [String]
    let sizes: [String]
    @Binding var colorIndex: Int
    @Binding var sizeIndex: Int
    var onChange: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.accessibilityIdentifier = "test-PickerView-Multi"
        picker.selectRow(colorIndex, inComponent: 0, animated: false)
        picker.selectRow(sizeIndex, inComponent: 1, animated: false)
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self
        if picker.selectedRow(inComponent: 0) != colorIndex {
            picker.selectRow(colorIndex, inComponent: 0, animated: false)
        }
        if picker.selectedRow(inComponent: 1) != sizeIndex {
            picker.selectRow(sizeIndex, inComponent: 1, animated: false)
        }
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: MultiColumnPickerRepresentable

        init(_ parent: MultiColumnPickerRepresentable) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            component == 0 ? parent.colors.count : parent.sizes.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            component == 0 ? parent.colors[row] : parent.sizes[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if component == 0 {
                parent.colorIndex = row
            } else {
                parent.sizeIndex = row
            }
            parent.onChange()
        }

        func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
            let title = component == 0 ? parent.colors[row] : parent.sizes[row]
            return NSAttributedString(
                string: title,
                attributes: [.foregroundColor: UIColor(LebyyTheme.text)]
            )
        }
    }
}
