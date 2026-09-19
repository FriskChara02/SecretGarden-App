//
//  ProfileMenuContentView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import DesignSystem
import SwiftUI

struct ProfileMenuContentView: View {
    let currentUser: User?
    let onLoginTapped: () -> Void
    let onLogoutTapped: () -> Void
    let onRowTapped: (ProfileRoute) -> Void

    /// TODO: replace with the actual ThemeManager - local placeholder,
    /// following the same pattern as ReaderMenuView.
    @State private var isDarkModePlaceholder = false

    private struct MenuRow: Identifiable {
        let id = UUID()
        let title: String
        let systemImage: String
        let route: ProfileRoute
    }

    private let rows: [MenuRow] = [
        MenuRow(title: "Trang cá nhân", systemImage: "person", route: .personalInfo),
        MenuRow(title: "Yêu thích", systemImage: "heart", route: .favorites),
        MenuRow(title: "Nhóm theo dõi", systemImage: "flag", route: .followedGroups),
        MenuRow(title: "Lịch sử", systemImage: "clock.arrow.circlepath", route: .history),
        MenuRow(title: "Danh mục", systemImage: "square.grid.2x2", route: .category),
        MenuRow(title: "Tìm kiếm nâng cao", systemImage: "magnifyingglass", route: .advancedSearch),
        MenuRow(title: "Yuri list", systemImage: "bookmark", route: .yuriList),
        MenuRow(title: "Đăng ký upload", systemImage: "square.and.arrow.up", route: .uploadRegistration),
        MenuRow(title: "Quy định", systemImage: "checkmark.shield", route: .rules)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            headerRow
            DSSectionDivider()

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                ForEach(rows) { row in
                    Button { onRowTapped(row.route) } label: {
                        HStack(spacing: DSSpacing.sm) {
                            Image(systemName: row.systemImage).frame(width: 22)
                            Text(row.title).fontWeight(.semibold)
                            Spacer()
                        }
                        .dsFont(.headline)
                        .foregroundStyle(DSColor.textPrimary)
                    }
                }
            }

            DSSectionDivider()
        }
        .padding(DSSpacing.lg)
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack(alignment: .top) {
            HStack(spacing: DSSpacing.sm) {
                avatarView
                VStack(alignment: .leading, spacing: 2) {
                    Text(currentUser?.username ?? "Khách")
                        .dsFont(.title3).fontWeight(.bold)
                        .foregroundStyle(DSColor.textPrimary)
                    Text(currentUser == nil ? "Vui lòng đăng nhập" : "@\(currentUser?.displayName ?? "")")
                        .dsFont(.footnote)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: DSSpacing.sm) {
                Button {
                    currentUser == nil ? onLoginTapped() : onLogoutTapped()
                } label: {
                    HStack(spacing: 4) {
                        Text(currentUser == nil ? "Đăng nhập" : "Đăng xuất")
                        Image(systemName: "arrow.right.square")
                    }
                    .dsFont(.subheadline).fontWeight(.bold)
                    .foregroundStyle(DSColor.brandPrimary)
                }
                Toggle("", isOn: $isDarkModePlaceholder)
                    .labelsHidden()
                    .toggleStyle(DSThemeToggleStyle())
            }
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if let url = currentUser?.avatarURL {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Circle().fill(DSColor.backgroundSecondary)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 48, height: 48)
                .foregroundStyle(DSColor.textSecondary.opacity(0.5))
        }
    }
}
