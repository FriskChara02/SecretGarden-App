//
//  SeriesCardView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 13/8/26.
//

// Card displaying a single story — shared across Home, Search, Category and Favorites.
// This component has NO knowledge of the `Series` struct (CoreModels) — it only accepts
// raw `SeriesCardData` (String/URL/Int), adhering to the Design System principle
// of absolute independence. Feature code maps `Series` to `SeriesCardData` when calling it.

import SwiftUI

public enum SeriesCardLayout {
    case grid   // 2 columns, cover image takes up most of the space — for Home/Category
    case list   // Single row, small image on the left — for list-style search results
}

public struct SeriesCardData: Identifiable, Equatable {
    public let id: String
    public let coverURL: URL?
    public let title: String
    public let subtitle: String        // author or translation team
    public let tag: String?            // e.g., "Doujins", main genre
    public let metaInfo: String        // e.g. "Chapter 18 · 3 months ago"
    public let isCompleted: Bool

    public init(
        id: String,
        coverURL: URL?,
        title: String,
        subtitle: String,
        tag: String? = nil,
        metaInfo: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.coverURL = coverURL
        self.title = title
        self.subtitle = subtitle
        self.tag = tag
        self.metaInfo = metaInfo
        self.isCompleted = isCompleted
    }
}

public struct SeriesCardView: View {
    private let data: SeriesCardData
    private let layout: SeriesCardLayout

    public init(data: SeriesCardData, layout: SeriesCardLayout = .grid) {
        self.data = data
        self.layout = layout
    }

    public var body: some View {
        switch layout {
        case .grid: gridBody
        case .list: listBody
        }
    }

    // MARK: - Grid layout

    private var gridBody: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            coverImage
                .aspectRatio(2 / 3, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                .overlay(alignment: .topLeading) {
                    if let tag = data.tag {
                        DSTag(tag)
                            .padding(DSSpacing.xs)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if data.isCompleted {
                        DSTag("Hoàn thành", color: DSColor.statusSuccess)
                            .padding(DSSpacing.xs)
                    }
                }

            Text(data.title)
                .dsFont(DSFontToken.title3)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(data.subtitle)
                .dsFont(DSFontToken.subheadline)
                .foregroundStyle(DSColor.textSecondary)
                .lineLimit(1)

            Text(data.metaInfo)
                .dsFont(DSFontToken.caption)
                .foregroundStyle(DSColor.textSecondary)
                .lineLimit(1)
        }
    }

    // MARK: - List layout

    private var listBody: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            coverImage
                .aspectRatio(2 / 3, contentMode: .fill)
                .frame(width: 72, height: 108)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                if let tag = data.tag {
                    DSTag(tag)
                }
                Text(data.title)
                    .dsFont(DSFontToken.title3)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(2)
                Text(data.subtitle)
                    .dsFont(DSFontToken.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
                Spacer(minLength: DSSpacing.xxs)
                Text(data.metaInfo)
                    .dsFont(DSFontToken.caption)
                    .foregroundStyle(DSColor.textSecondary)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Shared cover image

    @ViewBuilder
    private var coverImage: some View {
        AsyncImage(url: data.coverURL) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(DSColor.backgroundSecondary)
                    .overlay { ProgressView().tint(DSColor.textSecondary) }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Rectangle()
                    .fill(DSColor.backgroundSecondary)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(DSColor.textSecondary.opacity(0.5))
                    }
            @unknown default:
                Rectangle().fill(DSColor.backgroundSecondary)
            }
        }
    }
}

#Preview("SeriesCardView - Grid") {
    let sample = SeriesCardData(
        id: "1",
        coverURL: nil,
        title: "Ngày Tôi Quyết Định Yêu Cậu Ấy Lần Nữa",
        subtitle: "Nhóm dịch: Yuri no Sono",
        tag: "Doujins",
        metaInfo: "Chương 18 · 3 tháng trước",
        isCompleted: true
    )
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
        SeriesCardView(data: sample, layout: .grid)
        SeriesCardView(data: sample, layout: .grid)
    }
    .padding()
}

#Preview("SeriesCardView - List") {
    let sample = SeriesCardData(
        id: "1",
        coverURL: nil,
        title: "Ngày Tôi Quyết Định Yêu Cậu Ấy Lần Nữa",
        subtitle: "Nhóm dịch: Yuri no Sono",
        tag: "Doujins",
        metaInfo: "Chương 18 · 3 tháng trước"
    )
    VStack(spacing: DSSpacing.md) {
        SeriesCardView(data: sample, layout: .list)
        SeriesCardView(data: sample, layout: .list)
    }
    .padding()
}
