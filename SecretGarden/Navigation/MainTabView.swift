//
//  MainTabView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import SwiftUI
import DesignSystem
import CoreArchitecture
import HomeFeature
import FactoryKit
import SearchFeature

struct MainTabView: View {
    @State private var coordinator = MainTabCoordinator()
    let onLogout: () -> Void

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            homeTab
                .tabItem { Label(MainTab.home.title, systemImage: MainTab.home.systemImage) }
                .tag(MainTab.home)

            searchTab
                .tabItem { Label(MainTab.search.title, systemImage: MainTab.search.systemImage) }
                .tag(MainTab.search)

            notificationsTab
                .tabItem { Label(MainTab.notifications.title, systemImage: MainTab.notifications.systemImage) }
                .tag(MainTab.notifications)

            profileTab
                .tabItem { profileTabLabel }
                .tag(MainTab.profile)
        }
        .tint(DSColor.brandPrimary)
        .sheet(isPresented: Binding(
            get: { coordinator.sideMenuCoordinator.isPresented },
            set: { coordinator.sideMenuCoordinator.isPresented = $0 }
        )) {
            SideMenuView(coordinator: coordinator.sideMenuCoordinator)
        }
    }

    // MARK: - Profile tab icon (guest vs logged-in)

    /// TODO: Replace `avatarURL` with the actual session (AuthViewModel/KeychainManager) once
    /// Profile & Settings are implemented. Currently, it always returns `nil` -> displays the guest icon.
    private var avatarURL: URL? { nil }

    @ViewBuilder
    private var profileTabLabel: some View {
        if let avatarURL {
            Label {
                Text(MainTab.profile.title)
            } icon: {
                AsyncImage(url: avatarURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Circle().fill(DSColor.backgroundSecondary)
                    }
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .overlay {
                    // Pink border ONLY when the Personal tab is selected.
                    if coordinator.selectedTab == .profile {
                        Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 2)
                    }
                }
            }
        } else {
            // Guest: person icon, auto-filled when selected (default SF Symbol behavior in TabView).
            Label(MainTab.profile.title, systemImage: "person")
        }
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack(path: pathBinding(for: coordinator.homeCoordinator)) {
            HomeView(
                repository: Container.shared.homeRepository(),
                onSeriesSelected: { seriesId in
                    coordinator.homeCoordinator.push(.seriesDetail(id: seriesId))
                },
                onHeaderTapped: {
                    coordinator.homeCoordinator.popToRoot()
                }
            )
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .seriesDetail(let id):
                    SeriesDetailPlaceholderView(seriesId: id)
                }
            }
        }
    }

    // MARK: - Search Tab

    private var searchTab: some View {
        NavigationStack(path: pathBinding(for: coordinator.searchCoordinator)) {
            SearchView(
                repository: Container.shared.searchRepository(),
                onSeriesSelected: { seriesId in
                    coordinator.searchCoordinator.push(.seriesDetail(id: seriesId))
                },
                onHeaderTapped: {
                    coordinator.searchCoordinator.popToRoot()
                }
            )
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case .searchResults(let query):
                    Text("Search Results (demo) — query: \(query)")
                        .dsFont(.title1)
                case .seriesDetail(let id):
                    SeriesDetailPlaceholderView(seriesId: id)
                }
            }
        }
    }

    // MARK: - Notifications Tab

    private var notificationsTab: some View {
        NavigationStack(path: pathBinding(for: coordinator.notificationsCoordinator)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    GardenHeaderView {
                        coordinator.notificationsCoordinator.popToRoot()
                    }

                    VStack(spacing: DSSpacing.lg) {
                        Text("Thông báo — Phase tương ứng sẽ thay bằng NotificationListView thật")
                            .dsFont(.headline)

                        DSButton("Xem demo Notification Settings", variant: .primary) {
                            coordinator.notificationsCoordinator.push(.notificationSettings)
                        }
                    }
                    .padding(DSSpacing.lg)
                }
            }
            .background(DSColor.backgroundPrimary)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: NotificationsRoute.self) { route in
                switch route {
                case .notificationSettings:
                    Text("Notification Settings (demo)")
                        .dsFont(.title1)
                case .seriesDetail(let id):
                    Text("Series Detail (demo) — id: \(id)")
                        .dsFont(.title1)
                }
            }
        }
    }

    // MARK: - Profile Tab

    private var profileTab: some View {
        NavigationStack(path: pathBinding(for: coordinator.profileCoordinator)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    GardenHeaderView {
                        coordinator.profileCoordinator.popToRoot()
                    }

                    VStack(spacing: DSSpacing.lg) {
                        Text("Cá nhân — Phase 12 sẽ thay bằng ProfileView thật")
                            .dsFont(.headline)

                        DSButton("Xem demo Edit Profile", variant: .primary) {
                            coordinator.profileCoordinator.push(.editProfile)
                        }
                    }
                    .padding(DSSpacing.lg)
                }
            }
            .background(DSColor.backgroundPrimary)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .editProfile:
                    Text("Edit Profile (demo)")
                        .dsFont(.title1)
                case .accountSettings:
                    Text("Account Settings (demo)")
                        .dsFont(.title1)
                }
            }
        }
    }

    // MARK: - Helper

    private func pathBinding<Route: Hashable>(for coordinator: Coordinator<Route>) -> Binding<NavigationPath> {
        Binding(
            get: { coordinator.path },
            set: { coordinator.path = $0 }
        )
    }
}
