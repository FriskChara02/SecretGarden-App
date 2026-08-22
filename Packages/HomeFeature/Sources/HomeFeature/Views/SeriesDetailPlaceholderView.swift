//
//  SeriesDetailPlaceholderView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Placeholder for the HomeRoute.seriesDetail destination — TO BE REPLACED
// Leftover Text("Series Detail (demo)..."). This is NOT the actual
// SeriesDetailView — just cleaning up navigation technical debt,
// displaying the received ID, confirming the route works, without pretending to be the real screen.

import DesignSystem
import SwiftUI

public struct SeriesDetailPlaceholderView: View {
    let seriesId: String

    public init(seriesId: String) {
        self.seriesId = seriesId
    }

    public var body: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "book.pages")
                .font(.system(size: 48))
                .foregroundStyle(DSColor.brandPrimary)
            Text("Series Detail")
                .dsFont(.title2)
                .foregroundStyle(DSColor.textPrimary)
            Text("id: \(seriesId)")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)
            Text("Màn hình chi tiết thật sẽ được xây ở Phase 10 (theo roadmap).")
                .dsFont(.caption)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, DSSpacing.sm)
        }
        .padding(DSSpacing.lg)
        .navigationTitle("Chi tiết truyện")
    }
}
