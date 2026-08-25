//
//  SeriesCardView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 13/8/26.
//

// Card displaying a single story — shared across Home, Search, Category and Favorites.

import SwiftUI

public enum SeriesCardLayout {
    case grid
    case list
}

public struct SeriesCardData: Identifiable, Equatable {
    public let id: String
    public let coverURL: URL?
    public let title: String
    public let authorName: String?
    public let groupName: String?
    public let genres: [String]
    public let metaInfo: String
    public let chapterLabel: String?
    public let isCompleted: Bool

    public init(
        id: String,
        coverURL: URL?,
        title: String,
        authorName: String? = nil,
        groupName: String? = nil,
        genres: [String] = [],
        metaInfo: String,
        chapterLabel: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.coverURL = coverURL
        self.title = title
        self.authorName = authorName
        self.groupName = groupName
        self.genres = genres
        self.metaInfo = metaInfo
        self.chapterLabel = chapterLabel
        self.isCompleted = isCompleted
    }

    /// The final display string for the bookmark line - prioritizing the actual chapter, falling back to the status.
    var bookmarkLine: String {
        chapterLabel ?? (isCompleted ? "Hoàn thành" : "Đang cập nhật")
    }
}

public struct SeriesCardView: View {
    private let data: SeriesCardData
    private let layout: SeriesCardLayout
    private let onTap: (() -> Void)?

    @State private var isRevealed = false
    @State private var didLongPress = false
    @State private var autoDismissTask: Task<Void, Never>?

    private let gridCardAspectRatio: CGFloat = 0.62
    private let listCardHeight: CGFloat = 160

    public init(data: SeriesCardData, layout: SeriesCardLayout = .grid, onTap: (() -> Void)? = nil) {
        self.data = data
        self.layout = layout
        self.onTap = onTap
    }

    public var body: some View {
        switch layout {
        case .grid: gridBody
        case .list: listBody
        }
    }

    // MARK: - Grid layout

    private var gridBody: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                coverImageFill(width: proxy.size.width, height: proxy.size.height)

