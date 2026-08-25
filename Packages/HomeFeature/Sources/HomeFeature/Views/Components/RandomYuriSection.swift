//
//  RandomYuriSection.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 24/8/26.
//

// Section "Random Yuri"

import CoreModels
import CoreArchitecture
import DesignSystem
import SwiftUI

struct RandomYuriSection: View {
    let state: LoadableState<[Series]>
    let onRefresh: () -> Void
    let onSeriesSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            header

            switch state {
            case .idle, .loading:
                loadingSkeleton

            case .loaded(let series) where series.isEmpty:
                EmptyView()   // subsection — no need for noisy empty state

            case .loaded(let series):
                content(series)

            case .failed:
                EmptyView()   // supplementary section — silently suppress errors, similar to Continue Reading/Random Comments
            }
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.circle").font(.caption2)
                Text("Random Yuri").dsFont(.title3)
                Image(systemName: "diamond.circle").font(.caption2)
            }
            .foregroundStyle(DSColor.brandPrimary)

            Spacer()

            Button(action: onRefresh) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DSColor.brandPrimary)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5)
                    }
            }
            .accessibilityLabel("Làm mới Random Yuri")
        }
        .padding(.horizontal, DSSpacing.md)
    }

    private func content(_ series: [Series]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.md) {
                ForEach(series) { item in
                    RandomYuriCard(series: item)
                        .onTapGesture { onSeriesSelected(item.id) }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }

    private var loadingSkeleton: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.md) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .fill(DSColor.backgroundSecondary)
                        .frame(width: 170, height: 240)
                        .overlay { ProgressView() }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }
}

private struct RandomYuriCard: View {
    let series: Series

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            GeometryReader { proxy in
                AsyncImage(url: series.coverURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle().fill(DSColor.backgroundSecondary).overlay { ProgressView() }
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle().fill(DSColor.backgroundSecondary)
                            .overlay { Image(systemName: "photo").foregroundStyle(DSColor.textSecondary.opacity(0.5)) }
                    @unknown default:
                        Rectangle().fill(DSColor.backgroundSecondary)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))

            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "clock.arrow.circlepath").font(.caption2)
                Text(series.updatedAt.formatted(.relative(presentation: .named)))
            }
            .dsFont(DSFontToken.caption)
            .foregroundStyle(DSColor.textSecondary)

            Text(series.title)
                .dsFont(DSFontToken.headline)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)

            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "bookmark.fill").foregroundStyle(DSColor.bookmarkAccent)
                Text(series.latestChapterLabel ?? (series.status == .completed ? "Hoàn thành" : "Đang cập nhật"))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .dsFont(DSFontToken.footnote)
            .foregroundStyle(DSColor.textPrimary)
        }
        .padding(DSSpacing.sm)
        .frame(width: 170)
        .background(DSColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .strokeBorder(DSColor.brandPrimaryLight, lineWidth: 2)
        }
    }
}
