//
//  MainTabView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import SwiftUI
import DesignSystem
import CoreArchitecture
import CoreModels
import HomeFeature
import FactoryKit
import SearchFeature
import SocialFeature

struct MainTabView: View {
    @State private var coordinator = MainTabCoordinator()
    @State private var reportTarget: ReportSheetTarget?
    @State private var globalToastMessage: String?
    let currentUser: User?
    let onAuthenticated: () -> Void
    let onProfileUpdated: (User) -> Void
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
        .animation(.easeInOut(duration: 0.25), value: coordinator.profileDrawerCoordinator.isPresented)
        .overlay {
            if coordinator.profileDrawerCoordinator.isPresented {
                ZStack(alignment: .trailing) {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                coordinator.profileDrawerCoordinator.isPresented = false
                            }
                        }
                    ProfileDrawerView(
                        coordinator: coordinator.profileDrawerCoordinator,
                        currentUser: currentUser,
                        onAuthenticated: onAuthenticated,
                        onProfileUpdated: onProfileUpdated
                    )
                        .frame(width: 300)
                        .transition(.move(edge: .trailing))
                }
                .transition(.opacity)
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

    // MARK: - Profile tab icon (guest vs logged-in)

    private var avatarURL: URL? { currentUser?.avatarURL }

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
                    SeriesDetailView(
                        seriesId: id,
                        seriesRepository: Container.shared.seriesRepository(),
                        commentRepository: Container.shared.commentRepository(),
                        onHeaderTapped: { coordinator.homeCoordinator.popToRoot() },
                        onStartReading: { chapterId in
                            coordinator.homeCoordinator.push(.chapterReader(seriesId: id, chapterId: chapterId))
                        },
                        onContinueReading: { chapterId in
                            coordinator.homeCoordinator.push(.chapterReader(seriesId: id, chapterId: chapterId))
                        },
                        onReportTapped: {
                            reportTarget = ReportSheetTarget(seriesId: id, chapterId: nil)
                        },
                        onAuthorTapped: { authorId in
                            coordinator.homeCoordinator.push(.authorProfile(id: authorId, roleLabel: "Tác giả"))
                        },
                        onArtistTapped: { artistId in
                            coordinator.homeCoordinator.push(.authorProfile(id: artistId, roleLabel: "Họa sĩ"))
                        },
                        onGroupTapped: { groupId in
                            coordinator.homeCoordinator.push(.groupProfile(id: groupId))
                        }
                    )
                case .chapterReader(let seriesId, let chapterId):
                    ChapterReaderView(
                        seriesId: seriesId,
                        initialChapterId: chapterId,
                        seriesRepository: Container.shared.seriesRepository(),
                        commentRepository: Container.shared.commentRepository(),
                        onHomeTapped: { coordinator.homeCoordinator.popToRoot() },
                        onSeriesSelected: { newSeriesId in
                            coordinator.homeCoordinator.push(.seriesDetail(id: newSeriesId))
                        },
                        onBackToDetailTapped: { coordinator.homeCoordinator.pop() },
                        onReportTapped: { reportTarget = ReportSheetTarget(seriesId: seriesId, chapterId: chapterId) }
                    )
                case .groupProfile(let id):
                    GroupProfileView(
                        groupId: id,
                        groupRepository: Container.shared.groupRepository(),
                        onSeriesSelected: { seriesId in coordinator.homeCoordinator.push(.seriesDetail(id: seriesId)) }
                    )
                case .authorProfile(let id, let roleLabel):
                    AuthorProfileView(
                        authorId: id,
                        roleLabel: roleLabel,
                        authorRepository: Container.shared.authorRepository(),
                        onSeriesSelected: { seriesId in coordinator.homeCoordinator.push(.seriesDetail(id: seriesId)) }
                    )
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
                    SeriesDetailView(
                        seriesId: id,
                        seriesRepository: Container.shared.seriesRepository(),
                        commentRepository: Container.shared.commentRepository(),
                        onHeaderTapped: { coordinator.searchCoordinator.popToRoot() },
                        onStartReading: { chapterId in
                            coordinator.searchCoordinator.push(.chapterReader(seriesId: id, chapterId: chapterId))
                        },
                        onContinueReading: { chapterId in
                            coordinator.searchCoordinator.push(.chapterReader(seriesId: id, chapterId: chapterId))
                        },
                        onReportTapped: {
                            reportTarget = ReportSheetTarget(seriesId: id, chapterId: nil)
                        },
                        onAuthorTapped: { authorId in
                            coordinator.searchCoordinator.push(.authorProfile(id: authorId, roleLabel: "Tác giả"))
                        },
                        onArtistTapped: { artistId in
                            coordinator.searchCoordinator.push(.authorProfile(id: artistId, roleLabel: "Họa sĩ"))
                        },
                        onGroupTapped: { groupId in
                            coordinator.searchCoordinator.push(.groupProfile(id: groupId))
                        }
                    )
                case .chapterReader(let seriesId, let chapterId):
                    ChapterReaderView(
                        seriesId: seriesId,
                        initialChapterId: chapterId,
                        seriesRepository: Container.shared.seriesRepository(),
                        commentRepository: Container.shared.commentRepository(),
                        onHomeTapped: { coordinator.searchCoordinator.popToRoot() },
                        onSeriesSelected: { newSeriesId in
                            coordinator.searchCoordinator.push(.seriesDetail(id: newSeriesId))
                        },
                        onBackToDetailTapped: { coordinator.searchCoordinator.pop() },
                        onReportTapped: { reportTarget = ReportSheetTarget(seriesId: seriesId, chapterId: chapterId) }
                    )
                case .groupProfile(let id):
                    GroupProfileView(
                        groupId: id,
                        groupRepository: Container.shared.groupRepository(),
                        onSeriesSelected: { seriesId in coordinator.searchCoordinator.push(.seriesDetail(id: seriesId)) }
                    )
                case .authorProfile(let id, let roleLabel):
                    AuthorProfileView(
                        authorId: id,
                        roleLabel: roleLabel,
                        authorRepository: Container.shared.authorRepository(),
                        onSeriesSelected: { seriesId in coordinator.searchCoordinator.push(.seriesDetail(id: seriesId)) }
                    )
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
                        GardenHeaderView { coordinator.profileCoordinator.popToRoot() }
                        ProfileMenuContentView(
                            currentUser: currentUser,
                            onLoginTapped: { coordinator.profileCoordinator.push(.login) },
                            onLogoutTapped: onLogout,
                            onRowTapped: { route in coordinator.profileCoordinator.push(route) }
                        )
                    }
                }
                .background(DSColor.backgroundPrimary)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: ProfileRoute.self) { route in
                    ProfileDestinationBuilder.destination(
                        for: route,
                        coordinator: coordinator.profileCoordinator,
                        context: ProfileDestinationContext(
                            currentUser: currentUser,
                            onAuthenticated: onAuthenticated,
                            onProfileUpdated: onProfileUpdated
                        ),
                        onReportTapped: { reportTarget = $0 }
                    )
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

internal struct ReportSheetTarget: Identifiable {
    let seriesId: String
    let chapterId: String?
    var id: String { "\(seriesId)-\(chapterId ?? "series")" }
}
