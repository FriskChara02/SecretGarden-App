//
//  ProfileDestinationBuilder.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import AuthFeature
import CoreArchitecture
import CoreModels
import HomeFeature
import SearchFeature
import SocialFeature
import Repositories
import FactoryKit
import SwiftUI
import DesignSystem

enum ProfileDestinationBuilder {

    @ViewBuilder
    static func destination(
        for route: ProfileRoute,
        coordinator: Coordinator<ProfileRoute>,
        currentUser: User?,
        onReportTapped: @escaping (ReportSheetTarget) -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> some View {
        switch route {
        case .personalInfo:
            ProfileDetailView(
                currentUser: currentUser,
                onHeaderTapped: { coordinator.popToRoot() },
                onEditTapped: { coordinator.push(.editProfile) }
            )
        case .editProfile:
            Text("Edit Profile (demo) — Step 12.6").dsFont(.title1)
        case .favorites, .history, .category, .yuriList, .uploadRegistration, .rules:
            placeholderDestination(for: route)
        case .followedGroups, .discoverGroups, .groupProfile, .authorProfile:
            socialDestination(for: route, coordinator: coordinator)
        case .advancedSearch:
            AdvancedSearchView(
                repository: Container.shared.searchRepository(),
                onSeriesSelected: { id in coordinator.push(.seriesDetail(id: id)) },
                onHeaderTapped: { coordinator.popToRoot() }
            )
        case .seriesDetail, .chapterReader:
            readingFlowDestination(for: route, coordinator: coordinator, onReportTapped: onReportTapped)
        case .login:
            AuthFlowView(onAuthenticated: {
                coordinator.popToRoot()
                onAuthenticated()
            })
        }
    }

    // MARK: - Placeholder screens

    @ViewBuilder
    private static func placeholderDestination(for route: ProfileRoute) -> some View {
        switch route {
        case .personalInfo:
            Text("Personal Info (demo) — Step 12.4").dsFont(.title1)
        case .favorites:
            Text("Favorites (demo) — Phase 11").dsFont(.title1)
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
            EmptyView() // unreachable — caller only forwards these 7 cases here
        }
    }

    // MARK: - Group/Author (SocialFeature)

    @ViewBuilder
    private static func socialDestination(for route: ProfileRoute, coordinator: Coordinator<ProfileRoute>) -> some View {
        switch route {
        case .followedGroups:
            FollowedGroupsView(
                groupRepository: Container.shared.groupRepository(),
                onGroupSelected: { id in coordinator.push(.groupProfile(id: id)) },
                onDiscoverTapped: { coordinator.push(.discoverGroups) }
            )
        case .discoverGroups:
            DiscoverGroupsView(
                groupRepository: Container.shared.groupRepository(),
                onGroupSelected: { id in coordinator.push(.groupProfile(id: id)) }
            )
        case .groupProfile(let id):
            GroupProfileView(
                groupId: id,
                groupRepository: Container.shared.groupRepository(),
                onSeriesSelected: { seriesId in coordinator.push(.seriesDetail(id: seriesId)) }
            )
        case .authorProfile(let id, let roleLabel):
            AuthorProfileView(
                authorId: id,
                roleLabel: roleLabel,
                authorRepository: Container.shared.authorRepository(),
                onSeriesSelected: { seriesId in coordinator.push(.seriesDetail(id: seriesId)) }
            )
        default:
            EmptyView() // unreachable — caller only forwards these 4 cases here
        }
    }

    // MARK: - Series Detail / Chapter Reader (HomeFeature)

    @ViewBuilder
    private static func readingFlowDestination(
        for route: ProfileRoute,
        coordinator: Coordinator<ProfileRoute>,
        onReportTapped: @escaping (ReportSheetTarget) -> Void
    ) -> some View {
        switch route {
        case .seriesDetail(let id):
            SeriesDetailView(
                seriesId: id,
                seriesRepository: Container.shared.seriesRepository(),
                commentRepository: Container.shared.commentRepository(),
                onHeaderTapped: { coordinator.popToRoot() },
                onStartReading: { chapterId in coordinator.push(.chapterReader(seriesId: id, chapterId: chapterId)) },
                onContinueReading: { chapterId in coordinator.push(.chapterReader(seriesId: id, chapterId: chapterId)) },
                onReportTapped: { onReportTapped(ReportSheetTarget(seriesId: id, chapterId: nil)) },
                onAuthorTapped: { authorId in coordinator.push(.authorProfile(id: authorId, roleLabel: "Tác giả")) },
                onArtistTapped: { artistId in coordinator.push(.authorProfile(id: artistId, roleLabel: "Họa sĩ")) },
                onGroupTapped: { groupId in coordinator.push(.groupProfile(id: groupId)) }
            )
        case .chapterReader(let seriesId, let chapterId):
            ChapterReaderView(
                seriesId: seriesId,
                initialChapterId: chapterId,
                seriesRepository: Container.shared.seriesRepository(),
                commentRepository: Container.shared.commentRepository(),
                onHomeTapped: { coordinator.popToRoot() },
                onSeriesSelected: { newId in coordinator.push(.seriesDetail(id: newId)) },
                onBackToDetailTapped: { coordinator.pop() },
                onReportTapped: { onReportTapped(ReportSheetTarget(seriesId: seriesId, chapterId: chapterId)) }
            )
        default:
            EmptyView() // unreachable — caller only forwards these 2 cases here
        }
    }
}
