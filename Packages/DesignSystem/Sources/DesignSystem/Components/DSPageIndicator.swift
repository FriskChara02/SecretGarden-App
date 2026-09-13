//
//  DSPageIndicator.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 13/9/26.
//

// Numeric pagination (1 2 3 4 … N) — for author/artist story lists.
// Automatically abbreviates with "…" when the total number of pages is large, always displays the first and last pages, plus pages adjacent to the current one.

import SwiftUI

public struct DSPageIndicator: View {
    private let currentPage: Int
    private let totalPages: Int
    private let onPageSelected: (Int) -> Void

    public init(currentPage: Int, totalPages: Int, onPageSelected: @escaping (Int) -> Void) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.onPageSelected = onPageSelected
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            arrowButton(systemImage: "chevron.left", enabled: currentPage > 1) {
                onPageSelected(currentPage - 1)
            }

            ForEach(visibleItems, id: \.self) { item in
                switch item {
                case .page(let number):
                    pageButton(number)
                case .ellipsis:
                    Text("…").dsFont(.callout).foregroundStyle(DSColor.textSecondary)
                }
            }

            arrowButton(systemImage: "chevron.right", enabled: currentPage < totalPages) {
                onPageSelected(currentPage + 1)
            }
        }
    }

    private enum PageItem: Hashable {
        case page(Int)
        case ellipsis
    }

    /// Always visible: first page, last page, currentPage, and pages adjacent to currentPage - insert "…" in the gaps.
    private var visibleItems: [PageItem] {
        guard totalPages > 7 else {
            return (1...max(totalPages, 1)).map { .page($0) }
        }
        var pages = Set([1, totalPages, currentPage])
        if currentPage > 1 { pages.insert(currentPage - 1) }
        if currentPage < totalPages { pages.insert(currentPage + 1) }

        let sorted = pages.sorted()
        var result: [PageItem] = []
        for (index, page) in sorted.enumerated() {
            if index > 0, page - sorted[index - 1] > 1 {
                result.append(.ellipsis)
            }
            result.append(.page(page))
        }
        return result
    }

    private func pageButton(_ number: Int) -> some View {
        Button { onPageSelected(number) } label: {
            Text("\(number)")
                .dsFont(.callout)
                .fontWeight(number == currentPage ? .bold : .regular)
                .foregroundStyle(number == currentPage ? .white : DSColor.brandPrimary)
                .frame(width: 36, height: 36)
                .background {
                    if number == currentPage {
                        Circle().fill(DSColor.brandPrimary)
                    } else {
                        Circle().strokeBorder(DSColor.borderDefault, lineWidth: 1)
                    }
                }
        }
    }

    private func arrowButton(systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundStyle(enabled ? DSColor.brandPrimary : DSColor.textSecondary.opacity(0.4))
                .frame(width: 36, height: 36)
                .background(Circle().strokeBorder(DSColor.borderDefault, lineWidth: 1))
        }
        .disabled(!enabled)
    }
}

#Preview {
    VStack(spacing: DSSpacing.lg) {
        DSPageIndicator(currentPage: 1, totalPages: 18) { _ in }
        DSPageIndicator(currentPage: 9, totalPages: 18) { _ in }
        DSPageIndicator(currentPage: 3, totalPages: 5) { _ in }
    }
    .padding()
}
