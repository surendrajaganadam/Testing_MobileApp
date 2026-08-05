import SwiftUI

@main
struct LebyyApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    store.handleDeepLink(url)
                    if !store.isLoggedIn {
                        // Deep link remembered; navigate after login.
                    }
                }
        }
    }
}
