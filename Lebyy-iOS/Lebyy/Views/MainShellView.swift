import SwiftUI

/// Legacy shell kept only so older references compile; tabs replace the drawer.
struct MainShellView: View {
    var body: some View {
        TabRootView()
    }
}
