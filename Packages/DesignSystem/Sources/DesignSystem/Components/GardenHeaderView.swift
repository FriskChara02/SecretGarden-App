//
//  GardenHeaderView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 26/8/26.
//

// Fixed header on a pink background (logo + app name) that scrolls with the content
// (not the system NavigationBar) — placed as the first item inside each tab's ScrollView.
// Tapping the logo/name triggers the onTap closure (behavior determined by the app target).

import SwiftUI

public struct GardenHeaderView: View {
    private let title: String
    private let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    public init(title: String = "SECRET GARDEN", onTap: @escaping () -> Void) {
        self.title = title
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.sm) {
                logoIcon
                Text(title)
                    .dsFont(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.md)
            .frame(maxWidth: .infinity)
            .background(headerBackground)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var logoIcon: some View {
        if let uiImage = UIImage(named: "AppLogo", in: .designSystemModule, compatibleWith: nil) {
            Image(uiImage: uiImage).resizable().scaledToFit().frame(width: 32, height: 32)
        } else {
            Image(systemName: "leaf.fill").font(.system(size: 20)).foregroundStyle(.white).frame(width: 32, height: 32)
        }
    }

    private var headerBackground: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [DSColor.brandPrimary, DSColor.brandPrimary.opacity(0.55), Color.black]
                    : [DSColor.brandPrimary, DSColor.brandPrimary.opacity(0.85)],
                startPoint: .leading, endPoint: .trailing
            )
            if colorScheme == .dark { sparkleOverlay }
        }
        .overlay {
            Rectangle().strokeBorder(Color.white.opacity(0.4), lineWidth: 1).padding(4)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.brandPrimaryLight).frame(height: 2)
        }
        .ignoresSafeArea(edges: .top)
    }

    private var sparkleOverlay: some View {
        GeometryReader { proxy in
            ForEach(Self.sparklePositions.indices, id: \.self) { i in
                let pos = Self.sparklePositions[i]
                Image(systemName: "sparkle")
                    .font(.system(size: pos.size))
                    .foregroundStyle(.white.opacity(0.65))
                    .position(x: proxy.size.width * pos.x, y: proxy.size.height * pos.y)
            }
        }
        .allowsHitTesting(false)
    }

    private static let sparklePositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.55, 0.25, 8), (0.68, 0.65, 11), (0.78, 0.35, 13), (0.87, 0.6, 8), (0.94, 0.2, 9), (0.6, 0.85, 7)
    ]
}

#Preview {
    ScrollView {
        GardenHeaderView(onTap: {})
        Color.clear.frame(height: 400)
    }
    .ignoresSafeArea(edges: .top)
}
