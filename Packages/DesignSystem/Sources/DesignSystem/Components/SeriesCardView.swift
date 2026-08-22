//
//  SeriesCardView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 13/8/26.
//

// Card displaying a single story — shared across Home, Search, Category and Favorites.
// This component has NO knowledge of the `Series` struct (CoreModels) — it only accepts
// raw `SeriesCardData`, adhering to the Design System principle of absolute independence.

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
    public let metaInfo: String        // e.g. "Updated 1 hour ago"
    public let isCompleted: Bool

    public init(
        id: String,
        coverURL: URL?,
        title: String,
        authorName: String? = nil,
        groupName: String? = nil,
        genres: [String] = [],
        metaInfo: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.coverURL = coverURL
        self.title = title
        self.authorName = authorName
        self.groupName = groupName
        self.genres = genres
        self.metaInfo = metaInfo
        self.isCompleted = isCompleted
    }
}

public struct SeriesCardView: View {
    private let data: SeriesCardData
    private let layout: SeriesCardLayout
    private let onTap: (() -> Void)?

    @State private var isPreviewShowing = false
    @State private var pressTask: Task<Void, Never>?

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
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            fixedRatioCoverImage(ratio: 2 / 3)
                .overlay(alignment: .topLeading) {
                    if let firstGenre = data.genres.first {
                        DSTag(firstGenre).padding(DSSpacing.xs)
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if data.isCompleted {
                        DSTag("Hoàn thành", color: DSColor.statusSuccess).padding(DSSpacing.xs)
                    }
                }

            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "clock.arrow.circlepath").font(.caption2)
                Text(data.metaInfo)
            }
            .dsFont(DSFontToken.caption)
            .foregroundStyle(DSColor.textSecondary)
            .lineLimit(1)

            Text(data.title)
                .dsFont(DSFontToken.title3)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)

            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: "bookmark.fill").foregroundStyle(Color.orange)
                Text(data.isCompleted ? "Hoàn thành" : "Đang cập nhật")
            }
            .dsFont(DSFontToken.subheadline)
            .foregroundStyle(DSColor.textPrimary)
            .padding(.top, DSSpacing.xxs)
        }
        .padding(DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .strokeBorder(cardBorderGradient, lineWidth: 2)
        }
    }

    // MARK: - List layout

    private var listBody: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            fixedRatioCoverImage(ratio: 2 / 3)
                .frame(width: 88, height: 132)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "clock.arrow.circlepath").font(.caption2)
                    Text(data.metaInfo)
                }
                .dsFont(DSFontToken.caption)
                .foregroundStyle(DSColor.textSecondary)

                Text(data.title)
                    .dsFont(DSFontToken.title3)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                if let authorName = data.authorName {
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "person.fill").font(.caption2)
                        // TODO: DesignSystem does not yet have DSColor.info — using the system's Color.blue for now.
                        Text("Tác giả: \(authorName)").foregroundStyle(Color.blue)
                    }
                    .dsFont(DSFontToken.caption)
                }

                if let groupName = data.groupName {
                    HStack(spacing: DSSpacing.xxs) {
                        Image(systemName: "flag.fill").font(.caption2).foregroundStyle(DSColor.brandPrimary)
                        Text("Nhóm dịch: \(groupName)").foregroundStyle(DSColor.brandPrimary)
                    }
                    .dsFont(DSFontToken.caption)
                }

                if !data.genres.isEmpty {
                    genreTagsView(maxVisible: 4)
                        .padding(.top, DSSpacing.xxs)
                }

                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: "bookmark.fill").foregroundStyle(Color.orange)
                    Text(data.isCompleted ? "Hoàn thành" : "Đang cập nhật")
                }
                .dsFont(DSFontToken.subheadline)
                .foregroundStyle(DSColor.textPrimary)
                .padding(.top, DSSpacing.xxs)
            }

            Spacer(minLength: 0)
        }
        .padding(DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.md)
                .strokeBorder(cardBorderGradient, lineWidth: 1.5)
        }
        .overlay(alignment: .trailing) {
            if isPreviewShowing {
                hoverPreview
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        // Mouse/trackpad (Simulator, iPad Pointer): hover to show the preview immediately—no need to hold
        .onHover { hovering in
            guard pressTask == nil else { return } // Currently in a press-and-hold state -> prevent hover effects from overlapping
            withAnimation(.easeInOut(duration: 0.15)) {
                isPreviewShowing = hovering
            }
        }
        // Real touch interaction (iPhone): QUICK TAP = open story, HOLD = view preview, RELEASE AFTER HOLDING = hide preview only (do NOT open story).
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard pressTask == nil, !isPreviewShowing else { return }
                    pressTask = Task {
                        try? await Task.sleep(nanoseconds: 350_000_000) // threshold distinguishing between "quick tap" and "hold"
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            withAnimation(.easeInOut(duration: 0.15)) { isPreviewShowing = true }
                        }
                    }
                }
                .onEnded { _ in
                    let wasShowingPreview = isPreviewShowing
                    pressTask?.cancel()
                    pressTask = nil
                    withAnimation(.easeInOut(duration: 0.15)) { isPreviewShowing = false }

                    // Only navigate if this is a quick tap (before the preview appears).
                    // If the user holds long enough to see the preview, releasing their finger
                    // should ONLY hide the preview, not open the story —
                    // adhering to the requirement that "releasing the hold returns things to normal."
                    if !wasShowingPreview {
                        onTap?()
                    }
                }
        )
    }

    // MARK: - Hover preview (List view only, works only with mouse/trackpad/pointer)

    private var hoverPreview: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: data.coverURL) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle().fill(DSColor.backgroundSecondary)
                }
            }
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
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
        .frame(width: 170, height: 230)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .dsShadow(.floating)
        .offset(x: 0)   // This place will be changed in the future.
    }

    // MARK: - Genre tags (flow + overflow "+N")

    private func genreTagsView(maxVisible: Int) -> some View {
        let visible = Array(data.genres.prefix(maxVisible))
        let remaining = data.genres.count - visible.count

        return FlowLayout(spacing: DSSpacing.xs) {
            ForEach(visible, id: \.self) { genre in
                DSTag(genre)
            }
            if remaining > 0 {
                DSTag("+\(remaining)", color: DSColor.brandPrimary)
            }
        }
    }

    // MARK: - Gradient border

    private var cardBorderGradient: LinearGradient {
        LinearGradient(
            colors: [DSColor.brandPrimary, DSColor.brandPrimary.opacity(0.15)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Cover image (height forced via GeometryReader — fixing height misalignment)

    @ViewBuilder
    private func fixedRatioCoverImage(ratio: CGFloat) -> some View {
        GeometryReader { proxy in
            AsyncImage(url: data.coverURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(DSColor.backgroundSecondary)
                        .overlay { ProgressView().tint(DSColor.textSecondary) }
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(DSColor.backgroundSecondary)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(DSColor.textSecondary.opacity(0.5))
                        }
                @unknown default:
                    Rectangle().fill(DSColor.backgroundSecondary)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.width / ratio)
            .clipped()
        }
        .aspectRatio(ratio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}

#Preview("SeriesCardView - Grid") {
    let sample = SeriesCardData(
        id: "1", coverURL: nil, title: "Ngày Tôi Quyết Định Yêu Cậu Ấy Lần Nữa",
        authorName: "Yasaka Shuu", groupName: "Cánh Tập Dịch",
        genres: ["Comedy", "Romance", "School Life", "Yuri", "Slice of Life"],
        metaInfo: "Cập nhật 1 giờ trước", isCompleted: true
    )
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
        SeriesCardView(data: sample, layout: .grid)
        SeriesCardView(data: sample, layout: .grid)
    }
    .padding()
}

#Preview("SeriesCardView - List") {
    let sample = SeriesCardData(
        id: "1", coverURL: nil, title: "Ngày Tôi Quyết Định Yêu Cậu Ấy Lần Nữa",
        authorName: "Yasaka Shuu", groupName: "Cánh Tập Dịch",
        genres: ["Comedy", "Romance", "School Life", "Yuri", "Slice of Life"],
        metaInfo: "Cập nhật 1 giờ trước"
    )
    VStack(spacing: DSSpacing.md) {
        SeriesCardView(data: sample, layout: .list)
        SeriesCardView(data: sample, layout: .list)
    }
    .padding()
}
