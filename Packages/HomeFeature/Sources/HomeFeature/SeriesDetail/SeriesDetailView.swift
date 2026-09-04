//
//  SeriesDetailView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 5/9/26.
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

                    content
                        .padding(.horizontal, DSSpacing.md)
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
