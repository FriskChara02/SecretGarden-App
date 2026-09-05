//
//  ReaderMenuView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 5/9/26.
//

// Popup menu — slides in from the right, following the standard pattern (using the default .sheet, provides the correct behavior).

import CoreModels
import DesignSystem
import SwiftUI

struct ReaderMenuView: View {
    @ObservedObject var viewModel: ChapterReaderViewModel
    let onHomeTapped: () -> Void
    @Environment(\.dismiss) private var dismiss
    /// TODO: Replace with the actual ThemeManager. Local placeholder to prevent the UI from freezing.
    @State private var isDarkModePlaceholder = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("ĐĂNG LÚC")
                    .dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(viewModel.currentChapter.releasedAt, style: .relative)
                    .dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DSSectionDivider().padding(.vertical, DSSpacing.md)

                menuRow(icon: "house", title: "Trang chủ") {
                    dismiss()
                    onHomeTapped()
                }
                menuRow(icon: "exclamationmark.triangle", title: "Báo cáo") {
                    // TODO(Separate report — requires FormSubmissionState): Show the actual "Report Violation" modal.
                    dismiss()
                }
                menuRow(icon: viewModel.isFavoritedByMe ? "heart.fill" : "heart", title: "Đã yêu thích", isHighlighted: true) {
                    viewModel.toggleFavorite()
                }
                menuRow(icon: "bubble.left", title: "Bình luận") {
                    dismiss()
                    viewModel.isCommentsOverlayPresented = true
                }

                toggleRow(icon: "bell", title: "Thông báo", isOn: Binding(
                    get: { viewModel.isNotifyEnabled },
                    set: { _ in viewModel.toggleNotify() }
                ))
                toggleRow(icon: "moon.stars", title: "Chế độ sáng/tối", isOn: $isDarkModePlaceholder)

                Spacer()

                readingStatusButton
            }
            .padding(DSSpacing.lg)
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
    }

    @ViewBuilder
    private func menuRow(icon: String, title: String, isHighlighted: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundStyle(isHighlighted ? DSColor.brandPrimary : DSColor.textPrimary)
                Text(title).dsFont(.subheadline).foregroundStyle(isHighlighted ? DSColor.brandPrimary : DSColor.textPrimary)
                Spacer()
            }
            .padding(.vertical, DSSpacing.sm)
        }
        Divider()
    }

    private func toggleRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon).foregroundStyle(DSColor.textPrimary)
                Text(title).dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)
                Spacer()
                Toggle("", isOn: isOn).labelsHidden().tint(DSColor.brandPrimary)
            }
            .padding(.vertical, DSSpacing.sm)
            Divider()
        }
    }

    private var readingStatusButton: some View {
        Menu {
            ForEach(ReadingStatus.allCases, id: \.self) { status in
                Button(readingStatusLabel(status)) { viewModel.updateReadingStatus(to: status) }
            }
            Button("Xoá khỏi danh sách", role: .destructive) { viewModel.removeFromReadingList() }
        } label: {
            HStack {
                Image(systemName: "bookmark.fill")
                Text(readingStatusLabel(viewModel.readingStatus))
                Image(systemName: "chevron.down")
            }
            .dsFont(.subheadline).fontWeight(.semibold)
            .foregroundStyle(DSColor.brandPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.sm)
            .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
        }
    }

    private func readingStatusLabel(_ status: ReadingStatus?) -> String {
        switch status {
        case .planToRead, .none: return "Sẽ đọc"
        case .reading: return "Đang theo dõi"
        case .completed: return "Đọc xong"
        case .dropped: return "Ngừng đọc"
        }
    }
}
