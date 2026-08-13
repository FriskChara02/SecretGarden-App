//
//  DSEmptyStateView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 13/8/26.
//

// Empty states: "No search history", "No description",
// "Not following any groups"... Optional action button (e.g., "Discover Groups").

import SwiftUI

public struct DSEmptyStateView: View {
    private let icon: String
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let action: (() -> Void)?

    public init(
        icon: String = "tray",
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(DSColor.textSecondary.opacity(0.5))

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
