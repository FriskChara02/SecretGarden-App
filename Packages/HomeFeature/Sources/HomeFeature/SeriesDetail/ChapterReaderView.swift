//
//  ChapterReaderView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 4/9/26.
//

// Reader core framework — header, info card (title/page/Yuri list/notifications/
// chapter navigation), lazy-loading image scroll area.

import CoreModels
import Repositories
import DesignSystem
import SwiftUI

public struct ChapterReaderView: View {
    @StateObject private var viewModel: ChapterReaderViewModel
    @State private var isReadingStatusExpanded = false
    @State private var isReactionPickerPresentedInline = false
    @State private var isReactionPickerPresentedFloating = false
    @State private var selectedReactionEmoji = "❤️"
    @State private var hasReacted = false
    @State private var isFloatingBarVisible = true
    @State private var lastDragTranslationY: CGFloat = 0
    @State private var expandedReplyIDs: Set<String> = []
    @State private var readerContentWidth: CGFloat = UIScreen.main.bounds.width

    let onHomeTapped: () -> Void
    let onSeriesSelected: (String) -> Void
    let onBackToDetailTapped: () -> Void
    let onReportTapped: () -> Void

    public init(
        seriesId: String,
        initialChapterId: String,
        seriesRepository: SeriesRepositoryProtocol,
        commentRepository: CommentRepositoryProtocol,
        onHomeTapped: @escaping () -> Void,
        onSeriesSelected: @escaping (String) -> Void = { _ in },
        onBackToDetailTapped: @escaping () -> Void = {},
        onReportTapped: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: ChapterReaderViewModel(
            seriesId: seriesId,
            initialChapterId: initialChapterId,
            seriesRepository: seriesRepository,
            commentRepository: commentRepository
        ))
        self.onHomeTapped = onHomeTapped
        self.onSeriesSelected = onSeriesSelected
        self.onBackToDetailTapped = onBackToDetailTapped
        self.onReportTapped = onReportTapped
    }

    public var body: some View {
        Group {
            switch viewModel.seriesState {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed(let error):
                VStack(spacing: DSSpacing.md) {
                    Text(error.localizedDescription).dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                    DSButton("Thử lại", variant: .primary) { viewModel.onAppear() }
                }
            case .loaded(let series):
                readerScrollContent(series)
            }
        }
        .background(DSColor.backgroundSecondary)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { viewModel.onAppear() }
        .overlay {
            if viewModel.isMenuPresented {
                ZStack(alignment: .trailing) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { viewModel.isMenuPresented = false } }
                    ReaderMenuView(viewModel: viewModel, onHomeTapped: onHomeTapped)
                        .frame(width: 300)
                        .transition(.move(edge: .trailing))
                }
                .transition(.opacity)
                .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isMenuPresented)
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

    private func readerScrollContent(_ series: Series) -> some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DSSpacing.md) {
                        readerHeader(title: series.title, onTitleTapped: onBackToDetailTapped)
                            .id("readerTop")
                        infoCard(series: series, onCommentTapped: {
                            withAnimation { proxy.scrollTo("chapterComments", anchor: .top) }
                        }, onReportTapped: onReportTapped)
                        .padding(.horizontal, DSSpacing.md)

                        pagesSection
                            .padding(.horizontal, DSSpacing.md)
                        actionsCard
                            .padding(.horizontal, DSSpacing.md)
                        groupSection(series)
                            .padding(.horizontal, DSSpacing.md)
                        chapterCommentsCard
                            .padding(.horizontal, DSSpacing.md)
                            .id("chapterComments")

                        DSSectionDivider().padding(.vertical, DSSpacing.lg)

                        GardenFooterView(
                            policyLinks: [
                                GardenFooterLink(title: "Chính sách bảo mật", action: {}),
                                GardenFooterLink(title: "Quy định", action: {}),
                                GardenFooterLink(title: "Điều khoản", action: {})
                            ],
                            socialLinks: [
                                GardenFooterLink(title: "Discord", action: {}),
                                GardenFooterLink(title: "Facebook", action: {})
                            ],
                            onPolicyTapped: {}
                        )
                    }
                    .padding(.bottom, DSSpacing.xl)
                }
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.width
                } action: { newWidth in
                    readerContentWidth = newWidth
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 8)
                        .onChanged { value in
                            let delta = value.translation.height - lastDragTranslationY
                            if delta < -6, isFloatingBarVisible {
                                withAnimation(.easeInOut(duration: 0.25)) { isFloatingBarVisible = false }
                            }
                            else if delta > 6, !isFloatingBarVisible {
                                withAnimation(.easeInOut(duration: 0.25)) { isFloatingBarVisible = true }
                            }
                            lastDragTranslationY = value.translation.height
                        }
                        .onEnded { _ in
                            lastDragTranslationY = 0
                        }
                )

                VStack(alignment: .trailing, spacing: DSSpacing.sm) {
                    Button {
                        withAnimation { proxy.scrollTo("readerTop", anchor: .top) }
                    } label: {
                        Image(systemName: "chevron.up")
                            .foregroundStyle(DSColor.rankHighlight)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(DSColor.rankHighlight.opacity(0.15)))
                            .overlay(Circle().strokeBorder(DSColor.rankHighlight, lineWidth: 1.5))
                    }
                    .accessibilityLabel("Lên đầu trang")
                    .padding(.trailing, DSSpacing.lg)

                    floatingNavBar
                }
                .offset(y: isFloatingBarVisible ? 0 : 120)
                .opacity(isFloatingBarVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: isFloatingBarVisible)
            }
        }
        .confirmationDialog("Chọn chương", isPresented: $viewModel.isChapterPickerPresented, titleVisibility: .visible) {
            ForEach(viewModel.chapterPickerItems) { chapter in
                Button("Chương \(Self.chapterNumberString(chapter.chapterNumber))") { viewModel.selectChapter(chapter) }
            }
        }
    }

    // MARK: - Header

    private func readerHeader(title: String, onTitleTapped: @escaping () -> Void) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Button(action: onTitleTapped) {
                HStack(spacing: DSSpacing.sm) {
                    Circle().fill(DSColor.brandPrimary)
                        .frame(width: 36, height: 36)
                        .overlay { Image(systemName: "leaf.fill").foregroundStyle(.white).font(.system(size: 16)) }
                    Text(title)
                        .dsFont(.headline).fontWeight(.semibold)
                        .foregroundStyle(DSColor.textPrimary)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button { viewModel.isMenuPresented = true } label: {
                Image(systemName: "line.3.horizontal").foregroundStyle(DSColor.textPrimary).font(.title3)
            }
            .accessibilityLabel("Mở menu")
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
    }

    // MARK: - Info Card

    private func infoCard(series: Series, onCommentTapped: @escaping () -> Void, onReportTapped: @escaping () -> Void) -> some View {
        DSDecorativeCard(showCornerBrackets: false) {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(series.title)
                        .dsFont(.headline).fontWeight(.bold)
                        .foregroundStyle(DSColor.textPrimary)
                        .onTapGesture { onBackToDetailTapped() }

                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "book.pages.fill").foregroundStyle(.orange)
                        Text("Chương \(Self.chapterNumberString(viewModel.currentChapter.chapterNumber))")
                            .dsFont(.subheadline).fontWeight(.semibold)
                        Text("|").foregroundStyle(DSColor.textSecondary)
                        if let pageCount = viewModel.pagesState.value?.count {
                            Text("\(pageCount) trang").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                        }
                    }

                    Text("(Cập nhật: \(Self.daysAgoString(from: series.updatedAt)))")
                        .dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                }
                .padding(.trailing, 72)

                readingStatusRow

                VStack(spacing: DSSpacing.md) {
                    notifyRow
                    DSSectionDivider()
                    infoCardNavRow
                }
            }
            .padding(DSSpacing.md)
        }
        .overlay(alignment: .topTrailing) {
            VStack(spacing: DSSpacing.sm) {
                Button(action: onCommentTapped) {
                    Image(systemName: "message").font(.subheadline)
                        .foregroundStyle(DSColor.brandPrimary)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.2))
                }
                .accessibilityLabel("Bình luận chương")
                Button(action: onReportTapped) {
                    Image(systemName: "exclamationmark.triangle").font(.subheadline)
                        .foregroundStyle(DSColor.brandPrimary)
                        .frame(width: 30, height: 30)
                        .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.2))
                }
                .accessibilityLabel("Báo cáo vi phạm")
            }
            .padding(DSSpacing.md)
        }
    }

    private var readingStatusRow: some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            readingStatusDropdown
            Spacer()
            DSCrestPlaceholder()
        }
    }

    private var notifyRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Toggle("", isOn: Binding(
                get: { viewModel.isNotifyEnabled },
                set: { _ in viewModel.toggleNotify() }
            ))
            .labelsHidden()
            .toggleStyle(DSBellToggleStyle())
            .disabled(viewModel.isTogglingNotify)

            Text("Nhận thông báo")
                .dsFont(.footnote).fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()
        }
    }

    // MARK: - Reading status dropdown

    private var readingStatusDropdown: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isReadingStatusExpanded.toggle() }
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "bookmark.fill")
                    Text(readingStatusLabel(viewModel.readingStatus))
                    Image(systemName: isReadingStatusExpanded ? "chevron.up" : "chevron.down")
                }
                .dsFont(.subheadline).fontWeight(.semibold)
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.horizontal, 75)
                .padding(.vertical, DSSpacing.sm)
                .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }
            .disabled(viewModel.isUpdatingReadingStatus)

            if isReadingStatusExpanded {
                VStack(spacing: 0) {
                    ForEach(ReadingStatus.allCases, id: \.self) { status in
                        Button {
                            viewModel.updateReadingStatus(to: status)
                            isReadingStatusExpanded = false
                        } label: {
                            HStack {
                                Text(readingStatusLabel(status)).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                if viewModel.readingStatus == status {
                                    Image(systemName: "checkmark").foregroundStyle(DSColor.brandPrimary)
                                }
                            }
                            .padding(.vertical, DSSpacing.sm).padding(.horizontal, DSSpacing.md)
                        }
                    }
                    Divider()
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
            }
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

    // MARK: - Navigation bar

    private var infoCardNavRow: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                navCircleButton(icon: "arrow.left", isEnabled: viewModel.hasPreviousChapter, accessibilityLabel: "Chương trước") {
                    viewModel.goToPreviousChapter()
                }
                Button {
                    viewModel.isChapterPickerPresented = true
                } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Text("Chương \(Self.chapterNumberString(viewModel.currentChapter.chapterNumber))")
                        Image(systemName: "chevron.down")
                    }
                    .dsFont(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(DSColor.brandPrimary)
                    .padding(.vertical, DSSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                }
                navCircleButton(icon: "arrow.right", isEnabled: viewModel.hasNextChapter, accessibilityLabel: "Chương sau") {
                    viewModel.goToNextChapter()
                }
            }

            HStack {
                Button(action: onHomeTapped) {
                    Image(systemName: "house.fill").foregroundStyle(DSColor.brandPrimary)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                }
                .accessibilityLabel("Về trang chủ")
                Text("\(viewModel.pagesState.value?.count ?? 0) trang")
                    .dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                Spacer()
                Button { viewModel.toggleFavorite() } label: {
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: viewModel.isFavoritedByMe ? "heart.fill" : "heart")
                        Text(viewModel.isFavoritedByMe ? "Đã yêu thích" : "Yêu thích")
                    }
                    .dsFont(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.sm)
                    .background(Capsule().fill(DSColor.brandPrimary))
                }
                .disabled(viewModel.isTogglingFavorite)
            }
        }
    }

    private func navCircleButton(icon: String, isEnabled: Bool, accessibilityLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon).foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(isEnabled ? DSColor.brandPrimary : DSColor.backgroundSecondary))
        }
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Pages

    @ViewBuilder
    private var pagesSection: some View {
        switch viewModel.pagesState {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.xxl)
        case .failed(let error):
            VStack(spacing: DSSpacing.md) {
                Text(error.localizedDescription).dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                DSButton("Thử lại", variant: .primary) { viewModel.loadPages() }
            }
            .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.xxl)
        case .loaded(let pages):
            DSDecorativeCard {
                LazyVStack(spacing: 0) {
                    ForEach(pages) { page in
                        DSCachedAsyncImage(
                            url: page.imageURL,
                            resize: .width(readerContentWidth - DSSpacing.md * 2)
                        ) { phase in
                            switch phase {
                            case .success(let image): image.resizable().aspectRatio(contentMode: .fit)
                            case .failure:
                                Rectangle().fill(DSColor.backgroundSecondary).frame(height: 200)
                                    .overlay { Image(systemName: "photo").foregroundStyle(DSColor.textSecondary) }
                            default:
                                Rectangle().fill(DSColor.backgroundSecondary).frame(height: 200).overlay { ProgressView() }
                            }
                        }
                        .onAppear { viewModel.recordProgress(page: page.pageNumber) }
                    }
                }
            }
        }
    }
    
    private var reactionBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Spacer()
            Button {
                withAnimation { isReactionPickerPresentedInline.toggle() }
            } label: {
                HStack(spacing: DSSpacing.xxs) {
                    if hasReacted {
                        Text(selectedReactionEmoji).font(.subheadline)
                    } else {
                        Image(systemName: "heart")
                    }
                    Text("Cảm xúc")
                }
                .dsFont(.subheadline).fontWeight(.semibold)
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.sm)
                .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }

            HStack(spacing: -6) {
                ForEach(["🥳", "😆", "❤️"], id: \.self) { emoji in
                    Text(emoji).font(.caption)
                        .padding(4)
                        .background(Circle().fill(DSColor.backgroundPrimary))
                        .overlay(Circle().strokeBorder(DSColor.backgroundSecondary, lineWidth: 1))
                }
            }
            Text("49").dsFont(.caption).foregroundStyle(DSColor.textSecondary)
            Spacer()
        }
        .padding(.horizontal, DSSpacing.md)
        .overlay(alignment: .top) {
            if isReactionPickerPresentedInline {
                reactionPicker { emoji in
                    selectedReactionEmoji = emoji
                    hasReacted = true
                    withAnimation { isReactionPickerPresentedInline = false }
                }
                .offset(y: -60)
            }
        }
    }

    private let reactionEmojis = ["❤️", "😍", "😂", "😢", "😡", "👍"]
    
    private func reactionPicker(onSelect: @escaping (String) -> Void) -> some View {
        HStack(spacing: DSSpacing.md) {
            ForEach(reactionEmojis, id: \.self) { emoji in
                Button {
                    onSelect(emoji)
                } label: {
                    Text(emoji).font(.system(size: 30))
                }
                .accessibilityLabel(Self.reactionAccessibilityLabel(for: emoji))
            }
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.vertical, DSSpacing.md)
        .background(Capsule().fill(DSColor.backgroundPrimary))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        .fixedSize()
    }

    private static func reactionAccessibilityLabel(for emoji: String) -> String {
        switch emoji {
        case "❤️": return "Yêu thích"
        case "😍": return "Thích mê"
        case "😂": return "Buồn cười"
        case "😢": return "Buồn"
        case "😡": return "Tức giận"
        case "👍": return "Ủng hộ"
        default: return "Cảm xúc"
        }
    }

    // MARK: - "Other Group" (avatar + name + follow + divider + grid + divider)

    @ViewBuilder
    private func groupSection(_ series: Series) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack {
                Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
                Text("Khác của nhóm").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
                Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
            }
            .padding(.top, DSSpacing.md)

            if let group = series.group {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    HStack(spacing: DSSpacing.sm) {
                        // TODO(GroupRepository): Use a leaf icon as a placeholder avatar.
                        Circle().fill(DSColor.backgroundSecondary).frame(width: 44, height: 44)
                            .overlay { Image(systemName: "leaf.fill").foregroundStyle(DSColor.brandPrimary.opacity(0.6)) }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(group.name).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                            Text("@\(group.name.lowercased().replacingOccurrences(of: " ", with: "-"))")
                                .dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
                        }
                        Spacer()
                    }
                    Text("Đang theo dõi")
                        .dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                        .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.xs)
                        .background(Capsule().fill(DSColor.brandPrimaryLight.opacity(0.25)))
                }
            }

            DSSectionDivider()

            switch viewModel.groupOtherSeriesState {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.md)
            case .failed:
                Text("Không tải được nội dung.").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
            case .loaded(let items) where items.isEmpty:
                Text("Chưa có truyện khác của nhóm.").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
            case .loaded(let items):
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.sm) {
                        ForEach(items) { item in
                            SeriesCardView(data: SeriesCardMapper.map(item), layout: .grid) { onSeriesSelected(item.id) }
                                .frame(width: 140, height: 220)
                        }
                    }
                }
            }

            DSSectionDivider()
        }
    }

    // MARK: - Chapter comments

    private var chapterCommentsCard: some View {
        DSDecorativeCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                HStack {
                    Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
                    Text("Bình luận (\(viewModel.commentsState.value?.count ?? 0))")
                        .dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
                    Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
                }

                chapterCommentComposer

                HStack {
                    Text("Tất cả bình luận").dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
                    Image(systemName: "chevron.down").font(.caption).foregroundStyle(DSColor.textSecondary)
                    Spacer()
                }

                switch viewModel.commentsState {
                case .idle, .loading:
                    ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
                case .failed:
                    HStack {
                        Text("Không tải được bình luận.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
                        Button("Thử lại") { viewModel.loadComments() }.dsFont(.footnote).foregroundStyle(DSColor.brandPrimary)
                    }
                case .loaded(let comments) where comments.isEmpty:
                    Text("Chưa có bình luận nào cho chương này.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
                case .loaded(let comments):
                    VStack(spacing: DSSpacing.md) {
                        ForEach(comments) { comment in commentRow(comment) }
                    }
                }
            }
            .padding(DSSpacing.lg)
        }
    }

    private var chapterCommentComposer: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Circle().fill(DSColor.backgroundSecondary).frame(width: 36, height: 36)
                .overlay { Image(systemName: "person.fill").foregroundStyle(DSColor.textSecondary) }
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                TextField("Bình luận (@ để nhắc tên)...", text: $viewModel.commentDraft, axis: .vertical)
                    .dsFont(.subheadline)
                    .lineLimit(1...4)
                Divider()
                HStack {
                    Text("\(viewModel.commentDraft.count)/1000").dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    Spacer()
                    Image(systemName: "face.smiling").foregroundStyle(DSColor.textSecondary)
                    Image(systemName: "photo").foregroundStyle(DSColor.textSecondary)
                    Button {
                        viewModel.postComment()
                    } label: {
                        if viewModel.isPostingComment {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane.fill")
                                .foregroundStyle(
                                    viewModel.commentDraft.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? DSColor.textSecondary.opacity(0.4)
                                        : DSColor.brandPrimary
                                )
                        }
                    }
                    .disabled(viewModel.commentDraft.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isPostingComment)
                }
            }
        }
    }

    private func commentRow(_ comment: Comment) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack(alignment: .top, spacing: DSSpacing.sm) {
                avatarView(comment.user)
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    HStack(spacing: DSSpacing.xxs) {
                        Text(comment.user.username).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                        Image(systemName: "diamond.inset.filled").font(.system(size: 6)).foregroundStyle(DSColor.brandPrimary)
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
                        Button {
                            viewModel.toggleCommentLike(commentId: comment.id)
                        } label: {
                            Label("Cảm xúc", systemImage: comment.isLikedByMe ? "hand.thumbsup.fill" : "hand.thumbsup")
                        }
                        .foregroundStyle(comment.isLikedByMe ? DSColor.brandPrimary : DSColor.textSecondary)

                        Button {
                            viewModel.startReplying(to: comment.id)
                        } label: {
                            Label("Trả lời", systemImage: "arrowshape.turn.up.left")
                        }
                        .foregroundStyle(DSColor.textSecondary)
                    }
                    .dsFont(.caption)
                    .padding(.top, 2)

                    if viewModel.replyingToCommentId == comment.id {
                        replyComposer
                    }

                    if let replies = comment.replies, !replies.isEmpty {
                        replySection(replies, parentId: comment.id)
                    }
                }
            }
        }
    }

    private var replyComposer: some View {
        HStack(spacing: DSSpacing.xs) {
            TextField("Viết trả lời...", text: $viewModel.replyDraft)
                .dsFont(.caption)
                .padding(DSSpacing.xs)
                .background(DSColor.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))

            Button {
                viewModel.submitReply()
            } label: {
                if viewModel.isPostingReply {
                    ProgressView()
                } else {
                    Image(systemName: "paperplane.fill").font(.caption)
                }
            }
            .disabled(viewModel.replyDraft.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isPostingReply)

            Button("Hủy") { viewModel.cancelReplying() }
                .dsFont(.caption)
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.top, DSSpacing.xxs)
    }

    /// Bold and color the "@Name" section at the beginning of the content (if present) in pink, while keeping the rest of the text in the standard color.
    private func mentionAwareText(_ content: String) -> Text {
        guard content.hasPrefix("@"), let spaceIndex = content.firstIndex(of: " ") else {
            return Text(content).foregroundColor(DSColor.textPrimary)
        }
        let mention = String(content[..<spaceIndex])
        let rest = String(content[spaceIndex...])
        return Text(mention).foregroundColor(DSColor.brandPrimary).fontWeight(.bold)
            + Text(rest).foregroundColor(DSColor.textPrimary)
    }

    /// A pink arrow extends downwards from the original comment's avatar, with its tip obscured by the reply's avatar.
    private func replySection(_ replies: [Comment], parentId: String) -> some View {
        let isExpanded = expandedReplyIDs.contains(parentId)
        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Button {
                withAnimation {
                    if isExpanded { expandedReplyIDs.remove(parentId) } else { expandedReplyIDs.insert(parentId) }
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
                            avatarView(reply.user, size: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: DSSpacing.xxs) {
                                    Text(reply.user.username).dsFont(.caption).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                                    Image(systemName: "diamond.inset.filled").font(.system(size: 6)).foregroundStyle(.yellow)
                                    Text(Self.daysAgoShort(from: reply.createdAt)).dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                                }
                                mentionAwareText(reply.content)
                                    .dsFont(.caption)
                                    .padding(DSSpacing.xs).background(DSColor.backgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                            }
                        }
                    }
                }
                .padding(.leading, DSSpacing.md)
                .overlay(alignment: .leading) {
                    Rectangle().fill(DSColor.brandPrimary.opacity(0.4)).frame(width: 2)
                }
            }
        }
    }

    private func avatarView(_ user: User, size: CGFloat = 36) -> some View {
        DSCachedAsyncImage(url: user.avatarURL, resize: .size(CGSize(width: size, height: size))) { phase in
            if case .success(let image) = phase { image.resizable().aspectRatio(contentMode: .fill) }
            else { Circle().fill(DSColor.backgroundSecondary).overlay { Image(systemName: "person.fill").foregroundStyle(DSColor.textSecondary) } }
        }
        .frame(width: size, height: size).clipShape(Circle())
    }

    // MARK: - Floating nav bar (visible when scrolling up, hidden when scrolling down)

    private var floatingNavBar: some View {
        HStack(spacing: DSSpacing.sm) {
            navCircleButton(icon: "arrow.left", isEnabled: viewModel.hasPreviousChapter, accessibilityLabel: "Chương trước") { viewModel.goToPreviousChapter() }
            Button { viewModel.isChapterPickerPresented = true } label: {
                HStack { Text("Chương \(Self.chapterNumberString(viewModel.currentChapter.chapterNumber))"); Image(systemName: "chevron.up") }
                    .dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.brandPrimary)
                    .padding(.vertical, DSSpacing.sm).frame(maxWidth: .infinity)
                    .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }
            navCircleButton(icon: "arrow.right", isEnabled: viewModel.hasNextChapter, accessibilityLabel: "Chương sau") { viewModel.goToNextChapter() }
            Button(action: onHomeTapped) {
                Image(systemName: "house.fill").foregroundStyle(.white).frame(width: 40, height: 40)
                    .background(Circle().fill(DSColor.brandPrimary))
            }
            .accessibilityLabel("Về trang chủ")
            Button { withAnimation { isReactionPickerPresentedFloating.toggle() } } label: {
                Image(systemName: "face.smiling").foregroundStyle(.white).frame(width: 40, height: 40)
                    .background(Circle().fill(DSColor.brandPrimary))
            }
            .accessibilityLabel("Chọn cảm xúc")
        }
        .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.sm)
        .background(Capsule().fill(DSColor.backgroundPrimary))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        .padding(.horizontal, DSSpacing.lg)
        .padding(.bottom, DSSpacing.md)
        .overlay(alignment: .top) {
            if isReactionPickerPresentedFloating {
                reactionPicker { emoji in
                    selectedReactionEmoji = emoji
                    hasReacted = true
                    withAnimation { isReactionPickerPresentedFloating = false }
                }
                .padding(.bottom, DSSpacing.md)
                .offset(y: -60)
            }
        }
    }

    private static func chapterNumberString(_ number: Double) -> String {
        number == number.rounded() ? String(Int(number)) : String(number)
    }
    
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.unitsStyle = .full
        return formatter
    }()
    
    private static func daysAgoString(from date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return days <= 0 ? "hôm nay" : "\(days) ngày trước"
    }

    private static func daysAgoShort(from date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return days <= 0 ? "Hôm nay" : "\(days) ngày"
    }

    // MARK: - Actions Card (reaction + nav + share, separated from the mini-recap)

    private var actionsCard: some View {
        VStack(spacing: DSSpacing.md) {
            reactionBar
            Divider()
            HStack(spacing: DSSpacing.sm) {
                navCircleButton(icon: "arrow.left", isEnabled: viewModel.hasPreviousChapter, accessibilityLabel: "Chương trước") { viewModel.goToPreviousChapter() }
                Button { viewModel.isChapterPickerPresented = true } label: {
                    HStack(spacing: DSSpacing.xs) {
                        Text("Chương \(Self.chapterNumberString(viewModel.currentChapter.chapterNumber))")
                        Image(systemName: "chevron.down")
                    }
                    .dsFont(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(DSColor.brandPrimary)
                    .padding(.vertical, DSSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                }
                navCircleButton(icon: "arrow.right", isEnabled: viewModel.hasNextChapter, accessibilityLabel: "Chương sau") { viewModel.goToNextChapter() }
            }
            Divider()
            HStack(spacing: DSSpacing.md) {
                Spacer()
                Text("Chia sẻ:").dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                ForEach(["square.and.arrow.up", "message.fill", "paperplane.fill", "bubble.left.fill"], id: \.self) { icon in
                    Image(systemName: icon)
                        .foregroundStyle(DSColor.brandPrimary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(DSColor.backgroundSecondary))
                        .accessibilityHidden(true)
                }
                Spacer()
            }
        }
        .padding(DSSpacing.md)
        .background(RoundedRectangle(cornerRadius: DSRadius.lg).fill(DSColor.backgroundPrimary))
    }
}

#Preview {
    ChapterReaderView(
        seriesId: "series-1",
        initialChapterId: "chapter-190",
        seriesRepository: SeriesRepositoryMock(),
        commentRepository: CommentRepositoryMock(),
        onHomeTapped: {}
    )
}
