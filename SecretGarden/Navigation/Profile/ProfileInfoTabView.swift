//
//  ProfileInfoTabView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import DesignSystem
import Repositories
import UniformTypeIdentifiers
import SwiftUI

struct ProfileInfoTabView: View {
    let currentUser: User?
    let onEditTapped: () -> Void
    let userRepository: UserRepositoryProtocol
    let onUserUpdated: (User) -> Void

    @StateObject private var viewModel: ProfileInfoTabViewModel
    @State private var isAvatarMenuPresented = false
    @State private var isPhotoLibraryPresented = false
    @State private var isCameraPresented = false
    @State private var isFileImporterPresented = false

    init(
        currentUser: User?,
        onEditTapped: @escaping () -> Void,
        userRepository: UserRepositoryProtocol,
        onUserUpdated: @escaping (User) -> Void
    ) {
        self.currentUser = currentUser
        self.onEditTapped = onEditTapped
        self.userRepository = userRepository
        self.onUserUpdated = onUserUpdated
        _viewModel = StateObject(wrappedValue: ProfileInfoTabViewModel(userRepository: userRepository))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            sectionTitle
                .padding(.horizontal, DSSpacing.md)

            bannerAndAvatar

            if let bio = currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 16))
                    .foregroundStyle(DSColor.textPrimary)
                    .padding(.horizontal, DSSpacing.md)
            }

            DSSectionDivider().padding(.horizontal, DSSpacing.md)

            infoRows.padding(.horizontal, DSSpacing.md)

            DSSectionDivider().padding(.horizontal, DSSpacing.md)

            GardenFooterView(
                policyLinks: [GardenFooterLink(title: "Chính sách", action: {})],
                socialLinks: [
                    GardenFooterLink(title: "Discord", action: {}),
                    GardenFooterLink(title: "Facebook", action: {})
                ],
                onPolicyTapped: {}
            )
        }
        .padding(.top, DSSpacing.lg)
        .sheet(isPresented: $isPhotoLibraryPresented) {
            PhotoLibraryPicker(
                onImagePicked: { data in
                    isPhotoLibraryPresented = false
                    viewModel.uploadAvatar(
                        imageData: data,
                        fileName: "avatar.jpg",
                        mimeType: "image/jpeg",
                        onUploaded: onUserUpdated
                    )
                },
                onCancel: { isPhotoLibraryPresented = false }
            )
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraPicker(
                onImagePicked: { data in
                    isCameraPresented = false
                    viewModel.uploadAvatar(
                        imageData: data,
                        fileName: "avatar.jpg",
                        mimeType: "image/jpeg",
                        onUploaded: onUserUpdated
                    )
                },
                onCancel: { isCameraPresented = false }
            )
        }
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.image]) { result in
            guard let url = try? result.get(), let data = try? Data(contentsOf: url) else { return }
            viewModel.uploadAvatar(
                imageData: data,
                fileName: "avatar.jpg",
                mimeType: "image/jpeg",
                onUploaded: onUserUpdated
            )
        }
        .alert(
            "Có lỗi xảy ra",
            isPresented: Binding(
                get: { viewModel.uploadErrorMessage != nil },
                set: { if !$0 { viewModel.uploadErrorMessage = nil } }
            )
        ) {
            Button("Đã hiểu", role: .cancel) {}
        } message: {
            Text(viewModel.uploadErrorMessage ?? "")
        }
    }
}

