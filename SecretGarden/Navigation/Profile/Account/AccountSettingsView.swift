//
//  AccountSettingsView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import CoreArchitecture
import DesignSystem
import Repositories
import SwiftUI

struct AccountSettingsView: View {
    @StateObject private var viewModel: AccountSettingsViewModel
    let onUserUpdated: (User) -> Void

    @State private var editingField: Field?
    @State private var isChangePasswordPresented = false

    private enum Field { case username, displayName, email }

    init(
        currentUser: User,
        userRepository: UserRepositoryProtocol,
        authRepository: AuthRepositoryProtocol,
        onUserUpdated: @escaping (User) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AccountSettingsViewModel(
            currentUser: currentUser,
            userRepository: userRepository,
            authRepository: authRepository
        ))
        self.onUserUpdated = onUserUpdated
    }

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            sectionTitle

            accountRow(
                label: "User name",
                field: .username,
                text: $viewModel.editingUsername,
                isEditable: true,
                onSave: { viewModel.saveUsername(onSaved: onUserUpdated) }
            )
            accountRow(
                label: "Biệt danh",
                field: .displayName,
                text: $viewModel.editingDisplayName,
                isEditable: true,
                onSave: { viewModel.saveDisplayName(onSaved: onUserUpdated) }
            )
            accountRow(
                label: "Email",
                field: .email,
                text: $viewModel.editingEmail,
                isEditable: viewModel.canEditContactInfo,
                onSave: { viewModel.saveEmail(onSaved: onUserUpdated) }
            )
            passwordRow

            if let error = viewModel.fieldSubmissionState.error {
                Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                    .dsFont(.footnote)
                    .foregroundStyle(DSColor.statusError)
            }
        }
        .padding(DSSpacing.lg)
        .sheet(isPresented: $isChangePasswordPresented) {
            ChangePasswordSheetView(
                submissionState: viewModel.passwordSubmissionState,
                onSubmit: { old, new in viewModel.changePassword(oldPassword: old, newPassword: new) },
                onDismiss: { isChangePasswordPresented = false }
            )
        }
        .onChange(of: viewModel.passwordSubmissionState) { _, newState in
            if newState == .succeeded { isChangePasswordPresented = false }
        }
    }

    private var sectionTitle: some View {
        HStack {
            Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
            Text("Tài khoản").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
        }
    }

    private func accountRow(
        label: String,
        field: Field,
        text: Binding<String>,
        isEditable: Bool,
        onSave: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(label)
                .dsFont(.subheadline).fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 90, alignment: .leading)

            if editingField == field {
                TextField(label, text: text)
                    .dsFont(.subheadline)
                    .textFieldStyle(.roundedBorder)
                Button {
                    onSave()
                    editingField = nil
                } label: {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(DSColor.brandPrimary)
                }
                .disabled(viewModel.fieldSubmissionState.isSubmitting)
            } else {
                Text(text.wrappedValue.isEmpty ? "Chưa cập nhật" : text.wrappedValue)
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
                Spacer()
                if isEditable {
                    Button { editingField = field } label: {
                        Image(systemName: "pencil").foregroundStyle(DSColor.brandPrimary)
                    }
                }
            }
        }
    }

    private var passwordRow: some View {
        HStack {
            Text("Mật khẩu")
                .dsFont(.subheadline).fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 90, alignment: .leading)
            Text("••••••••••").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
            Spacer()
            if viewModel.canEditContactInfo {
                Button { isChangePasswordPresented = true } label: {
                    Image(systemName: "pencil").foregroundStyle(DSColor.brandPrimary)
                }
            }
        }
    }
}
