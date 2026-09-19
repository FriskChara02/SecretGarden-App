//
//  ChangePasswordSheetView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreArchitecture
import DesignSystem
import SwiftUI

struct ChangePasswordSheetView: View {
    let submissionState: FormSubmissionState
    let onSubmit: (String, String) -> Void
    let onDismiss: () -> Void

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    private var canSubmit: Bool {
        !oldPassword.isEmpty && newPassword.count >= 6 && newPassword == confirmPassword && !submissionState.isSubmitting
    }

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Text("Đổi mật khẩu").dsFont(.title3).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)

            DSTextField(label: "Mật khẩu cũ", placeholder: "••••••••", text: $oldPassword, isSecure: true)
            DSTextField(label: "Mật khẩu mới", placeholder: "••••••••", text: $newPassword, isSecure: true)
            DSTextField(
                label: "Xác nhận mật khẩu mới",
                placeholder: "••••••••",
                text: $confirmPassword,
                isSecure: true,
                errorMessage: (!confirmPassword.isEmpty && confirmPassword != newPassword) ? "Mật khẩu xác nhận không khớp." : nil
            )

            if let error = submissionState.error {
                Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                    .dsFont(.footnote).foregroundStyle(DSColor.statusError)
            }

            DSButton("Xác nhận", variant: .primary, isLoading: submissionState.isSubmitting) {
                onSubmit(oldPassword, newPassword)
            }
            .disabled(!canSubmit)

            DSButton("Huỷ", variant: .text) { onDismiss() }
        }
        .padding(DSSpacing.lg)
    }
}
