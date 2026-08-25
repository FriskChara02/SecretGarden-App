//
//  LatestUpdatesSection.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// "Latest Updates" section — the MAIN section of the Home page,
// distinct from "Continue Reading" (a secondary section): errors here MUST be clearly displayed
// (not silently hidden), as this is core content users expect to see when opening the Home page.
//
// Filtering by Manga/Novel is handled CLIENT-SIDE — because
// the System Design only defines `GET /home/latest-updates?page=`, without
// a `type=` query parameter. Do not arbitrarily modify the API contract.

import CoreModels
import DesignSystem
import SwiftUI
import CoreArchitecture

struct LatestUpdatesSection: View {
    let state: LoadableState<[Series]>
    let contentType: HomeContentType
    let onRetry: () -> Void
    let onSeriesSelected: (String) -> Void

    @State private var layout: SeriesCardLayout = .grid

    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            header

            switch state {
            case .idle, .loading:
                loadingSkeleton

            case .loaded(let series):
                let filtered = filter(series)
                if filtered.isEmpty {
                    emptyState
                } else {
                    cardsContainer(filtered)
                }

            case .failed(let error):
                errorState(error)
            }
        }
    }

    // MARK: - Header (pink diamond title + circular Grid/List toggle icons)

    private var header: some View {
        HStack {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.circle")
                    .font(.caption2)
                Text("Mới Cập Nhật")
                    .dsFont(.title3)
                Image(systemName: "diamond.circle")
                    .font(.caption2)
            }
            .foregroundStyle(DSColor.brandPrimary)

            Spacer()

            HStack(spacing: DSSpacing.sm) {
                toggleIcon(systemName: "square.grid.2x2.fill", isActive: layout == .grid) {
                    layout = .grid
                }
                toggleIcon(systemName: "list.bullet", isActive: layout == .list) {
                    layout = .list
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    /// Round "pill toggle" icon button: solid pink background + white icon when active,
    /// white background + pink border/icon when inactive.
    private func toggleIcon(systemName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isActive ? .white : DSColor.brandPrimary)
                .frame(width: 32, height: 32)
                .background(isActive ? DSColor.brandPrimary : DSColor.backgroundPrimary)
                .clipShape(Circle())
                .overlay {
                    Circle().strokeBorder(DSColor.brandPrimary, lineWidth: isActive ? 0 : 1.5)
                }
        }
        .accessibilityLabel(systemName == "square.grid.2x2.fill" ? "Xem dạng lưới" : "Xem dạng danh sách")
    }

    // MARK: - Filtering (client-side)

    private func filter(_ series: [Series]) -> [Series] {
        series.filter { $0.type == contentType.seriesType }
    }

    // MARK: - Content states

    private func cardsContainer(_ series: [Series]) -> some View {
        Group {
            switch layout {
            case .grid:
                LazyVGrid(columns: gridColumns, spacing: DSSpacing.md) {
                    ForEach(series) { item in
                        SeriesCardView(
                            data: SeriesCardMapper.map(item),
                            layout: .grid,
                            onTap: { onSeriesSelected(item.id) }
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, DSSpacing.md)

            case .list:
                LazyVStack(spacing: DSSpacing.md) {
                    ForEach(series) { item in
                        SeriesCardView(
                            data: SeriesCardMapper.map(item),
                            layout: .list,
                            onTap: { onSeriesSelected(item.id) }
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    private var loadingSkeleton: some View {
        LazyVGrid(columns: gridColumns, spacing: DSSpacing.md) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(DSColor.backgroundSecondary)
                    .aspectRatio(2 / 3, contentMode: .fit)
                    .overlay { ProgressView() }
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "books.vertical")
                .font(.system(size: 32))
                .foregroundStyle(DSColor.textSecondary.opacity(0.5))
            Text(contentType == .manga ? "Chưa có Manga mới cập nhật" : "Chưa có Novel mới cập nhật")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
    }

    private func errorState(_ error: AppError) -> some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28))
                .foregroundStyle(DSColor.statusError)
            Text("Không tải được truyện mới cập nhật")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textPrimary)
            DSButton("Thử lại", variant: .outline) {
                onRetry()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.lg)
    }
}
