import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var store: AppStore
    @State private var username = ""
    @State private var password = ""
    @State private var error = ""
    @State private var gestureResult = ""
    @State private var doubleTapCount = 0
    @State private var doubleTapResetTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Image("logo_lebyy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .padding(.top, 32)

                Text("Lebyy")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(LebyyTheme.primary)
                    .accessibilityIdentifier("test-LoginBrand")

                Text("Learn by yourself")
                    .font(.subheadline)
                    .foregroundStyle(LebyyTheme.muted)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Currently accepted credentials\nUsername: demo_user\nPassword: demo_pass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(LebyyTheme.accent)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .accessibilityIdentifier("test-DemoCredentials")
                }
                .background(LebyyTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(LebyyTheme.line, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                TextField("", text: $username, prompt: Text("Username"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-Username")
                    .accessibilityLabel("test-Username")

                SecureField("", text: $password, prompt: Text("Password"))
                    .padding()
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-Password")
                    .accessibilityLabel("test-Password")

                Button {
                    if store.login(username: username.trimmingCharacters(in: .whitespaces), password: password) {
                        error = ""
                        store.loginSuccess()
                    } else {
                        error = "Invalid credentials. Use demo_user / demo_pass"
                    }
                } label: {
                    Text("LOGIN")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LebyyTheme.accent)
                        .foregroundStyle(LebyyTheme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("test-LOGIN")
                .accessibilityLabel("test-LOGIN")

                if !error.isEmpty {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .accessibilityIdentifier("test-LoginError")
                        .accessibilityLabel(error)
                }

                Text("Quick Gestures")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(LebyyTheme.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 14)
                    .accessibilityIdentifier("test-QuickGestures")

                gestureButton(title: "LONG PRESS ME", accessibilityId: "test-LoginLongPress")
                    .highPriorityGesture(
                        LongPressGesture(minimumDuration: 2)
                            .onEnded { _ in showGestureResult("Long press done") }
                    )

                Button {
                    handleDoubleTap()
                } label: {
                    gestureButtonLabel(title: "DOUBLE TAP ME")
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("test-LoginDoubleTap")
                .accessibilityLabel("DOUBLE TAP ME")

                if !gestureResult.isEmpty {
                    HStack(spacing: 10) {
                        Text(gestureResult)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(LebyyTheme.success)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("test-LoginGestureResult")
                            .accessibilityLabel(gestureResult)

                        Button {
                            gestureResult = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(LebyyTheme.muted)
                                .frame(width: 36, height: 36)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("test-LoginGestureResult-Dismiss")
                        .accessibilityLabel("Dismiss")
                    }
                    .padding(12)
                    .background(LebyyTheme.surface)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(LebyyTheme.line, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(24)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: gestureResult)
        .accessibilityIdentifier("test-LoginScreen")
    }

    private func gestureButton(title: String, accessibilityId: String) -> some View {
        gestureButtonLabel(title: title)
            .accessibilityIdentifier(accessibilityId)
            .accessibilityLabel(title)
    }

    private func gestureButtonLabel(title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(LebyyTheme.primary)
            .background(LebyyTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LebyyTheme.primary, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
    }

    private func handleDoubleTap() {
        doubleTapCount += 1
        if doubleTapCount >= 2 {
            doubleTapResetTask?.cancel()
            doubleTapCount = 0
            showGestureResult("Double tap done")
            return
        }
        doubleTapResetTask?.cancel()
        doubleTapResetTask = Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run { doubleTapCount = 0 }
        }
    }

    private func showGestureResult(_ message: String) {
        gestureResult = message
    }
}
