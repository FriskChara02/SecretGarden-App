//
//  ProfileDetailView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import DesignSystem
import FactoryKit
import Repositories
import SwiftUI

enum ProfileDetailTab: String, CaseIterable {
    case info = "Trang cá nhân"
    case account = "Tài khoản"
    case notifications = "Thông báo"
    case blockList = "Danh sách chặn"
}

struct ProfileDetailView: View {
    let currentUser: User?
    let onHeaderTapped: () -> Void
    let onEditTapped: () -> Void
    let onUserUpdated: (User) -> Void

    @State private var selectedTab: ProfileDetailTab = .info

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)
                tabBar

                switch selectedTab {
                case .info:
                    ProfileInfoTabView(currentUser: currentUser, onEditTapped: onEditTapped)
                case .account:
                    if let currentUser {
                        AccountSettingsView(
                            currentUser: currentUser,
                            userRepository: Container.shared.userRepository(),
                            authRepository: Container.shared.authRepository(),
                            onUserUpdated: onUserUpdated
                        )
                    } else {
                        placeholderTab("Vui lòng đăng nhập để xem Tài khoản")
                    }
                case .notifications:
                    placeholderTab("Thông báo — Step 12.8")
                case .blockList:
                    placeholderTab("Danh sách chặn — Step 12.9-10")
                }
            }
        }
        .background(DSColor.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(ProfileDetailTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    VStack(spacing: DSSpacing.xs) {
                        Text(tab.rawValue)
                            .dsFont(.subheadline)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                            .foregroundStyle(selectedTab == tab ? DSColor.brandPrimary : DSColor.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Rectangle()
                            .fill(selectedTab == tab ? DSColor.brandPrimary : .clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
    }

    private func placeholderTab(_ text: String) -> some View {
        Text(text)
            .dsFont(.headline)
            .foregroundStyle(DSColor.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, DSSpacing.xxl)
    }
}
