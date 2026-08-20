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
            tabStack(for: .home, coordinator: coordinator.homeCoordinator) {
                homeDemoContent
            }
            .tabItem { Label(MainTab.home.title, systemImage: MainTab.home.systemImage) }
            .tag(MainTab.home)

            tabStack(for: .search, coordinator: coordinator.searchCoordinator) {
                demoContent(title: "Tìm kiếm — Step 7.4")
            }
            .tabItem { Label(MainTab.search.title, systemImage: MainTab.search.systemImage) }
            .tag(MainTab.search)

            tabStack(for: .notifications, coordinator: coordinator.notificationsCoordinator) {
                demoContent(title: "Thông báo — Step 7.4")
            }
            .tabItem { Label(MainTab.notifications.title, systemImage: MainTab.notifications.systemImage) }
            .tag(MainTab.notifications)

            tabStack(for: .profile, coordinator: coordinator.profileCoordinator) {
                demoContent(title: "Cá nhân — Step 7.4")
            }
            .tabItem { Label(MainTab.profile.title, systemImage: MainTab.profile.systemImage) }
            .tag(MainTab.profile)
        }
        .sheet(isPresented: $coordinator.isSideMenuPresented) {
            // Placeholder — SideMenuCoordinator thật sẽ thay
            VStack(spacing: DSSpacing.lg) {
                Text("Side Menu — Step 7.5").dsFont(.title2)
                DSButton("Đăng xuất", variant: .outline) {
                    coordinator.dismissSideMenu()
                    onLogout()
                }
            }
            .padding(DSSpacing.lg)
        }
    }

    // MARK: - Reusable per-tab NavigationStack wrapper

    @ViewBuilder
    private func tabStack<Content: View>(
        for tab: MainTab,
        coordinator: Coordinator<PlaceholderRoute>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack(path: Binding(
            get: { coordinator.path },
            set: { coordinator.path = $0 }
        )) {
            content()
                .navigationDestination(for: PlaceholderRoute.self) { route in
                    switch route {
                    case .demoDetail(let text):
                        Text("Demo detail: \(text)")
                            .dsFont(.title2)
                    }
                }
        }
    }

    // MARK: - Demo content (chứng minh state riêng từng tab — xoá ở Step 7.4)

    private var homeDemoContent: some View {
        VStack(spacing: DSSpacing.lg) {
            Text("Trang chủ — Step 7.4 sẽ thay bằng HomeView thật")
                .dsFont(.headline)

            DSButton("Mở Side Menu", variant: .outline) {
                coordinator.presentSideMenu()
            }

            DSButton("Push demo screen (test NavigationStack)", variant: .primary) {
                coordinator.homeCoordinator.push(.demoDetail("Từ Home"))
            }
        }
        .padding(DSSpacing.lg)
    }

    private func demoContent(title: String) -> some View {
        Text(title).dsFont(.headline)
    }
}
