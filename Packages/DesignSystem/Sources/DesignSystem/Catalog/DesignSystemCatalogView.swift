//
//  DesignSystemCatalogView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 14/8/26.
//

// Internal living style guide — lists all tokens/components on
// a single screen for visual QA (Light/Dark modes) and quick reference
// for features. NOT a final product screen — intended solely for internal use during development.

import SwiftUI

public struct DesignSystemCatalogView: View {

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                colorSection
                typographySection
                buttonSection
                textFieldSection
                tagSection
                loadingStateSection
                emptyStateSection
                errorStateSection
                seriesCardSection
            }
            .navigationTitle("Design System")
        }
    }

    // MARK: - Colors

    private var colorSection: some View {
        Section("Colors") {
            colorSwatch("Brand Primary", DSColor.brandPrimary)
            colorSwatch("Brand Secondary", DSColor.brandSecondary)
            colorSwatch("Background Primary", DSColor.backgroundPrimary)
            colorSwatch("Background Secondary", DSColor.backgroundSecondary)
            colorSwatch("Text Primary", DSColor.textPrimary)
            colorSwatch("Text Secondary", DSColor.textSecondary)
            colorSwatch("Border Default", DSColor.borderDefault)
            colorSwatch("Status Error", DSColor.statusError)
            colorSwatch("Status Success", DSColor.statusSuccess)
        }
    }

    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        HStack(spacing: DSSpacing.sm) {
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(RoundedRectangle(cornerRadius: DSRadius.sm).stroke(DSColor.borderDefault, lineWidth: 1))
            Text(name)
                .dsFont(DSFontToken.body)
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    // MARK: - Typography

    private var typographySection: some View {
        Section("Typography") {
            ForEach(DSFontToken.allCases, id: \.self) { token in
                Text("\(String(describing: token)) — Aa Bb Yy Ơ Ư Đ")
                    .dsFont(token)
                    .foregroundStyle(DSColor.textPrimary)
            }
        }
    }

    // MARK: - Buttons

    private var buttonSection: some View {
        Section("Buttons") {
            DSButton("Primary", variant: .primary) {}
            DSButton("Outline", variant: .outline) {}
            DSButton("Text", variant: .text, size: .medium) {}
            DSButton("Loading", variant: .primary, isLoading: true) {}
            DSButton("Disabled", variant: .primary) {}
                .disabled(true)
        }
    }

    // MARK: - TextField

    private var textFieldSection: some View {
        Section("TextField") {
            DSTextField(label: "Email", placeholder: "you@example.com", text: .constant(""))
            DSTextField(label: "Mật khẩu", placeholder: "••••••••", text: .constant("123456"), isSecure: true)
            DSTextField(
                label: "Email (error)",
                placeholder: "you@example.com",
                text: .constant("sai-dinh-dang"),
                errorMessage: "Email không đúng định dạng"
            )
        }
    }

    // MARK: - Tags

    private var tagSection: some View {
        Section("Tags") {
            HStack(spacing: DSSpacing.xs) {
                DSTag("Doujins")
                DSTag("Slice of Life", style: .outline)
                DSTag("Hoàn thành", color: DSColor.statusSuccess)
            }
        }
    }

    // MARK: - Loading States

    private var loadingStateSection: some View {
        Section("Loading States") {
            DSLoadingView(style: .spinner, message: "Đang tải...")
                .frame(height: 80)
            DSLoadingView(style: .skeleton(rows: 2))
        }
    }

    // MARK: - Empty States

    private var emptyStateSection: some View {
        Section("Empty States") {
            DSEmptyStateView(
                icon: "person.2.slash",
                title: "Chưa theo dõi nhóm nào",
                message: "Khám phá các nhóm dịch để không bỏ lỡ truyện mới",
                actionTitle: "Khám Phá Nhóm",
                action: {}
            )
            .frame(height: 220)
        }
    }

    // MARK: - Error States

    private var errorStateSection: some View {
        Section("Error States") {
            DSErrorView(message: "Không thể tải dữ liệu. Vui lòng kiểm tra kết nối mạng.", retryAction: {})
                .frame(height: 200)
        }
    }

    // MARK: - SeriesCard

    private var seriesCardSection: some View {
        Section("SeriesCardView") {
            let sample = SeriesCardData(
                id: "1",
                coverURL: nil,
                title: "Ngày Tôi Quyết Định Yêu Cậu Ấy Lần Nữa",
                subtitle: "Nhóm dịch: Yuri no Sono",
                tag: "Doujins",
                metaInfo: "Chương 18 · 3 tháng trước",
                isCompleted: true
            )
            SeriesCardView(data: sample, layout: .list)
                .padding(.vertical, DSSpacing.xs)
        }
    }
}

#Preview("Catalog - Light") {
    DesignSystemCatalogView()
        .preferredColorScheme(.light)
}

#Preview("Catalog - Dark") {
    DesignSystemCatalogView()
        .preferredColorScheme(.dark)
}
