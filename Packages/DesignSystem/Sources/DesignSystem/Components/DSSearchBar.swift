//
//  DSSearchBar.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 29/8/26.
//

// Pill-shaped search bar: magnifying glass icon + TextField + quick-clear "X" button (when content is present),
// accompanied by a separate "Search" button on the right (for explicit submission).

import SwiftUI

public struct DSSearchBar: View {
    @Binding private var text: String
    private let placeholder: String
    private let onSubmit: () -> Void

    public init(text: Binding<String>, placeholder: String = "Tìm kiếm", onSubmit: @escaping () -> Void) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(DSColor.textSecondary)

                TextField(placeholder, text: $text)
                    .dsFont(.body)
                    .foregroundStyle(DSColor.textPrimary)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(DSColor.textSecondary.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(Capsule().fill(DSColor.backgroundSecondary))

            Button("Tìm", action: onSubmit)
                .dsFont(.headline)
                .foregroundStyle(DSColor.brandPrimary)
        }
    }
}

#Preview("DSSearchBar") {
    VStack(spacing: DSSpacing.lg) {
        DSSearchBar(text: .constant(""), onSubmit: {})
        DSSearchBar(text: .constant("Đồ ăn của ta thật đáng yêu"), onSubmit: {})
    }
    .padding()
}
