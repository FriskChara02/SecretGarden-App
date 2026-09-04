//
//  SeriesDetailView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 4/9/26.
//

// Info Card section (cover, title, author/artist/group, tags, views, status,
// description, read button, notifications, favorites, Yuri list dropdown, share) — ENTIRELY contained within
// a single DSDecorativeCard (with corner brackets only at the start and end of the block).

import CoreModels
import DesignSystem
import Repositories
import SwiftUI

public struct SeriesDetailView: View {
    @StateObject private var viewModel: SeriesDetailViewModel
    @State private var isDescriptionExpanded = false
    @State private var isReadingStatusExpanded = false
    @State private var expandedCommentReplyIDs: Set<String> = []

    let onHeaderTapped: () -> Void
    /// TODO: sẽ điều hướng thật sang ChapterReaderView khi Reader hoàn thành.
    let onStartReading: (String) -> Void
    let onContinueReading: (String) -> Void
    /// TODO(Report riêng): hiện modal Báo cáo vi phạm khi có FormSubmissionState.
    let onReportTapped: () -> Void

    public init(
        seriesId: String,
        seriesRepository: SeriesRepositoryProtocol,
        commentRepository: CommentRepositoryProtocol,
        onHeaderTapped: @escaping () -> Void,
        onStartReading: @escaping (String) -> Void,
        onContinueReading: @escaping (String) -> Void,
        onReportTapped: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: SeriesDetailViewModel(
            seriesId: seriesId,
            seriesRepository: seriesRepository,
            commentRepository: commentRepository
        ))
        self.onHeaderTapped = onHeaderTapped
        self.onStartReading = onStartReading
        self.onContinueReading = onContinueReading
        self.onReportTapped = onReportTapped
    }

    public var body: some View {
        ZStack(alignment: .top) {
            DSCoverFadeBackground(coverURL: viewModel.detailState.value?.coverURL)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    GardenHeaderView(onTap: onHeaderTapped)

                    Spacer().frame(height: DSSpacing.lg)

                    if case .loaded(let series) = viewModel.detailState {
                        content
                            .padding(.horizontal, DSSpacing.md)

                        DSSectionDivider().padding(.vertical, DSSpacing.lg)
                        chaptersCard(series)

                        DSSectionDivider().padding(.vertical, DSSpacing.lg)
                        relatedCard

                        DSSectionDivider().padding(.vertical, DSSpacing.lg)
                        commentsCard
                    } else {
                        content
                            .padding(.horizontal, DSSpacing.md)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .background(Color.clear)
        .onAppear { viewModel.onAppear() }
        .alert(
            "Có lỗi xảy ra",
            isPresented: Binding(
                get: { viewModel.actionErrorMessage != nil },
                set: { if !$0 { viewModel.dismissActionError() } }
            )
        ) {
            Button("Đã hiểu", role: .cancel) { viewModel.dismissActionError() }
        } message: {
            Text(viewModel.actionErrorMessage ?? "")
        }
    }

    // MARK: - Root content switch according to critical state

    @ViewBuilder
    private var content: some View {
        switch viewModel.detailState {
        case .idle, .loading:
            ProgressView().padding(.top, DSSpacing.xxl)
        case .failed(let error):
            errorView(error.localizedDescription)
        case .loaded(let series):
            infoCard(series)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 32)).foregroundStyle(DSColor.statusError)
            Text(message).dsFont(.subheadline).foregroundStyle(DSColor.textSecondary).multilineTextAlignment(.center)
            DSButton("Thử lại", variant: .primary) { viewModel.loadDetailAndChapters() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xxl)
    }

    // MARK: - Info Card (single block — start/end corner brackets)

    private func infoCard(_ series: Series) -> some View {
        DSDecorativeCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                coverImage(series.coverURL)
                titleBlock(series)
                infoRows(series)
                genreTags(series.genres)
                viewCountRow(series.viewCount)
                statusRow(series.status)
                descriptionBlock(series)
                actionButtons(series)
                notifyRow(series)
                favoriteButton(series)
                readingStatusDropdown(series)
                shareRow
            }
            .padding(DSSpacing.lg)
        }
    }

    // MARK: - Cover

    private func coverImage(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            if case .success(let image) = phase {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Rectangle().fill(DSColor.backgroundSecondary)
            }
        }
        .frame(width: 220, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .padding(6)
        .background(RoundedRectangle(cornerRadius: DSRadius.md + 4).fill(DSColor.backgroundPrimary))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Title + original title

    private func titleBlock(_ series: Series) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(series.title)
                .dsFont(.title2)
                .fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)

            if let originalTitle = series.originalTitle {
                Text(originalTitle)
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
    }

    // MARK: - Author / Artist / Group rows

    private func infoRows(_ series: Series) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            if let author = series.author {
                infoRow(icon: "pencil.tip", iconColor: DSColor.info, label: "Tác giả:", value: author.name, valueColor: DSColor.info)
            }
            if let artist = series.artist {
                infoRow(icon: "paintpalette", iconColor: .purple, label: "Họa sĩ:", value: artist.name, valueColor: .purple)
            }
            if let group = series.group {
                infoRow(icon: "flag.fill", iconColor: DSColor.brandPrimary, label: "Nhóm dịch:", value: group.name, valueColor: DSColor.brandPrimary)
            }
        }
    }

    private func infoRow(icon: String, iconColor: Color, label: String, value: String, valueColor: Color) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: icon).foregroundStyle(iconColor)
            Text(label).dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
            Text(value).dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(valueColor)
        }
    }

    // MARK: - Genre tags (dark capsule, distinct from default DSTag — custom-styled to match the Detail aesthetic)

    private func genreTags(_ genres: [Genre]) -> some View {
        FlowLayout(spacing: DSSpacing.xs) {
            ForEach(genres) { genre in
                Text(genre.name)
                    .dsFont(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xxs)
                    .background(Capsule().fill(Color.black.opacity(0.72)))
            }
        }
    }

    // MARK: - View count

    private func viewCountRow(_ count: Int) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "eye.fill").foregroundStyle(DSColor.brandPrimary)
            Text("Lượt xem:").dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
            Text(Self.numberFormatter.string(from: NSNumber(value: count)) ?? "\(count)")
                .dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
        }
    }

    // MARK: - Status

    private func statusRow(_ status: SeriesStatus) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "battery.50").foregroundStyle(.orange)
            Text("Trạng thái:").dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
            Text(statusLabel(status)).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(.orange)
        }
    }

    private func statusLabel(_ status: SeriesStatus) -> String {
        switch status {
        case .ongoing: return "Đang tiến hành"
        case .completed: return "Hoàn thành"
        case .upcoming: return "Sắp ra mắt"
        case .dropped: return "Ngừng dịch"
        }
    }

    // MARK: - Description (collapse/expand)

    private func descriptionBlock(_ series: Series) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Nội dung:").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                Spacer()
                Text("(Cập nhật: \(Self.dateFormatter.string(from: series.updatedAt)))")
                    .dsFont(.caption).foregroundStyle(DSColor.textSecondary)
            }

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(series.description)
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(isDescriptionExpanded ? nil : 3)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isDescriptionExpanded.toggle() }
                } label: {
                    Text(isDescriptionExpanded ? "Thu gọn" : "Xem thêm")
                        .dsFont(.footnote).foregroundStyle(DSColor.brandPrimary)
                }
            }
            .padding(DSSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DSColor.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
        }
    }

    // MARK: - Action buttons (Read from the beginning / Continue reading)

    private func actionButtons(_ series: Series) -> some View {
        HStack(spacing: DSSpacing.sm) {
            if let firstChapter = viewModel.visibleSortedChapters.last ?? series.chapters?.first {
                DSButton("Đọc từ đầu", variant: .primary) { onStartReading(firstChapter.id) }
            }
            // TODO(Actual history): currently points to the LATEST chapter, not the actual
            // last-read position (requires READING_HISTORY). Note this clearly, do not pretend it represents the final intended behavior.
            if let latestChapter = viewModel.visibleSortedChapters.first ?? series.chapters?.last {
                DSButton("Tiếp tục đọc (Ch. \(Int(latestChapter.chapterNumber)))", variant: .outline) {
                    onContinueReading(latestChapter.id)
                }
            }
        }
    }

    // MARK: - Notify toggle

    private func notifyRow(_ series: Series) -> some View {
        HStack {
            Image(systemName: series.isNotifyEnabled ? "bell.fill" : "bell").foregroundStyle(DSColor.brandPrimary)
            Text("Nhận thông báo").dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
            Spacer()
            Toggle("", isOn: Binding(
                get: { series.isNotifyEnabled },
                set: { _ in viewModel.toggleNotify() }
            ))
            .labelsHidden()
            .tint(DSColor.brandPrimary)
            .disabled(viewModel.isTogglingNotify)
        }
    }

    // MARK: - Favorite

    private func favoriteButton(_ series: Series) -> some View {
        Button {
            viewModel.toggleFavorite()
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: series.isFavoritedByMe ? "heart.fill" : "heart")
                Text(series.isFavoritedByMe ? "Đã yêu thích" : "Yêu thích")
                    .fontWeight(.semibold)
                Text("(\(Self.numberFormatter.string(from: NSNumber(value: series.favoriteCount)) ?? "0") người)")
            }
            .dsFont(.subheadline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .background(Capsule().fill(DSColor.brandPrimary))
        }
        .disabled(viewModel.isTogglingFavorite)
    }

    // MARK: - Reading Status dropdown ("Yuri list")

    private func readingStatusDropdown(_ series: Series) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isReadingStatusExpanded.toggle() }
            } label: {
                HStack {
                    Image(systemName: "bookmark.fill")
                    Text(readingStatusLabel(series.readingStatus))
                    Spacer()
                    Image(systemName: isReadingStatusExpanded ? "chevron.up" : "chevron.down")
                }
                .dsFont(.subheadline).fontWeight(.semibold)
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.vertical, DSSpacing.sm)
                .padding(.horizontal, DSSpacing.md)
                .frame(maxWidth: .infinity)
                .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }
            .disabled(viewModel.isUpdatingReadingStatus)

            if isReadingStatusExpanded {
                VStack(spacing: 0) {
                    ForEach(ReadingStatus.allCases, id: \.self) { status in
                        readingStatusOptionRow(status, isSelected: series.readingStatus == status)
                    }
                    Button {
                        viewModel.removeFromReadingList()
                        isReadingStatusExpanded = false
                    } label: {
                        Text("Xoá khỏi danh sách")
                            .dsFont(.subheadline).fontWeight(.semibold)
                            .foregroundStyle(DSColor.statusError)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, DSSpacing.sm)
                    }
                }
                .padding(.top, DSSpacing.xxs)
            }
        }
    }

    private func readingStatusOptionRow(_ status: ReadingStatus, isSelected: Bool) -> some View {
        Button {
            viewModel.updateReadingStatus(to: status)
            isReadingStatusExpanded = false
        } label: {
            HStack {
                Text(readingStatusLabel(status)).dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark").foregroundStyle(DSColor.brandPrimary)
                }
            }
            .padding(.vertical, DSSpacing.sm)
            .padding(.horizontal, DSSpacing.md)
            .background(isSelected ? DSColor.brandPrimaryLight.opacity(0.15) : Color.clear)
        }
    }

    private func readingStatusLabel(_ status: ReadingStatus?) -> String {
        switch status {
        case .planToRead, .none: return "Sẽ đọc"
        case .reading: return "Đang theo dõi"
        case .completed: return "Đọc xong"
        case .dropped: return "Ngừng đọc"
        }
    }

    // MARK: - Share row (TODO: actual share sheet)

    private var shareRow: some View {
        HStack(spacing: DSSpacing.md) {
            Text("Chia sẻ:").dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
            ForEach(["square.and.arrow.up", "message.fill", "paperplane.fill", "bubble.left.fill"], id: \.self) { icon in
                Image(systemName: icon)
                    .foregroundStyle(DSColor.brandPrimary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(DSColor.backgroundSecondary))
            }
        }
    }

    // MARK: - Formatters

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss dd/MM/yyyy"
        return formatter
    }()
    
    // MARK: - Chapters Card

    private func chaptersCard(_ series: Series) -> some View {
        DSDecorativeCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack {
                    sectionTitle("Danh sách chương")
                    Spacer()
                    sortButton(icon: "arrow.up", isSelected: !viewModel.chaptersSortDescending) {
                        viewModel.setChaptersSortDescending(false)
                    }
                    sortButton(icon: "arrow.down", isSelected: viewModel.chaptersSortDescending) {
                        viewModel.setChaptersSortDescending(true)
                    }
                }

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.visibleSortedChapters.enumerated()), id: \.element.id) { index, chapter in
                        chapterRow(chapter, isLatest: chapter.chapterNumber == series.chapters?.map(\.chapterNumber).max())
                        if index < viewModel.visibleSortedChapters.count - 1 {
                            Divider().foregroundStyle(DSColor.borderDefault.opacity(0.3))
                        }
                    }
                }

                if viewModel.hasMoreChapters {
                    Button {
                        viewModel.showMoreChapters()
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            Text("Xem thêm")
                            Image(systemName: "chevron.down")
                        }
                        .dsFont(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(DSColor.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DSSpacing.sm)
                        .overlay(Capsule().strokeBorder(DSColor.brandPrimary.opacity(0.5), lineWidth: 1))
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }

    private func sortButton(icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(isSelected ? .white : DSColor.brandPrimary)
                .frame(width: 32, height: 32)
                .background(Circle().fill(isSelected ? DSColor.brandPrimary : DSColor.backgroundSecondary))
        }
    }

    private func chapterRow(_ chapter: Chapter, isLatest: Bool) -> some View {
        Button {
            onContinueReading(chapter.id)
        } label: {
            HStack {
                HStack(spacing: DSSpacing.xs) {
                    Text("Chương \(Self.chapterNumberString(chapter.chapterNumber))")
                        .dsFont(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(DSColor.textPrimary)
                    if isLatest {
                        Text("Mới nhất")
                            .dsFont(.caption).fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, DSSpacing.xs).padding(.vertical, 2)
                            .background(Capsule().fill(DSColor.brandPrimary))
                    }
                }
                Spacer()
                Text(Self.chapterDateFormatter.string(from: chapter.releasedAt))
                    .dsFont(.caption).foregroundStyle(DSColor.textSecondary)
            }
            .padding(.vertical, DSSpacing.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Related Card ("You might also like")

    private var relatedCard: some View {
        DSDecorativeCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                sectionTitle("Có thể bạn cũng thích")

                switch viewModel.relatedState {
                case .idle, .loading:
                    ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
                case .failed:
                    sectionErrorRow { viewModel.loadRelated() }
                case .loaded(let items) where items.isEmpty:
                    Text("Chưa có gợi ý nào.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
                case .loaded(let items):
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.sm) {
                            ForEach(items) { item in
                                SeriesCardView(data: SeriesCardMapper.map(item), layout: .grid) {
                                    onStartReading(item.id)
                                }
                                .frame(width: 140, height: 220)
                            }
                        }
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }

    // MARK: - Comments Card

    private var commentsCard: some View {
        DSDecorativeCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                sectionTitle("Bình luận (\(viewModel.commentsState.value?.count ?? 0))")

                commentComposerPlaceholder

                HStack {
                    Text("Tất cả bình luận").dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
                    Image(systemName: "chevron.down").font(.caption).foregroundStyle(DSColor.textSecondary)
                    Spacer()
                }

                switch viewModel.commentsState {
                case .idle, .loading:
                    ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
                case .failed:
                    sectionErrorRow { viewModel.loadComments() }
                case .loaded(let comments) where comments.isEmpty:
                    Text("Chưa có bình luận nào.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
                case .loaded(let comments):
                    VStack(spacing: DSSpacing.md) {
                        ForEach(comments) { comment in
                            commentRow(comment)
                        }
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }

    /// TODO: The comment input field currently only displays the UI - the actual submission action is not yet connected.
    private var commentComposerPlaceholder: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Circle().fill(DSColor.backgroundSecondary).frame(width: 36, height: 36)
                .overlay { Image(systemName: "person.fill").foregroundStyle(DSColor.textSecondary) }
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("Bình luận (@ để nhắc tên)...")
                    .dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                Divider()
                HStack {
                    Text("0/1000").dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    Spacer()
                    Image(systemName: "face.smiling").foregroundStyle(DSColor.textSecondary)
                    Image(systemName: "photo").foregroundStyle(DSColor.textSecondary)
                    Image(systemName: "paperplane.fill").foregroundStyle(DSColor.textSecondary.opacity(0.4))
                }
            }
        }
        .opacity(0.6) // Visual cue: this block is not yet active in Phase 10.
    }

    private func commentRow(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(alignment: .top, spacing: DSSpacing.sm) {
                avatarView(comment.user)
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    HStack(spacing: DSSpacing.xxs) {
                        Text(comment.user.username).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                        Image(systemName: "diamond.circle").font(.system(size: 6)).foregroundStyle(DSColor.brandPrimary)
                        Text(Self.relativeFormatter.localizedString(for: comment.createdAt, relativeTo: Date()))
                            .dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    }

                    ZStack(alignment: .bottomTrailing) {
                        Text(comment.content)
                            .dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                            .padding(DSSpacing.sm)
                            .background(DSColor.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))

                        if comment.likeCount > 0 {
                            HStack(spacing: 2) {
                                Text("❤️").font(.system(size: 9))
                                Text("\(comment.likeCount)").dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                            }
                            .padding(.horizontal, DSSpacing.xs).padding(.vertical, 2)
                            .background(Capsule().fill(DSColor.backgroundPrimary))
                            .overlay(Capsule().strokeBorder(DSColor.borderDefault.opacity(0.4), lineWidth: 0.5))
                            .offset(x: 8, y: 10)
                        }
                    }

                    HStack(spacing: DSSpacing.md) {
                        Label("Cảm xúc", systemImage: "hand.thumbsup")
                        Label("Trả lời", systemImage: "arrowshape.turn.up.left")
                    }
                    .dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    .padding(.top, 2)

                    if let replies = comment.replies, !replies.isEmpty {
                        replySection(replies, parentId: comment.id)
                    }
                }
            }
        }
    }

    private func replySection(_ replies: [Comment], parentId: String) -> some View {
        let isExpanded = expandedCommentReplyIDs.contains(parentId)
        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded { expandedCommentReplyIDs.remove(parentId) } else { expandedCommentReplyIDs.insert(parentId) }
                }
            } label: {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: isExpanded ? "chevron.up" : "arrow.turn.down.right")
                    Text(isExpanded ? "Thu gọn" : "Xem thêm \(replies.count) phản hồi")
                }
                .dsFont(.caption).fontWeight(.semibold).foregroundStyle(DSColor.textSecondary)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    ForEach(replies) { reply in
                        HStack(alignment: .top, spacing: DSSpacing.sm) {
                            avatarView(reply.user, size: 28)
                            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                Text(reply.user.username).dsFont(.caption).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                                Text(reply.content)
                                    .dsFont(.caption).foregroundStyle(DSColor.textPrimary)
                                    .padding(DSSpacing.xs)
                                    .background(DSColor.backgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                            }
                        }
                    }
                }
                .padding(.leading, DSSpacing.md)
                .overlay(alignment: .leading) {
                    Rectangle().fill(DSColor.brandPrimary.opacity(0.3)).frame(width: 2)
                }
            }
        }
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

    // MARK: - Shared small helpers

    private func sectionTitle(_ text: String) -> some View {
        HStack {
            Image(systemName: "diamond.circle").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
            Text(text).dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.circle").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
        }
    }

    private func sectionErrorRow(retry: @escaping () -> Void) -> some View {
        HStack {
            Text("Không tải được nội dung.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
            Button("Thử lại", action: retry).dsFont(.footnote).foregroundStyle(DSColor.brandPrimary)
        }
    }

    private static func chapterNumberString(_ number: Double) -> String {
        number == number.rounded() ? String(Int(number)) : String(number)
    }

    private static let chapterDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.unitsStyle = .full
        return formatter
    }()
}

#Preview {
    SeriesDetailView(
        seriesId: "series-1",
        seriesRepository: SeriesRepositoryMock(),
        commentRepository: CommentRepositoryMock(),
        onHeaderTapped: {},
        onStartReading: { _ in },
        onContinueReading: { _ in }
    )
}
