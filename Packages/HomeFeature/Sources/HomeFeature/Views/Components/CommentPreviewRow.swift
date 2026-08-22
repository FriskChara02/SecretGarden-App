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

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            avatar

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                HStack(spacing: DSSpacing.xs) {
                    Text(comment.user.username)
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.textPrimary)
                    Text(Self.relativeFormatter.localizedString(for: comment.createdAt, relativeTo: Date()))
                        .dsFont(.caption)
                        .foregroundStyle(DSColor.textSecondary)
                }

                Text(comment.content)
                    .dsFont(.body)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
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
        .frame(width: 36, height: 36)
        .clipShape(Circle())
    }
}
