import SwiftUI

struct AlertsView: View {
    @State private var result = "Result: —"
    @State private var showAlert = false
    @State private var showConfirm = false
    @State private var showPrompt = false
    @State private var promptText = ""

    var body: some View {
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

            Text(result)
                .foregroundStyle(LebyyTheme.accent)
                .accessibilityIdentifier("test-AlertResult")

            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LebyyTheme.bg.ignoresSafeArea())
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

    private let options = [
        "Select an item...",
        "This app is awesome",
        "webdriver.io is awesome",
        "Appium is awesome",
        "Lebyy is awesome",
    ]

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

                // Split label + switch so automation taps hit the knob (center of a
                // full-width Toggle lands on the label and never flips the value).
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

                Picker("Dropdown", selection: $dropdown) {
                    ForEach(options, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(LebyyTheme.text)
                .accessibilityIdentifier("test-Dropdown")
                .onChange(of: dropdown) { _, value in
                    result = "Result: Dropdown \(value)"
                }

                Text("Checkboxes").font(.caption).foregroundStyle(LebyyTheme.muted)
                Toggle("Option A", isOn: $checkA)
                    .toggleStyle(.checkboxIOS)
                    .accessibilityIdentifier("test-Checkbox-1")
                    .onChange(of: checkA) { _, _ in updateChecks() }
                Toggle("Option B", isOn: $checkB)
                    .toggleStyle(.checkboxIOS)
                    .accessibilityIdentifier("test-Checkbox-2")
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

                Text(result)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-FormsResult")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
    }

    private func updateChecks() {
        var parts: [String] = []
        if checkA { parts.append("A") }
        if checkB { parts.append("B") }
        result = "Result: Checkbox \(parts.isEmpty ? "none" : parts.joined(separator: ","))"
    }
}

/// Simple checkbox-like toggle for Forms demo
struct CheckboxIOSToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(LebyyTheme.primary)
                configuration.label.foregroundStyle(LebyyTheme.text)
                Spacer()
            }
        }
        .buttonStyle(.plain)
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
            ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                VStack(alignment: .leading, spacing: 0) {
                    Image(card.2)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .padding(12)
                    Text(card.0)
                        .font(.title2.bold())
                        .foregroundStyle(LebyyTheme.primary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .accessibilityIdentifier("test-CARD \(index + 1)")
                    Text(card.1)
                        .foregroundStyle(LebyyTheme.text)
                        .padding()
                }
                .background(LebyyTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(16)
                .frame(maxHeight: 360)
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

    var body: some View {
        VStack(spacing: 20) {
            Text(result)
                .foregroundStyle(LebyyTheme.accent)
                .accessibilityIdentifier("test-GestureResult")

            Text("Long press this box")
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.primary)
                .font(.headline)
                .onLongPressGesture(minimumDuration: 0.6) {
                    result = "Result: Long Pressed"
                }
                .accessibilityIdentifier("test-LongPress")

            Text("Double tap this box")
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(LebyyTheme.surface)
                .foregroundStyle(LebyyTheme.primary)
                .font(.headline)
                .onTapGesture(count: 2) {
                    result = "Result: Double Tapped"
                }
                .accessibilityIdentifier("test-DoubleTap")

            Spacer()
        }
        .padding(20)
        .background(LebyyTheme.bg.ignoresSafeArea())
    }
}

struct WebBrowserView: View {
    @State private var urlText = "https://www.google.com"
    @State private var loadURL = URL(string: "about:blank")!

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
            }
            .padding(12)
            .background(LebyyTheme.surface)

            WebViewRepresentable(url: loadURL)
                .background(Color.white)
                .accessibilityIdentifier("test-WebView")
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .onAppear {
            // Local starter page
            let html = """
            <html><body style='font-family:sans-serif;padding:16px;background:#fff;color:#0f2144'>
            <h1>Lebyy</h1><p>Learn by yourself</p>
            <p>Enter a URL above and tap <b>GO TO SITE</b>.</p>
            <p><a href='https://www.google.com'>Open Google</a></p>
            </body></html>
            """
            loadURL = URL(string: "data:text/html;charset=utf-8,\(html.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!
        }
    }
}

import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView()
        web.isInspectable = true
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
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
