//
//  DSRankingSection.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 12/9/26.
//

// Dumb component shared across ALL leaderboards in the app (system-wide Home, group-scoped).

import SwiftUI

public struct DSRankingSection: View {
    private let title: String
    private let items: [RankingItemData]
    private let isLoading: Bool
    private let errorMessage: String?
    private let selectedSortBy: DSRankingSortBy
    private let selectedRange: DSRankingRange
    private let onFilterChanged: (DSRankingRange, DSRankingSortBy) -> Void
    private let onRetry: () -> Void
    private let onItemSelected: (String) -> Void

    public init(
        title: String,
        items: [RankingItemData],
        isLoading: Bool,
        errorMessage: String?,
        selectedSortBy: DSRankingSortBy,
        selectedRange: DSRankingRange,
        onFilterChanged: @escaping (DSRankingRange, DSRankingSortBy) -> Void,
        onRetry: @escaping () -> Void,
        onItemSelected: @escaping (String) -> Void
    ) {
        self.title = title
        self.items = items
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.selectedSortBy = selectedSortBy
        self.selectedRange = selectedRange
        self.onFilterChanged = onFilterChanged
        self.onRetry = onRetry
        self.onItemSelected = onItemSelected
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionTitle
            filterTabs

            if isLoading {
                loadingSkeleton
            } else if errorMessage != nil {
                errorState
            } else if items.isEmpty {
                emptyState
            } else {
                content
            }
        }
    }

    private var sectionTitle: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "diamond.inset.filled").font(.caption2)
            Text(title).dsFont(.title3)
            Image(systemName: "diamond.inset.filled").font(.caption2)
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

    private func rangeButton(_ range: DSRankingRange, _ title: String) -> some View {
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

    private var content: some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(Array(items.prefix(10).enumerated()), id: \.element.id) { index, item in
                DSRankingRow(rank: index + 1, item: item, sortBy: selectedSortBy) {
                    onItemSelected(item.id)
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
            DSButton("Thử lại", variant: .outline) { onRetry() }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
    }
}
