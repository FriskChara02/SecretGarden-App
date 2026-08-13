//
//  DSTag.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 13/8/26.
//

// Used for story genres/tags, status badges ("Doujins", "Ongoing"),
// and similar small labels that appear repeatedly throughout the app.

import SwiftUI

public enum DSTagStyle {
    case filled
    case outline
}

public struct DSTag: View {
    private let text: String
    private let style: DSTagStyle
    private let color: Color

    public init(_ text: String, style: DSTagStyle = .filled, color: Color = DSColor.brandPrimary) {
        self.text = text
        self.style = style
        self.color = color
    }

    public var body: some View {
        Text(text)
            .dsFont(.caption)
            .foregroundStyle(style == .filled ? .white : color)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(
                Capsule()
                    .fill(style == .filled ? color : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: style == .outline ? 1 : 0)
            )
    }
}

#Preview("DSTag variants") {
    VStack(alignment: .leading, spacing: DSSpacing.sm) {
        HStack(spacing: DSSpacing.xs) {
            DSTag("Doujins")
            DSTag("Slice of Life", style: .outline)
            DSTag("Hoàn thành", color: DSColor.statusSuccess)
        }
    }
    .padding()
}
