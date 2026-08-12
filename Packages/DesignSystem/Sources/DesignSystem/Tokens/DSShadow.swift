//
//  DSShadow.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 12/8/26.
//

// Standardized shadows for Card/SeriesCardView, floating modals, ...
// Returns a struct containing all parameters for the .shadow() modifier, rather than calling them individually in each location.

import SwiftUI

public struct DSShadowStyle {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension DSShadowStyle {
    static let card = DSShadowStyle(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 2
    )

    static let floating = DSShadowStyle(
        color: Color.black.opacity(0.15),
        radius: 16,
        x: 0,
        y: 4
    )
}

// Handy extension for direct application: .dsShadow(.card)
public extension View {
    func dsShadow(_ style: DSShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
