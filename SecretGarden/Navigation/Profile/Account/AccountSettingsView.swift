//
//  AccountSettingsView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreArchitecture
import CoreModels
import DesignSystem
import Repositories
import SwiftUI

struct AccountSettingsView: View {
    @StateObject private var viewModel: AccountSettingsViewModel
    let onUserUpdated: (User) -> Void

    @State private var editingSheet: EditSheet?
    @State private var isChangePasswordPresented = false
    @State private var toastMessage: String?

    private enum EditSheet: Identifiable {
        case username, displayName, email
        var id: Self { self }
    }

    init(
        currentUser: User,
        userRepository: UserRepositoryProtocol,
        authRepository: AuthRepositoryProtocol,
        onUserUpdated: @escaping (User) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: AccountSettingsViewModel(
                currentUser: currentUser,
                userRepository: userRepository,
                authRepository: authRepository
            )
        )
        self.onUserUpdated = onUserUpdated
    }

    var body: some View {
        content
            .fullScreenCover(item: $editingSheet) { sheet in
                BottomSheetContainer(
                    onTapOutside: {
                        dismissWithoutAnimation {
                            editingSheet = nil
                        }
                    },
                    content: {
                        fieldSheet(for: sheet)
                    }
                )
                .ignoresSafeArea(.all)
            }
            .transaction { $0.disablesAnimations = true }
            .fullScreenCover(isPresented: $isChangePasswordPresented) {
                BottomSheetContainer(
                    onTapOutside: {
                        dismissWithoutAnimation {
                            isChangePasswordPresented = false
                        }
                    },
                    content: {
                        ChangePasswordSheetView(
                            submissionState: viewModel.passwordSubmissionState,
                            onSubmit: { old, new in
                                viewModel.changePassword(
                                    oldPassword: old,
                                    newPassword: new
                                )
                            },
                            onDismiss: {
                                dismissWithoutAnimation {
                                    isChangePasswordPresented = false
                                }
                            }
                        )
                    }
                )
                .ignoresSafeArea(.all)
            }
            .transaction { $0.disablesAnimations = true }
            .onChange(of: viewModel.passwordSubmissionState) { _, newState in
                if newState == .succeeded {
                    dismissWithoutAnimation {
                        isChangePasswordPresented = false
                    }
                    toastMessage = "Đã cập nhật thành công"
                }
            }
            .dsSuccessToast(message: $toastMessage)
    }

    private var content: some View {
        VStack(spacing: DSSpacing.lg) {
            sectionTitle
            DSSectionDivider()
            accountRowsBox
            DSSectionDivider()
            GardenFooterView(
                policyLinks: [GardenFooterLink(title: "Chính sách", action: {})],
                socialLinks: [
                    GardenFooterLink(title: "Discord", action: {}),
                    GardenFooterLink(title: "Facebook", action: {})
                ],
                onPolicyTapped: {}
            )
        }
        .padding(.vertical, DSSpacing.lg)
    }

    private var sectionTitle: some View {
        HStack {
            Image(systemName: "diamond.inset.filled")
                .font(.system(size: 9))
                .foregroundStyle(DSColor.brandPrimary)

            Text("Tài khoản")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DSColor.brandPrimary)

            Image(systemName: "diamond.inset.filled")
                .font(.system(size: 9))
                .foregroundStyle(DSColor.brandPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DSSpacing.md)
    }

    private var accountRowsBox: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            accountRow(
                label: "User name",
                value: viewModel.currentUser.username,
                isEditable: true
            ) {
                dismissWithoutAnimation {
                    editingSheet = .username
                }
            }

            accountRow(
                label: "Biệt danh",
                value: viewModel.currentUser.displayName ?? "Chưa cập nhật",
                isEditable: true
            ) {
                dismissWithoutAnimation {
                    editingSheet = .displayName
                }
            }

            accountRow(
                label: "Email",
                value: viewModel.currentUser.email,
                isEditable: viewModel.canEditContactInfo
            ) {
                dismissWithoutAnimation {
                    editingSheet = .email
                }
            }

            accountRow(
                label: "Mật khẩu",
                value: "••••••••••",
                isEditable: viewModel.canEditContactInfo
            ) {
                dismissWithoutAnimation {
                    isChangePasswordPresented = true
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    private func accountRow(
        label: String,
        value: String,
        isEditable: Bool,
        onEdit: @escaping () -> Void
    ) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text("\(label):")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 100, alignment: .trailing)

            HStack {
                Text(value)
                    .font(.system(size: 15))
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(DSColor.backgroundSecondary)
            )

            if isEditable {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(DSColor.brandPrimary)
                }
            } else {
                Spacer()
                    .frame(width: 20)
            }
        }
    }

    private func dismissWithoutAnimation(_ action: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }

    @ViewBuilder
    private func fieldSheet(for sheet: EditSheet) -> some View {
        switch sheet {
        case .username:
            makeSingleFieldSheet(
                title: "Đổi tên hiển thị",
                label: "Tên hiển thị",
                value: viewModel.currentUser.username
            ) { newValue in
                viewModel.editingUsername = newValue
                viewModel.saveUsername { handleUpdate($0) }
            }

        case .displayName:
            makeSingleFieldSheet(
                title: "Đổi Biệt danh",
                label: "Biệt danh",
                value: viewModel.currentUser.displayName ?? ""
            ) { newValue in
                viewModel.editingDisplayName = newValue
                viewModel.saveDisplayName { handleUpdate($0) }
            }

        case .email:
            makeSingleFieldSheet(
                title: "Đổi Email",
                label: "Email",
                value: viewModel.currentUser.email
            ) { newValue in
                viewModel.editingEmail = newValue
                viewModel.saveEmail { handleUpdate($0) }
            }
        }
    }

    private func handleUpdate(_ updated: User) {
        onUserUpdated(updated)
        editingSheet = nil
        toastMessage = "Đã cập nhật thành công"
    }

    private func makeSingleFieldSheet(
        title: String,
        label: String,
        value: String,
        onSubmit: @escaping (String) -> Void
    ) -> some View {
        SingleFieldEditSheetView(
            title: title,
            fieldLabel: label,
            value: value,
            submissionState: viewModel.fieldSubmissionState,
            onSubmit: onSubmit,
            onDismiss: { editingSheet = nil }
        )
    }
}
