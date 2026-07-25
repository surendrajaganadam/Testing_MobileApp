import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var store: AppStore
    @State private var username = ""
    @State private var password = ""
    @State private var error = ""
    @State private var toastMessage = ""
    @State private var toastTask: Task<Void, Never>?

    var body: some View {
        ZStack {
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

                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.text)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("test-Username")
                        .accessibilityLabel("Username")

                    SecureField("Password", text: $password)
                        .padding()
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.text)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .accessibilityIdentifier("test-Password")
                        .accessibilityLabel("Password")

                    Button("LOGIN") {
                        if store.login(username: username.trimmingCharacters(in: .whitespaces), password: password) {
                            error = ""
                            store.isLoggedIn = true
                        } else {
                            error = "Invalid credentials. Use demo_user / demo_pass"
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LebyyTheme.accent)
                    .foregroundStyle(LebyyTheme.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityIdentifier("test-LOGIN")

                    if !error.isEmpty {
                        Text(error).foregroundStyle(.red).font(.footnote)
                    }

                    Text("Quick Gestures")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(LebyyTheme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 14)
                        .accessibilityIdentifier("test-QuickGestures")

                    gestureButton(title: "LONG PRESS ME", accessibilityId: "test-LoginLongPress")
                        .onLongPressGesture(minimumDuration: 2) {
                            showToast("Long press done")
                        }

                    gestureButton(title: "DOUBLE TAP ME", accessibilityId: "test-LoginDoubleTap")
                        .onTapGesture(count: 2) {
                            showToast("Double tap done")
                        }
                }
                .padding(24)
            }

            if !toastMessage.isEmpty {
                Text(toastMessage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(LebyyTheme.bg)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(LebyyTheme.accent)
                    .clipShape(Capsule())
                    .padding(.bottom, 40)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .transition(.opacity)
                    .accessibilityIdentifier("test-LoginGestureToast")
            }
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.2), value: toastMessage)
    }

    private func gestureButton(title: String, accessibilityId: String) -> some View {
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
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityIdentifier(accessibilityId)
    }

    private func showToast(_ message: String) {
        toastTask?.cancel()
        toastMessage = message
        toastTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                toastMessage = ""
            }
        }
    }
}
