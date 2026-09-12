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
    let onSeriesSelected: (String) -> Void

    public init(
        groupId: String,
        groupRepository: GroupRepositoryProtocol,
        onSeriesSelected: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: GroupProfileViewModel(
            groupId: groupId,
            groupRepository: groupRepository
        ))
        self.onSeriesSelected = onSeriesSelected
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                switch viewModel.detailState {
                case .idle, .loading:
                    ProgressView().padding(.top, DSSpacing.xxl)
                case .loaded(let group):
                    headerSection(group)
                    DSSectionDivider()
                    membersSection
                    DSSectionDivider()
                    seriesSection
                    DSSectionDivider()
                    highlightsSection
                case .failed:
                    errorState
                }
            }
            .padding(.bottom, DSSpacing.xl)
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
        VStack(spacing: 0) {
            bannerAndAvatar(group)

            VStack(alignment: .leading, spacing: DSSpacing.md) {
                followRow(group)
                infoRows(group)
            }
            .padding(DSSpacing.md)
        }
    }

    private func bannerAndAvatar(_ group: TranslationGroup) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [DSColor.brandPrimaryLight.opacity(0.4), DSColor.brandPrimary.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 160)

            avatarImage(group.avatarURL)
                .offset(x: DSSpacing.md, y: 36)
        }
        .padding(.bottom, 36)
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(group.name)
                    .dsFont(.title3)
                    .fontWeight(.bold)
                Text("@\(group.id)")
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(.leading, 112)
            .padding(.bottom, DSSpacing.sm)
        }
    }

    private func avatarImage(_ url: URL?) -> some View {
        AsyncImage(url: url) { phase in
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
            DSButton(
                group.isFollowedByMe ? "Đang theo dõi" : "Theo dõi",
                variant: group.isFollowedByMe ? .outline : .primary,
                isLoading: viewModel.isTogglingFollow
            ) {
                viewModel.toggleFollow()
            }

            Toggle("Nhận thông báo", isOn: Binding(
                get: { group.isNotifyEnabled },
                set: { _ in viewModel.toggleNotify() }
            ))
            .labelsHidden()
            .toggleStyle(DSBellToggleStyle())
            .disabled(!group.isFollowedByMe || viewModel.isTogglingNotify)
            .opacity(group.isFollowedByMe ? 1 : 0.4)

            Text("Nhận thông báo")
                .dsFont(.subheadline)
                .foregroundStyle(DSColor.textPrimary)
        }
    }

    private func infoRows(_ group: TranslationGroup) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            infoRow(icon: "info.circle", text: group.description ?? "Chưa có mô tả")
            infoRow(icon: "person.2.fill", text: "\(group.followerCount) người theo dõi")
            if let socialLinks = group.socialLinks, !socialLinks.isEmpty {
                socialLinksRow(socialLinks)
            }
            infoRow(icon: "person.fill", text: "\(group.members?.count ?? 0) thành viên")
        }
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: icon).foregroundStyle(DSColor.brandPrimary)
            Text(text).dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
        }
    }

    private func socialLinksRow(_ links: [String: String]) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "globe").foregroundStyle(DSColor.brandPrimary)
            Text("Mạng xã hội:").dsFont(.subheadline)
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
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionTitle("Thành viên nhóm")

            switch viewModel.membersState {
            case .idle, .loading:
                ProgressView()
            case .loaded(let members):
                DSDecorativeCard {
                    VStack(spacing: 0) {
                        ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                            memberRow(member)
                            if index < members.count - 1 {
                                Divider().padding(.leading, 70)
                            }
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
            case .failed:
                Text("Không tải được danh sách thành viên")
                    .dsFont(.footnote)
                    .foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    private func memberRow(_ member: GroupMember) -> some View {
        HStack(spacing: DSSpacing.sm) {
            AsyncImage(url: member.user.avatarURL) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Circle().fill(DSColor.backgroundSecondary)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())
            .overlay { Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 2) }

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                HStack(spacing: DSSpacing.xs) {
                    Text(member.user.username).dsFont(.headline).fontWeight(.bold)
                    if member.role.lowercased() == "leader" {
                        leaderBadge
                    }
                }
                if let bio = member.user.bio, !bio.isEmpty {
                    Text(bio)
                        .dsFont(.caption)
                        .foregroundStyle(DSColor.textSecondary)
                        .lineLimit(1)
                } else {
                    Text("Chưa có giới thiệu")
                        .dsFont(.caption)
                        .foregroundStyle(DSColor.textSecondary.opacity(0.6))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(DSSpacing.sm)
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
            Button { seriesLayout = .grid } label: {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(seriesLayout == .grid ? .white : DSColor.brandPrimary)
                    .padding(DSSpacing.xs)
                    .background(Circle().fill(seriesLayout == .grid ? DSColor.brandPrimary : .clear))
                    .overlay { Circle().strokeBorder(DSColor.brandPrimary, lineWidth: seriesLayout == .grid ? 0 : 1.5) }
            }
            Button { seriesLayout = .list } label: {
                Image(systemName: "list.bullet")
                    .foregroundStyle(seriesLayout == .list ? .white : DSColor.brandPrimary)
                    .padding(DSSpacing.xs)
                    .background(Circle().fill(seriesLayout == .list ? DSColor.brandPrimary : .clear))
                    .overlay { Circle().strokeBorder(DSColor.brandPrimary, lineWidth: seriesLayout == .list ? 0 : 1.5) }
            }
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
