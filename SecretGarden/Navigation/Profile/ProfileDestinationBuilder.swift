//
//  ProfileDestinationBuilder.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import AuthFeature
import CoreArchitecture
import CoreModels
import DesignSystem
import FactoryKit
import HomeFeature
import Repositories
import SearchFeature
import SocialFeature
import SwiftUI

struct ProfileDestinationContext {
    let currentUser: User?
    let onAuthenticated: () -> Void
    let onProfileUpdated: (User) -> Void
    let onSuccessMessage: (String) -> Void
}

enum ProfileDestinationBuilder {

    @ViewBuilder
    static func destination(
        for route: ProfileRoute,
        coordinator: Coordinator<ProfileRoute>,
        context: ProfileDestinationContext,
        onReportTapped: @escaping (ReportSheetTarget) -> Void
    ) -> some View {
        switch route {
        case .personalInfo:
            ProfileDetailView(
                currentUser: context.currentUser,
                onHeaderTapped: { coordinator.popToRoot() },
                onUserUpdated: context.onProfileUpdated,
                onSuccessMessage: context.onSuccessMessage
            )
        case .editProfile:
            if let currentUser = context.currentUser {
                EditProfileView(
                    currentUser: currentUser,
                    userRepository: Container.shared.userRepository(),
                    onSaved: { updated in
                        context.onProfileUpdated(updated)
                        coordinator.pop()
                    },
                    onCancel: { coordinator.pop() }
                )
            } else {
                EmptyView()
            }
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
            AuthFlowView(
                onAuthenticated: {
                    coordinator.popToRoot()
                    context.onAuthenticated()
                },
                embedsOwnNavigationStack: false
            )
            .toolbar(.hidden, for: .navigationBar)
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
            EmptyView()
        }
    }

    // MARK: - Group/Author (SocialFeature)

    @ViewBuilder
    private static func socialDestination(
        for route: ProfileRoute,
        coordinator: Coordinator<ProfileRoute>
    ) -> some View {
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
            EmptyView()
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
            EmptyView()
        }
    }
}