                if isRevealed {
                    revealedOverlayGrid.transition(.opacity)
                } else {
                    normalOverlayGrid.transition(.opacity)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .overlay(alignment: .topLeading) {
                if let firstGenre = data.genres.first, !isRevealed {
                    DSTag(firstGenre, color: DSColor.tagNeutral).padding(DSSpacing.xs)
                }
            }
        }
        .aspectRatio(gridCardAspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.lg).strokeBorder(cardBorderGradient, lineWidth: 2)
        }
        .animation(.easeInOut(duration: 0.25), value: isRevealed)
        .revealInteractions(isRevealed: $isRevealed, didLongPress: $didLongPress, autoDismissTask: $autoDismissTask, onTap: onTap)
    }

    private var normalOverlayGrid: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "clock.arrow.circlepath").font(.caption2)
                Text(data.metaInfo)
            }
            .dsFont(DSFontToken.caption)
            .foregroundStyle(DSColor.textSecondary)
            .lineLimit(1)

            Text(data.title)
                .dsFont(DSFontToken.headline)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)

            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "bookmark.fill").foregroundStyle(DSColor.bookmarkAccent)
                Text(data.bookmarkLine)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .dsFont(DSFontToken.footnote)
            .foregroundStyle(DSColor.textPrimary)
        }
        .padding(DSSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DSColor.backgroundPrimary)
    }

    private var revealedOverlayGrid: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(data.title)
                    .dsFont(DSFontToken.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if !data.genres.isEmpty {
                    genreTagsView(maxVisible: 3)
                }
            }
            .padding(DSSpacing.sm)
        }
    }

    // MARK: - List layout

    private var listBody: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                if isRevealed {
                    coverImageFill(width: proxy.size.width, height: proxy.size.height)
                        .transition(.opacity)
                    LinearGradient(
                        colors: [
                            DSColor.backgroundPrimary.opacity(0.97),
                            DSColor.backgroundPrimary.opacity(0.85),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .transition(.opacity)
                }

                HStack(alignment: .top, spacing: DSSpacing.sm) {
                    if !isRevealed {
                        fixedRatioCoverImage(ratio: 2 / 3)
                            .frame(width: 88, height: 132)
                    }
                    listTextContent
                    Spacer(minLength: 0)
                }
                .padding(DSSpacing.sm)
            }
        }
        .frame(height: listCardHeight)
        .background(DSColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.md).strokeBorder(cardBorderGradient, lineWidth: 1.5)
        }
        .animation(.easeInOut(duration: 0.25), value: isRevealed)
        .revealInteractions(isRevealed: $isRevealed, didLongPress: $didLongPress, autoDismissTask: $autoDismissTask, onTap: onTap)
    }

    private var listTextContent: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "clock.arrow.circlepath").font(.caption2)
                Text(data.metaInfo)
            }
            .dsFont(DSFontToken.caption)
            .foregroundStyle(DSColor.textSecondary)

            Text(data.title)
                .dsFont(DSFontToken.headline)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)

            if let authorName = data.authorName {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "person")
                        .fontWeight(.bold)
                        .foregroundStyle(DSColor.info)
                    twoPartText(
                        token: .caption,
                        prefix: "Tác giả: ", prefixBold: true, prefixColor: DSColor.textPrimary,
                        value: authorName, valueBold: true, valueColor: DSColor.info
                    )
                }
            }

            if let groupName = data.groupName {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "flag.fill")
                        .fontWeight(.bold)
                        .foregroundStyle(DSColor.brandPrimary)
                    twoPartText(
                        token: .caption,
                        prefix: "Nhóm dịch: ", prefixBold: true, prefixColor: DSColor.textPrimary,
                        value: groupName, valueBold: true, valueColor: DSColor.brandPrimary.opacity(0.75)
                    )
                }
            }

            if !data.genres.isEmpty {
                genreTagsView(maxVisible: 4)
            }

            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "bookmark.fill").foregroundStyle(DSColor.bookmarkAccent)
                Text(data.bookmarkLine)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColor.chapterLabelText)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .dsFont(DSFontToken.footnote)
        }
    }

    // MARK: - Genre tags (flow + overflow "+N" gradient badge)

    private func genreTagsView(maxVisible: Int) -> some View {
        let visible = Array(data.genres.prefix(maxVisible))
        let remaining = data.genres.count - visible.count

        return FlowLayout(spacing: DSSpacing.xs) {
            ForEach(visible, id: \.self) { genre in
                DSTag(genre, color: DSColor.tagNeutral)
            }
            if remaining > 0 {
                overflowTag(remaining)
            }
        }
    }

    private func overflowTag(_ count: Int) -> some View {
        Text("+\(count)")
            .dsFont(DSFontToken.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [DSColor.brandPrimaryLight,
                                 DSColor.brandPrimary,
                                 DSColor.brandPrimary,
                                 DSColor.brandPrimary],
                        startPoint: .bottomLeading,
                        endPoint: .trailing
                    )
                )
            )
    }

    // MARK: - Shared 2-part text helper (label bold/color different from value bold/color)

    private func twoPartText(
        token: DSFontToken,
        prefix: String, prefixBold: Bool, prefixColor: Color,
        value: String, valueBold: Bool, valueColor: Color
    ) -> some View {
        let baseFont = DSFont.font(token)
        return (
            Text(prefix).font(prefixBold ? baseFont.bold() : baseFont).foregroundColor(prefixColor)
            + Text(value).font(valueBold ? baseFont.bold() : baseFont).foregroundColor(valueColor)
        )
    }

    // MARK: - Gradient border

    private var cardBorderGradient: LinearGradient {
        LinearGradient(
            colors: [DSColor.brandPrimary, DSColor.brandPrimaryLight],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Cover image helpers

    /// Image covering the ENTIRE provided frame (used as a persistent background layer for both states).
    @ViewBuilder
    private func coverImageFill(width: CGFloat, height: CGFloat) -> some View {
        AsyncImage(url: data.coverURL) { phase in
            switch phase {
            case .empty:
                Rectangle().fill(DSColor.backgroundSecondary).overlay { ProgressView() }
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                Rectangle().fill(DSColor.backgroundSecondary)
                    .overlay { Image(systemName: "photo").foregroundStyle(DSColor.textSecondary.opacity(0.5)) }
            @unknown default:
                Rectangle().fill(DSColor.backgroundSecondary)
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }

    /// Fixed-aspect-ratio thumbnail image (used for list thumbnails in the default state).
    @ViewBuilder
    private func fixedRatioCoverImage(ratio: CGFloat) -> some View {
        GeometryReader { proxy in
            coverImageFill(width: proxy.size.width, height: proxy.size.width / ratio)
        }
        .aspectRatio(ratio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
    }
}

// MARK: - Shared gesture: hover (mouse/trackpad) or long-press (touch, without blocking scrolling).
// Long-press automatically dismisses the reveal after 4 seconds if the user holds their finger still,
// so they aren't required to remember to lift it.

private struct RevealInteractionModifier: ViewModifier {
    @Binding var isRevealed: Bool
    @Binding var didLongPress: Bool
    @Binding var autoDismissTask: Task<Void, Never>?
    let onTap: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                guard !didLongPress else { return }
                withAnimation(.easeInOut(duration: 0.15)) { isRevealed = hovering }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.35, maximumDistance: 15)
                    .onEnded { _ in
                        didLongPress = true
                        withAnimation(.easeInOut(duration: 0.15)) { isRevealed = true }
                        scheduleAutoDismiss()
                    }
            )
            .onTapGesture {
                if didLongPress {
                    dismissReveal()
                } else {
                    onTap?()
                }
            }
    }

    private func scheduleAutoDismiss() {
        autoDismissTask?.cancel()
        autoDismissTask = Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000) // 4s
            guard !Task.isCancelled else { return }
            await MainActor.run { dismissReveal() }
        }
    }

    private func dismissReveal() {
        autoDismissTask?.cancel()
        autoDismissTask = nil
        didLongPress = false
        withAnimation(.easeInOut(duration: 0.15)) { isRevealed = false }
    }
}

