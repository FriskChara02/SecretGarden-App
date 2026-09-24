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
            HStack {
                Image(systemName: "diamond.inset.filled").font(.system(size: 9)).foregroundStyle(DSColor.brandPrimary)
                Text("Đổi mật khẩu").font(.system(size: 18, weight: .bold)).foregroundStyle(DSColor.brandPrimary)
                Image(systemName: "diamond.inset.filled").font(.system(size: 9)).foregroundStyle(DSColor.brandPrimary)
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Button(action: onDismiss) { Image(systemName: "xmark.circle.fill").foregroundStyle(DSColor.brandPrimary) }
            }

            secureField(label: "Mật khẩu hiện tại", text: $oldPassword)
            secureField(label: "Mật khẩu mới", text: $newPassword)
            secureField(
                label: "Xác nhận mật khẩu",
                text: $confirmPassword,
                errorMessage: (!confirmPassword.isEmpty && confirmPassword != newPassword) ? "Mật khẩu xác nhận không khớp." : nil
            )

            if let error = submissionState.error {
                Text(error.errorDescription ?? "Đã có lỗi xảy ra.").font(.system(size: 14)).foregroundStyle(DSColor.statusError)
            }

            Button {
                onSubmit(oldPassword, newPassword)
            } label: {
                if submissionState.isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Cập nhật").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.sm)
            .background(Capsule().fill(DSColor.brandPrimary))
            .disabled(!canSubmit)

            Button("Huỷ") { onDismiss() }
                .font(.system(size: 16, weight: .semibold)).foregroundStyle(DSColor.textSecondary)
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.top, DSSpacing.lg)
        .padding(.bottom, DSSpacing.md)
        .frame(maxWidth: .infinity)
        .background(DSColor.backgroundPrimary)
    }

    private func secureField(label: String, text: Binding<String>, errorMessage: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("\(label):").font(.system(size: 15, weight: .semibold)).foregroundStyle(DSColor.textPrimary)
            PasswordFieldWithToggle(placeholder: "Nhập mật khẩu", text: text)
            if let errorMessage {
                Text(errorMessage).font(.caption).foregroundStyle(DSColor.statusError)
            }
        }
    }
}

private struct PasswordFieldWithToggle: View {
    let placeholder: String
    @Binding var text: String
    @State private var isRevealed = false

    var body: some View {
        HStack {
            Group {
                if isRevealed {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(DSSpacing.sm)
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .strokeBorder(DSColor.borderDefault, lineWidth: 1)
        )
    }
}
