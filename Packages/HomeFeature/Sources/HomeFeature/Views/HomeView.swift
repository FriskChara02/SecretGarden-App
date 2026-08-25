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

    private let banners: [BannerItem] = [
        BannerItem(
            id: "banner_1",
            title: "Sự kiện mùa hè",
            subtitle: "Khám phá truyện Yuri hot nhất tháng này",
            gradientColors: [DSColor.brandPrimary, DSColor.brandSecondary]
        ),
        BannerItem(
            id: "banner_2",
            title: "Nhóm dịch nổi bật",
            subtitle: "Cùng khám phá các nhóm dịch tận tâm",
            gradientColors: [DSColor.brandSecondary, DSColor.brandPrimary]
        )
    ]

    public init(repository: HomeRepositoryProtocol, onSeriesSelected: @escaping (String) -> Void) {
        self._viewModel = StateObject(wrappedValue: HomeViewModel(repository: repository))
        self.onSeriesSelected = onSeriesSelected
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                BannerCarouselView(banners: banners)

                ContentTypeToggle(selection: $selectedContentType)
                    .onChange(of: selectedContentType) { _, newValue in
                        viewModel.refreshRandomYuri(type: newValue.seriesType)
                    }

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

                RandomCommentsSection(state: viewModel.randomCommentsState)
            }
            .padding(.vertical, DSSpacing.lg)
        }
        .background(DSColor.backgroundPrimary)
        .navigationTitle("Trang chủ")
        .task {
            viewModel.loadHome()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(repository: HomeRepositoryMock(), onSeriesSelected: { _ in })
    }
}
