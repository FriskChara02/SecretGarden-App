//
//  RandomCommentsSection.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// "Random Comments" section - the LAST section on the Home screen.
// Treated as a secondary section (like "Continue Reading"): errors fail silently (no display of
// Alert/DSErrorView), as this is merely "fun" content rather than core content
// required for app usage (unlike "Latest Updates" or "Ranking" — the main sections).

import CoreModels
import CoreArchitecture
import DesignSystem
import SwiftUI

struct RandomCommentsSection: View {
    let state: LoadableState<[Comment]>

    var body: some View {
        switch state {
        case .idle, .failed:
            EmptyView()

        case .loading:
            loadingSkeleton

        case .loaded(let comments) where comments.isEmpty:
            EmptyView()

        case .loaded(let comments):
            content(comments)
        }
    }

    private func content(_ comments: [Comment]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Bình luận ngẫu nhiên")
                .dsFont(.title3)
                .foregroundStyle(DSColor.textPrimary)
                .padding(.horizontal, DSSpacing.md)

            VStack(spacing: DSSpacing.sm) {
                ForEach(comments) { comment in
                    CommentPreviewRow(comment: comment)
                    if comment.id != comments.last?.id {
                        Divider()
                    }
                }
            }
            .padding(DSSpacing.md)
            .background(DSColor.backgroundSecondary.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
            .padding(.horizontal, DSSpacing.md)
        }
    }

    private var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Bình luận ngẫu nhiên")
                .dsFont(.title3)
                .foregroundStyle(DSColor.textPrimary)
                .padding(.horizontal, DSSpacing.md)

            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(DSColor.backgroundSecondary)
                .frame(height: 100)
                .overlay { ProgressView() }
                .padding(.horizontal, DSSpacing.md)
        }
    }
}
