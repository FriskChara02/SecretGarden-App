//
//  EditProfileView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreArchitecture
import CoreModels
import DesignSystem
import Repositories
import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    let onSaved: (User) -> Void
    let onCancel: () -> Void

    init(
        currentUser: User,
        userRepository: UserRepositoryProtocol,
        onSaved: @escaping (User) -> Void,
        onCancel: @escaping (
        ) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: EditProfileViewModel(currentUser: currentUser, userRepository: userRepository)
        )
        self.onSaved = onSaved
        self.onCancel = onCancel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                header

                bioSection

                DSTextField(label: "Sở thích", placeholder: "Nghe nhạc - Gaming", text: $viewModel.interests)
                DSTextField(label: "Địa chỉ", placeholder: "TP.HCM", text: $viewModel.address)

                genderSection
                birthdaySection
                socialLinksSection

                if let error = viewModel.submissionState.error {
                    Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                        .dsFont(.footnote)
                        .foregroundStyle(DSColor.statusError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                actionButtons
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.backgroundPrimary)
        .onChange(of: viewModel.submissionState) { _, newState in
            if newState == .succeeded, let updated = viewModel.updatedUser {
                onSaved(updated)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Chỉnh sửa thông tin")
                .dsFont(.title3).fontWeight(.bold)
                .foregroundStyle(DSColor.brandPrimary)
            Spacer()
            Button(action: onCancel) {
                Image(systemName: "xmark").foregroundStyle(DSColor.textSecondary)
            }
        }
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Giới thiệu (Bio)")
                .dsFont(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DSColor.textPrimary)

            TextField("Nói vài lời về bạn...", text: $viewModel.bio, axis: .vertical)
                .dsFont(.body)
                .lineLimit(3...6)
                .padding(DSSpacing.sm)
                .background(DSColor.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
        }
    }

    private var genderSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Giới tính").dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
            HStack(spacing: DSSpacing.sm) {
                genderButton("Nam")
                genderButton("Nữ")
                genderButton("Khác")
            }
        }
    }

    private func genderButton(_ label: String) -> some View {
        let isSelected = viewModel.gender == label
        return Button { viewModel.gender = label } label: {
            Text(label)
                .dsFont(.subheadline).fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : DSColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    Capsule().fill(isSelected ? DSColor.brandPrimary : DSColor.backgroundSecondary)
                )
        }
    }

    private var birthdaySection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Ngày sinh").dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
            HStack(spacing: DSSpacing.sm) {
                Picker("Ngày", selection: $viewModel.birthDay) {
                    ForEach(1...31, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.menu)

                Picker("Tháng", selection: $viewModel.birthMonth) {
                    ForEach(1...12, id: \.self) { Text("Tháng \($0)").tag($0) }
                }
                .pickerStyle(.menu)

                Picker("Năm", selection: $viewModel.birthYear) {
                    ForEach(viewModel.yearRange, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.menu)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.xs)
            .background(DSColor.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
        }
    }

    private var socialLinksSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Mạng xã hội").dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
            socialLinkRow(label: "Facebook", text: $viewModel.facebookLink)
            socialLinkRow(label: "Discord", text: $viewModel.discordLink)
        }
    }

    private func socialLinkRow(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label).dsFont(.subheadline).foregroundStyle(.blue).frame(width: 70, alignment: .leading)
            TextField("https://...", text: text)
                .dsFont(.footnote)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }

    private var actionButtons: some View {
        HStack(spacing: DSSpacing.sm) {
            DSButton("Huỷ", variant: .outline) { onCancel() }
            DSButton("Lưu thay đổi", variant: .primary, isLoading: viewModel.submissionState.isSubmitting) {
                viewModel.save()
            }
        }
    }
}
