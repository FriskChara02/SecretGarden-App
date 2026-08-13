//
//  DSLoadingView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 13/8/26.
//

// Displays loading state. There are two types: a simple spinner (for minor actions,
// e.g., button clicks) and a skeleton (for lists/cards — offers a smoother experience
// than a spinner against a blank screen).

import SwiftUI

public enum DSLoadingStyle {
    case spinner
    case skeleton(rows: Int)
}

public struct DSLoadingView: View {
    private let style: DSLoadingStyle
    private let message: String?

    public init(style: DSLoadingStyle = .spinner, message: String? = nil) {
        self.style = style
        self.message = message
    }

    public var body: some View {
        switch style {
        case .spinner:
            VStack(spacing: DSSpacing.sm) {
                ProgressView()
                    .tint(DSColor.brandPrimary)
                if let message {
                    Text(message)
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .skeleton(let rows):
            VStack(spacing: DSSpacing.md) {
                ForEach(0..<rows, id: \.self) { _ in
                    skeletonRow
                }
            }
        }
    }

    private var skeletonRow: some View {
        HStack(spacing: DSSpacing.sm) {
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(DSColor.backgroundSecondary)
                .frame(width: 72, height: 96)
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(DSColor.backgroundSecondary)
                    .frame(height: 16)
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(DSColor.backgroundSecondary)
                    .frame(width: 120, height: 12)
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

// MARK: - Shimmer effect (a "light-sweep" effect for skeletons)

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.3

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, Color.white.opacity(0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase * 400)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1.3
                }
            }
    }
}

private extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview("DSLoadingView") {
    VStack(spacing: DSSpacing.xl) {
        DSLoadingView(style: .spinner, message: "Đang tải danh sách yêu thích...")
            .frame(height: 100)
        DSLoadingView(style: .skeleton(rows: 3))
    }
    .padding()
}
