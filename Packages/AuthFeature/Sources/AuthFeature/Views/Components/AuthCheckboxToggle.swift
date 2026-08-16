//
//  AuthCheckboxToggle.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 17/8/26.
//

// Checkbox tối giản cho "Ghi nhớ mật khẩu"

import DesignSystem
import SwiftUI

struct AuthCheckboxToggle: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isOn ? DSColor.brandPrimary : DSColor.textSecondary)
                Text(title)
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}
