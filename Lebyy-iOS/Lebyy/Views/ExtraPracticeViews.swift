import SwiftUI
import PhotosUI

// MARK: - Lists (pull to refresh, swipe delete, nested scroll, infinite scroll)

struct ListsPracticeView: View {
    @State private var refreshItems = (1...8).map { "Refresh Item \($0)" }
    @State private var refreshCount = 0
    @State private var swipeItems = (1...6).map { "Swipe Row \($0)" }
    @State private var deletedMessage = "Deleted: —"
    @State private var infiniteItems = Array(1...15)
    @State private var isLoadingMore = false
    @State private var loadMoreCount = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                sectionTitle("Pull to Refresh")
                Text("Pull the list below to refresh")
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-PullRefreshHint")

                List {
                    ForEach(refreshItems, id: \.self) { item in
                        Text(item)
                            .foregroundStyle(LebyyTheme.text)
                            .listRowBackground(LebyyTheme.surface)
                            .accessibilityIdentifier("test-RefreshItem")
                    }
                }
                .frame(height: 220)
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .refreshable {
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    refreshCount += 1
                    refreshItems = (1...8).map { "Refresh Item \($0) · v\(refreshCount)" }
                }
                .accessibilityIdentifier("test-PullRefreshList")

                Text("Refresh count: \(refreshCount)")
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-RefreshCount")
                    .accessibilityLabel("Refresh count: \(refreshCount)")

                sectionTitle("Swipe to Delete")
                List {
                    ForEach(swipeItems, id: \.self) { item in
                        Text(item)
                            .foregroundStyle(LebyyTheme.text)
                            .listRowBackground(LebyyTheme.surface)
                            .accessibilityIdentifier("test-SwipeRow")
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    swipeItems.removeAll { $0 == item }
                                    deletedMessage = "Deleted: \(item)"
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .accessibilityIdentifier("test-SwipeDeleteAction")
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    deletedMessage = "Edited: \(item)"
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(LebyyTheme.primary)
                                .accessibilityIdentifier("test-SwipeEditAction")
                            }
                    }
                }
                .frame(height: 240)
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .accessibilityIdentifier("test-SwipeActionsList")

                Text(deletedMessage)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-SwipeActionResult")

                Button("Reset Swipe Rows") {
                    swipeItems = (1...6).map { "Swipe Row \($0)" }
                    deletedMessage = "Deleted: —"
                }
                .buttonStyle(LebyyCyanButton())
                .accessibilityIdentifier("test-ResetSwipeRows")

                sectionTitle("Nested Scroll")
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 12) {
                        ForEach(1...10, id: \.self) { i in
                            Text("Card \(i)")
                                .frame(width: 120, height: 80)
                                .background(LebyyTheme.surface)
                                .foregroundStyle(LebyyTheme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .accessibilityIdentifier("test-NestedCard-\(i)")
                        }
                    }
                    .padding(.vertical, 4)
                }
                .accessibilityIdentifier("test-NestedHorizontalScroll")

                sectionTitle("Infinite Scroll")
                LazyVStack(spacing: 8) {
                    ForEach(infiniteItems, id: \.self) { i in
                        Text("Infinite Item \(i)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(LebyyTheme.surface)
                            .foregroundStyle(LebyyTheme.text)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .accessibilityIdentifier("test-InfiniteItem")
                            .onAppear {
                                if i == infiniteItems.last {
                                    loadMore()
                                }
                            }
                    }
                    if isLoadingMore {
                        ProgressView("Loading more…")
                            .tint(LebyyTheme.primary)
                            .foregroundStyle(LebyyTheme.muted)
                            .accessibilityIdentifier("test-InfiniteLoading")
                    }
                }
                .accessibilityIdentifier("test-InfiniteList")

                Text("Pages loaded: \(loadMoreCount)")
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-InfinitePageCount")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-ListsScreen")
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(LebyyTheme.primary)
            .accessibilityAddTraits(.isHeader)
    }

    private func loadMore() {
        guard !isLoadingMore, loadMoreCount < 5 else { return }
        isLoadingMore = true
        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)
            await MainActor.run {
                let start = (infiniteItems.last ?? 0) + 1
                infiniteItems.append(contentsOf: start...(start + 9))
                loadMoreCount += 1
                isLoadingMore = false
            }
        }
    }
}

