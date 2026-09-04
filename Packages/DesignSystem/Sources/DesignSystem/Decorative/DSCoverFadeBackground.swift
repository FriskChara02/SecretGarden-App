//
//  DSCoverFadeBackground.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 4/9/26.
//

// Background for the top of the Detail/Reader screen: story cover image (blurred and darkened),
// fading to transparent as the user scrolls down, revealing the DSWavePatternBackground underneath.

import SwiftUI

public struct DSCoverFadeBackground: View {
    private let coverURL: URL?
    private let fadeHeight: CGFloat

    public init(coverURL: URL?, fadeHeight: CGFloat = 340) {
        self.coverURL = coverURL
        self.fadeHeight = fadeHeight
    }

    public var body: some View {
        ZStack(alignment: .top) {
            DSWavePatternBackground()

            if let coverURL {
                AsyncImage(url: coverURL) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: fadeHeight)
                            .clipped()
                            .blur(radius: 20)
                            .overlay(Color.black.opacity(0.22))
                            .mask(fadeMask)
                    }
                }
                .frame(height: fadeHeight)
                .allowsHitTesting(false)
            }
        }
    }

    /// Fully transparent at the top (most visible in the cover image), gradually fading out and disappearing completely
    /// (revealing the pattern) at approximately 65% ​​of the height from the top downwards.
    private var fadeMask: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: .black.opacity(0.5), location: 0.55),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    DSCoverFadeBackground(coverURL: URL(string: "https://picsum.photos/seed/preview/600/900"))
        .frame(height: 500)
}
