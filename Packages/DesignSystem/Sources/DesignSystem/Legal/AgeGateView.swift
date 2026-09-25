//
//  AgeGateView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 25/9/26.
//

// Pure static View — shown as a full-screen blocker before the person can
// reach any app content. Two outcomes only: confirm (16+) or decline (blocked).

import SwiftUI

public struct AgeGateView: View {
    private let isDeclined: Bool
    private let onConfirm: () -> Void
    private let onDecline: () -> Void
    private let onViewTerms: () -> Void

    public init(
        isDeclined: Bool,
        onConfirm: @escaping () -> Void,
        onDecline: @escaping () -> Void,
        onViewTerms: @escaping () -> Void
    ) {
        self.isDeclined = isDeclined
        self.onConfirm = onConfirm
        self.onDecline = onDecline
        self.onViewTerms = onViewTerms
    }

    public var body: some View {
        ZStack {
            DSColor.backgroundPrimary.ignoresSafeArea()

            if isDeclined {
                declinedContent
            } else {
                gateContent
            }
        }
    }

    // MARK: - Gate (unconfirmed)

    private var gateContent: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()

            VStack(spacing: DSSpacing.sm) {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(DSColor.brandPrimary)

                Text("XÁC NHẬN ĐỘ TUỔI")
                    .dsFont(.title1)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColor.textPrimary)
            }

            VStack(spacing: DSSpacing.md) {
                Text("Secret Garden có chứa nội dung dành cho người trưởng thành (bao gồm yếu tố 18+/NSFW ở một số truyện).")
                    .multilineTextAlignment(.center)
                    .dsFont(.body)
                    .foregroundStyle(DSColor.textSecondary)

                Text("Bằng việc bấm \u{201c}Tôi đủ 16 tuổi\u{201d}, bạn xác nhận đã đủ 16 tuổi trở lên theo Điều khoản dịch vụ.")
                    .multilineTextAlignment(.center)
                    .dsFont(.footnote)
                    .foregroundStyle(DSColor.textSecondary)

                Button(action: onViewTerms) {
                    Text("Xem Điều khoản dịch vụ")
                        .dsFont(.footnote)
                        .foregroundStyle(DSColor.brandPrimary)
                        .underline()
                }
            }
            .padding(.horizontal, DSSpacing.lg)

            Spacer()

            VStack(spacing: DSSpacing.sm) {
                DSButton("Tôi đủ 16 tuổi", variant: .primary, action: onConfirm)
                DSButton("Tôi chưa đủ 16 tuổi", variant: .outline, action: onDecline)
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.bottom, DSSpacing.xl)
        }
    }

    // MARK: - Declined (fully blocked)

    private var declinedContent: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()

            Image(systemName: "hand.raised.fill")
                .font(.system(size: 48))
                .foregroundStyle(DSColor.statusError)

            Text("Rất tiếc")
                .dsFont(.title1)
                .fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)

            Text("Secret Garden chỉ dành cho người dùng từ 16 tuổi trở lên. Vui lòng thoát ứng dụng.")
                .multilineTextAlignment(.center)
                .dsFont(.body)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.lg)

            Spacer()
        }
    }
}

#Preview("Gate") {
    AgeGateView(isDeclined: false, onConfirm: {}, onDecline: {}, onViewTerms: {})
}

#Preview("Declined") {
    AgeGateView(isDeclined: true, onConfirm: {}, onDecline: {}, onViewTerms: {})
}
