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
                Image(systemName: "diamond.circle").font(.system(size: 12)).foregroundStyle(DSColor.brandPrimaryLight)
                Text("Bộ lọc").dsFont(.title2).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark").foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(DSSpacing.lg)
    }

    // MARK: - Tab switcher (Include / Exclude)

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            tabButton("MUỐN CHỌN", isActive: viewModel.tabMode == .include) { viewModel.tabMode = .include }

            Rectangle()
                .fill(.white.opacity(0.6))
                .frame(width: 1, height: 18)

            tabButton("MUỐN LOẠI BỎ", isActive: viewModel.tabMode == .exclude) { viewModel.tabMode = .exclude }
        }
        .background(
            LinearGradient(colors: [DSColor.brandPrimary, DSColor.brandPrimaryLight], startPoint: .leading, endPoint: .trailing)
        )
        .overlay(
            Rectangle().strokeBorder(.white.opacity(0.5), lineWidth: 1)
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
        FilterSingleSelectField(
            label: "Sắp xếp",
            options: sortOptions.map { (value: $0.value, title: $0.label) },
            selection: $viewModel.draft.sort
        )
    }

    private let sortOptions: [(value: String, label: String)] = [
        ("latest_update", "Mới cập nhật"), ("newest", "Mới đăng"),
        ("oldest", "Cũ nhất"), ("views", "Lượt xem"), ("follows", "Lượt theo dõi")
    ]

    private var statusField: some View {
        FilterSingleSelectField(
            label: "Tình trạng",
            options: statusOptions,
            selection: statusSelectionBinding
        )
    }

    // "All" is represented by the string "all" instead of directly using nil — required by FilterSingleSelectField.
    // Value: Must be Hashable, using String for both sort and status for simplicity.
    private var statusOptions: [(value: String, title: String)] {
        [(value: "all", title: "Tất cả")] + SeriesStatus.allCases.map { (value: $0.rawValue, title: statusLabel($0)) }
    }

    private var statusSelectionBinding: Binding<String> {
        Binding(
            get: { viewModel.draft.status?.rawValue ?? "all" },
            set: { newValue in
                viewModel.draft.status = newValue == "all" ? nil : SeriesStatus(rawValue: newValue)
            }
        )
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
                .overlay(RoundedRectangle(cornerRadius: DSRadius.lg).stroke(DSColor.brandPrimary, lineWidth: 1.5))
        }
    }

    // MARK: - Footer

    private var footerButtons: some View {
        HStack(spacing: DSSpacing.md) {
            Button {
                viewModel.resetDraft()
            } label: {
                Text("Đặt lại")
                    .dsFont(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DSColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.sm)
            }
            .overlay(
                Capsule().stroke(DSColor.brandPrimary, lineWidth: 1.5)
            )

            Button {
                onApply(viewModel.draft)
            } label: {
                Text("Áp dụng")
                    .dsFont(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.sm)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [DSColor.brandPrimary, DSColor.brandPrimaryLight],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                    )
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
                    .background(RoundedRectangle(cornerRadius: DSRadius.lg).fill(DSColor.backgroundSecondary))
                    .overlay(
                        // Default thin gray border; changes to a thicker pink border when expanded (isExpanded)
                        // — adds a pink frame around the field when the user clicks on it.
                        RoundedRectangle(cornerRadius: DSRadius.lg)
                            .stroke(isExpanded ? DSColor.brandPrimary : DSColor.borderDefault, lineWidth: isExpanded ? 2 : 1)
                    )
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
            .background(RoundedRectangle(cornerRadius: DSRadius.lg).fill(DSColor.backgroundPrimary))
            .overlay(RoundedRectangle(cornerRadius: DSRadius.lg).stroke(DSColor.borderDefault, lineWidth: 1))
        }
    }

    // MARK: - Reusable single-select field (Sort / Status)

    private struct FilterSingleSelectField<Value: Hashable>: View {
        let label: String
        let options: [(value: Value, title: String)]
        @Binding var selection: Value
        @State private var isExpanded = false

        var body: some View {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(label).dsFont(.headline).foregroundStyle(DSColor.textPrimary)

                Button { isExpanded.toggle() } label: {
                    HStack {
                        Text(options.first { $0.value == selection }?.title ?? "")
                            .dsFont(.body)
                            .foregroundStyle(DSColor.textPrimary)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundStyle(DSColor.textSecondary)
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.sm)
                    .overlay(RoundedRectangle(cornerRadius: DSRadius.lg).stroke(DSColor.brandPrimary, lineWidth: 1.5))
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.value) { option in
                            let isSelected = option.value == selection
                            Button {
                                selection = option.value
                                isExpanded = false
                            } label: {
                                HStack(spacing: DSSpacing.xs) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(DSColor.brandPrimary)
                                        .opacity(isSelected ? 1 : 0)
                                        .frame(width: 16, alignment: .leading)

                                    Text(option.title)
                                        .dsFont(.body)
                                        .foregroundStyle(isSelected ? DSColor.brandPrimary : DSColor.textPrimary)

                                    Spacer()
                                }
                                .padding(.horizontal, DSSpacing.md)
                                .padding(.vertical, DSSpacing.sm)
                                .background(isSelected ? DSColor.brandPrimary.opacity(0.12) : Color.clear)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: DSRadius.lg).fill(DSColor.backgroundPrimary))
                    .overlay(RoundedRectangle(cornerRadius: DSRadius.lg).stroke(DSColor.borderDefault, lineWidth: 1))
                }
            }
        }
    }
}
