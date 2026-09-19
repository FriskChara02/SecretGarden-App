//
//  ProfileInfoTabView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import DesignSystem
import SwiftUI

struct ProfileInfoTabView: View {
    let currentUser: User?
    let onEditTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            sectionTitle
            bannerAndAvatar

            if let bio = currentUser?.bio, !bio.isEmpty {
                Text(bio)
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textPrimary)
            }

            DSSectionDivider()

            infoRows

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
        .padding(DSSpacing.lg)
    }

    private var sectionTitle: some View {
        HStack {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
                Text("Thông tin cá nhân").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
                Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
            }
            Spacer()
            if currentUser != nil {
                Button(action: onEditTapped) {
                    Image(systemName: "pencil")
                        .foregroundStyle(DSColor.brandPrimary)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.2))
                }
            }
        }
    }

    private var bannerAndAvatar: some View {
        ZStack(alignment: .bottomLeading) {
            bannerView
            HStack(spacing: DSSpacing.sm) {
                avatarView
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentUser?.username ?? "Khách")
                        .dsFont(.headline).fontWeight(.bold).foregroundStyle(.white)
                    if let displayName = currentUser?.displayName {
                        Text("@\(displayName)").dsFont(.footnote).foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
            .padding(DSSpacing.sm)
            .background(.black.opacity(0.25))
        }
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }

    @ViewBuilder
    private var bannerView: some View {
        if let url = currentUser?.bannerURL {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    fallbackBanner
                }
            }
            .frame(height: 140).clipped()
        } else {
            fallbackBanner
        }
    }

    private var fallbackBanner: some View {
        LinearGradient(colors: [DSColor.brandPrimary, DSColor.brandPrimaryLight], startPoint: .top, endPoint: .bottom)
            .frame(height: 140)
    }

    private var avatarView: some View {
        Group {
            if let url = currentUser?.avatarURL {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Circle().fill(DSColor.backgroundSecondary)
                    }
                }
            } else {
                Circle().fill(DSColor.backgroundSecondary)
                    .overlay { Image(systemName: "person.fill").foregroundStyle(DSColor.textSecondary) }
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(.white, lineWidth: 2))
    }

    private var infoRows: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            infoRow(icon: "birthday.cake", label: "Ngày sinh", value: birthdayText)
            infoRow(icon: "figure.stand", label: "Giới tính", value: currentUser?.gender ?? "Chưa cập nhật")
            infoRow(icon: "mappin.circle", label: "Địa chỉ", value: currentUser?.address ?? "Chưa cập nhật")
            infoRow(icon: "face.smiling", label: "Sở thích", value: currentUser?.interests ?? "Chưa cập nhật")
            if let joinedAt = currentUser?.joinedAt {
                infoRow(icon: "calendar", label: "Ngày tham gia", value: Self.joinedDateFormatter.string(from: joinedAt))
            }
            if let links = currentUser?.socialLinks, !links.isEmpty {
                socialLinksRow(links)
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon).foregroundStyle(DSColor.brandPrimary).frame(width: 20)
            Text(label)
                .dsFont(.subheadline).fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 90, alignment: .leading)
            Text(value).dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
            Spacer()
        }
    }

    private func socialLinksRow(_ links: [String: String]) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: "globe").foregroundStyle(DSColor.brandPrimary).frame(width: 20)
            Text("Mạng xã hội")
                .dsFont(.subheadline).fontWeight(.bold)
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 90, alignment: .leading)
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
