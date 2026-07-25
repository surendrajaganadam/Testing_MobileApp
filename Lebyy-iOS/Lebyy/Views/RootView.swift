import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Group {
            if store.isLoggedIn {
                MainShellView()
            } else {
                LoginView()
            }
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
    }
}
