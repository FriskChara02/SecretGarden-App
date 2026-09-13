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
    let onGroupSelected: (String) -> Void
    let onDiscoverTapped: () -> Void

    public init(
        groupRepository: GroupRepositoryProtocol,
        onGroupSelected: @escaping (String) -> Void,
        onDiscoverTapped: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: FollowedGroupsViewModel(groupRepository: groupRepository))
        self.onGroupSelected = onGroupSelected
        self.onDiscoverTapped = onDiscoverTapped
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                sectionTitle

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView().padding(.top, DSSpacing.xxl)
                case .loaded(let groups) where groups.isEmpty:
                    emptyState
                case .loaded(let groups):
                    ForEach(groups) { group in
                        GroupListCard(group: group) { onGroupSelected(group.id) }
                    }
                    .padding(.horizontal, DSSpacing.md)
                case .failed:
                    errorState
                }
            }
            .padding(.vertical, DSSpacing.lg)
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

    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundStyle(DSColor.textSecondary.opacity(0.4))
            Text("Chưa theo dõi nhóm nào")
                .dsFont(.headline)
            Text("Bạn chưa theo dõi nhóm dịch nào. Hãy khám phá và ủng hộ các nhóm dịch nhé!")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.xl)
            DSButton("Khám Phá Nhóm", variant: .outline) { onDiscoverTapped() }
                .padding(.horizontal, DSSpacing.xxl)
        }
        .padding(.top, DSSpacing.xl)
    }

    private var errorState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 32)).foregroundStyle(DSColor.statusError)
            Text("Không tải được danh sách nhóm").dsFont(.subheadline)
            DSButton("Thử lại", variant: .outline) { viewModel.load() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xxl)
    }
}
