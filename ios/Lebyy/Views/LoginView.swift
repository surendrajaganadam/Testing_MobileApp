import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var store: AppStore
    @State private var username = ""
    @State private var password = ""
    @State private var error = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("logo_lebyy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .padding(.top, 48)

                Text("Lebyy")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(LebyyTheme.primary)

                Text("Learn by yourself")
                    .font(.subheadline)
                    .foregroundStyle(LebyyTheme.muted)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Currently accepted credentials\nUsername: demo_user\nPassword: demo_pass")
                        .font(.subheadline)
                        .foregroundStyle(LebyyTheme.accent)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
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
            }
            .padding(24)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
    }
}
