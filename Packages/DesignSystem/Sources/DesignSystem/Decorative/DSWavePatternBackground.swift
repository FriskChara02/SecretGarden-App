//
//  DSWavePatternBackground.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 4/9/26.
//

// Static background pattern (East Asian wave style, "seigaiha") — repeated across sections.
// Prioritize loading the "DecorativeWavePattern" image from Assets.xcassets.
// If the image is missing or fails to load, automatically fall back to a Canvas-drawn vector — ensuring no blank screens appear.

import SwiftUI

public struct DSWavePatternBackground: View {
    private let lineColor: Color
    private let backgroundColor: Color
    private let tileSize: CGFloat

    public init(
        lineColor: Color = DSColor.borderDefault.opacity(0.4),
        backgroundColor: Color = DSColor.backgroundSecondary,
        tileSize: CGFloat = 44
    ) {
        self.lineColor = lineColor
        self.backgroundColor = backgroundColor
        self.tileSize = tileSize
    }

    public var body: some View {
        ZStack {
            backgroundColor
            if let uiImage = UIImage(named: "DecorativeWavePattern", in: .designSystemModule, compatibleWith: nil) {
                Image(uiImage: uiImage)
                    .resizable(resizingMode: .tile)
            } else {
                Canvas { context, size in
                    drawSeigaihaPattern(context: context, size: size)
                }
            }
        }
    }

    /// Draw the "seigaiha" pattern (interlocking, staggered arcs) — pure vector, no image assets required.
    private func drawSeigaihaPattern(context: GraphicsContext, size: CGSize) {
        let radius = tileSize / 2
        var rowIndex = 0
        var y: CGFloat = -radius

        while y < size.height + radius {
            let xOffset: CGFloat = rowIndex.isMultiple(of: 2) ? 0 : radius
            var x: CGFloat = -radius + xOffset

            while x < size.width + radius {
                drawArcSet(context: context, center: CGPoint(x: x, y: y), radius: radius)
                x += tileSize
            }
            y += radius
            rowIndex += 1
        }
    }

    private func drawArcSet(context: GraphicsContext, center: CGPoint, radius: CGFloat) {
        // 3 nested arcs (with decreasing radii) — characteristic of the seigaiha pattern.
        for scale: CGFloat in [0.9, 0.6, 0.3] {
            var path = Path()
            path.addArc(
                center: center,
                radius: radius * scale,
                startAngle: .degrees(180),
                endAngle: .degrees(360),
                clockwise: false
            )
            context.stroke(path, with: .color(lineColor.opacity(Double(scale))), lineWidth: 1)
        }
    }
}

#Preview {
    DSWavePatternBackground()
        .frame(height: 300)
}