private extension ProfileInfoTabView {
    var sectionTitle: some View {
        HStack {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.inset.filled").font(.system(size: 12)).foregroundStyle(DSColor.brandPrimary)
                Text("Thông tin cá nhân").font(.system(size: 20, weight: .bold)).foregroundStyle(DSColor.brandPrimary)
                Image(systemName: "diamond.inset.filled").font(.system(size: 12)).foregroundStyle(DSColor.brandPrimary)
            }
            Spacer()
            if currentUser != nil {
                Button(action: onEditTapped) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundStyle(DSColor.brandPrimary)
                        .frame(width: 38, height: 38)
                        .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                }
            }
        }
    }

    private var bannerAndAvatar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                bannerFill
                LinearGradient(colors: [.white.opacity(0.9), .white.opacity(0)], startPoint: .leading, endPoint: .trailing)
                    .frame(width: proxy.size.width - 60, height: 52.5)
                    .offset(x: 60)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(height: 160)
        .clipped()
        .overlay(alignment: .bottomLeading) {
            HStack(alignment: .center, spacing: DSSpacing.lg) {
                avatarImageButton
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(currentUser?.username ?? "Khách")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(DSColor.textPrimary)
                    if let displayName = currentUser?.displayName {
                        Text("@\(displayName)").font(.system(size: 15)).foregroundStyle(DSColor.textSecondary)
                    }
                }
            }
            .padding(.leading, DSSpacing.md)
            .offset(y: 36)
        }
        .padding(.bottom, 36)
    }

    @ViewBuilder
    private var bannerFill: some View {
        if let url = currentUser?.bannerURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                default:
                    fallbackBanner
                }
            }
        } else {
            fallbackBanner
        }
    }

    private var fallbackBanner: some View {
        LinearGradient(
            colors: [DSColor.brandPrimaryLight.opacity(0.4), DSColor.brandPrimary.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    private var avatarImageButton: some View {
        if currentUser != nil {
            avatarImage
                .contentShape(Circle())
                .onTapGesture {
                    isAvatarMenuPresented = true
                }
                .overlay {
                    if viewModel.isUploadingAvatar {
                        Circle()
                            .fill(.black.opacity(0.4))
                            .frame(width: 88, height: 88)
                        ProgressView().tint(.white)
                    }
                }
                .popover(isPresented: $isAvatarMenuPresented, attachmentAnchor: .point(.bottom)) {
                    VStack(spacing: 0) {
                        Button {
                            isAvatarMenuPresented = false
                            isPhotoLibraryPresented = true
                        } label: {
                            HStack {
                                Text("Photo Library")
                                Spacer()
                                Image(systemName: "photo.on.rectangle")
                            }
                            .padding()
                        }

                        Divider().background(Color.white.opacity(0.2))

                        Button {
                            isAvatarMenuPresented = false
                            isCameraPresented = true
                        } label: {
                            HStack {
                                Text("Take Photo")
                                Spacer()
                                Image(systemName: "camera")
                            }
                            .padding()
                        }

                        Divider().background(Color.white.opacity(0.2))

                        Button {
                            isAvatarMenuPresented = false
                            isFileImporterPresented = true
                        } label: {
                            HStack {
                                Text("Choose File")
                                Spacer()
                                Image(systemName: "folder")
                            }
                            .padding()
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 200)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .presentationCompactAdaptation(.popover)
                }
        } else {
            avatarImage
        }
    }

    private var avatarImage: some View {
        Group {
            if let url = currentUser?.avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Circle().fill(DSColor.backgroundSecondary)
                    }
                }
            } else {
                Circle().fill(DSColor.backgroundSecondary)
                    .overlay { Image(systemName: "person.fill").foregroundStyle(DSColor.textSecondary) }
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(Circle())
        .clipped()
        .overlay { Circle().strokeBorder(.white, lineWidth: 3) }
        .shadow(radius: 2)
    }

    private var infoRows: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            infoRow(icon: "birthday.cake.fill", label: "NGÀY SINH", value: birthdayText)
            infoRow(icon: "figure.stand", label: "GIỚI TÍNH", value: currentUser?.gender ?? "Chưa cập nhật")
            infoRow(icon: "mappin.and.ellipse", label: "ĐỊA CHỈ", value: currentUser?.address ?? "Chưa cập nhật")
            infoRow(icon: "face.smiling", label: "SỞ THÍCH", value: currentUser?.interests ?? "Chưa cập nhật")
            if let joinedAt = currentUser?.joinedAt {
                infoRow(icon: "calendar", label: "NGÀY THAM GIA", value: Self.joinedDateFormatter.string(from: joinedAt))
            }
            if let links = currentUser?.socialLinks, !links.isEmpty {
                socialLinksRow(links)
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon).foregroundStyle(DSColor.brandPrimary).frame(width: 22)
            Text("\(label):")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 140, alignment: .leading)
            Text(value).font(.system(size: 16)).foregroundStyle(DSColor.textSecondary)
            Spacer()
        }
    }

    private func socialLinksRow(_ links: [String: String]) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: "globe").foregroundStyle(DSColor.brandPrimary).frame(width: 22)
            Text("MẠNG XÃ HỘI:")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 140, alignment: .leading)
            HStack(spacing: DSSpacing.sm) {
                ForEach(links.keys.sorted(), id: \.self) { key in
                    Image(systemName: key == "facebook" ? "f.square.fill" : "message.circle.fill")
                        .foregroundStyle(DSColor.brandPrimary)
                }
            }
            Spacer()
        }
    }

    private var birthdayText: String {
        guard let birthday = currentUser?.birthday else { return "Chưa cập nhật" }
        return Self.birthdayFormatter.string(from: birthday)
    }

    private static let birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        return formatter
    }()

    private static let joinedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
}
