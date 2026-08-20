//
//  MainTabView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import SwiftUI
import DesignSystem
import CoreArchitecture

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
                .tabItem { Label(MainTab.profile.title, systemImage: MainTab.profile.systemImage) }
                .tag(MainTab.profile)
        }
        .sheet(isPresented: Binding(
            get: { coordinator.sideMenuCoordinator.isPresented },
            set: { coordinator.sideMenuCoordinator.isPresented = $0 }
        )) {
            SideMenuView(coordinator: coordinator.sideMenuCoordinator)
        }
    }

    // MARK: - Home Tab

    private var homeTab: some View {
        NavigationStack(path: pathBinding(for: coordinator.homeCoordinator)) {
            VStack(spacing: DSSpacing.lg) {
                Text("Trang chủ — Step 8 sẽ thay bằng HomeView thật")
                    .dsFont(.headline)

                DSButton("Mở Side Menu", variant: .outline) {
                    coordinator.sideMenuCoordinator.present()
                }

                DSButton("Xem demo Series Detail", variant: .primary) {
                    coordinator.homeCoordinator.push(.seriesDetail(id: "demo-001"))
                }
            }
            .padding(DSSpacing.lg)
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .seriesDetail(let id):
                    Text("Series Detail (demo) — id: \(id)")
                        .dsFont(.title1)
                }
            }
        }
    }

    // MARK: - Search Tab

    private var searchTab: some View {
        NavigationStack(path: pathBinding(for: coordinator.searchCoordinator)) {
            VStack(spacing: DSSpacing.lg) {
                Text("Tìm kiếm — Step 9 sẽ thay bằng SearchView thật")
                    .dsFont(.headline)

                DSButton("Xem demo Search Results", variant: .primary) {
                    coordinator.searchCoordinator.push(.searchResults(query: "yuri"))
                }
            }
            .padding(DSSpacing.lg)
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case .searchResults(let query):
                    Text("Search Results (demo) — query: \(query)")
                        .dsFont(.title1)
                case .seriesDetail(let id):
                    Text("Series Detail (demo) — id: \(id)")
                        .dsFont(.title1)
                }
            }
        }
    }

    // MARK: - Notifications Tab

    private var notificationsTab: some View {
        NavigationStack(path: pathBinding(for: coordinator.notificationsCoordinator)) {
            VStack(spacing: DSSpacing.lg) {
                Text("Thông báo — Phase tương ứng sẽ thay bằng NotificationListView thật")
                    .dsFont(.headline)

                DSButton("Xem demo Notification Settings", variant: .primary) {
                    coordinator.notificationsCoordinator.push(.notificationSettings)
                }
            }
            .padding(DSSpacing.lg)
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
            VStack(spacing: DSSpacing.lg) {
                Text("Cá nhân — Phase 12 sẽ thay bằng ProfileView thật")
                    .dsFont(.headline)

                DSButton("Xem demo Edit Profile", variant: .primary) {
                    coordinator.profileCoordinator.push(.editProfile)
                }
            }
            .padding(DSSpacing.lg)
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
