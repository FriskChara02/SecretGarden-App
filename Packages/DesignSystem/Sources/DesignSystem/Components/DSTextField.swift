//
//  DSTextField.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 13/8/26.
//

// Reusable TextField — supports floating labels, error messages (validation),
// secure mode (password), and border color changes based on focus/error states.

import SwiftUI

public struct DSTextField: View {
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let isSecure: Bool
    private let errorMessage: String?

    @FocusState private var isFocused: Bool

    public init(
        label: String,
        placeholder: String = "",
        text: Binding<String>,
        isSecure: Bool = false,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.errorMessage = errorMessage
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(label)
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .dsFont(.body)
            .foregroundStyle(DSColor.textPrimary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .focused($isFocused)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(DSColor.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(borderColor, lineWidth: isFocused ? 1.5 : 1)
            )
            .animation(.easeOut(duration: 0.15), value: isFocused)
            .animation(.easeOut(duration: 0.15), value: errorMessage)

            if let errorMessage {
                Text(errorMessage)
                    .dsFont(.footnote)
                    .foregroundStyle(DSColor.statusError)
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return DSColor.statusError }
        if isFocused { return DSColor.brandPrimary }
        return DSColor.borderDefault
    }
}

#Preview("DSTextField states") {
    VStack(spacing: DSSpacing.lg) {
        DSTextField(label: "Email", placeholder: "you@example.com", text: .constant(""))
        DSTextField(label: "Mật khẩu", placeholder: "••••••••", text: .constant("123456"), isSecure: true)
        DSTextField(
            label: "Email",
            placeholder: "you@example.com",
            text: .constant("sai-dinh-dang"),
            errorMessage: "Email không đúng định dạng"
        )
    }
    .padding()
}
