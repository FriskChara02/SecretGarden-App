//
//  DiscoverGroupsView.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

import CoreArchitecture
import Repositories
import DesignSystem
import SwiftUI

public struct DiscoverGroupsView: View {
    @StateObject private var viewModel: DiscoverGroupsViewModel
    @State private var isSortMenuExpanded = false
    let onGroupSelected: (String) -> Void

    public init(groupRepository: GroupRepositoryProtocol, onGroupSelected: @escaping (String) -> Void) {
        _viewModel = StateObject(wrappedValue: DiscoverGroupsViewModel(groupRepository: groupRepository))
        self.onGroupSelected = onGroupSelected
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                sectionTitle
                searchBar
                sortDropdown

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView().padding(.top, DSSpacing.xl)
                case .loaded(let groups) where groups.isEmpty:
                    Text("Không tìm thấy nhóm dịch nào")
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.textSecondary)
                        .padding(.top, DSSpacing.xl)
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
        .onTapGesture { isSortMenuExpanded = false }
    }

    private var sectionTitle: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "diamond.inset.filled").font(.caption2)
            Text("Danh Sách Nhóm Dịch").dsFont(.title3)
            Image(systemName: "diamond.inset.filled").font(.caption2)
        }
        .foregroundStyle(DSColor.brandPrimary)
    }

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass").foregroundStyle(DSColor.textSecondary)
            TextField("Tìm kiếm nhóm...", text: $viewModel.searchQuery)
        }
        .padding(DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
        .clipShape(Capsule())
        .overlay { Capsule().strokeBorder(DSColor.borderDefault, lineWidth: 1) }
        .padding(.horizontal, DSSpacing.md)
    }

    // MARK: - Sort dropdown

    private var sortDropdown: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { isSortMenuExpanded.toggle() }
            } label: {
                HStack {
                    Text(viewModel.selectedSort.displayName)
                        .dsFont(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(DSColor.brandPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(DSColor.brandPrimary)
                        .rotationEffect(.degrees(isSortMenuExpanded ? 180 : 0))
                }
                .padding(DSSpacing.md)
                .background(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }

            if isSortMenuExpanded {
                VStack(spacing: 0) {
                    ForEach(GroupDiscoverSort.allCases) { sort in
                        sortOptionRow(sort)
                        if sort != GroupDiscoverSort.allCases.last {
                            Divider()
                        }
                    }
                }
                .background(DSColor.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                .overlay { RoundedRectangle(cornerRadius: DSRadius.md).strokeBorder(DSColor.borderDefault, lineWidth: 1) }
                .padding(.top, DSSpacing.xs)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, DSSpacing.md)
    }

    private func sortOptionRow(_ sort: GroupDiscoverSort) -> some View {
        Button {
            viewModel.changeSort(sort)
            withAnimation(.easeInOut(duration: 0.15)) { isSortMenuExpanded = false }
        } label: {
            HStack {
                Text(sort.displayName)
                    .dsFont(.callout)
                    .fontWeight(sort == viewModel.selectedSort ? .bold : .regular)
                    .foregroundStyle(sort == viewModel.selectedSort ? DSColor.brandPrimary : DSColor.textPrimary)
                Spacer()
                if sort == viewModel.selectedSort {
                    Circle().fill(DSColor.brandPrimary).frame(width: 6, height: 6)
                }
            }
            .padding(DSSpacing.md)
            .background(sort == viewModel.selectedSort ? DSColor.brandPrimary.opacity(0.08) : Color.clear)
        }
    }

    private var errorState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 32)).foregroundStyle(DSColor.statusError)
            Text("Không tải được danh sách nhóm").dsFont(.subheadline)
            DSButton("Thử lại", variant: .outline) { viewModel.load() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xl)
    }
}
