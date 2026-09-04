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

    let onHomeTapped: () -> Void

    public init(
        seriesId: String,
        chapters: [Chapter],
        initialChapterId: String,
        isFavoritedByMe: Bool,
        isNotifyEnabled: Bool,
        readingStatus: ReadingStatus?,
        seriesRepository: SeriesRepositoryProtocol,
        commentRepository: CommentRepositoryProtocol,
        onHomeTapped: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: ChapterReaderViewModel(
            seriesId: seriesId,
            chapters: chapters,
            initialChapterId: initialChapterId,
            isFavoritedByMe: isFavoritedByMe,
            isNotifyEnabled: isNotifyEnabled,
            readingStatus: readingStatus,
            seriesRepository: seriesRepository,
            commentRepository: commentRepository
        ))
        self.onHomeTapped = onHomeTapped
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                readerHeader
                infoCard
                    .padding(.horizontal, DSSpacing.md)
                pagesSection
                    .padding(.horizontal, DSSpacing.md)
            }
            .padding(.bottom, DSSpacing.xl)
        }
        .background(DSColor.backgroundSecondary)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { viewModel.onAppear() }
        .sheet(isPresented: $viewModel.isMenuPresented) {
            // TODO: Replace with the actual ReaderMenuView (Home/Reports/Favorites/
            // Comments/Notifications/Dark mode) — temporary placeholder to verify state functionality.
            Text("Menu (Step 10.10)").dsFont(.title2).padding()
        }
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

    // MARK: - Header (smaller than GardenHeaderView — features a circular avatar and a hamburger menu instead of a large logo)

    private var readerHeader: some View {
        HStack(spacing: DSSpacing.sm) {
            Circle().fill(DSColor.brandPrimary)
                .frame(width: 36, height: 36)
                .overlay { Image(systemName: "leaf.fill").foregroundStyle(.white).font(.system(size: 16)) }

            Text(seriesTitleForHeader)
                .dsFont(.headline).fontWeight(.semibold)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)

            Spacer()

            Button {
                viewModel.isMenuPresented = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(DSColor.textPrimary)
                    .font(.title3)
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
    }

    /// TODO: Receive the actual series name via a parameter instead of a temporary string.
    /// The full `Series` object hasn't been passed to the Reader yet (only `chapters`); this will be
    /// finalized when the actual navigation is hooked up.
    private var seriesTitleForHeader: String { "Đồ Ăn Của Ta Trông..." }

    // MARK: - Info Card

    private var infoCard: some View {
        DSDecorativeCard(showCornerBrackets: false) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(seriesTitleForHeader)
                    .dsFont(.headline).fontWeight(.bold)
                    .foregroundStyle(DSColor.textPrimary)

                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "book.pages.fill").foregroundStyle(.orange)
                    Text("Chương \(Self.chapterNumberString(viewModel.currentChapter.chapterNumber))")
                        .dsFont(.subheadline).fontWeight(.semibold)
                    Text("|").foregroundStyle(DSColor.textSecondary)
                    if let pageCount = viewModel.pagesState.value?.count {
                        Text("\(pageCount) trang").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                    }
                }

                readingStatusDropdown

                HStack {
                    Image(systemName: viewModel.isNotifyEnabled ? "bell.fill" : "bell")
                        .foregroundStyle(DSColor.brandPrimary)
                    Text("Nhận thông báo").dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { viewModel.isNotifyEnabled },
                        set: { _ in viewModel.toggleNotify() }
                    ))
                    .labelsHidden().tint(DSColor.brandPrimary)
                    .disabled(viewModel.isTogglingNotify)
                }

                Divider()

                navigationBar
            }
            .padding(DSSpacing.md)
        }
    }

    // MARK: - Reading status dropdown (similar to "Detail," but more compact)

    private var readingStatusDropdown: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isReadingStatusExpanded.toggle() }
            } label: {
                HStack {
                    Image(systemName: "bookmark.fill")
                    Text(readingStatusLabel(viewModel.readingStatus))
                    Spacer()
                    Image(systemName: isReadingStatusExpanded ? "chevron.up" : "chevron.down")
                }
                .dsFont(.subheadline).fontWeight(.semibold)
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.vertical, DSSpacing.xs)
                .padding(.horizontal, DSSpacing.md)
                .frame(maxWidth: .infinity)
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
                                Text(readingStatusLabel(status)).dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                if viewModel.readingStatus == status {
                                    Image(systemName: "checkmark").foregroundStyle(DSColor.brandPrimary)
                                }
                            }
                            .padding(.vertical, DSSpacing.sm).padding(.horizontal, DSSpacing.md)
                        }
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

    // MARK: - Navigation bar (prev / chapter picker / next + home / favorite)

    private var navigationBar: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                navCircleButton(icon: "arrow.left", isEnabled: viewModel.hasPreviousChapter) {
                    viewModel.goToPreviousChapter()
                }

                Button {
                    viewModel.isChapterPickerPresented = true
                } label: {
                    HStack {
                        Text("Chương \(Self.chapterNumberString(viewModel.currentChapter.chapterNumber))")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .dsFont(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(DSColor.brandPrimary)
                    .padding(.vertical, DSSpacing.xs).padding(.horizontal, DSSpacing.md)
                    .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                }

                navCircleButton(icon: "arrow.right", isEnabled: viewModel.hasNextChapter) {
                    viewModel.goToNextChapter()
                }
            }

            HStack {
                Button(action: onHomeTapped) {
                    Image(systemName: "house.fill")
                        .foregroundStyle(DSColor.brandPrimary)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                }
                Spacer()
                Button { viewModel.toggleFavorite() } label: {
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: viewModel.isFavoritedByMe ? "heart.fill" : "heart")
                        Text(viewModel.isFavoritedByMe ? "Đã yêu thích" : "Yêu thích")
                    }
                    .dsFont(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.xs)
                    .background(Capsule().fill(DSColor.brandPrimary))
                }
                .disabled(viewModel.isTogglingFavorite)
            }
        }
        .confirmationDialog("Chọn chương", isPresented: $viewModel.isChapterPickerPresented, titleVisibility: .visible) {
            ForEach(viewModel.chapterPickerItems) { chapter in
                Button("Chương \(Self.chapterNumberString(chapter.chapterNumber))") {
                    viewModel.selectChapter(chapter)
                }
            }
        }
    }

    private func navCircleButton(icon: String, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(isEnabled ? DSColor.brandPrimary : DSColor.backgroundSecondary))
        }
        .disabled(!isEnabled)
    }

    // MARK: - Pages (lazy-loaded, corner-bracket framed)

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
                        AsyncImage(url: page.imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().aspectRatio(contentMode: .fit)
                            case .failure:
                                Rectangle().fill(DSColor.backgroundSecondary)
                                    .frame(height: 200)
                                    .overlay { Image(systemName: "photo").foregroundStyle(DSColor.textSecondary) }
                            default:
                                Rectangle().fill(DSColor.backgroundSecondary)
                                    .frame(height: 200)
                                    .overlay { ProgressView() }
                            }
                        }
                        .onAppear { viewModel.recordProgress(page: page.pageNumber) }
                    }
                }
            }
        }
    }

    private static func chapterNumberString(_ number: Double) -> String {
        number == number.rounded() ? String(Int(number)) : String(number)
    }
}

#Preview {
    let mock = SeriesRepositoryMock()
    return ChapterReaderView(
        seriesId: "series-1",
        chapters: [
            Chapter(id: "chapter-190", seriesId: "series-1", chapterNumber: 190, releasedAt: Date(), pageCount: 50),
            Chapter(id: "chapter-189", seriesId: "series-1", chapterNumber: 189, releasedAt: Date(), pageCount: 50)
        ],
        initialChapterId: "chapter-190",
        isFavoritedByMe: true,
        isNotifyEnabled: true,
        readingStatus: .planToRead,
        seriesRepository: mock,
        commentRepository: CommentRepositoryMock(),
        onHomeTapped: {}
    )
}
