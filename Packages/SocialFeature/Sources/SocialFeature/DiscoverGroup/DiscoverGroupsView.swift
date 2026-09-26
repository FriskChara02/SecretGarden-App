//
//  DiscoverGroupsView.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

import CoreArchitecture
import CoreModels
import Repositories
import DesignSystem
import SwiftUI

public struct DiscoverGroupsView: View {
    @StateObject private var viewModel: DiscoverGroupsViewModel
    @State private var isSortMenuExpanded = false
    @State private var layout: SeriesCardLayout = .list
    
    let onHeaderTapped: () -> Void
    let onGroupSelected: (String) -> Void

    public init(
        groupRepository: GroupRepositoryProtocol,
        onHeaderTapped: @escaping () -> Void = {},
        onGroupSelected: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: DiscoverGroupsViewModel(groupRepository: groupRepository))
        self.onHeaderTapped = onHeaderTapped
        self.onGroupSelected = onGroupSelected
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)

                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    headerRow
                    searchBar
                    sortDropdown
                }
                .padding(.top, DSSpacing.lg)
                .zIndex(2)

                VStack(alignment: .leading, spacing: 0) {
                    switch viewModel.state {
                    case .idle, .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, DSSpacing.xl)
                    case .loaded(let groups) where groups.isEmpty:
                        Text("Không tìm thấy nhóm dịch nào")
                            .dsFont(.subheadline)
                            .foregroundStyle(DSColor.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, DSSpacing.xl)
                    case .loaded(let groups):
                        groupsContainer(groups)
                    case .failed:
                        errorState
                    }
                }
                .zIndex(1)

                Spacer(minLength: DSSpacing.xxl * 3)

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
            }
            .frame(minHeight: UIScreen.main.bounds.height, alignment: .top)
        }
        .background(DSColor.backgroundSecondary)
        .onAppear { viewModel.onAppear() }
        .overlay {
            Color.black.opacity(isSortMenuExpanded ? 0.001 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(isSortMenuExpanded)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isSortMenuExpanded = false
                    }
                }
        }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "diamond.inset.filled").font(.caption2)
            Text("Danh Sách Nhóm Dịch").dsFont(.title3)
            Image(systemName: "diamond.inset.filled").font(.caption2)
        }
        .foregroundStyle(DSColor.brandPrimary)
        .padding(.horizontal, DSSpacing.md)
    }

    private func toggleIcon(systemName: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isActive ? .white : DSColor.brandPrimary)
                .frame(width: 32, height: 32)
                .background(isActive ? DSColor.brandPrimary : DSColor.backgroundPrimary)
                .clipShape(Circle())
                .overlay { Circle().strokeBorder(DSColor.brandPrimary, lineWidth: isActive ? 0 : 1.5) }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }

    // MARK: - Search & Sort

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass").foregroundStyle(DSColor.textSecondary)
            TextField("Tìm kiếm nhóm...", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
        }
        .padding(DSSpacing.sm)
        .background(DSColor.backgroundPrimary)
        .clipShape(Capsule())
        .overlay { Capsule().strokeBorder(DSColor.borderDefault, lineWidth: 1) }
        .padding(.horizontal, DSSpacing.md)
        .contentShape(Capsule())
    }

    // MARK: - Sort dropdown

    private var sortDropdown: some View {
        HStack(spacing: DSSpacing.sm) {
            sortButton
            toggleIcon(systemName: "square.grid.2x2.fill", isActive: layout == .grid) { layout = .grid }
            toggleIcon(systemName: "list.bullet", isActive: layout == .list) { layout = .list }
        }
        .padding(.horizontal, DSSpacing.md)
        .overlay(alignment: .topLeading) {
            if isSortMenuExpanded {
                VStack(spacing: 0) {
                    ForEach(GroupDiscoverSort.allCases) { sort in
                        sortOptionRow(sort)
                        if sort != GroupDiscoverSort.allCases.last { Divider() }
                    }
                }
                .background(DSColor.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                .overlay(RoundedRectangle(cornerRadius: DSRadius.md).strokeBorder(DSColor.borderDefault, lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .frame(width: 280)
                .offset(y: 54)
                .padding(.horizontal, DSSpacing.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .zIndex(10)
            }
        }
    }

    private var sortButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { isSortMenuExpanded.toggle() }
        } label: {
            HStack {
                Text(viewModel.selectedSort.displayName)
                    .dsFont(.callout).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
                Spacer()
                Image(systemName: "chevron.down").foregroundStyle(DSColor.brandPrimary)
            }
            .padding(DSSpacing.md)
            .background(DSColor.backgroundPrimary)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
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
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content Containers

    @ViewBuilder
    private func groupsContainer(_ groups: [TranslationGroup]) -> some View {
        switch layout {
        case .grid:
            VStack(spacing: DSSpacing.md) {
                ForEach(groups) { group in GroupListCard(group: group) { onGroupSelected(group.id) } }
            }
            .padding(.horizontal, DSSpacing.md).padding(.top, DSSpacing.md)
        case .list:
            VStack(spacing: DSSpacing.md) {
                ForEach(groups) { group in GroupBannerCard(group: group) { onGroupSelected(group.id) } }
            }
            .padding(.horizontal, DSSpacing.md).padding(.top, DSSpacing.md)
        }
    }

    private var errorState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(DSColor.statusError)
            Text("Không tải được danh sách nhóm").dsFont(.subheadline)
            DSButton("Thử lại", variant: .outline) { viewModel.load() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xl)
    }

    private struct GroupBannerCard: View {
        let group: TranslationGroup
        let onTap: () -> Void

        var body: some View {
            Button(action: onTap) {
                ZStack(alignment: .leading) {
                    backgroundImage
                    LinearGradient(colors: [.black.opacity(0.2), .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                    content
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                .overlay { RoundedRectangle(cornerRadius: DSRadius.lg).strokeBorder(DSColor.borderDefault, lineWidth: 1) }
                .contentShape(RoundedRectangle(cornerRadius: DSRadius.lg))
            }
            .buttonStyle(.plain)
        }

        private var content: some View {
            HStack(alignment: .center, spacing: DSSpacing.md) {
                DSCachedAsyncImage(url: group.avatarURL, resize: .size(CGSize(width: 60, height: 60))) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Circle().fill(DSColor.backgroundSecondary)
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay { Circle().strokeBorder(.white, lineWidth: 2) }

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .dsFont(.headline).fontWeight(.bold).foregroundStyle(.white)
                        .lineLimit(1)

                    HStack(spacing: DSSpacing.md) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2").font(.caption2)
                            Text("\(group.followerCount) người theo dõi")
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "calendar").font(.caption2)
                            Text(Self.dateFormatter.string(from: group.createdAt))
                                .lineLimit(1)
                        }
                    }
                    .dsFont(.caption)
                    .foregroundStyle(.white.opacity(0.9))

                    if let description = group.description, !description.isEmpty {
                        Text(description)
                            .dsFont(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(DSSpacing.md)
        }

        @ViewBuilder
        private var backgroundImage: some View {
            GeometryReader { geo in
                DSCachedAsyncImage(url: group.avatarURL, resize: .size(CGSize(width: geo.size.width, height: geo.size.height))) { phase in
                    if case .success(let img) = phase {
                        img.resizable()
                           .scaledToFill()
                           .frame(width: geo.size.width, height: geo.size.height)
                           .clipped()
                    } else {
                        LinearGradient(colors: [DSColor.brandPrimaryLight.opacity(0.5), DSColor.brandPrimary.opacity(0.75)],
                                       startPoint: .top, endPoint: .bottom)
                    }
                }
            }
        }

        private static let dateFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "dd/MM/yyyy"; return f }()
    }
}
