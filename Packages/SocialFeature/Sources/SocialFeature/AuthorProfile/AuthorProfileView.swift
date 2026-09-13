//
//  AuthorProfileView.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

// Shared UI for Author and Artist — the only difference is the `roleLabel` passed from the caller
// (SeriesDetailView knows whether it is being pushed from series.author or series.artist).

import CoreArchitecture
import CoreModels
import DesignSystem
import Repositories
import SwiftUI

public struct AuthorProfileView: View {
    @StateObject private var viewModel: AuthorProfileViewModel
    @State private var seriesLayout: SeriesCardLayout = .list
    let roleLabel: String
    let onSeriesSelected: (String) -> Void

    public init(
        authorId: String,
        roleLabel: String,
        authorRepository: AuthorRepositoryProtocol,
        onSeriesSelected: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AuthorProfileViewModel(
            authorId: authorId,
            authorRepository: authorRepository
        ))
        self.roleLabel = roleLabel
        self.onSeriesSelected = onSeriesSelected
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                switch viewModel.detailState {
                case .idle, .loading:
                    ProgressView().padding(.top, DSSpacing.xxl)
                case .loaded(let author):
                    headerSection(author)
                    DSSectionDivider()
                    seriesSection
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

    // MARK: - Header

    private func headerSection(_ author: AuthorGroupCommon) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            HStack(spacing: DSSpacing.md) {
                avatarImage(author.avatarURL)
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text("\(roleLabel): \(author.name)")
                        .dsFont(.title3)
                        .fontWeight(.bold)
                    if let socialLink = author.socialLink, let url = URL(string: socialLink) {
                        Link(socialLink, destination: url)
                            .dsFont(.footnote)
                            .foregroundStyle(DSColor.info)
                            .lineLimit(1)
                    }
                }
            }

            followRow(author)

            Text(author.bio ?? "Chưa có mô tả")
                .dsFont(.subheadline)
                .foregroundStyle(author.bio == nil ? DSColor.textSecondary.opacity(0.6) : DSColor.textPrimary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.lg)
    }

    private func avatarImage(_ url: URL?) -> some View {
        AsyncImage(url: url) { phase in
            if case .success(let image) = phase {
                image.resizable().aspectRatio(contentMode: .fill)
            } else {
                Circle().fill(DSColor.backgroundSecondary)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
        .overlay { Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 2) }
    }

    private func followRow(_ author: AuthorGroupCommon) -> some View {
        HStack(spacing: DSSpacing.md) {
            DSButton(
                author.isFollowedByMe ? "Đang theo dõi" : "Theo dõi",
                variant: author.isFollowedByMe ? .outline : .primary,
                size: .medium,
                isLoading: viewModel.isTogglingFollow
            ) {
                viewModel.toggleFollow()
            }

            HStack(spacing: DSSpacing.xs) {
                Toggle("", isOn: Binding(
                    get: { author.isNotifyEnabled },
                    set: { _ in viewModel.toggleNotify() }
                ))
                .labelsHidden()
                .toggleStyle(DSBellToggleStyle())
                .disabled(!author.isFollowedByMe || viewModel.isTogglingNotify)
                .opacity(author.isFollowedByMe ? 1 : 0.4)

                Text("Nhận thông báo").dsFont(.subheadline)
            }
        }
    }

    // MARK: - Series section (reusing SeriesCardView + GroupSeriesCardMapper in the same package)

    private var seriesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                sectionTitle("Truyện của \(roleLabel)")
                Spacer()
                layoutToggle
            }
            .padding(.horizontal, DSSpacing.md)

            switch viewModel.seriesState {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
            case .loaded(let series) where series.isEmpty:
                Text("Chưa có truyện nào").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
            case .loaded(let series):
                seriesList(series)
                if viewModel.totalPages > 1 {
                    DSPageIndicator(
                        currentPage: viewModel.currentPage,
                        totalPages: viewModel.totalPages
                    ) { page in
                        viewModel.loadSeries(page: page)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, DSSpacing.sm)
                }
            case .failed:
                Text("Không tải được danh sách truyện")
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
    private func seriesList(_ series: [Series]) -> some View {
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
            Text("Không tải được trang \(roleLabel.lowercased())").dsFont(.subheadline)
            DSButton("Thử lại", variant: .outline) { viewModel.loadDetail() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xxl)
    }
}
