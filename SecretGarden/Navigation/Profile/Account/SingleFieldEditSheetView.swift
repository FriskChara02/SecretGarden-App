//
//  SingleFieldEditSheetView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 21/9/26.
//

import CoreArchitecture
import DesignSystem
import SwiftUI

struct SingleFieldEditSheetView: View {
    let title: String
    let fieldLabel: String
    @State var value: String
    let submissionState: FormSubmissionState
    let onSubmit: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            HStack {
                Image(systemName: "diamond.inset.filled").font(.system(size: 9)).foregroundStyle(DSColor.brandPrimary)
                Text(title).font(.system(size: 18, weight: .bold)).foregroundStyle(DSColor.brandPrimary)
                Image(systemName: "diamond.inset.filled").font(.system(size: 9)).foregroundStyle(DSColor.brandPrimary)
            }
            .frame(maxWidth: .infinity)
            .overlay(alignment: .trailing) {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill").foregroundStyle(DSColor.brandPrimary)
                }
            }

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("\(fieldLabel):").font(.system(size: 15, weight: .semibold)).foregroundStyle(DSColor.textPrimary)
                TextField(fieldLabel, text: $value)
                    .padding(DSSpacing.sm)
                    .overlay(RoundedRectangle(cornerRadius: DSRadius.sm).strokeBorder(DSColor.borderDefault, lineWidth: 1))
            }

            if let error = submissionState.error {
                Text(error.errorDescription ?? "Đã có lỗi xảy ra.").font(.system(size: 14)).foregroundStyle(DSColor.statusError)
            }

            HStack(spacing: DSSpacing.sm) {
                Button("Huỷ") { onDismiss() }
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(DSColor.brandPrimary)
                    .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.sm)
                    .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))

                Button {
                    onSubmit(value)
                } label: {
                    if submissionState.isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Cập nhật").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.sm)
                .background(Capsule().fill(DSColor.brandPrimary))
            }
        }
        .padding(.horizontal, DSSpacing.lg)
        .padding(.top, DSSpacing.lg)
        .padding(.bottom, DSSpacing.md)
        .frame(maxWidth: .infinity)
        .background(DSColor.backgroundPrimary)
    }
}
