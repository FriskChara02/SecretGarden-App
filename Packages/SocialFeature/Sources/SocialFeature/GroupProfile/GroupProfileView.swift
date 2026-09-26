//
//  GroupProfileView.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 12/9/26.
//

import CoreArchitecture
import CoreModels
import DesignSystem
import Repositories
import SwiftUI

public struct GroupProfileView: View {
    @StateObject private var viewModel: GroupProfileViewModel
    @State private var seriesLayout: SeriesCardLayout = .list
    @Environment(\.colorScheme) private var colorScheme
    let onHeaderTapped: () -> Void
    let onSeriesSelected: (String) -> Void

    public init(
        groupId: String, groupRepository: GroupRepositoryProtocol,
        onHeaderTapped: @escaping () -> Void = {},
        onSeriesSelected: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: GroupProfileViewModel(groupId: groupId, groupRepository: groupRepository))
        self.onHeaderTapped = onHeaderTapped
        self.onSeriesSelected = onSeriesSelected
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GardenHeaderView(onTap: onHeaderTapped)

                switch viewModel.detailState {
                case .idle, .loading:
                    ProgressView().frame(maxWidth: .infinity).padding(.top, DSSpacing.xxl)
                case .loaded(let group):
                    headerSection(group)
                        .padding(.bottom, DSSpacing.xxl)
                    membersSection
                        .padding(.bottom, DSSpacing.lg)
                    DSSectionDivider()
                        .padding(.vertical, DSSpacing.lg)
                    seriesSection
                        .padding(.bottom, DSSpacing.lg)
                    DSSectionDivider()
                        .padding(.vertical, DSSpacing.lg)
                    highlightsSection
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
                    backgroundColor: colorScheme == .dark ? DSColor.backgroundSecondary : DSColor.backgroundPrimary,
                    onPolicyTapped: {}
                )
                .padding(.top, DSSpacing.xl)
            }
        }
        .background(DSColor.backgroundSecondary)
        .onAppear { viewModel.onAppear() }
        .dsSuccessToast(message: $viewModel.successMessage)
        .alert(
            "Có lỗi xảy ra",
            isPresented: Binding(
                get: { viewModel.actionErrorMessage != nil },
                set: { if !$0 { viewModel.dismissActionError() } }
            )
        ) {
            Button("Đóng", role: .cancel) { viewModel.dismissActionError() }
        } message: {
            Text(viewModel.actionErrorMessage ?? "")
        }
    }

    // MARK: - Header (banner + avatar + follow + notify)

    private func headerSection(_ group: TranslationGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            bannerAndAvatar(group)

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                followRow(group)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.sm)

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                infoRows(group)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.md)
        }
    }

    private func bannerAndAvatar(_ group: TranslationGroup) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                LinearGradient(colors: [DSColor.brandPrimaryLight.opacity(0.4), DSColor.brandPrimary.opacity(0.6)],
                                startPoint: .top, endPoint: .bottom)

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
                avatarImage(group.avatarURL)
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(group.name).dsFont(.title3).fontWeight(.bold)
                    Text("@\(group.id)").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.leading, DSSpacing.md)
            .offset(y: 36)
        }
        .padding(.bottom, 36)
    }

    private func avatarImage(_ url: URL?) -> some View {
        DSCachedAsyncImage(url: url, resize: .size(CGSize(width: 88, height: 88))) { phase in
            if case .success(let image) = phase {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Circle().fill(DSColor.backgroundSecondary)
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(Circle())
        .overlay { Circle().strokeBorder(.white, lineWidth: 3) }
        .shadow(radius: 2)
    }

    private func followRow(_ group: TranslationGroup) -> some View {
        HStack(spacing: DSSpacing.md) {
            Button { viewModel.toggleFollow() } label: {
                HStack(spacing: DSSpacing.xxs) {
                    Image(systemName: group.isFollowedByMe ? "person.fill.checkmark" : "person.badge.plus")
                    Text(group.isFollowedByMe ? "Đang theo dõi" : "Theo dõi")
                }
                .dsFont(.subheadline).fontWeight(.bold)
                .foregroundStyle(group.isFollowedByMe ? DSColor.brandPrimary : .white)
                .lineLimit(1)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.sm)
                .frame(minWidth: 150)
                .fixedSize(horizontal: true, vertical: false)
                .background(Capsule().fill(group.isFollowedByMe ? DSColor.brandPrimary.opacity(0.15) : DSColor.brandPrimary))
                .overlay {
                    if group.isFollowedByMe { Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5) }
                }
            }
            .disabled(viewModel.isTogglingFollow)

            Toggle("", isOn: Binding(get: { group.isNotifyEnabled }, set: { _ in viewModel.toggleNotify() }))
                .labelsHidden().toggleStyle(DSBellToggleStyle())
                .disabled(!group.isFollowedByMe || viewModel.isTogglingNotify)
                .opacity(group.isFollowedByMe ? 1 : 0.4)

            Text("Nhận thông báo").dsFont(.subheadline).fontWeight(.bold)
        }
        .frame(height: 44)
    }

    private func infoRows(_ group: TranslationGroup) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            VStack(alignment: .center, spacing: DSSpacing.sm) {
                Image(systemName: "info.circle")
                Image(systemName: "person.2.fill")
                if let socialLinks = group.socialLinks, !socialLinks.isEmpty {
                    Image(systemName: "globe")
                }
                Image(systemName: "person.fill")
            }
            .foregroundStyle(DSColor.brandPrimary)
            .frame(width: 20)

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text(group.description ?? "Chưa có mô tả")
                    .dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                Text("\(group.followerCount) người theo dõi")
                    .dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                if let socialLinks = group.socialLinks, !socialLinks.isEmpty {
                    socialLinksRow(socialLinks)
                }
                Text("\(group.members?.count ?? 0) thành viên")
                    .dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
            }
        }
    }

    private func socialLinksRow(_ links: [String: String]) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Text("Mạng xã hội:").dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
            ForEach(links.keys.sorted(), id: \.self) { key in
                if let url = links[key], let linkURL = URL(string: url) {
                    Link(destination: linkURL) {
                        Image(systemName: key == "facebook" ? "f.circle.fill" : "globe")
                    }
                }
            }
        }
    }

    // MARK: - Members section

    private var membersSection: some View {
        DSDecorativeCard {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                sectionTitle("Thành viên nhóm")

                switch viewModel.membersState {
                case .loaded(let members):
                    VStack(spacing: DSSpacing.lg) {
                        ForEach(members) { memberRow($0) }
                    }
                default:
                    ProgressView()
                }
            }
            .padding(DSSpacing.lg)
        }
        .padding(.horizontal, DSSpacing.md)
    }

    private func memberRow(_ member: GroupMember) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.md) {
            Image(systemName: "diamond.fill").font(.system(size: 7)).foregroundStyle(.brown.opacity(0.55)).padding(.top, 4)

            DSCachedAsyncImage(url: member.user.avatarURL, resize: .size(CGSize(width: 52, height: 52))) { phase in
                if case .success(let img) = phase { img.resizable().aspectRatio(contentMode: .fill) }
                else { Circle().fill(DSColor.backgroundSecondary) }
            }
            .frame(width: 52, height: 52).clipShape(Circle())
            .overlay { Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 2) }

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                HStack(spacing: DSSpacing.xs) {
                    Text(member.user.username).dsFont(.headline).fontWeight(.bold)
                    if member.role.lowercased() == "leader" { leaderBadge }
                }
                Rectangle().fill(DSColor.brandPrimary.opacity(0.35)).frame(height: 1)
                if let bio = member.user.bio, !bio.isEmpty {
                    Text(bio).dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                } else {
                    Text("Chưa có giới thiệu").dsFont(.caption).foregroundStyle(DSColor.textSecondary.opacity(0.6))
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var leaderBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill").font(.system(size: 9))
            Text("LEADER").font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, DSSpacing.xs)
        .padding(.vertical, 2)
        .background(Capsule().fill(DSColor.leaderBadgeAccent))
    }

    // MARK: - Series section (reusing SeriesCardView)

    private var seriesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                sectionTitle("Truyện Của Nhóm")
                Spacer()
                layoutToggle
            }
            .padding(.horizontal, DSSpacing.md)

            switch viewModel.seriesState {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
            case .loaded(let series) where series.isEmpty:
                Text("Nhóm chưa có truyện nào").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
            case .loaded(let series):
                seriesGrid(series)
            case .failed:
                Text("Không tải được truyện của nhóm")
                    .dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    private var layoutToggle: some View {
        HStack(spacing: DSSpacing.sm) {
            toggleIcon(systemName: "square.grid.2x2.fill", isActive: seriesLayout == .grid) { seriesLayout = .grid }
            toggleIcon(systemName: "list.bullet", isActive: seriesLayout == .list) { seriesLayout = .list }
        }
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
    }

    @ViewBuilder
    private func seriesGrid(_ series: [Series]) -> some View {
        switch seriesLayout {
        case .list:
            VStack(spacing: DSSpacing.md) {
                ForEach(series) { item in
                    SeriesCardView(data: GroupSeriesCardMapper.map(item), layout: .list) {
                        onSeriesSelected(item.id)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        case .grid:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
                ForEach(series) { item in
                    SeriesCardView(data: GroupSeriesCardMapper.map(item), layout: .grid) {
                        onSeriesSelected(item.id)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }

    // MARK: - Shared pieces

    private func sectionTitle(_ text: String) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "diamond.inset.filled").font(.caption2)
            Text(text).dsFont(.title3)
            Image(systemName: "diamond.inset.filled").font(.caption2)
        }
        .foregroundStyle(DSColor.brandPrimary)
    }

    private var errorState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 32)).foregroundStyle(DSColor.statusError)
            Text("Không tải được trang nhóm dịch").dsFont(.subheadline)
            DSButton("Thử lại", variant: .outline) { viewModel.loadDetail() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xxl)
    }
    
    private var highlightsSection: some View {
        DSRankingSection(
            title: "Nổi Bật Của Nhóm",
            items: viewModel.highlightsState.value?.map(GroupHighlightMapper.map) ?? [],
            isLoading: viewModel.highlightsState.isLoading,
            errorMessage: viewModel.highlightsState.error?.errorDescription,
            selectedSortBy: GroupHighlightMapper.map(viewModel.selectedHighlightsSortBy),
            selectedRange: GroupHighlightMapper.map(viewModel.selectedHighlightsRange),
            onFilterChanged: { dsRange, dsSortBy in
                viewModel.changeHighlightsFilter(
                    range: GroupHighlightMapper.map(dsRange),
                    sortBy: GroupHighlightMapper.map(dsSortBy)
                )
            },
            onRetry: { viewModel.loadHighlights() },
            onItemSelected: { onSeriesSelected($0) }
        )
    }
}
