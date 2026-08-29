//
//  SearchView.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 29/8/26.
//

// Search Screen — inline 100%: displays history when the search field is empty,
// displays search results (grid/list) when there is content — does NOT navigate to a separate screen.
// The searchResults(query:) route is reserved for the Advanced Filter flow, is not used here.

import CoreArchitecture
import CoreModels
import Repositories
import DesignSystem
import SwiftUI

public struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var layout: SeriesCardLayout = .grid

    private let onSeriesSelected: (String) -> Void
    private let onHeaderTapped: () -> Void

    public init(
        repository: SearchRepositoryProtocol,
        onSeriesSelected: @escaping (String) -> Void,
        onHeaderTapped: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: SearchViewModel(repository: repository))
        self.onSeriesSelected = onSeriesSelected
        self.onHeaderTapped = onHeaderTapped
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)

                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    searchBarRow

                    if isShowingHistory {
                        historySection
                    } else {
                        resultsSection
                    }
                }
                .padding(DSSpacing.lg)
            }
        }
        .background(DSColor.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.onAppear() }
    }

    /// true if the search field is empty — determines whether to show history or results.
    private var isShowingHistory: Bool {
        viewModel.queryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Search bar + layout toggle

    private var searchBarRow: some View {
        HStack(spacing: DSSpacing.sm) {
            DSSearchBar(text: $viewModel.queryText, onSubmit: { viewModel.submitSearch() })
                .onChange(of: viewModel.queryText) { _, newValue in
                    viewModel.handleQueryChange(newValue)
                }

            if !isShowingHistory {
                layoutToggle
            }
        }
    }

    /// Two icon buttons to toggle between Grid and List views - the selected icon is highlighted in pink, following the established pattern (the active icon has a dark pink background).
    private var layoutToggle: some View {
        HStack(spacing: DSSpacing.xs) {
            toggleButton(icon: "square.grid.2x2", isActive: layout == .grid) { layout = .grid }
            toggleButton(icon: "list.bullet", isActive: layout == .list) { layout = .list }
        }
    }

    private func toggleButton(icon: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isActive ? .white : DSColor.brandPrimary)
                .frame(width: 36, height: 36)
                .background(Circle().fill(isActive ? DSColor.brandPrimary : DSColor.backgroundSecondary))
        }
    }

    // MARK: - History section

    private var historySection: some View {
        LoadableContentView(
            state: viewModel.historyState,
            emptyTitle: "Chưa có lịch sử tìm kiếm",
            isEmpty: { $0.isEmpty }
        ) { items in
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack {
                    Spacer()
                    Button("Xoá lịch sử", role: .destructive) { viewModel.clearAllHistory() }
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.statusError)
                }

                ForEach(items) { item in
                    historyRow(item)
                }
            }
        }
    }

    private func historyRow(_ item: SearchHistoryItem) -> some View {
        Button {
            viewModel.submitSearch(query: item.query)
        } label: {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "clock")
                    .foregroundStyle(DSColor.textSecondary)
                Text(item.query)
                    .dsFont(.body)
                    .foregroundStyle(DSColor.textPrimary)
                Spacer()
                Button {
                    viewModel.removeHistoryItem(id: item.id)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(DSColor.textSecondary.opacity(0.6))
                }
            }
            .padding(.vertical, DSSpacing.xs)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Results section

    private var resultsSection: some View {
        LoadableContentView(
            state: viewModel.resultsState,
            emptyTitle: "Không tìm thấy kết quả",
            emptyMessage: "Thử tìm với từ khoá khác",
            isEmpty: { $0.isEmpty }
        ) { series in
            switch layout {
            case .grid:
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
                    ForEach(series) { item in
                        SeriesCardView(
                            data: SearchSeriesCardMapper.map(item),
                            layout: .grid,
                            onTap: { onSeriesSelected(item.id) }
                        )
                    }
                }
            case .list:
                LazyVStack(spacing: DSSpacing.md) {
                    ForEach(series) { item in
                        SeriesCardView(
                            data: SearchSeriesCardMapper.map(item),
                            layout: .list,
                            onTap: { onSeriesSelected(item.id) }
                        )
                    }
                }
            }
        }
    }
}
