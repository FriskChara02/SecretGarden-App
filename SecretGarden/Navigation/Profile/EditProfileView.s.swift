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
        onCancel: @escaping () -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: EditProfileViewModel(
                currentUser: currentUser,
                userRepository: userRepository
            )
        )
        self.onSaved = onSaved
        self.onCancel = onCancel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                header

                fieldBlock(title: "Giới thiệu (Bio)") {
                    TextField("Nói vài lời về bạn...", text: $viewModel.bio, axis: .vertical)
                        .font(.system(size: 15)).lineLimit(3...6)
                        .padding(DSSpacing.sm)
                        .background(RoundedRectangle(cornerRadius: DSRadius.md).fill(DSColor.backgroundSecondary))
                }
                fieldBlock(title: "Sở thích") {
                    TextField("Nghe nhạc - Gaming", text: $viewModel.interests)
                        .font(.system(size: 15)).padding(DSSpacing.sm)
                        .background(RoundedRectangle(cornerRadius: DSRadius.md).fill(DSColor.backgroundSecondary))
                }
                fieldBlock(title: "Địa chỉ") {
                    TextField("TP.HCM", text: $viewModel.address)
                        .font(.system(size: 15)).padding(DSSpacing.sm)
                        .background(RoundedRectangle(cornerRadius: DSRadius.md).fill(DSColor.backgroundSecondary))
                }
                fieldBlock(title: "Giới tính") { genderRow }
                fieldBlock(title: "Ngày sinh") { birthdayRow }
                fieldBlock(title: "Mạng xã hội") { socialLinksSection }

                if let error = viewModel.submissionState.error {
                    Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                        .font(.system(size: 14)).foregroundStyle(DSColor.statusError)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                actionButtons
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.backgroundPrimary)
        .onChange(of: viewModel.submissionState) { _, newState in
            if newState == .succeeded, let updated = viewModel.updatedUser { onSaved(updated) }
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "diamond.inset.filled").font(.system(size: 9)).foregroundStyle(DSColor.brandPrimary)
            Text("Chỉnh sửa thông tin").font(.system(size: 20, weight: .bold)).foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.inset.filled").font(.system(size: 9)).foregroundStyle(DSColor.brandPrimary)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill").foregroundStyle(DSColor.brandPrimary)
            }
        }
    }

    private func fieldBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(DSColor.textPrimary)
            content()
        }
    }

    private var genderRow: some View {
        HStack(spacing: DSSpacing.sm) {
            genderButton("Nam")
            genderButton("Nữ")
            genderButton("Khác")
        }
    }

    private func genderButton(_ label: String) -> some View {
        let isSelected = viewModel.gender == label
        return Button { viewModel.gender = label } label: {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isSelected ? .white : DSColor.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.sm)
                .background(RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(isSelected ? DSColor.brandPrimary : DSColor.backgroundSecondary))
        }
    }

    private var birthdayRow: some View {
            HStack(spacing: DSSpacing.sm) {
                dayMonthYearBox(prefix: "", options: Array(1...31), selection: $viewModel.birthDay)
                dayMonthYearBox(prefix: "Tháng", options: Array(1...12), selection: $viewModel.birthMonth)
                dayMonthYearBox(prefix: "", options: viewModel.yearRange, selection: $viewModel.birthYear, isYear: true)
            }
        }

        private func dayMonthYearBox(
            prefix: String,
            options: [Int],
            selection: Binding<Int>,
            isYear: Bool = false
        ) -> some View {
            let formatValue: (Int) -> String = { value in
                if isYear {
                    return String(format: "%d", value)
                }
                return prefix.isEmpty ? "\(value)" : "\(prefix) \(value)"
            }

            return Menu {
                ForEach(options, id: \.self) { value in
                    Button(formatValue(value)) {
                        selection.wrappedValue = value
                    }
                }
            } label: {
                HStack {
                    Text(formatValue(selection.wrappedValue))
                        .font(.system(size: 15))
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(DSColor.borderDefault, lineWidth: 1)
                )
            }
        }

    private var socialLinksSection: some View {
        VStack(spacing: DSSpacing.sm) {
            socialLinkBox(label: "Facebook", labelColor: .blue, text: $viewModel.facebookLink)
            socialLinkBox(label: "Discord", labelColor: .purple, text: $viewModel.discordLink)
        }
    }

    private func socialLinkBox(label: String, labelColor: Color, text: Binding<String>) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(labelColor)
                .frame(width: 70, alignment: .leading)
            TextField("https://...", text: text)
                .font(.system(size: 14))
                .keyboardType(.URL).textInputAutocapitalization(.never).autocorrectionDisabled()
                .padding(.horizontal, DSSpacing.sm).padding(.vertical, DSSpacing.xs)
                .background(RoundedRectangle(cornerRadius: 10).fill(DSColor.backgroundSecondary))
        }
    }

    private var actionButtons: some View {
        HStack(spacing: DSSpacing.sm) {
            Button("Huỷ") { onCancel() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DSColor.brandPrimary)
                .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.sm)
                .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))

            Button {
                viewModel.save()
            } label: {
                if viewModel.submissionState.isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Lưu thay đổi").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.sm)
            .background(Capsule().fill(DSColor.brandPrimary))
        }
    }
}
