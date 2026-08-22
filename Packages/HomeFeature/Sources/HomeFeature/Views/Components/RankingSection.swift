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

import CoreModels
import CoreArchitecture
import DesignSystem
import SwiftUI

struct RankingSection: View {
    let state: LoadableState<[Series]>
    let selectedRange: RankingRange
    let onRangeSelected: (RankingRange) -> Void
    let onSeriesSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            header

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

    // MARK: - Header (title + segmented range filter)

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Xếp hạng")
                .dsFont(.title3)
                .foregroundStyle(DSColor.textPrimary)
                .padding(.horizontal, DSSpacing.md)

            Picker("Khoảng thời gian", selection: rangeBinding) {
                Text("Ngày").tag(RankingRange.day)
                Text("Tuần").tag(RankingRange.week)
                Text("Tháng").tag(RankingRange.month)
                Text("Tất cả").tag(RankingRange.all)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DSSpacing.md)
        }
    }

    /// "Fake" binding - reads from `selectedRange` (the source of truth in the ViewModel), but when the user
    /// changes the value, it does NOT automatically update a local variable; instead, it emits an `onRangeSelected` intent.
    /// The Picker requires a real Binding to function; this is a valid way to achieve "read-only + emit intent"
    /// behavior without introducing an extra `@State` that duplicates the ViewModel's state.
    private var rangeBinding: Binding<RankingRange> {
        Binding(get: { selectedRange }, set: { onRangeSelected($0) })
    }

    // MARK: - Content states

    private func content(_ series: [Series]) -> some View {
        VStack(spacing: DSSpacing.xs) {
            ForEach(Array(series.prefix(10).enumerated()), id: \.element.id) { index, item in
                RankingRow(rank: index + 1, series: item) {
                    onSeriesSelected(item.id)
                }
                .padding(.horizontal, DSSpacing.md)

                if index < series.prefix(10).count - 1 {
                    Divider().padding(.leading, DSSpacing.md + 28 + DSSpacing.sm)
                }
            }
        }
    }

    private var loadingSkeleton: some View {
        VStack(spacing: DSSpacing.sm) {
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: DSSpacing.sm) {
                    Circle().fill(DSColor.backgroundSecondary).frame(width: 28, height: 28)
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(DSColor.backgroundSecondary)
                        .frame(width: 52, height: 78)
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .fill(DSColor.backgroundSecondary).frame(height: 14)
                        RoundedRectangle(cornerRadius: DSRadius.sm)
                            .fill(DSColor.backgroundSecondary).frame(width: 100, height: 10)
                    }
                    Spacer()
                }
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
                onRangeSelected(selectedRange) // Re-fetch the current range without changing the filter
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
    }
}
