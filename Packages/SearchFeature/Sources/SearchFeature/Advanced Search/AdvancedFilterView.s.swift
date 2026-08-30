//
//  AdvancedFilterView.swift
//  SearchFeature
//
//  Created by Loi Nguyen on 30/8/26.
//

// Modal Filters — 2 tabs SELECT/EXCLUDE for 5 multi-select fields
// (Tags, Author, Artist, Pair, Translation Team & Sorting/Status/Minimum Number of Chapters)

import CoreArchitecture
import CoreModels
import DesignSystem
import Repositories
import SwiftUI

public struct AdvancedFilterView: View {
    @StateObject private var viewModel: AdvancedFilterViewModel
    @Environment(\.dismiss) private var dismiss

    private let onApply: (AdvancedFilterRequest) -> Void

    public init(
        repository: SearchRepositoryProtocol,
        initialFilter: AdvancedFilterRequest,
        onApply: @escaping (AdvancedFilterRequest) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: AdvancedFilterViewModel(repository: repository, initialFilter: initialFilter))
        self.onApply = onApply
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            tabSwitcher

            LoadableContentView(
                state: viewModel.optionsState,
                emptyTitle: "Chưa có dữ liệu bộ lọc",
                isEmpty: { _ in false }
            ) { options in
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.lg) {
                        tabSpecificFields(options: options)
                        Divider()
                        commonFields
                    }
                    .padding(DSSpacing.lg)
                }
            }

            footerButtons
        }
        .onAppear { viewModel.loadOptions() }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.fill").font(.system(size: 12)).foregroundStyle(DSColor.brandPrimaryLight)
                Text("Bộ lọc").dsFont(.title2).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark").foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(DSSpacing.lg)
    }

    // MARK: - Tab switcher (SELECT/EXCLUDE)

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            tabButton("MUỐN CHỌN", isActive: viewModel.tabMode == .include) { viewModel.tabMode = .include }
            tabButton("MUỐN LOẠI BỎ", isActive: viewModel.tabMode == .exclude) { viewModel.tabMode = .exclude }
        }
        .background(
            LinearGradient(colors: [DSColor.brandPrimary, DSColor.brandPrimaryLight], startPoint: .leading, endPoint: .trailing)
        )
    }

    private func tabButton(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .dsFont(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.md)
                .overlay(alignment: .bottom) {
                    if isActive {
                        Rectangle().fill(.white).frame(height: 3)
                    }
                }
        }
    }

    // MARK: - 5-field multi-select — update include/exclude array content based on tabMode

    @ViewBuilder
    private func tabSpecificFields(options: AdvancedFilterOptions) -> some View {
        let isInclude = viewModel.tabMode == .include
        let tagsKeyPath = isInclude ? \AdvancedFilterRequest.includeTags : \AdvancedFilterRequest.excludeTags
        let authorsKeyPath = isInclude ? \AdvancedFilterRequest.includeAuthors : \AdvancedFilterRequest.excludeAuthors
        let artistsKeyPath = isInclude ? \AdvancedFilterRequest.includeArtists : \AdvancedFilterRequest.excludeArtists
        let pairingsKeyPath = isInclude ? \AdvancedFilterRequest.includePairings : \AdvancedFilterRequest.excludePairings
        let groupsKeyPath = isInclude ? \AdvancedFilterRequest.includeGroups : \AdvancedFilterRequest.excludeGroups

        FilterMultiSelectField(
            label: "Tags",
            placeholder: isInclude ? "Chọn tag..." : "Loại tag...",
            options: options.tags.map { ($0.id, $0.name) },
            selectedIDs: viewModel.draft[keyPath: tagsKeyPath],
            onToggle: { id in viewModel.toggleSelection(id: id, at: tagsKeyPath) }
        )

        FilterMultiSelectField(
            label: "Tác giả",
            placeholder: isInclude ? "Chọn tác giả..." : "Loại tác giả...",
            options: options.authors.map { ($0.id, $0.name) },
            selectedIDs: viewModel.draft[keyPath: authorsKeyPath],
            onToggle: { id in viewModel.toggleSelection(id: id, at: authorsKeyPath) }
        )

        FilterMultiSelectField(
            label: "Họa sĩ",
            placeholder: isInclude ? "Chọn họa sĩ..." : "Loại họa sĩ...",
            options: options.artists.map { ($0.id, $0.name) },
            selectedIDs: viewModel.draft[keyPath: artistsKeyPath],
            onToggle: { id in viewModel.toggleSelection(id: id, at: artistsKeyPath) }
        )

        FilterMultiSelectField(
            label: "Nhóm dịch",
            placeholder: isInclude ? "Chọn nhóm dịch..." : "Loại nhóm dịch...",
            options: options.groups.map { ($0.id, $0.name) },
            selectedIDs: viewModel.draft[keyPath: groupsKeyPath],
            onToggle: { id in viewModel.toggleSelection(id: id, at: groupsKeyPath) }
        )

        FilterMultiSelectField(
            label: "Cặp đôi",
            placeholder: isInclude ? "Chọn cặp đôi..." : "Loại cặp đôi...",
            options: options.pairings.map { ($0.id, $0.name) },
            selectedIDs: viewModel.draft[keyPath: pairingsKeyPath],
            onToggle: { id in viewModel.toggleSelection(id: id, at: pairingsKeyPath) }
        )
    }

    // MARK: - 3 shared fields (no include/exclude)

    private var commonFields: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            sortField
            statusField
            minChapterField
        }
    }

    private var sortField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Sắp xếp").dsFont(.headline).foregroundStyle(DSColor.textPrimary)
            Menu {
                ForEach(sortOptions, id: \.value) { option in
                    Button {
                        viewModel.draft.sort = option.value
                    } label: {
                        if viewModel.draft.sort == option.value {
                            Label(option.label, systemImage: "checkmark")
                        } else {
                            Text(option.label)
                        }
                    }
                }
            } label: {
                filterPickerLabel(sortOptions.first { $0.value == viewModel.draft.sort }?.label ?? "Mới cập nhật")
            }
        }
    }

    private let sortOptions: [(value: String, label: String)] = [
        ("latest_update", "Mới cập nhật"), ("newest", "Mới đăng"),
        ("oldest", "Cũ nhất"), ("views", "Lượt xem"), ("follows", "Lượt theo dõi")
    ]

    private var statusField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Tình trạng").dsFont(.headline).foregroundStyle(DSColor.textPrimary)
            Menu {
                Button {
                    viewModel.draft.status = nil
                } label: {
                    if viewModel.draft.status == nil { Label("Tất cả", systemImage: "checkmark") } else { Text("Tất cả") }
                }
                ForEach(SeriesStatus.allCases, id: \.self) { status in
                    Button {
                        viewModel.draft.status = status
                    } label: {
                        if viewModel.draft.status == status {
                            Label(statusLabel(status), systemImage: "checkmark")
                        } else {
                            Text(statusLabel(status))
                        }
                    }
                }
            } label: {
                filterPickerLabel(viewModel.draft.status.map(statusLabel) ?? "Tất cả")
            }
        }
    }

    private func statusLabel(_ status: SeriesStatus) -> String {
        switch status {
        case .ongoing: return "Đang tiến hành"
        case .completed: return "Đã hoàn thành"
        case .upcoming: return "Sắp ra mắt"
        case .dropped: return "Ngừng dịch"
        }
    }

    private var minChapterField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Số chương tối thiểu").dsFont(.headline).foregroundStyle(DSColor.textPrimary)
            TextField("0", value: $viewModel.draft.minChapterCount, format: .number)
                .keyboardType(.numberPad)
                .dsFont(.body)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .overlay(RoundedRectangle(cornerRadius: DSRadius.md).stroke(DSColor.brandPrimary, lineWidth: 1.5))
        }
    }

    private func filterPickerLabel(_ text: String) -> some View {
        HStack {
            Text(text).dsFont(.body).foregroundStyle(DSColor.textPrimary)
            Spacer()
            Image(systemName: "chevron.down").foregroundStyle(DSColor.textSecondary)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.sm)
        .overlay(RoundedRectangle(cornerRadius: DSRadius.md).stroke(DSColor.brandPrimary, lineWidth: 1.5))
    }

    // MARK: - Footer

    private var footerButtons: some View {
        HStack(spacing: DSSpacing.md) {
            DSButton("Đặt lại", variant: .outline) {
                viewModel.resetDraft()
            }
            DSButton("Áp dụng", variant: .primary) {
                onApply(viewModel.draft)
            }
        }
        .padding(DSSpacing.lg)
    }
    
    // MARK: - Reusable multi-select field (selected chips within the field + searchable checkbox list)

    private struct FilterMultiSelectField: View {
        let label: String
        let placeholder: String
        let options: [(id: String, name: String)]
        let selectedIDs: [String]
        let onToggle: (String) -> Void

        @State private var isExpanded = false
        @State private var searchText = ""

        private var filteredOptions: [(id: String, name: String)] {
            guard !searchText.isEmpty else { return options }
            return options.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(label).dsFont(.headline).foregroundStyle(DSColor.textPrimary)

                Button { isExpanded.toggle() } label: {
                    HStack {
                        if selectedIDs.isEmpty {
                            Text(placeholder).dsFont(.body).foregroundStyle(DSColor.textSecondary)
                        } else {
                            FlowLayout(spacing: DSSpacing.xs) {
                                ForEach(options.filter { selectedIDs.contains($0.id) }, id: \.id) { option in
                                    selectedChip(option)
                                }
                            }
                        }
                        Spacer(minLength: DSSpacing.sm)
                        Image(systemName: "chevron.up.chevron.down").foregroundStyle(DSColor.textSecondary)
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.sm)
                    .background(RoundedRectangle(cornerRadius: DSRadius.md).fill(DSColor.backgroundSecondary))
                }
                .buttonStyle(.plain)

                if isExpanded {
                    expandedList
                }
            }
        }

        private func selectedChip(_ option: (id: String, name: String)) -> some View {
            HStack(spacing: DSSpacing.xxs) {
                Text(option.name).dsFont(.caption)
                Button { onToggle(option.id) } label: {
                    Image(systemName: "xmark").font(.system(size: 9))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(Capsule().fill(DSColor.brandPrimary))
        }

        private var expandedList: some View {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Tìm kiếm...", text: $searchText)
                    .dsFont(.body)
                    .padding(DSSpacing.sm)

                Divider()

                ForEach(filteredOptions, id: \.id) { option in
                    Button { onToggle(option.id) } label: {
                        HStack {
                            Image(systemName: selectedIDs.contains(option.id) ? "checkmark.square.fill" : "square")
                                .foregroundStyle(selectedIDs.contains(option.id) ? DSColor.brandPrimary : DSColor.textSecondary)
                            Text(option.name).dsFont(.body).foregroundStyle(DSColor.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, DSSpacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DSSpacing.sm)
            .background(RoundedRectangle(cornerRadius: DSRadius.md).fill(DSColor.backgroundPrimary))
            .overlay(RoundedRectangle(cornerRadius: DSRadius.md).stroke(DSColor.borderDefault, lineWidth: 1))
        }
    }
}
