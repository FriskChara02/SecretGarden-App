//
//  AdvancedSearchView.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 30/8/26.
//

// Advanced Search screen — pushed from the Side Menu/Drawer, NOT part of the Search tab.

import CoreArchitecture
import CoreModels
import Repositories
import DesignSystem
import SwiftUI

public struct AdvancedSearchView: View {
    @StateObject private var viewModel: AdvancedSearchViewModel
    @State private var layout: SeriesCardLayout = .grid

    private let onSeriesSelected: (String) -> Void
    private let onHeaderTapped: () -> Void

    public init(
        repository: SearchRepositoryProtocol,
        onSeriesSelected: @escaping (String) -> Void,
        onHeaderTapped: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AdvancedSearchViewModel(repository: repository))
        self.onSeriesSelected = onSeriesSelected
        self.onHeaderTapped = onHeaderTapped
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)

                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    titleRow
                    filterBarRow

                    if let results = viewModel.resultsState.value, !results.isEmpty {
                        layoutToggleRow
                    }

                    resultsSection
                }
                .padding(DSSpacing.lg)
            }
        }
        .background(DSColor.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.isFilterSheetPresented) {
            Text("AdvancedFilterView (Step 9.6 sẽ thay thế)")
                .dsFont(.title1)
                .padding()
        }
    }

    // MARK: - Title

    private var titleRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Spacer()
            Image(systemName: "diamond.circle").font(.system(size: 10)).foregroundStyle(DSColor.brandPrimaryLight)
            Text("Tìm kiếm nâng cao")
                .dsFont(.title2)
                .fontWeight(.bold)
                .foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.circle").font(.system(size: 10)).foregroundStyle(DSColor.brandPrimaryLight)
            Spacer()
        }
    }

    // MARK: - Filter bar ("Filter" button + "!" badge when active)

    private var filterBarRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Button(action: viewModel.openFilterSheet) {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "line.3.horizontal.decrease")
                    Text("Bộ lọc")
                    if viewModel.hasActiveFilter {
                        filterActiveBadge
                    }
                }
                .dsFont(.headline)
                .foregroundStyle(DSColor.brandPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
            }
            .overlay(
                Capsule().stroke(DSColor.brandPrimary, lineWidth: 1.5)
            )
        }
    }

    private var filterActiveBadge: some View {
        Circle()
            .fill(DSColor.statusError)
            .frame(width: 18, height: 18)
            .overlay {
                Text("!").dsFont(.caption).fontWeight(.bold).foregroundStyle(.white)
            }
    }

    // MARK: - Layout toggle (only appears when results are available to view)

    private var layoutToggleRow: some View {
        HStack {
            Spacer()
            HStack(spacing: DSSpacing.xs) {
                toggleButton(icon: "square.grid.2x2", isActive: layout == .grid) { layout = .grid }
                toggleButton(icon: "list.bullet", isActive: layout == .list) { layout = .list }
            }
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

    // MARK: - Results

    private var resultsSection: some View {
        LoadableContentView(
            state: viewModel.resultsState,
            emptyIcon: "magnifyingglass",
            emptyTitle: "Chọn bộ lọc và nhấn tìm kiếm để bắt đầu",
            emptyTitleFont: .subheadline,
            emptyTitleColor: DSColor.textSecondary,
            emptyTopPadding: 60,
            isEmpty: { $0.isEmpty },
            retryAction: { viewModel.search() }
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
