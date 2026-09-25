//
//  HomeView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Main view of the Home tab – Banner + Manga/Novel toggle.
// `onSeriesSelected` is passed in from outside (App target) rather than being called directly by HomeView.
// Direct Coordinator usage — adhering to the "View emits intent, Coordinator handles navigation" pattern.

import CoreModels
import DesignSystem
import Repositories
import SwiftUI

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedContentType: HomeContentType = .manga

    private let onSeriesSelected: (String) -> Void
    private let onHeaderTapped: () -> Void
    private let onPolicyTapped: (PolicyKind) -> Void

    public init(
        repository: HomeRepositoryProtocol,
        onSeriesSelected: @escaping (String) -> Void,
        onHeaderTapped: @escaping () -> Void,
        onPolicyTapped: @escaping (PolicyKind) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
        self.onSeriesSelected = onSeriesSelected
        self.onHeaderTapped = onHeaderTapped
        self.onPolicyTapped = onPolicyTapped
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)
                GardenBannerView()
                ContentTypeToggle(selection: $selectedContentType)
                    .onChange(of: selectedContentType) { _, newValue in
                        viewModel.refreshRandomYuri(type: newValue.seriesType)
                    }

                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    RandomYuriSection(
                        state: viewModel.randomYuriState,
                        onRefresh: { viewModel.refreshRandomYuri(type: selectedContentType.seriesType) },
                        onSeriesSelected: { seriesId in onSeriesSelected(seriesId) }
                    )

                    ContinueReadingSection(
                        state: viewModel.continueReadingState,
                        onItemTapped: { seriesId in onSeriesSelected(seriesId) }
                    )

                    LatestUpdatesSection(
                        state: viewModel.latestUpdatesState,
                        contentType: selectedContentType,
                        onRetry: { viewModel.loadHome() },
                        onSeriesSelected: { seriesId in onSeriesSelected(seriesId) }
                    )

                    DSRankingSection(
                        title: "Xếp Hạng",
                        items: viewModel.rankingState.value?.map(RankingItemMapper.map) ?? [],
                        isLoading: viewModel.rankingState.isLoading,
                        errorMessage: viewModel.rankingState.error?.errorDescription,
                        selectedSortBy: RankingItemMapper.map(viewModel.selectedRankingSortBy),
                        selectedRange: RankingItemMapper.map(viewModel.selectedRankingRange),
                        onFilterChanged: { dsRange, dsSortBy in
                            viewModel.reloadRanking(
                                range: RankingItemMapper.map(dsRange),
                                sortBy: RankingItemMapper.map(dsSortBy)
                            )
                        },
                        onRetry: { viewModel.reloadRanking(range: viewModel.selectedRankingRange, sortBy: viewModel.selectedRankingSortBy) },
                        onItemSelected: { seriesId in onSeriesSelected(seriesId) }
                    )

                    RandomCommentsSection(
                        state: viewModel.randomCommentsState,
                        onRefresh: { viewModel.refreshRandomComments() },
                        onSeriesSelected: { seriesId in onSeriesSelected(seriesId) }
                    )
                }
                .padding(.top, DSSpacing.lg)

                GardenFooterView(
                    policyLinks: [
                        GardenFooterLink(title: "Chính sách bảo mật", action: { onPolicyTapped(.privacyPolicy) }),
                        GardenFooterLink(title: "Quy định", action: { onPolicyTapped(.communityRules) }),
                        GardenFooterLink(title: "Điều khoản", action: { onPolicyTapped(.termsOfService) })
                    ],
                    socialLinks: [
                        GardenFooterLink(title: "Discord", action: {}),
                        GardenFooterLink(title: "Facebook", action: {})
                    ],
                    onPolicyTapped: { onPolicyTapped(.communityRules) }
                )
                .padding(.top, DSSpacing.xl)
            }
        }
        .background(DSColor.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.loadHome()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(
            repository: HomeRepositoryMock(),
            onSeriesSelected: { _ in },
            onHeaderTapped: {},
            onPolicyTapped: { _ in }
        )
    }
}
