//
//  ProfileDrawerView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

// A separate Drawer + NavigationStack list inside its own sheet.

import SearchFeature
import HomeFeature
import SocialFeature
import Repositories
import FactoryKit
import SwiftUI
import DesignSystem
import CoreArchitecture
import CoreModels

struct ProfileDrawerView: View {
    @Bindable var coordinator: ProfileDrawerCoordinator
    let currentUser: User?
    let onAuthenticated: () -> Void
    let onProfileUpdated: (User) -> Void
    @State private var reportTarget: ReportSheetTarget?
    @State private var globalToastMessage: String?

    private struct DrawerItem: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let route: ProfileRoute
    }

    private let drawerItems: [DrawerItem] = [
        DrawerItem(title: "Trang cá nhân", systemImage: "person.crop.circle", route: .personalInfo),
        DrawerItem(title: "Yêu thích", systemImage: "heart", route: .favorites),
        DrawerItem(title: "Nhóm theo dõi", systemImage: "person.3", route: .followedGroups),
        DrawerItem(title: "Lịch sử", systemImage: "clock.arrow.circlepath", route: .history),
        DrawerItem(title: "Danh mục", systemImage: "square.grid.2x2", route: .category),
        DrawerItem(title: "Tìm kiếm nâng cao", systemImage: "slider.horizontal.3", route: .advancedSearch),
        DrawerItem(title: "Yuri list", systemImage: "list.bullet.rectangle", route: .yuriList),
        DrawerItem(title: "Đăng ký upload", systemImage: "square.and.arrow.up", route: .uploadRegistration),
        DrawerItem(title: "Quy định", systemImage: "doc.text", route: .rules)
    ]

    var body: some View {
        NavigationStack(path: pathBinding) {
            List {
                ForEach(drawerItems) { item in
                    Button { coordinator.contentCoordinator.push(item.route) } label: {
                        Label(item.title, systemImage: item.systemImage)
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationDestination(for: ProfileRoute.self) { route in
                ProfileDestinationBuilder.destination(
                    for: route,
                    coordinator: coordinator.contentCoordinator,
                    context: ProfileDestinationContext(
                        currentUser: currentUser,
                        onAuthenticated: onAuthenticated,
                        onProfileUpdated: onProfileUpdated
                    ),
                    onReportTapped: { reportTarget = $0 }
                )
            }
        }
        .overlay {
            if let target = reportTarget {
                ReportView(
                    seriesId: target.seriesId,
                    chapterId: target.chapterId,
                    seriesRepository: Container.shared.seriesRepository(),
                    onDismiss: { reportTarget = nil },
                    onSubmitted: { message in globalToastMessage = message }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: reportTarget != nil)
        .dsSuccessToast(message: $globalToastMessage)
    }

    private var pathBinding: Binding<NavigationPath> {
        Binding(get: { coordinator.contentCoordinator.path }, set: { coordinator.contentCoordinator.path = $0 })
    }
}
