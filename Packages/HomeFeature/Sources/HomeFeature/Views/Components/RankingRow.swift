//
//  RankingRow.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// A row displaying a single series in the ranking list.
// Do NOT use SeriesCardView.
// They involve complex tap/hold gestures (triggering hover previews) that are unsuitable for a list row,
// a simple ranking list requires a prominent rank number that is easy to scan sequentially.
// This is a local component required only by HomeFeature—do not add it to the Design System.

import CoreModels
import DesignSystem
import SwiftUI

struct RankingRow: View {
    let rank: Int
    let series: Series
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.sm) {
                rankBadge

                AsyncImage(url: series.coverURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(DSColor.backgroundSecondary)
                    }
                }
                .frame(width: 52, height: 78)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(series.title)
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "eye.fill").font(.caption2)
                        Text("\(formattedViewCount) lượt xem")
                    }
                    .dsFont(.caption)
                    .foregroundStyle(DSColor.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, DSSpacing.xxs)
        }
        .buttonStyle(.plain)
    }

    private var rankBadge: some View {
        Text("\(rank)")
            .dsFont(.title3)
            .foregroundStyle(rank <= 3 ? .white : DSColor.textSecondary)
            .frame(width: 28, height: 28)
            .background(rank <= 3 ? DSColor.brandPrimary : Color.clear)
            .clipShape(Circle())
    }

    private var formattedViewCount: String {
        if series.viewCount >= 1_000_000 {
            return String(format: "%.1fM", Double(series.viewCount) / 1_000_000)
        } else if series.viewCount >= 1_000 {
            return String(format: "%.1fK", Double(series.viewCount) / 1_000)
        }
        return "\(series.viewCount)"
    }
}