private extension View {
    func revealInteractions(
        isRevealed: Binding<Bool>,
        didLongPress: Binding<Bool>,
        autoDismissTask: Binding<Task<Void, Never>?>,
        onTap: (() -> Void)?
    ) -> some View {
        modifier(RevealInteractionModifier(
            isRevealed: isRevealed,
            didLongPress: didLongPress,
            autoDismissTask: autoDismissTask,
            onTap: onTap
        ))
    }
}

#Preview("SeriesCardView - Grid") {
    let sample = SeriesCardData(
        id: "1", coverURL: nil, title: "Bắt nạt mình đi mà, nữ phản diện ơi!",
        authorName: "Chise, Ciweimao", groupName: "Knights of Yuri",
        genres: ["Bullying", "Comedy", "Fantasy", "Full Color"],
        metaInfo: "khoảng 1 giờ trước", isCompleted: false
    )
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
        SeriesCardView(data: sample, layout: .grid)
        SeriesCardView(data: sample, layout: .grid)
    }
    .padding()
}

#Preview("SeriesCardView - List") {
    let sample = SeriesCardData(
        id: "1", coverURL: nil, title: "Bắt nạt mình đi mà, nữ phản diện ơi!",
        authorName: "Chise, Ciweimao", groupName: "Knights of Yuri",
        genres: ["Bullying", "Comedy", "Fantasy", "Full Color"],
        metaInfo: "khoảng 1 giờ trước"
    )
    VStack(spacing: DSSpacing.md) {
        SeriesCardView(data: sample, layout: .list)
        SeriesCardView(data: sample, layout: .list)
    }
    .padding()
}
