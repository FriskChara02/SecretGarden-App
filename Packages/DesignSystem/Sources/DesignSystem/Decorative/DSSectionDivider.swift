//
//  DSSectionDivider.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 4/9/26.
//

// Decorative divider "── ◆ ──" — separates large cards on the Detail page (info/chapters/
// related/comments) and individual comment entries. Reusable component.

import SwiftUI

public struct DSSectionDivider: View {
    private let diamondColor: Color
    private let lineColor: Color

    public init(diamondColor: Color = DSColor.brandPrimary, lineColor: Color? = nil) {
        self.diamondColor = diamondColor
        self.lineColor = lineColor ?? diamondColor.opacity(0.35)
    }

    public var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Rectangle().fill(lineColor).frame(height: 1)
            Image(systemName: "diamond.circle")
                .font(.system(size: 7))
                .foregroundStyle(diamondColor)
            Rectangle().fill(lineColor).frame(height: 1)
        }
        .padding(.horizontal, DSSpacing.xl)
    }
}

#Preview {
    VStack(spacing: DSSpacing.lg) {
        Text("Section A")
        DSSectionDivider()
        Text("Section B")
    }
    .padding()
}
