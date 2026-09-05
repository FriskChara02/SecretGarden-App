//
//  ChapterCommentsOverlayView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 5/9/26.
//

// Chapter-specific comment overlay — separate from the home comments on the Details page.

import CoreModels
import DesignSystem
import SwiftUI

struct ChapterCommentsOverlayView: View {
    @ObservedObject var viewModel: ChapterReaderViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var expandedReplyIDs: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                switch viewModel.commentsState {
                case .idle, .loading:
                    ProgressView().padding(.top, DSSpacing.xxl)
                case .failed:
                    VStack(spacing: DSSpacing.md) {
                        Text("Không tải được bình luận.").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                        DSButton("Thử lại", variant: .primary) { viewModel.loadComments() }
                    }
                    .padding(.top, DSSpacing.xxl)
                case .loaded(let comments) where comments.isEmpty:
                    Text("Chưa có bình luận nào cho chương này.")
                        .dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                        .padding(.top, DSSpacing.xxl)
                case .loaded(let comments):
                    VStack(spacing: DSSpacing.md) {
                        ForEach(comments) { comment in
                            commentRow(comment)
                        }
                    }
                    .padding(DSSpacing.lg)
                }
            }
            .navigationTitle("Bình luận (\(viewModel.commentsState.value?.count ?? 0))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }

    private func commentRow(_ comment: Comment) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            avatarView(comment.user)
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(comment.user.username).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                Text(comment.content)
                    .dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                    .padding(DSSpacing.sm)
                    .background(DSColor.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))

                HStack(spacing: DSSpacing.md) {
                    Label("Cảm xúc", systemImage: "hand.thumbsup")
                    Label("Trả lời", systemImage: "arrowshape.turn.up.left")
                    if comment.likeCount > 0 {
                        Text("\(comment.likeCount)").dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    }
                }
                .dsFont(.caption).foregroundStyle(DSColor.textSecondary)

                if let replies = comment.replies, !replies.isEmpty {
                    replySection(replies, parentId: comment.id)
                }
            }
        }
    }

    private func replySection(_ replies: [Comment], parentId: String) -> some View {
        let isExpanded = expandedReplyIDs.contains(parentId)
        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded { expandedReplyIDs.remove(parentId) } else { expandedReplyIDs.insert(parentId) }
                }
            } label: {
                Text(isExpanded ? "Thu gọn" : "Xem thêm \(replies.count) phản hồi")
                    .dsFont(.caption).fontWeight(.semibold).foregroundStyle(DSColor.textSecondary)
            }
            if isExpanded {
                ForEach(replies) { reply in
                    HStack(alignment: .top, spacing: DSSpacing.sm) {
                        avatarView(reply.user, size: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(reply.user.username).dsFont(.caption).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                            Text(reply.content).dsFont(.caption).foregroundStyle(DSColor.textPrimary)
                                .padding(DSSpacing.xs).background(DSColor.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                        }
                    }
                }
            }
        }
        .padding(.leading, DSSpacing.md)
    }

    private func avatarView(_ user: User, size: CGFloat = 36) -> some View {
        AsyncImage(url: user.avatarURL) { phase in
            if case .success(let image) = phase {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Circle().fill(DSColor.backgroundSecondary).overlay { Image(systemName: "person.fill").foregroundStyle(DSColor.textSecondary) }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
