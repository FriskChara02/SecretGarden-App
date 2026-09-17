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
    let onHeaderTapped: () -> Void
    let onSeriesSelected: (String) -> Void

    public init(
        authorId: String, roleLabel: String, authorRepository: AuthorRepositoryProtocol,
        onHeaderTapped: @escaping () -> Void = {},
        onSeriesSelected: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AuthorProfileViewModel(authorId: authorId, authorRepository: authorRepository))
        self.roleLabel = roleLabel
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
                case .loaded(let author):
                    headerRow(author)
                    linkBlock(author)
                    Rectangle().fill(DSColor.borderDefault.opacity(0.6)).frame(height: 1)
                        .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.md)
                    seriesSection
                        .frame(minHeight: 260)
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

    private func headerRow(_ author: AuthorGroupCommon) -> some View {
        HStack {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.inset.filled").font(.caption2)
                Text("\(roleLabel): \(author.name)").dsFont(.title3)
                Text("(\(viewModel.seriesState.value?.count ?? 0))").dsFont(.title3)
                Image(systemName: "diamond.inset.filled").font(.caption2)
            }
            .foregroundStyle(DSColor.brandPrimary)
            Spacer()
            HStack(spacing: DSSpacing.sm) {
                toggleIcon(systemName: "square.grid.2x2.fill", isActive: seriesLayout == .grid) { seriesLayout = .grid }
                toggleIcon(systemName: "list.bullet", isActive: seriesLayout == .list) { seriesLayout = .list }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.lg)
    }

    private func linkBlock(_ author: AuthorGroupCommon) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            ForEach(author.socialLinks ?? [], id: \.self) { link in
                if let url = URL(string: link) {
                    Link(link, destination: url)
                        .dsFont(.subheadline)
                        .foregroundStyle(DSColor.textSecondary)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.sm)
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

    private var seriesSection: some View {
        Group {
            switch viewModel.seriesState {
            case .idle, .loading:
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
            case .loaded(let series) where series.isEmpty:
                Text("Chưa có truyện nào").dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, DSSpacing.lg)
            case .loaded(let series):
                seriesList(series)
                if viewModel.totalPages > 1 {
                    DSPageIndicator(currentPage: viewModel.currentPage, totalPages: viewModel.totalPages) {
                        viewModel.loadSeries(page: $0)
                    }
                    .frame(maxWidth: .infinity).padding(.top, DSSpacing.sm)
                }
            case .failed:
                Text("Không tải được danh sách truyện").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
                    .padding(.horizontal, DSSpacing.md)
            }
        }
    }

    @ViewBuilder
    private func seriesList(_ series: [Series]) -> some View {
        switch seriesLayout {
        case .list:
            VStack(spacing: DSSpacing.md) {
                ForEach(series) { item in
                    SeriesCardView(data: GroupSeriesCardMapper.map(item), layout: .list) { onSeriesSelected(item.id) }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        case .grid:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DSSpacing.md) {
                ForEach(series) { item in
                    SeriesCardView(data: GroupSeriesCardMapper.map(item), layout: .grid) { onSeriesSelected(item.id) }
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }

    private var errorState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 32)).foregroundStyle(DSColor.statusError)
            Text("Không tải được trang \(roleLabel.lowercased())").dsFont(.subheadline)
            DSButton("Thử lại", variant: .outline) { viewModel.loadDetail() }
        }
        .frame(maxWidth: .infinity).padding(.top, DSSpacing.xxl)
    }
}