// MARK: - Waits (delayed load + network error)

struct WaitsPracticeView: View {
    @State private var isLoading = false
    @State private var loadedText = ""
    @State private var networkState: NetworkDemoState = .idle
    @State private var delaySeconds = 3

    enum NetworkDemoState {
        case idle, loading, success, error
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Delayed Content")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                Stepper("Delay: \(delaySeconds)s", value: $delaySeconds, in: 1...8)
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-DelayStepper")

                Button("Load After Delay") {
                    loadedText = ""
                    isLoading = true
                    let seconds = delaySeconds
                    Task {
                        try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
                        await MainActor.run {
                            isLoading = false
                            loadedText = "Content ready after \(seconds)s"
                        }
                    }
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-LoadDelayed")

                if isLoading {
                    ProgressView("Loading…")
                        .tint(LebyyTheme.accent)
                        .foregroundStyle(LebyyTheme.text)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .accessibilityIdentifier("test-LoadingSpinner")
                        .accessibilityLabel("Loading")
                }

                if !loadedText.isEmpty {
                    Text(loadedText)
                        .foregroundStyle(LebyyTheme.success)
                        .accessibilityIdentifier("test-DelayedContent")
                        .accessibilityLabel(loadedText)
                }

                Divider().overlay(LebyyTheme.line)

                Text("Network Error / Retry")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                Button("Simulate Network Fail") {
                    networkState = .loading
                    Task {
                        try? await Task.sleep(nanoseconds: 600_000_000)
                        await MainActor.run { networkState = .error }
                    }
                }
                .buttonStyle(LebyyCyanButton())
                .accessibilityIdentifier("test-SimulateNetworkFail")

                Button("Simulate Network Success") {
                    networkState = .loading
                    Task {
                        try? await Task.sleep(nanoseconds: 600_000_000)
                        await MainActor.run { networkState = .success }
                    }
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-SimulateNetworkSuccess")

                switch networkState {
                case .idle:
                    Text("Status: Idle")
                        .foregroundStyle(LebyyTheme.muted)
                        .accessibilityIdentifier("test-NetworkStatus-Idle")
                case .loading:
                    ProgressView("Fetching…")
                        .accessibilityIdentifier("test-NetworkStatus-Loading")
                case .error:
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Status: Offline / Error")
                            .foregroundStyle(.red)
                            .accessibilityIdentifier("test-NetworkStatus-Error")
                        Text("Could not reach server")
                            .font(.caption)
                            .foregroundStyle(LebyyTheme.muted)
                            .accessibilityIdentifier("test-NetworkErrorMessage")
                        Button("Retry") {
                            networkState = .loading
                            Task {
                                try? await Task.sleep(nanoseconds: 500_000_000)
                                await MainActor.run { networkState = .success }
                            }
                        }
                        .buttonStyle(LebyyPrimaryButton())
                        .accessibilityIdentifier("test-NetworkRetry")
                    }
                case .success:
                    Text("Status: Success — data loaded")
                        .foregroundStyle(LebyyTheme.success)
                        .accessibilityIdentifier("test-NetworkStatus-Success")
                }
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-WaitsScreen")
    }
}

// MARK: - System (permissions, image, share, clipboard, orientation)

struct SystemPracticeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var permissionResult = "Permission: —"
    @State private var showPermissionDialog = false
    @State private var pendingPermission = ""
    @State private var pickedImageName = "None"
    @State private var photoItem: PhotosPickerItem?
    @State private var clipboardResult = "Clipboard: —"
    @State private var shareText = "Lebyy automation rocks"
    @State private var orientationNote = "Rotate device to practice landscape"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Mock Permissions")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                HStack(spacing: 10) {
                    Button("Camera") { askPermission("Camera") }
                        .buttonStyle(LebyyCyanButton())
                        .accessibilityIdentifier("test-PermissionCamera")
                    Button("Location") { askPermission("Location") }
                        .buttonStyle(LebyyCyanButton())
                        .accessibilityIdentifier("test-PermissionLocation")
                }
                Button("Notifications") { askPermission("Notifications") }
                    .buttonStyle(LebyyCyanButton())
                    .accessibilityIdentifier("test-PermissionNotifications")

                Text(permissionResult)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-PermissionResult")

                Divider().overlay(LebyyTheme.line)

                Text("Image Picker")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text("Pick Photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LebyyTheme.accent)
                        .foregroundStyle(LebyyTheme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityIdentifier("test-PickPhoto")
                .accessibilityLabel("Pick Photo")

                Button("Use Sample Image") {
                    pickedImageName = "course_1"
                }
                .buttonStyle(LebyyCyanButton())
                .accessibilityIdentifier("test-UseSampleImage")

                Text("Selected: \(pickedImageName)")
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-SelectedImage")
                    .accessibilityLabel("Selected: \(pickedImageName)")

                if pickedImageName != "None", pickedImageName != "Picked Photo" {
                    Image(pickedImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .accessibilityIdentifier("test-ImagePreview")
                }

                Divider().overlay(LebyyTheme.line)

                Text("Clipboard & Share")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                TextField("Share text", text: $shareText)
                    .padding()
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-ShareText")
                    .accessibilityLabel("Share text")

                Button("Copy to Clipboard") {
                    UIPasteboard.general.string = shareText
                    clipboardResult = "Clipboard: copied"
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-CopyClipboard")

                Button("Paste from Clipboard") {
                    let value = UIPasteboard.general.string ?? ""
                    clipboardResult = "Clipboard: \(value.isEmpty ? "(empty)" : value)"
                }
                .buttonStyle(LebyyCyanButton())
                .accessibilityIdentifier("test-PasteClipboard")

                ShareLink(item: shareText) {
                    Text("Open Share Sheet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LebyyTheme.surface)
                        .foregroundStyle(LebyyTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityIdentifier("test-ShareSheet")
                .accessibilityLabel("Open Share Sheet")

                Text(clipboardResult)
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier("test-ClipboardResult")

                Divider().overlay(LebyyTheme.line)

                Text("Orientation")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                Text(orientationNote)
                    .font(.caption)
                    .foregroundStyle(LebyyTheme.muted)
                    .accessibilityIdentifier("test-OrientationHint")

                Toggle("Force Portrait Only", isOn: $store.forcePortraitOnly)
                    .tint(LebyyTheme.primary)
                    .foregroundStyle(LebyyTheme.text)
                    .accessibilityIdentifier("test-ForcePortrait")
                    .accessibilityLabel("Force Portrait Only")

                Text(store.forcePortraitOnly ? "Mode: Portrait locked" : "Mode: All orientations")
                    .foregroundStyle(LebyyTheme.accent)
                    .accessibilityIdentifier(store.forcePortraitOnly ? "test-Orientation-Portrait" : "test-Orientation-All")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-SystemScreen")
        .onChange(of: photoItem) { _, item in
            if item != nil {
                pickedImageName = "Picked Photo"
            }
        }
        .alert("Allow \(pendingPermission)?", isPresented: $showPermissionDialog) {
            Button("Allow") {
                permissionResult = "Permission: \(pendingPermission) Allow"
            }
            .accessibilityIdentifier("test-PermissionAllow")
            Button("Don't Allow", role: .cancel) {
                permissionResult = "Permission: \(pendingPermission) Deny"
            }
            .accessibilityIdentifier("test-PermissionDeny")
        } message: {
            Text("Lebyy would like to access \(pendingPermission.lowercased()).")
        }
    }

    private func askPermission(_ name: String) {
        pendingPermission = name
        showPermissionDialog = true
    }
}

// MARK: - Navigation (bottom tabs + deep link)

struct NavigationPracticeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            Text("Last deep link: \(store.lastDeepLink.isEmpty ? "—" : store.lastDeepLink)")
                .font(.caption)
                .foregroundStyle(LebyyTheme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .accessibilityIdentifier("test-LastDeepLink")
                .accessibilityLabel("Last deep link: \(store.lastDeepLink.isEmpty ? "none" : store.lastDeepLink)")

            Text("Open via: lebyy://forms  ·  lebyy://shop  ·  lebyy://waits")
                .font(.caption2)
                .foregroundStyle(LebyyTheme.muted)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .accessibilityIdentifier("test-DeepLinkHelp")

            TabView(selection: $tab) {
                tabPane(title: "Home Tab", id: "Home", color: LebyyTheme.primary)
                    .tabItem { Label("Home", systemImage: "house") }
                    .tag(0)
                    .accessibilityIdentifier("test-Tab-Home")

                tabPane(title: "Search Tab", id: "Search", color: LebyyTheme.accent)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(1)
                    .accessibilityIdentifier("test-Tab-Search")

                tabPane(title: "Profile Tab", id: "Profile", color: LebyyTheme.success)
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(2)
                    .accessibilityIdentifier("test-Tab-Profile")
            }
            .tint(LebyyTheme.primary)
            .accessibilityIdentifier("test-BottomTabs")

            Text("Selected tab: \(["Home", "Search", "Profile"][tab])")
                .padding(12)
                .foregroundStyle(LebyyTheme.accent)
                .accessibilityIdentifier("test-SelectedTab")
                .accessibilityLabel("Selected tab: \(["Home", "Search", "Profile"][tab])")
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-NavigationScreen")
    }

    private func tabPane(title: String, id: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(color)
                .accessibilityIdentifier("test-TabContent-\(id)")
            Text("Practice bottom-tab switching")
                .foregroundStyle(LebyyTheme.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LebyyTheme.bg)
    }
}

// MARK: - Settings (profile + session timeout)

struct SettingsPracticeView: View {
    @EnvironmentObject private var store: AppStore
    @State private var savedBanner = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Profile")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                TextField("Display name", text: $store.displayName)
                    .padding()
                    .background(LebyyTheme.surface)
                    .foregroundStyle(LebyyTheme.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .accessibilityIdentifier("test-DisplayName")
                    .accessibilityLabel("Display name")

                Button("Save Profile") {
                    savedBanner = "Saved: \(store.displayName)"
                    store.touchSession()
                }
                .buttonStyle(LebyyPrimaryButton())
                .accessibilityIdentifier("test-SaveProfile")

                if !savedBanner.isEmpty {
                    Text(savedBanner)
                        .foregroundStyle(LebyyTheme.success)
                        .accessibilityIdentifier("test-ProfileSaved")
                }

                Divider().overlay(LebyyTheme.line)

                Text("Session Timeout")
                    .font(.headline)
                    .foregroundStyle(LebyyTheme.primary)

                Toggle("Enable auto logout", isOn: Binding(
                    get: { store.sessionTimeoutEnabled },
                    set: { store.setSessionTimeout(enabled: $0) }
                ))
                .tint(LebyyTheme.primary)
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-SessionTimeoutToggle")
                .accessibilityLabel("Enable auto logout")

                Stepper("Timeout: \(store.sessionTimeoutSeconds)s", value: Binding(
                    get: { store.sessionTimeoutSeconds },
                    set: { store.setSessionTimeout(enabled: store.sessionTimeoutEnabled, seconds: $0) }
                ), in: 10...120, step: 10)
                .foregroundStyle(LebyyTheme.text)
                .accessibilityIdentifier("test-SessionTimeoutStepper")

                if store.sessionTimeoutEnabled {
                    Text("Logs out in: \(store.sessionSecondsRemaining)s")
                        .foregroundStyle(LebyyTheme.accent)
                        .accessibilityIdentifier("test-SessionCountdown")
                        .accessibilityLabel("Logs out in: \(store.sessionSecondsRemaining)s")

                    Button("Reset Session Timer") {
                        store.touchSession()
                    }
                    .buttonStyle(LebyyCyanButton())
                    .accessibilityIdentifier("test-ResetSessionTimer")
                }

                Button("Force Logout Now") {
                    store.logout()
                }
                .buttonStyle(LebyyMutedButton())
                .accessibilityIdentifier("test-ForceLogout")
            }
            .padding(16)
        }
        .background(LebyyTheme.bg.ignoresSafeArea())
        .accessibilityIdentifier("test-SettingsScreen")
        .onAppear { store.touchSession() }
        .onTapGesture { store.touchSession() }
    }
}
