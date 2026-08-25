//
//  RankingSection.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// "Rankings" section — filters: Day/Week/Month/All.
// This is a PRIMARY section (similar to Latest Updates) -> display errors clearly; do not fail silently.
//
// IMPORTANT: Changing the filter must call `onRangeSelected` (intent) — do NOT arbitrarily set local state
// that falls out of sync with `viewModel.selectedRankingRange` (single source of truth).

// "Rankings" — 2-level filter: sortBy (Views/Favorites) × range (Day/Week/Month/All-time).
// MAIN Section — display errors clearly, do not hide them silently.

import CoreModels
import CoreArchitecture
import DesignSystem
import SwiftUI

struct RankingSection: View {
    let state: LoadableState<[Series]>
    let selectedRange: RankingRange
    let selectedSortBy: RankingSortBy
    let onFilterChanged: (RankingRange, RankingSortBy) -> Void
    let onSeriesSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionTitle
            filterTabs

            switch state {
            case .idle, .loading:
                loadingSkeleton
            case .loaded(let series) where series.isEmpty:
                emptyState
            case .loaded(let series):
                content(series)
            case .failed:
                errorState
            }
        }
    }

    private var sectionTitle: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "diamond.circle").font(.caption2)
            Text("Xếp Hạng").dsFont(.title3)
            Image(systemName: "diamond.circle").font(.caption2)
        }
        .foregroundStyle(DSColor.brandPrimary)
        .frame(maxWidth: .infinity)
    }

    // MARK: - 2-tier filter container (pink box)

    private var filterTabs: some View {
        VStack(spacing: 0) {
            sortByTabRow
            Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
            rangeTabRow
        }
        .background(DSColor.brandPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.lg).strokeBorder(DSColor.brandPrimaryLight, lineWidth: 2)
        }
        .padding(.horizontal, DSSpacing.md)
    }

    private var sortByTabRow: some View {
        HStack(spacing: 0) {
            tabButton("Lượt xem", isSelected: selectedSortBy == .views) {
                onFilterChanged(selectedRange, .views)
            }
            tabDivider
            tabButton("Yêu thích", isSelected: selectedSortBy == .favorites) {
                onFilterChanged(selectedRange, .favorites)
            }
        }
        .padding(.vertical, DSSpacing.sm)
    }

    private var rangeTabRow: some View {
        HStack(spacing: 0) {
            rangeButton(.day, "Ngày")
            tabDivider
            rangeButton(.week, "Tuần")
            tabDivider
            rangeButton(.month, "Tháng")
            tabDivider
            rangeButton(.all, "Tất cả")
        }
        .padding(.vertical, DSSpacing.sm)
    }

    private var tabDivider: some View {
        Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1, height: 14)
    }

    private func rangeButton(_ range: RankingRange, _ title: String) -> some View {
        tabButton(title, isSelected: selectedRange == range) {
            onFilterChanged(range, selectedSortBy)
        }
    }

    private func tabButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xxs) {
                Text(title)
                    .dsFont(.callout)
                    .fontWeight(isSelected ? .bold : .regular)
                    .foregroundStyle(.white)
                Rectangle()
                    .fill(isSelected ? Color.white : Color.clear)
                    .frame(width: 32, height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content states

    private func content(_ series: [Series]) -> some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(Array(series.prefix(10).enumerated()), id: \.element.id) { index, item in
                RankingRow(rank: index + 1, series: item, sortBy: selectedSortBy) {
                    onSeriesSelected(item.id)
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    private var loadingSkeleton: some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(DSColor.backgroundSecondary)
                    .frame(height: 90)
                    .overlay { ProgressView() }
                    .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundStyle(DSColor.textSecondary.opacity(0.5))
            Text("Chưa có dữ liệu xếp hạng cho khoảng thời gian này")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
    }

    private var errorState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28))
                .foregroundStyle(DSColor.statusError)
            Text("Không tải được bảng xếp hạng")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textPrimary)
            DSButton("Thử lại", variant: .outline) {
                onFilterChanged(selectedRange, selectedSortBy)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
    }
}
