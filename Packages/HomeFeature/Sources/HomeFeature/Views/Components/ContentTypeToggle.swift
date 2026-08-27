//
//  ContentTypeToggle.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Toggle "Yuri Manga" ⟷ "Yuri Novel".

import CoreModels
import DesignSystem
import SwiftUI

public enum HomeContentType: String, CaseIterable, Identifiable {
    case manga = "GARDEN MANGA"
    case novel = "GARDEN NOVEL"

    public var id: String { rawValue }
}

public struct ContentTypeToggle: View {
    @Binding private var selection: HomeContentType
    @Environment(\.colorScheme) private var colorScheme

    public init(selection: Binding<HomeContentType>) {
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            tabButton(.manga)
            Text("|")
                .dsFont(.headline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, DSSpacing.xs)
            tabButton(.novel)
        }
        .padding(.vertical, DSSpacing.md)
        .frame(maxWidth: .infinity)
        .background(barBackground)
        .overlay {
            if colorScheme == .dark { sparkleOverlay }
        }
        .overlay { doubleBorder }
    }

    private func tabButton(_ type: HomeContentType) -> some View {
        let isSelected = selection == type
        return Button {
            selection = type
        } label: {
            VStack(spacing: DSSpacing.xxs) {
                Text(type.rawValue)
                    .dsFont(.callout)
                    .fontWeight(isSelected ? .bold : .regular)
                    .tracking(1.2)   // Adjust letter spacing to match the header's uppercase style
                    .foregroundStyle(.white.opacity(isSelected ? 1 : 0.55))

                Rectangle()
                    .fill(isSelected ? Color.white : Color.clear)
                    .frame(height: 2)
                    .frame(maxWidth: 90)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var barBackground: some View {
        LinearGradient(
            colors: [DSColor.brandPrimary, DSColor.brandPrimary.opacity(0.85)],
            startPoint: .leading, endPoint: .trailing
        )
    }

    private var doubleBorder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DSRadius.sm - 4)
                .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                .padding(4)
        }
    }

    private var sparkleOverlay: some View {
        GeometryReader { proxy in
            ForEach(Self.sparklePositions.indices, id: \.self) { i in
                let pos = Self.sparklePositions[i]
                Image(systemName: "sparkle")
                    .font(.system(size: pos.size))
                    .foregroundStyle(.white.opacity(0.7))
                    .position(x: proxy.size.width * pos.x, y: proxy.size.height * pos.y)
            }
        }
        .allowsHitTesting(false)
    }

    private static let sparklePositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.6, 0.2, 10), (0.9, 0.7, 8), (0.7, 0.85, 9), (0.85, 0.3, 7)
    ]
}

extension HomeContentType {
    /// Map the UI toggle (Manga/Novel) to the actual `SeriesType` domain for client-side filtering.
    /// Note: `.doujinshi` does not fall under either of these two toggle options - consistent with
    /// the system design (the toggle only switches between "Yurineko Manga" and "Yurineko Novel", Doujinshi has its own tab).
    var seriesType: SeriesType {
        switch self {
        case .manga: return .manga
        case .novel: return .novel
        }
    }
}

#Preview("Light") {
    ContentTypeToggle(selection: .constant(.manga)).preferredColorScheme(.light)
}

#Preview("Dark") {
    ContentTypeToggle(selection: .constant(.novel)).preferredColorScheme(.dark)
}
