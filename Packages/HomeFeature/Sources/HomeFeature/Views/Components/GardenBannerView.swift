//
//  GardenBannerView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 26/8/26.
//

// Garden Banner — full-bleed background image with overlaid logo/tagline,
// image automatically switches between Light/Dark modes via the "GardenBanner" Asset Catalog (Any + Dark Appearance).

import DesignSystem
import SwiftUI

struct GardenBannerView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            bannerImage(width: proxy.size.width, height: proxy.size.height)
                .overlay {
                    if colorScheme == .dark {
                        sparkleOverlay
                    }
                }
        }
        .frame(height: 150)
    }

    @ViewBuilder
    private func bannerImage(width: CGFloat, height: CGFloat) -> some View {
        // "GardenBanner" — fallback gradient if no image is available (to avoid a blank white area).
        if let uiImage = UIImage(named: "GardenBanner", in: .designSystemModule, compatibleWith: nil) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()
        } else {
            LinearGradient(
                colors: [DSColor.brandPrimary, DSColor.brandSecondary],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .frame(width: width, height: height)
        }
    }

    /// Decorative sparkle — Dark mode only
    private var sparkleOverlay: some View {
        GeometryReader { proxy in
            ForEach(Self.sparklePositions.indices, id: \.self) { i in
                let pos = Self.sparklePositions[i]
                Image(systemName: "sparkle")
                    .font(.system(size: pos.size))
                    .foregroundStyle(.white.opacity(0.75))
                    .position(x: proxy.size.width * pos.x, y: proxy.size.height * pos.y)
            }
        }
        .allowsHitTesting(false)
    }

    private static let sparklePositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.08, 0.15, 12), (0.85, 0.12, 16), (0.92, 0.45, 10),
        (0.15, 0.85, 14), (0.6, 0.9, 10), (0.75, 0.7, 13)
    ]
}

#Preview("Light") { GardenBannerView().preferredColorScheme(.light) }
#Preview("Dark") { GardenBannerView().preferredColorScheme(.dark) }
