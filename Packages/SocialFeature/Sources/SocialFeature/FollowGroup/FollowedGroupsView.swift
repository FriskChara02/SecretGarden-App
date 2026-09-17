//
//  FollowedGroupsView.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

import CoreArchitecture
import Repositories
import DesignSystem
import SwiftUI

public struct FollowedGroupsView: View {
    @StateObject private var viewModel: FollowedGroupsViewModel
    let onHeaderTapped: () -> Void
    let onGroupSelected: (String) -> Void
    let onDiscoverTapped: () -> Void

    public init(
        groupRepository: GroupRepositoryProtocol,
        onHeaderTapped: @escaping () -> Void = {},
        onGroupSelected: @escaping (String) -> Void,
        onDiscoverTapped: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: FollowedGroupsViewModel(groupRepository: groupRepository))
        self.onHeaderTapped = onHeaderTapped
        self.onGroupSelected = onGroupSelected
        self.onDiscoverTapped = onDiscoverTapped
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)

                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    sectionTitle
                    searchBar
                }
                .padding(.top, DSSpacing.lg)
                .padding(.horizontal, DSSpacing.md)

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView().frame(maxWidth: .infinity).padding(.top, DSSpacing.xxl)
                case .loaded(let groups) where groups.isEmpty:
                    emptyState.frame(minHeight: 560)
                case .loaded(let groups):
                    VStack(spacing: DSSpacing.md) {
                        ForEach(groups) { group in
                            GroupListCard(group: group) { onGroupSelected(group.id) }
                        }
                    }
                    .padding(.horizontal, DSSpacing.md).padding(.top, DSSpacing.md)
                case .failed:
                    errorState
                }

                GardenFooterView(
                    policyLinks: [
                        GardenFooterLink(title: "Chính sách bảo mật", action: {}),
                        GardenFooterLink(title: "Quy định", action: {}),
                        GardenFooterLink(title: "Điều khoản", action: {})
                    ],
                    socialLinks: [
                        GardenFooterLink(title: "Discord", action: {}),
                        GardenFooterLink(title: "Facebook", action: {})
                    ],
                    backgroundColor: DSColor.backgroundSecondary,
                    onPolicyTapped: {}
                )
                .padding(.top, DSSpacing.xl)
            }
        }
        .background(DSColor.backgroundSecondary)
        .onAppear { viewModel.onAppear() }
    }

    private var sectionTitle: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "diamond.inset.filled").font(.caption2)
            Text("Nhóm đã theo dõi").dsFont(.title3)
            Image(systemName: "diamond.inset.filled").font(.caption2)
        }
        .foregroundStyle(DSColor.brandPrimary)
    }

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass").foregroundStyle(DSColor.textSecondary)
            Text("Tìm kiếm nhóm...").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
            Spacer()
        }
        .padding(DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
        .clipShape(Capsule())
        .overlay { Capsule().strokeBorder(DSColor.borderDefault, lineWidth: 1) }
    }

    private var emptyState: some View {
            VStack {
                Spacer()
                VStack(spacing: DSSpacing.md) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 48))
                        .foregroundStyle(DSColor.textSecondary.opacity(0.4))
                    Text("Chưa theo dõi nhóm nào").dsFont(.headline)
                    Text("Bạn chưa theo dõi nhóm dịch nào. Hãy khám phá và ủng hộ các nhóm dịch nhé!")
                        .dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                        .multilineTextAlignment(.center).padding(.horizontal, DSSpacing.xl)

                    Button(action: onDiscoverTapped) {
                        HStack(spacing: DSSpacing.xs) {
                            Image(systemName: "safari")
                            Text("Khám Phá Nhóm").fontWeight(.bold)
                        }
                        .dsFont(.subheadline).foregroundStyle(DSColor.brandPrimary)
                        .padding(.horizontal, DSSpacing.xl).padding(.vertical, DSSpacing.sm)
                        .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }

    private var errorState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 32)).foregroundStyle(DSColor.statusError)
            Text("Không tải được danh sách nhóm").dsFont(.subheadline)
            DSButton("Thử lại", variant: .outline) { viewModel.load() }
        }
        .frame(maxWidth: .infinity).padding(.top, DSSpacing.xxl)
    }
}
