//
//  DSRankingRow.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 12/9/26.
//

import SwiftUI

public struct DSRankingRow: View {
    private let rank: Int
    private let item: RankingItemData
    private let sortBy: DSRankingSortBy
    private let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var isTopRank: Bool { rank == 1 }

    public init(rank: Int, item: RankingItemData, sortBy: DSRankingSortBy, onTap: @escaping () -> Void) {
        self.rank = rank
        self.item = item
        self.sortBy = sortBy
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            cardBody
                .padding(DSSpacing.sm)
                .frame(maxWidth: .infinity)
                .background(cardBackground)
                .overlay(alignment: .trailing) {
                    if isTopRank { backgroundArtwork }
                }
                .overlay {
                    starCluster(color: starColor, compact: !isTopRank)
                }
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        }
        .buttonStyle(.plain)
    }

    private var cardBody: some View {
        HStack(spacing: DSSpacing.sm) {
            rankBadge
            coverImage(width: 60, height: 84)
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(item.title)
                    .dsFont(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(titleColor)
                    .lineLimit(2)
                    .truncationMode(.tail)

                Rectangle().fill(dividerColor).frame(height: 1)

                metricRow
                    .lineLimit(1)
                    .truncationMode(.tail)

                if let author = item.authorName {
                    twoPartText(
                        token: .caption,
                        prefix: "Tác giả: ", prefixBold: false, prefixColor: labelColor,
                        value: author, valueBold: true, valueColor: authorColor
                    )
                    .lineLimit(1)
                    .truncationMode(.tail)
                }

                if let chapterLabel = item.chapterLabel {
                    if isTopRank {
                        chapterText(chapterLabel)
                    } else {
                        Text(chapterLabel)
                            .dsFont(.caption)
                            .foregroundStyle(labelColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var backgroundArtwork: some View {
        DSCachedAsyncImage(url: item.coverURL) { phase in
            if case .success(let image) = phase {
                image.resizable().aspectRatio(contentMode: .fill)
                    .opacity(0.25)
                    .frame(width: 140)
                    .clipped()
                    .mask(LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing))
            }
        }
        .allowsHitTesting(false)
    }

    private var titleColor: Color { isTopRank ? .white : DSColor.textPrimary }
    private var labelColor: Color { isTopRank ? .white.opacity(0.9) : DSColor.textSecondary }
    private var authorColor: Color { isTopRank ? .white : DSColor.textPrimary }
    private var dividerColor: Color { isTopRank ? Color.white.opacity(0.6) : DSColor.rankHighlight }

    private var metricNumberColor: Color {
        if isTopRank { return .white }
        return colorScheme == .dark ? DSColor.brandPrimary : DSColor.rankHighlight
    }

    private var starColor: Color {
        if isTopRank { return .white }
        return colorScheme == .dark ? .white : DSColor.rankHighlight
    }

    private var cardBackground: some View {
        Group {
            if isTopRank {
                LinearGradient(colors: [DSColor.brandPrimary, DSColor.brandPrimary.opacity(0.85)],
                                startPoint: .leading, endPoint: .trailing)
            } else {
                LinearGradient(colors: [stripeColor, DSColor.backgroundPrimary],
                                startPoint: .leading, endPoint: .trailing)
            }
        }
    }

    private var stripeColor: Color {
        DSColor.rankHighlight.opacity(colorScheme == .dark ? 0.30 : 0.25)
    }

    private var rankBadge: some View {
        ZStack {
            Circle()
                .fill((isTopRank ? DSColor.rankHighlight : DSColor.rankAccentStripe).opacity(0.25))
                .frame(width: 40, height: 40)
            Text("\(rank)")
                .dsFont(.title3)
                .fontWeight(.bold)
                .foregroundStyle(isTopRank ? DSColor.brandPrimary : DSColor.rankAccentStripe)
                .frame(width: 30, height: 30)
                .background(Circle().fill(.white))
                .overlay {
                    Circle().strokeBorder(isTopRank ? DSColor.rankHighlight : DSColor.rankAccentStripe, lineWidth: 2)
                }
        }
    }

    private var metricRow: some View {
        HStack(spacing: DSSpacing.xxs) {
            Text(sortBy == .views ? "Lượt xem:" : "Yêu thích:")
                .foregroundStyle(labelColor)
            Text(formattedMetricValue)
                .fontWeight(isTopRank ? .bold : .regular)
                .foregroundStyle(metricNumberColor)
        }
        .dsFont(.subheadline)
    }

    private var formattedMetricValue: String {
        let value = sortBy == .views ? item.viewCount : item.favoriteCount
        return value.formatted(.number.locale(Locale(identifier: "en_US")))
    }

    private func chapterText(_ label: String) -> some View {
        let parts = ChapterLabelParser.parse(label)
        return (
            Text(parts.prefix + " ").font(DSFont.font(.caption)).foregroundColor(labelColor)
            + Text(parts.number).font(DSFont.font(.caption).bold()).foregroundColor(labelColor)
            + Text(parts.rest ?? "").font(DSFont.font(.caption)).foregroundColor(labelColor)
        )
        .lineLimit(1)
        .truncationMode(.tail)
    }

    private func starCluster(color: Color, compact: Bool) -> some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            Group {
                sparkle(size: compact ? 7 : 9, color: color).position(x: 12, y: 14)
                sparkle(size: compact ? 11 : 15, color: color).position(x: 24, y: 8)
                sparkle(size: compact ? 11 : 15, color: color).position(x: 12, y: h - 12)
                sparkle(size: compact ? 11 : 15, color: color).position(x: w - 18, y: 12)
                sparkle(size: compact ? 7 : 9, color: color).position(x: w - 24, y: h - 18)
                sparkle(size: compact ? 11 : 15, color: color).position(x: w - 12, y: h - 8)
            }
        }
        .allowsHitTesting(false)
    }

    private func sparkle(size: CGFloat, color: Color) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundStyle(color.opacity(0.85))
    }

    @ViewBuilder
    private func coverImage(width: CGFloat, height: CGFloat) -> some View {
        DSCachedAsyncImage(url: item.coverURL, resize: .size(CGSize(width: width, height: height))) { phase in
            if case .success(let image) = phase {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Rectangle().fill(DSColor.backgroundSecondary)
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }

    private func twoPartText(
        token: DSFontToken,
        prefix: String, prefixBold: Bool, prefixColor: Color,
        value: String, valueBold: Bool, valueColor: Color
    ) -> some View {
        let baseFont = DSFont.font(token)
        return (
            Text(prefix).font(prefixBold ? baseFont.bold() : baseFont).foregroundColor(prefixColor)
            + Text(value).font(valueBold ? baseFont.bold() : baseFont).foregroundColor(valueColor)
        )
    }
}

private enum ChapterLabelParser {
    struct Parts { let prefix: String; let number: String; let rest: String? }

    static func parse(_ label: String) -> Parts {
        guard let colonIndex = label.firstIndex(of: ":") else {
            let comps = label.split(separator: " ")
            guard comps.count == 2 else { return Parts(prefix: label, number: "", rest: nil) }
            return Parts(prefix: String(comps[0]), number: String(comps[1]), rest: nil)
        }
        let before = label[..<colonIndex]
        let after = label[label.index(after: colonIndex)...]
        let comps = before.split(separator: " ")
        guard comps.count == 2 else { return Parts(prefix: label, number: "", rest: nil) }
        return Parts(prefix: String(comps[0]), number: String(comps[1]), rest: ":" + after)
    }
}
