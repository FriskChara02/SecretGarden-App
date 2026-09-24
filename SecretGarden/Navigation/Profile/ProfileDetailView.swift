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
    let onUserUpdated: (User) -> Void
    let onSuccessMessage: (String) -> Void

    @State private var selectedTab: ProfileDetailTab = .info
    @State private var isEditProfilePresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)
                ProfileSubTabBar(selectedTab: $selectedTab)

                switch selectedTab {
                case .info:
                    ProfileInfoTabView(
                        currentUser: currentUser,
                        onEditTapped: { isEditProfilePresented = true },
                        userRepository: Container.shared.userRepository(),
                        onUserUpdated: onUserUpdated
                    )
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
                    if currentUser != nil {
                        NotificationSettingsView(repository: Container.shared.notificationSettingsRepository())
                    } else {
                        placeholderTab("Vui lòng đăng nhập để xem Thông báo")
                    }
                case .blockList:
                    if currentUser != nil {
                        BlockListView(
                            repository: Container.shared.blockListRepository(),
                            searchRepository: Container.shared.searchRepository(),
                            onSuccessMessage: onSuccessMessage
                        )
                    } else {
                        placeholderTab("Vui lòng đăng nhập để xem Danh sách chặn")
                    }
                }
            }
        }
        .background(DSColor.backgroundPrimary)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $isEditProfilePresented) {
            if let currentUser {
                EditProfileView(
                    currentUser: currentUser,
                    userRepository: Container.shared.userRepository(),
                    onSaved: { updated in
                        onUserUpdated(updated)
                        isEditProfilePresented = false
                    },
                    onCancel: { isEditProfilePresented = false }
                )
            }
        }
    }

    private func placeholderTab(_ text: String) -> some View {
        Text(text)
            .dsFont(.headline)
            .foregroundStyle(DSColor.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, DSSpacing.xxl)
    }
}

struct ProfileSubTabBar: View {
    @Binding var selectedTab: ProfileDetailTab

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.lg) {
                ForEach(ProfileDetailTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                    } label: {
                        VStack(spacing: DSSpacing.xxs) {
                            Text(tab.rawValue.uppercased())
                                .font(.system(size: 15, weight: selectedTab == tab ? .bold : .semibold))
                                .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.6))
                                .fixedSize()
                            Rectangle()
                                .fill(selectedTab == tab ? .white : .clear)
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
        .padding(.vertical, DSSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [DSColor.brandPrimary, DSColor.brandPrimary.opacity(0.85)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
