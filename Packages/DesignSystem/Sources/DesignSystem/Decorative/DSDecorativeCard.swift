//
//  DSDecorativeCard.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 4/9/26.
//

// Rounded-corner card used for all "content blocks" on the Detail/Reader pages (story info, chapter list,
// related content, comments, ...) — white background, decorative quote-mark style at the four corners,
// with a SUBTLE WHITE BORDER specifically for dark mode.

import SwiftUI

public struct DSDecorativeCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let content: Content
    private let cornerRadius: CGFloat
    private let showCornerBrackets: Bool

    public init(
        cornerRadius: CGFloat = DSRadius.lg,
        showCornerBrackets: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.showCornerBrackets = showCornerBrackets
        self.content = content()
    }

    public var body: some View {
        content
            .background(DSColor.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                // Only dark mode features a faint white border
                // light mode does not require, as the white background stands out sufficiently against the subtle pattern
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
            }
            .overlay {
                if showCornerBrackets { cornerBrackets }
            }
    }

    private var cornerBrackets: some View {
        GeometryReader { proxy in
            let inset: CGFloat = 10
            let length: CGFloat = 14
            ForEach(0..<4) { index in
                CornerBracketShape()
                    .stroke(DSColor.brandPrimary.opacity(0.55), lineWidth: 1.5)
                    .frame(width: length, height: length)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .position(cornerPosition(index: index, size: proxy.size, inset: inset, length: length))
            }
        }
        .allowsHitTesting(false)
    }

    private func cornerPosition(index: Int, size: CGSize, inset: CGFloat, length: CGFloat) -> CGPoint {
        let half = length / 2
        switch index {
        case 0: return CGPoint(x: inset + half, y: inset + half)                              // top-left
        case 1: return CGPoint(x: size.width - inset - half, y: inset + half)                 // top-right
        case 2: return CGPoint(x: size.width - inset - half, y: size.height - inset - half)    // bottom-right
        default: return CGPoint(x: inset + half, y: size.height - inset - half)                // bottom-left
        }
    }
}

/// The "⌐" shape - 2 perpendicular line segments, used as a decorative corner bracket, rotate it 90° x4 times to cover all 4 corners.
private struct CornerBracketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

#Preview {
    DSDecorativeCard {
        Text("Nội dung mẫu bên trong card")
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity)
    }
    .padding()
}

#Preview("Dark mode") {
    DSDecorativeCard {
        Text("Nội dung mẫu bên trong card")
            .padding(DSSpacing.lg)
            .frame(maxWidth: .infinity)
    }
    .padding()
    .preferredColorScheme(.dark)
}
