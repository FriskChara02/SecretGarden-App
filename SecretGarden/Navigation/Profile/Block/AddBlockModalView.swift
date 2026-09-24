//
//  AddBlockModalView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/9/26.
//

import CoreArchitecture
import CoreModels
import DesignSystem
import SwiftUI

struct AddBlockModalView: View {
    @ObservedObject var viewModel: BlockListViewModel
    let category: BlockListCategory
    let onDismiss: () -> Void

    @State private var isDismissing = false

    var body: some View {
        BottomSheetContainer(
            isDismissing: isDismissing,
            onTapOutside: dismissWithAnimation
        ) {
            VStack(spacing: 0) {
                header
                searchField
                resultsList
            }
            .frame(height: 620, alignment: .top)
        }
        .ignoresSafeArea()
        .onAppear {
            if category == .tags {
                viewModel.loadTagOptions()
            }
        }
    }

    private func dismissWithAnimation() {
        isDismissing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "diamond.inset.filled")
                .font(.system(size: 9))
                .foregroundStyle(DSColor.brandPrimary)
            Text(category == .series ? "Chặn truyện" : "Chặn Tags")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.inset.filled")
                .font(.system(size: 9))
                .foregroundStyle(DSColor.brandPrimary)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
            Button(action: dismissWithAnimation) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(DSColor.brandPrimary)
            }
        }
        .padding(DSSpacing.lg)
    }

    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(DSColor.textSecondary)
            TextField(
                category == .series ? "Nhập tên truyện..." : "Tìm tag...",
                text: Binding(
                    get: { category == .series ? viewModel.seriesSearchQuery : viewModel.tagSearchQuery },
                    set: { newValue in
                        if category == .series {
                            viewModel.searchSeries(query: newValue)
                        } else {
                            viewModel.tagSearchQuery = newValue
                        }
                    }
                )
            )
        }
        .padding(DSSpacing.sm)
        .background(DSColor.backgroundSecondary)
        .clipShape(Capsule())
        .padding(.horizontal, DSSpacing.lg)
    }

    @ViewBuilder
    private var resultsList: some View {
        switch category {
        case .series:
            seriesResults
        case .tags:
            tagResults
        }
    }

    @ViewBuilder
    private var seriesResults: some View {
        switch viewModel.seriesSearchState {
        case .idle:
            emptyHint("Nhập từ khóa để tìm kiếm")
        case .loading:
            ProgressView()
                .padding(.top, DSSpacing.xl)
        case .failed:
            emptyHint("Không tìm được kết quả.")
        case .loaded(let results) where results.isEmpty:
            emptyHint("Không tìm thấy kết quả")
        case .loaded(let results):
            ScrollView {
                VStack(spacing: DSSpacing.sm) {
                    ForEach(results) { series in
                        resultRow(
                            title: series.title.uppercased(),
                            imageURL: series.coverURL,
                            isBlocked: viewModel.isSeriesBlocked(series.id)
                        ) {
                            viewModel.blockSeries(series)
                        }
                    }
                }
                .padding(DSSpacing.lg)
            }
        }
    }

    @ViewBuilder
    private var tagResults: some View {
        switch viewModel.tagOptionsState {
        case .idle, .loading:
            ProgressView()
                .padding(.top, DSSpacing.xl)
        case .failed:
            emptyHint("Không tải được danh sách tag.")
        case .loaded:
            ScrollView {
                VStack(spacing: DSSpacing.sm) {
                    ForEach(viewModel.filteredTagOptions) { tag in
                        resultRow(
                            title: tag.name,
                            imageURL: nil,
                            isBlocked: viewModel.isTagBlocked(tag.id),
                            showTagIcon: true
                        ) {
                            viewModel.blockTag(tag)
                        }
                    }
                }
                .padding(DSSpacing.lg)
            }
        }
    }

    private func resultRow(
        title: String,
        imageURL: URL?,
        isBlocked: Bool,
        showTagIcon: Bool = false,
        onBlock: @escaping () -> Void
    ) -> some View {
        HStack(spacing: DSSpacing.sm) {
            if showTagIcon {
                Image(systemName: "tag.fill")
                    .foregroundStyle(DSColor.brandPrimary)
            } else if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(DSColor.backgroundSecondary)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
            }

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DSColor.textPrimary)

            Spacer()

            Button(action: onBlock) {
                HStack(spacing: 4) {
                    if isBlocked {
                        Image(systemName: "checkmark")
                    }
                    Text(isBlocked ? "Đã chặn" : "Chặn")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isBlocked ? DSColor.statusSuccess : DSColor.textPrimary)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.xs)
                .background(Capsule().fill(DSColor.backgroundSecondary))
            }
            .disabled(isBlocked)
        }
    }

    private func emptyHint(_ text: String) -> some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(DSColor.textSecondary.opacity(0.4))
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xxl)
        .padding(.bottom, DSSpacing.xl)
    }
}
