//
//  ContinueReadingSection.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// "Continue Reading" section — horizontal carousel; each card
// consists of a cover image + reading progress; clicking opens the story directly.
//
// DISPLAY LOGIC (specified here as this is the only section with special visibility conditions):
// - .idle / .loading  -> show skeleton loading (show nothing if .idle to avoid flickering)
// - .loaded([])       -> hide section completely (no reading history — "display only if user is logged in & has reading history")
// - .loaded([...])    -> show carousel
// - .loaded(error)    -> hide section completely (including 401 errors for unlogged-in users or other network errors) —
//                        DO NOT show an Alert/Error here; a failure in a secondary section
//                        should not disrupt the Home page experience (adhering to the "partial failure" principle).
//                        "Random Comments" or "Latest Updates" will display a DSErrorView more prominently, as they are primary sections.

import CoreModels
import DesignSystem
import SwiftUI
import CoreArchitecture

struct ContinueReadingSection: View {
    let state: LoadableState<[ContinueReadingItem]>
    let onItemTapped: (String) -> Void

    var body: some View {
        switch state {
        case .idle:
            EmptyView()

        case .loading:
            loadingSkeleton

        case .loaded(let items) where items.isEmpty:
            EmptyView()

        case .loaded(let items):
            content(items)

        case .failed:
            EmptyView()
        }
    }

    private var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionTitle
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.md) {
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .fill(DSColor.backgroundSecondary)
                            .frame(width: 260, height: 120)
                            .overlay { ProgressView() }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    private func content(_ items: [ContinueReadingItem]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionTitle
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DSSpacing.md) {
                    ForEach(items) { item in
                        ContinueReadingCard(item: item)
                            .onTapGesture { onItemTapped(item.series.id) }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    private var sectionTitle: some View {
        Text("Tiếp tục đọc")
            .dsFont(.title3)
            .foregroundStyle(DSColor.textPrimary)
            .padding(.horizontal, DSSpacing.md)
    }
}

private struct ContinueReadingCard: View {
    let item: ContinueReadingItem

    private var progress: Double {
        guard item.totalPages > 0 else { return 0 }
        return Double(item.lastPageRead) / Double(item.totalPages)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: item.series.coverURL) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Rectangle().fill(DSColor.backgroundSecondary)
                }
            }
            .frame(width: 260, height: 120)
            .clipped()
            .overlay(Color.black.opacity(0.35))

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(item.series.title)
                    .dsFont(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("Chương \(formattedChapterNumber) · Trang \(item.lastPageRead)/\(item.totalPages)")
                    .dsFont(.caption)
                    .foregroundStyle(.white.opacity(0.85))

                ProgressView(value: progress)
                    .tint(DSColor.brandPrimary)
                    .frame(width: 200)
            }
            .padding(DSSpacing.sm)
        }
        .frame(width: 260, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
    }

    private var formattedChapterNumber: String {
        item.chapter.chapterNumber.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", item.chapter.chapterNumber)
            : String(item.chapter.chapterNumber)
    }
}

#Preview("Có dữ liệu") {
    ContinueReadingSection(
        state: .loaded([
            ContinueReadingItem(
                id: "1",
                series: Series(
                    id: "s1", title: "Ánh Trăng Bên Em", type: .manga,
                    coverURL: URL(string: "https://picsum.photos/seed/s1/400/560")!,
                    description: "", status: .ongoing, updatedAt: Date()
                ),
                chapter: Chapter(id: "c1", seriesId: "s1", chapterNumber: 12, releasedAt: Date()),
                lastPageRead: 14,
                totalPages: 22
            )
        ]),
        onItemTapped: { _ in }
    )
}

#Preview("Loading") {
    ContinueReadingSection(state: .loading, onItemTapped: { _ in })
}
