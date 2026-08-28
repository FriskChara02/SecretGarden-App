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

    public init(
        repository: HomeRepositoryProtocol,
        onSeriesSelected: @escaping (String) -> Void,
        onHeaderTapped: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
        self.onSeriesSelected = onSeriesSelected
        self.onHeaderTapped = onHeaderTapped
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

                    RankingSection(
                        state: viewModel.rankingState,
                        selectedRange: viewModel.selectedRankingRange,
                        selectedSortBy: viewModel.selectedRankingSortBy,
                        onFilterChanged: { range, sortBy in viewModel.reloadRanking(range: range, sortBy: sortBy) },
                        onSeriesSelected: { seriesId in onSeriesSelected(seriesId) }
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
                        GardenFooterLink(title: "Chính sách bảo mật", action: {}),
                        GardenFooterLink(title: "Quy định", action: {}),
                        GardenFooterLink(title: "Điều khoản", action: {})
                    ],
                    socialLinks: [
                        GardenFooterLink(title: "Discord", action: {}),
                        GardenFooterLink(title: "Facebook", action: {})
                    ],
                    onPolicyTapped: {}   // TODO: connect Rules/Policy route
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
        HomeView(repository: HomeRepositoryMock(), onSeriesSelected: { _ in }, onHeaderTapped: {})
    }
}
