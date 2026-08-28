//
//  CommentPreviewRow.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Displays a single condensed comment for the "Random Comments" section.
// A minimal, local HomeFeature component—NOT the full CommentRowView
// (that belongs to Comments & Social, which handles replies, likes, and reporting).

import CoreModels
import DesignSystem
import SwiftUI

struct CommentPreviewRow: View {
    let comment: Comment
    let onSeriesTapped: (String) -> Void

    private let avatarSize: CGFloat = 32
    private let contentHeight: CGFloat = 44

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            // Row 1: avatar + username + timestamp
            HStack(spacing: DSSpacing.sm) {
                avatar
                Text(comment.user.username)
                    .dsFont(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColor.textPrimary)
                Spacer()
                Text(Self.daysAgoText(from: comment.createdAt))
                    .dsFont(.caption)
                    .foregroundStyle(DSColor.textSecondary)
            }

            // Row 2: comment content
            Text(comment.content)
                .dsFont(.body)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(height: contentHeight, alignment: .top)

            if let seriesId = comment.seriesId, let seriesTitle = comment.seriesTitle {
                Divider()
                Button {
                    onSeriesTapped(seriesId)
                } label: {
                    Text(seriesTitle)
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.brandPrimary)
                }
            }
        }
    }

    @ViewBuilder
    private var avatar: some View {
        AsyncImage(url: comment.user.avatarURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            default:
                Circle().fill(DSColor.backgroundSecondary)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundStyle(DSColor.textSecondary.opacity(0.6))
                    }
            }
        }
        .frame(width: avatarSize, height: avatarSize)
        .clipShape(Circle())
    }

    /// "N days ago" — Calculated manually by day, without using the default RelativeDateTimeFormatter
    /// (which automatically selects "week"/"month" units based on the time span)
    static func daysAgoText(from date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return days <= 0 ? "Hôm nay" : "\(days) ngày trước"
    }
}
