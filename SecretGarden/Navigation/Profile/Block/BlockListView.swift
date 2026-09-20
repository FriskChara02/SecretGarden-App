//
//  BlockListView.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/9/26.
//

import CoreArchitecture
import CoreModels
import DesignSystem
import Repositories
import SwiftUI

struct BlockListView: View {
    @StateObject private var viewModel: BlockListViewModel
    @State private var isCategoryPickerExpanded = false
    @State private var isAddBlockModalPresented = false

    init(repository: BlockListRepositoryProtocol, searchRepository: SearchRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: BlockListViewModel(repository: repository, searchRepository: searchRepository))
    }

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            sectionTitle
            categoryPicker

            switch viewModel.selectedCategory {
            case .series:
                seriesContent
            case .tags:
                tagsContent
            }
        }
        .padding(DSSpacing.lg)
        .onAppear { viewModel.onAppear() }
        .sheet(isPresented: $isAddBlockModalPresented) {
            AddBlockModalView(viewModel: viewModel, category: viewModel.selectedCategory)
        }
        .alert(
            "Có lỗi xảy ra",
            isPresented: Binding(get: { viewModel.actionErrorMessage != nil }, set: { if !$0 { viewModel.dismissActionError() } })
        ) {
            Button("Đã hiểu", role: .cancel) { viewModel.dismissActionError() }
        } message: {
            Text(viewModel.actionErrorMessage ?? "")
        }
    }

    private var sectionTitle: some View {
        HStack {
            Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
            Text("Danh sách chặn").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
        }
    }

    private var categoryPicker: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isCategoryPickerExpanded.toggle() }
            } label: {
                HStack {
                    Text("Chọn danh sách: \(viewModel.selectedCategory.rawValue)")
                    Spacer()
                    Image(systemName: isCategoryPickerExpanded ? "chevron.up" : "chevron.down")
                }
                .dsFont(.subheadline).fontWeight(.semibold)
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.horizontal, DSSpacing.md).padding(.vertical, DSSpacing.sm)
                .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }
            Button { isAddBlockModalPresented = true } label: {
                Image(systemName: "plus")
                    .foregroundStyle(DSColor.brandPrimary)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }
        }
        .overlay(alignment: .topLeading) {
            if isCategoryPickerExpanded {
                categoryDropdown.offset(y: 46).zIndex(1)
            }
        }
    }

    private var categoryDropdown: some View {
        VStack(spacing: 0) {
            ForEach(BlockListCategory.allCases, id: \.self) { category in
                Button {
                    viewModel.selectedCategory = category
                    withAnimation { isCategoryPickerExpanded = false }
                } label: {
                    HStack {
                        Image(systemName: category == .series ? "book" : "tag")
                        Text(category.rawValue)
                        Spacer()
                        if viewModel.selectedCategory == category {
                            Circle().fill(DSColor.brandPrimary).frame(width: 6, height: 6)
                        }
                    }
                    .dsFont(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(DSColor.textPrimary)
                    .padding(DSSpacing.md)
                }
                .background(viewModel.selectedCategory == category ? DSColor.brandPrimaryLight.opacity(0.15) : Color.clear)
            }
        }
        .background(DSColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
        .frame(maxWidth: 260)
    }

    @ViewBuilder
    private var seriesContent: some View {
        switch viewModel.blockedSeriesState {
        case .idle, .loading:
            ProgressView().padding(.top, DSSpacing.xxl)
        case .failed(let error):
            errorView(error.errorDescription ?? "Đã có lỗi xảy ra.") { viewModel.loadBlockedSeries() }
        case .loaded(let items) where items.isEmpty:
            emptyState
        case .loaded(let items):
            VStack(spacing: DSSpacing.sm) {
                ForEach(items) { item in
                    blockedRow(title: item.series.title, imageURL: item.series.coverURL) {
                        viewModel.unblockSeries(item.series.id)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var tagsContent: some View {
        switch viewModel.blockedTagsState {
        case .idle, .loading:
            ProgressView().padding(.top, DSSpacing.xxl)
        case .failed(let error):
            errorView(error.errorDescription ?? "Đã có lỗi xảy ra.") { viewModel.loadBlockedTags() }
        case .loaded(let items) where items.isEmpty:
            emptyState
        case .loaded(let items):
            VStack(spacing: DSSpacing.sm) {
                ForEach(items) { item in
                    blockedRow(title: item.tag.name, imageURL: nil) {
                        viewModel.unblockTag(item.tag.id)
                    }
                }
            }
        }
    }

    private func blockedRow(title: String, imageURL: URL?, onDelete: @escaping () -> Void) -> some View {
        HStack(spacing: DSSpacing.sm) {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    if case .success(let image) = phase {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle().fill(DSColor.backgroundSecondary)
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
            } else {
                Image(systemName: "tag.fill")
                    .foregroundStyle(DSColor.brandPrimary)
                    .frame(width: 44, height: 44)
                    .background(DSColor.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
            }
            Text(title).dsFont(.subheadline).fontWeight(.semibold).foregroundStyle(DSColor.textPrimary)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash").foregroundStyle(DSColor.textSecondary)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "questionmark.circle").font(.system(size: 44)).foregroundStyle(DSColor.textSecondary.opacity(0.5))
            Text("Danh sách trống").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
            Text("Bạn chưa chặn bất kỳ ai/mục nào.").dsFont(.footnote).foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xxl)
    }

    private func errorView(_ message: String, retry: @escaping () -> Void) -> some View {
        VStack(spacing: DSSpacing.md) {
            Text(message).dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
            DSButton("Thử lại", variant: .primary, action: retry)
        }
        .padding(.top, DSSpacing.xxl)
    }
}
