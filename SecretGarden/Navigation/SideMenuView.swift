//
//  SideMenuView.swift
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

struct SideMenuView: View {
    @Bindable var coordinator: SideMenuCoordinator
    @State private var reportTarget: (seriesId: String, chapterId: String?)?

    private struct DrawerItem: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let action: () -> Void
    }

    var body: some View {
        NavigationStack(path: pathBinding) {
            List {
                ForEach(drawerItems) { item in
                    Button(action: item.action) {
                        Label(item.title, systemImage: item.systemImage)
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationDestination(for: SideMenuRoute.self) { route in
                destinationView(for: route)
            }
        }
        .sheet(item: Binding(
            get: { reportTarget.map { ReportSheetTarget(seriesId: $0.seriesId, chapterId: $0.chapterId) } },
            set: { if $0 == nil { reportTarget = nil } }
        )) { target in
            ReportView(
                seriesId: target.seriesId,
                chapterId: target.chapterId,
                seriesRepository: Container.shared.seriesRepository()
            )
        }
    }

    private var drawerItems: [DrawerItem] {
        [
            DrawerItem(title: "Trang cá nhân", systemImage: "person.crop.circle") {
                coordinator.selectPersonalProfile()
            },
            DrawerItem(title: "Yêu thích", systemImage: "heart") {
                coordinator.contentCoordinator.push(.favorites)
            },
            DrawerItem(title: "Nhóm theo dõi", systemImage: "person.3") {
                coordinator.contentCoordinator.push(.followedGroups)
            },
            DrawerItem(title: "Lịch sử", systemImage: "clock.arrow.circlepath") {
                coordinator.contentCoordinator.push(.history)
            },
            DrawerItem(title: "Danh mục", systemImage: "square.grid.2x2") {
                coordinator.contentCoordinator.push(.category)
            },
            DrawerItem(title: "Tìm kiếm nâng cao", systemImage: "slider.horizontal.3") {
                coordinator.contentCoordinator.push(.advancedSearch)
            },
            DrawerItem(title: "Yuri list", systemImage: "list.bullet.rectangle") {
                coordinator.contentCoordinator.push(.yuriList)
            },
            DrawerItem(title: "Đăng ký upload", systemImage: "square.and.arrow.up") {
                coordinator.contentCoordinator.push(.uploadRegistration)
            },
            DrawerItem(title: "Quy định", systemImage: "doc.text") {
                coordinator.contentCoordinator.push(.rules)
            }
        ]
    }

    @ViewBuilder
    private func destinationView(for route: SideMenuRoute) -> some View {
        switch route {
        case .favorites, .history, .category, .yuriList, .uploadRegistration, .rules:
            placeholderDestination(for: route)
        case .followedGroups:
            FollowedGroupsView(
                groupRepository: Container.shared.groupRepository(),
                onGroupSelected: { id in coordinator.contentCoordinator.push(.groupProfile(id: id)) },
                onDiscoverTapped: { coordinator.contentCoordinator.push(.discoverGroups) }
            )
        case .discoverGroups:
            DiscoverGroupsView(
                groupRepository: Container.shared.groupRepository(),
                onGroupSelected: { id in coordinator.contentCoordinator.push(.groupProfile(id: id)) }
            )
        case .advancedSearch:
            AdvancedSearchView(
                repository: Container.shared.searchRepository(),
                onSeriesSelected: { seriesId in coordinator.contentCoordinator.push(.seriesDetail(id: seriesId)) },
                onHeaderTapped: { coordinator.contentCoordinator.popToRoot() }
            )
        case .seriesDetail(let id):
            seriesDetailDestination(id: id)
        case .chapterReader(let seriesId, let chapterId):
            chapterReaderDestination(seriesId: seriesId, chapterId: chapterId)
        case .groupProfile(let id):
            GroupProfileView(
                groupId: id,
                groupRepository: Container.shared.groupRepository(),
                onSeriesSelected: { seriesId in coordinator.contentCoordinator.push(.seriesDetail(id: seriesId)) }
            )
        case .authorProfile(let id, let roleLabel):
            AuthorProfileView(
                authorId: id,
                roleLabel: roleLabel,
                authorRepository: Container.shared.authorRepository(),
                onSeriesSelected: { seriesId in coordinator.contentCoordinator.push(.seriesDetail(id: seriesId)) }
            )
        }
    }

    @ViewBuilder
    private func placeholderDestination(for route: SideMenuRoute) -> some View {
        switch route {
        case .favorites:
            Text("Favorites (demo) — Phase 11").dsFont(.title1)
        case .followedGroups:
            Text("Followed Groups (demo) — Phase 11").dsFont(.title1)
        case .history:
            Text("History (demo) — Phase 11").dsFont(.title1)
        case .category:
            Text("Category (demo) — Phase 9").dsFont(.title1)
        case .yuriList:
            Text("Yuri List (demo) — Phase 10").dsFont(.title1)
        case .uploadRegistration:
            Text("Upload Registration (demo)").dsFont(.title1)
        case .rules:
            Text("Rules/Policy (demo)").dsFont(.title1)
        default:
            EmptyView() // unreachable — the caller only forwards these 7 cases here
        }
    }

    private func seriesDetailDestination(id: String) -> some View {
        SeriesDetailView(
            seriesId: id,
            seriesRepository: Container.shared.seriesRepository(),
            commentRepository: Container.shared.commentRepository(),
            onHeaderTapped: { coordinator.contentCoordinator.popToRoot() },
            onStartReading: { chapterId in
                coordinator.contentCoordinator.push(.chapterReader(seriesId: id, chapterId: chapterId))
            },
            onContinueReading: { chapterId in
                coordinator.contentCoordinator.push(.chapterReader(seriesId: id, chapterId: chapterId))
            },
            onReportTapped: {
                reportTarget = (seriesId: id, chapterId: nil)
            },
            onAuthorTapped: { authorId in
                coordinator.contentCoordinator.push(.authorProfile(id: authorId, roleLabel: "Tác giả"))
            },
            onArtistTapped: { artistId in
                coordinator.contentCoordinator.push(.authorProfile(id: artistId, roleLabel: "Họa sĩ"))
            },
            onGroupTapped: { groupId in
                coordinator.contentCoordinator.push(.groupProfile(id: groupId))
            }
        )
    }

    private func chapterReaderDestination(seriesId: String, chapterId: String) -> some View {
        ChapterReaderView(
            seriesId: seriesId,
            initialChapterId: chapterId,
            seriesRepository: Container.shared.seriesRepository(),
            commentRepository: Container.shared.commentRepository(),
            onHomeTapped: { coordinator.contentCoordinator.popToRoot() },
            onSeriesSelected: { newSeriesId in
                coordinator.contentCoordinator.push(.seriesDetail(id: newSeriesId))
            },
            onBackToDetailTapped: { coordinator.contentCoordinator.pop() }
        )
    }

    private var pathBinding: Binding<NavigationPath> {
        Binding(
            get: { coordinator.contentCoordinator.path },
            set: { coordinator.contentCoordinator.path = $0 }
        )
    }
}
