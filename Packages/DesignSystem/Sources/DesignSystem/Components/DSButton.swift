//
//  DSButton.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 13/8/26.
//

// App-wide shared button — 3 variants: primary (main button, brand background),
// outline (secondary button, border), text (link-style button, no background/border).
// No feature component should implement its own custom button for standard use cases
// (Log In, Follow, Apply...) - always use DSButton.

import SwiftUI

public enum DSButtonVariant {
    case primary
    case outline
    case text
}

public enum DSButtonSize {
    case medium
    case large

    var verticalPadding: CGFloat {
        switch self {
        case .medium: return DSSpacing.sm
        case .large: return DSSpacing.md
        }
    }

    var font: DSFontToken {
        switch self {
        case .medium: return .callout
        case .large: return .headline
        }
    }
}

public struct DSButton: View {
    private let title: String
    private let variant: DSButtonVariant
    private let size: DSButtonSize
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        variant: DSButtonVariant = .primary,
        size: DSButtonSize = .large,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(variant == .primary ? .white : DSColor.brandPrimary)
                } else {
                    Text(title)
                        .dsFont(size.font)
                }
            }
            .frame(maxWidth: variant == .text ? nil : .infinity)
            .padding(.vertical, size.verticalPadding)
        }
        .buttonStyle(DSButtonStyleImpl(variant: variant))
        .disabled(isLoading)
    }
}

// MARK: - ButtonStyle implements the visual representation for each variant

private struct DSButtonStyleImpl: ButtonStyle {
    let variant: DSButtonVariant
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(backgroundView)
            .overlay(borderView)
            .opacity(configuration.isPressed ? 0.7 : (isEnabled ? 1 : 0.4))
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary: return .white
        case .outline, .text: return DSColor.brandPrimary
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch variant {
        case .primary:
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(DSColor.brandPrimary)
        case .outline, .text:
            Color.clear
        }
    }

    @ViewBuilder
    private var borderView: some View {
        if variant == .outline {
            RoundedRectangle(cornerRadius: DSRadius.md)
                .stroke(DSColor.brandPrimary, lineWidth: 1.5)
        }
    }
}

#Preview("DSButton variants") {
    VStack(spacing: DSSpacing.md) {
        DSButton("Đăng nhập", variant: .primary) {}
        DSButton("Đăng nhập bằng Google", variant: .outline) {}
        DSButton("Khôi phục mật khẩu?", variant: .text, size: .medium) {}
        DSButton("Đang xử lý...", variant: .primary, isLoading: true) {}
        DSButton("Disabled", variant: .primary) {}
            .disabled(true)
    }
    .padding()
}
