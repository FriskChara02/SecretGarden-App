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
    let onRefresh: () -> Void
    let onSeriesSelected: (String) -> Void

    @State private var currentPage = 0
    private let pageSize = 3

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
        let pages = comments.chunked(into: pageSize)
        let safePage = min(currentPage, max(pages.count - 1, 0))

        return VStack(alignment: .leading, spacing: DSSpacing.sm) {
            header(pageCount: pages.count, currentPage: safePage)

            if let page = pages[safe: safePage] {
                cardContainer(page)
                    .id(safePage)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: safePage)
        .onChange(of: comments) { _, _ in currentPage = 0 }
        .task(id: pages.count) {
            guard pages.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 4_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    if currentPage >= pages.count - 1 {
                        currentPage = 0
                        onRefresh()   // After completing the 4-page cycle -> fetch a new set of comments for the first pass.
                    } else {
                        currentPage += 1
                    }
                }
            }
        }
    }

    private func header(pageCount: Int, currentPage: Int) -> some View {
        HStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.circle").font(.caption2)
                Text("Bình Luận Ngẫu Nhiên")
                    .dsFont(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Image(systemName: "diamond.circle").font(.caption2)
            }
            .foregroundStyle(DSColor.brandPrimary)

            Spacer(minLength: DSSpacing.xs)

            Button {
                currentPage_reset()
            } label: {
                Image(systemName: "shuffle")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DSColor.brandPrimary)
                    .frame(width: 28, height: 28)
                    .overlay { Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.2) }
            }

            pageArrow(systemName: "chevron.left", enabled: currentPage > 0) {
                self.currentPage = max(currentPage - 1, 0)
            }

            HStack(spacing: DSSpacing.xxs) {
                ForEach(0..<max(pageCount, 1), id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? DSColor.brandPrimary : DSColor.brandPrimaryLight)
                        .frame(width: i == currentPage ? 14 : 6, height: 6)
                }
            }

            pageArrow(systemName: "chevron.right", enabled: currentPage < pageCount - 1) {
                self.currentPage = min(currentPage + 1, pageCount - 1)
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    private func currentPage_reset() {
        currentPage = 0
        onRefresh()
    }

    private func pageArrow(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(enabled ? DSColor.brandPrimary : DSColor.textSecondary.opacity(0.3))
                .frame(width: 24, height: 24)
                .overlay { Circle().strokeBorder(DSColor.borderDefault, lineWidth: 1) }
        }
        .disabled(!enabled)
    }

    private func cardContainer(_ comments: [Comment]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(comments.enumerated()), id: \.element.id) { index, comment in
                CommentPreviewRow(comment: comment, onSeriesTapped: onSeriesSelected)
                    .padding(DSSpacing.md)
                if index < comments.count - 1 {
                    Divider().padding(.horizontal, DSSpacing.md)
                }
            }
        }
        .background(DSColor.backgroundSecondary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .strokeBorder(DSColor.brandPrimaryLight, lineWidth: 1.5)
        }
        .overlay { CornerBracketOverlay() }
        .dsShadow(.card)
        .padding(.horizontal, DSSpacing.md)
    }

    private var loadingSkeleton: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Bình Luận Ngẫu Nhiên")
                .dsFont(.title3)
                .fontWeight(.bold)
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.horizontal, DSSpacing.md)

            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(DSColor.backgroundSecondary)
                .frame(height: 140)
                .overlay { ProgressView() }
                .padding(.horizontal, DSSpacing.md)
        }
    }
}

private struct CornerBracketOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            let len: CGFloat = 14
            Group {
                bracket(from: CGPoint(x: 8, y: 8 + len), corner: CGPoint(x: 8, y: 8), to: CGPoint(x: 8 + len, y: 8))
                bracket(from: CGPoint(x: w - 8 - len, y: 8), corner: CGPoint(x: w - 8, y: 8), to: CGPoint(x: w - 8, y: 8 + len))
                bracket(from: CGPoint(x: 8, y: h - 8 - len), corner: CGPoint(x: 8, y: h - 8), to: CGPoint(x: 8 + len, y: h - 8))
                bracket(from: CGPoint(x: w - 8 - len, y: h - 8), corner: CGPoint(x: w - 8, y: h - 8), to: CGPoint(x: w - 8, y: h - 8 - len))
            }
        }
        .allowsHitTesting(false)
    }

    private func bracket(from: CGPoint, corner: CGPoint, to: CGPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: corner)
            path.addLine(to: to)
        }
        .stroke(DSColor.brandPrimary.opacity(0.6), lineWidth: 2)
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
