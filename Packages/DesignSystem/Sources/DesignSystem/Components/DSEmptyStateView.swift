//
//  DSEmptyStateView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 13/8/26.
//

// Empty states: "No search history", "No description",
// "Not following any groups"... Optional action button (e.g., "Discover Groups").
// Supports custom image assets (imageName) — prioritizes the actual image if present in the Asset Catalog,
// and automatically falls back to an SF Symbol (icon) if the image is missing or fails to load.

import SwiftUI

public struct DSEmptyStateView: View {
    private let icon: String
    private let imageName: String?
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        icon: String = "tray",
        imageName: String? = nil,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.imageName = imageName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            illustrationView

            Text(title)
                .dsFont(.headline)
                .foregroundStyle(DSColor.textPrimary)
                .multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                DSButton(actionTitle, variant: .outline, size: .medium, action: action)
                    .padding(.top, DSSpacing.sm)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Prioritize the actual image asset (if `imageName` is provided AND the image exists in the Asset Catalog);
    /// otherwise, always fall back to an SF Symbol — never leave it completely blank.
    @ViewBuilder
    private var illustrationView: some View {
        if let imageName, let uiImage = UIImage(named: imageName, in: .designSystemModule, compatibleWith: nil) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .opacity(0.6)
        } else {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(DSColor.textSecondary.opacity(0.5))
        }
    }
}

#Preview("DSEmptyStateView") {
    VStack(spacing: 0) {
        DSEmptyStateView(icon: "magnifyingglass", title: "Chưa có lịch sử tìm kiếm")
        Divider()
        DSEmptyStateView(
            icon: "person.2.slash",
            title: "Chưa theo dõi nhóm nào",
            message: "Khám phá các nhóm dịch để không bỏ lỡ truyện mới",
            actionTitle: "Khám Phá Nhóm",
            action: {}
        )
    }
}
