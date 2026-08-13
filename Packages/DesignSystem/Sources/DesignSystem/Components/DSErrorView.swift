//
//  DSErrorView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 13/8/26.
//

// Display an error with a "Retry" button — the retry closure calls back to the ViewModel
// (usually re-invoking the specific fetch function that failed).

import SwiftUI

public struct DSErrorView: View {
    private let message: String
    private let retryAction: (() -> Void)?

    public init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(DSColor.statusError)

            Text(message)
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)

            if let retryAction {
                DSButton("Thử lại", variant: .primary, size: .medium, action: retryAction)
                    .padding(.top, DSSpacing.sm)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(DSSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("DSErrorView") {
    DSErrorView(message: "Không thể tải dữ liệu. Vui lòng kiểm tra kết nối mạng.", retryAction: {})
}
