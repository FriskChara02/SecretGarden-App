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
    let onSeriesSelected: (String) -> Void

    public init(
        seriesId: String,
        initialChapterId: String,
        seriesRepository: SeriesRepositoryProtocol,
        commentRepository: CommentRepositoryProtocol,
        onHomeTapped: @escaping () -> Void,
        onSeriesSelected: @escaping (String) -> Void = { _ in }
    ) {
        _viewModel = StateObject(wrappedValue: ChapterReaderViewModel(
            seriesId: seriesId,
            initialChapterId: initialChapterId,
            seriesRepository: seriesRepository,
            commentRepository: commentRepository
        ))
        self.onHomeTapped = onHomeTapped
        self.onSeriesSelected = onSeriesSelected
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
        .onAppear { viewModel.onAppear() }
        .sheet(isPresented: $viewModel.isMenuPresented) {
            ReaderMenuView(viewModel: viewModel, onHomeTapped: onHomeTapped)
        }
        .sheet(isPresented: $viewModel.isCommentsOverlayPresented) {
            ChapterCommentsOverlayView(viewModel: viewModel)
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

    private func readerScrollContent(_ series: Series) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                readerHeader(title: series.title)
                infoCard(title: series.title)
                    .padding(.horizontal, DSSpacing.md)
                pagesSection
                    .padding(.horizontal, DSSpacing.md)
                recapCard(series)
                    .padding(.horizontal, DSSpacing.md)

                DSSectionDivider()

                groupOtherSeriesSection
                    .padding(.horizontal, DSSpacing.md)
            }
            .padding(.bottom, DSSpacing.xl)
        }
    }

    // MARK: - Header (smaller than GardenHeaderView — features a circular avatar and a hamburger menu instead of a large logo)

    private func readerHeader(title: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Circle().fill(DSColor.brandPrimary)
                .frame(width: 36, height: 36)
                .overlay { Image(systemName: "leaf.fill").foregroundStyle(.white).font(.system(size: 16)) }

            Text(title)
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

    // MARK: - Info Card

    private func infoCard(title: String) -> some View {
        DSDecorativeCard(showCornerBrackets: false) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(title)
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
    
    // MARK: - End-of-chapter recap card

    private func recapCard(_ series: Series) -> some View {
        DSDecorativeCard {
            HStack(alignment: .top, spacing: DSSpacing.md) {
                AsyncImage(url: series.coverURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(DSColor.backgroundSecondary)
                    }
                }
                .frame(width: 64, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))

                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(series.title).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary).lineLimit(2)
                    if let author = series.author {
                        Text("Tác giả: \(author.name)").dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    }
                    Button { viewModel.toggleFavorite() } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            Image(systemName: viewModel.isFavoritedByMe ? "heart.fill" : "heart")
                            Text(viewModel.isFavoritedByMe ? "Đã yêu thích" : "Yêu thích")
                        }
                        .dsFont(.caption).fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DSSpacing.sm).padding(.vertical, 4)
                        .background(Capsule().fill(DSColor.brandPrimary))
                    }
                    .disabled(viewModel.isTogglingFavorite)
                }
                Spacer()
            }
            .padding(DSSpacing.md)
        }
    }

    // MARK: - "Group Others"

    @ViewBuilder
    private var groupOtherSeriesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Image(systemName: "diamond.fill").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
                Text("Khác của nhóm").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
                Image(systemName: "diamond.fill").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
            }

            switch viewModel.groupOtherSeriesState {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.md)
            case .failed:
                Text("Không tải được nội dung.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
            case .loaded(let items) where items.isEmpty:
                Text("Chưa có truyện khác của nhóm.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
            case .loaded(let items):
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DSSpacing.sm) {
                        ForEach(items) { item in
                            SeriesCardView(data: SeriesCardMapper.map(item), layout: .grid) {
                                onSeriesSelected(item.id)
                            }
                            .frame(width: 140, height: 220)
                        }
                    }
                }
            }
        }
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
