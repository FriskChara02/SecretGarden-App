//
//  HomeView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Main view of the Home tab – Banner + Manga/Novel toggle.
// `onSeriesSelected` is passed in from outside (App target) rather than being called directly by HomeView.
// Direct Coordinator usage — adhering to the "View emits intent, Coordinator handles navigation" pattern.

import DesignSystem
import SwiftUI

public struct HomeView: View {
    @State private var selectedContentType: HomeContentType = .manga

    private let onSeriesSelected: (String) -> Void

    private let banners: [BannerItem] = [
        BannerItem(
            id: "banner_1",
            title: "Sự kiện mùa hè",
            subtitle: "Khám phá truyện Yuri hot nhất tháng này",
            gradientColors: [DSColor.brandPrimary, DSColor.brandSecondary]
        ),
        BannerItem(
            id: "banner_2",
            title: "Nhóm dịch nổi bật",
            subtitle: "Cùng khám phá các nhóm dịch tận tâm",
            gradientColors: [DSColor.brandSecondary, DSColor.brandPrimary]
        )
    ]

    public init(onSeriesSelected: @escaping (String) -> Void) {
        self.onSeriesSelected = onSeriesSelected
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                BannerCarouselView(banners: banners)

                ContentTypeToggle(selection: $selectedContentType)

                // Placeholder tạm cho các section chưa dựng — sẽ bị thay thế hoàn toàn
                // ở Step 8.5-8.8, không phải nợ kỹ thuật, chỉ là mốc kế hoạch rõ ràng.
                Text("Các section tiếp theo (Tiếp tục đọc, Mới cập nhật, Xếp hạng, Bình luận) sẽ được thêm ở Step 8.5 – 8.8.")
                    .dsFont(.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.md)

                DSButton("Xem demo Series Detail", variant: .outline) {
                    onSeriesSelected("demo-001")
                }
                .padding(.horizontal, DSSpacing.md)
            }
            .padding(.vertical, DSSpacing.lg)
        }
        .background(DSColor.backgroundPrimary)
        .navigationTitle("Trang chủ")
    }
}

#Preview {
    NavigationStack {
        HomeView(onSeriesSelected: { _ in })
    }
}
