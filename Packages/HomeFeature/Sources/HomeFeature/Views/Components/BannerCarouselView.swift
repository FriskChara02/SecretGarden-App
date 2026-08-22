//
//  BannerCarouselView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Static banner carousel for Home.

import DesignSystem
import SwiftUI

public struct BannerItem: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let gradientColors: [Color]

    public init(id: String, title: String, subtitle: String, gradientColors: [Color]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.gradientColors = gradientColors
    }
}

public struct BannerCarouselView: View {
    private let banners: [BannerItem]

    public init(banners: [BannerItem]) {
        self.banners = banners
    }

    public var body: some View {
        TabView {
            ForEach(banners) { banner in
                bannerCard(banner)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 160)
    }

    private func bannerCard(_ banner: BannerItem) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: banner.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(banner.title)
                    .dsFont(.title2)
                    .foregroundStyle(.white)
                Text(banner.subtitle)
                    .dsFont(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(DSSpacing.md)
        }
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .padding(.horizontal, DSSpacing.md)
    }
}

#Preview {
    BannerCarouselView(banners: [
        BannerItem(
            id: "1",
            title: "Sự kiện mùa hè",
            subtitle: "Khám phá truyện Yuri hot nhất tháng này",
            gradientColors: [DSColor.brandPrimary, DSColor.brandSecondary]
        ),
        BannerItem(
            id: "2",
            title: "Nhóm dịch nổi bật",
            subtitle: "Cùng khám phá các nhóm dịch tận tâm",
            gradientColors: [DSColor.brandSecondary, DSColor.brandPrimary]
        )
    ])
}
