//
//  ReaderMenuView.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 5/9/26.
//

// Popup menu — slides in from the right, following the standard pattern (using the default .sheet, provides the correct behavior).

import CoreArchitecture
import CoreModels
import DesignSystem
import SwiftUI

struct ReaderMenuView: View {
    @ObservedObject var viewModel: ChapterReaderViewModel
    let onHomeTapped: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var isReadingStatusExpanded = false

    private let contentVerticalOffset: CGFloat = 60

    var body: some View {
        VStack(spacing: 0) {

            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                header
                
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text("ĐĂNG LÚC")
                        .dsFont(.caption).foregroundStyle(DSColor.textSecondary)
                    Text(Self.relativeFormatter.localizedString(for: viewModel.currentChapter.releasedAt, relativeTo: Date()))
                        .dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, DSSpacing.xs)

                DSSectionDivider()

                VStack(spacing: 0) {
                    menuRow(icon: "house", title: "Trang chủ") {
                        viewModel.isMenuPresented = false
                        onHomeTapped()
                    }
                    Divider()
                    menuRow(icon: "exclamationmark.triangle", title: "Báo cáo") {
                        viewModel.isMenuPresented = false // TODO(Separate report — requires FormSubmissionState)
                    }
                    Divider()
                    menuRow(icon: viewModel.isFavoritedByMe ? "heart.fill" : "heart", title: "Đã yêu thích", isHighlighted: viewModel.isFavoritedByMe) {
                        viewModel.toggleFavorite()
                    }
                    Divider()
                    menuRow(icon: "message", title: "Bình luận") {
                        viewModel.isMenuPresented = false
                        viewModel.isCommentsOverlayPresented = true
                    }
                    Divider()
                    toggleRow(icon: "bell", activeIcon: "bell.fill", title: "Thông báo", isOn: Binding(
                        get: { viewModel.isNotifyEnabled },
                        set: { _ in viewModel.toggleNotify() }
                    ))
                    Divider()
                    toggleRow(
                            icon: "sun.max",
                            activeIcon: "moon.stars.fill",
                            title: "Chế độ sáng/tối",
                            isOn: Binding(
                                get: { themeManager.isDarkMode },
                                set: { _ in themeManager.toggle() }
                            ),
                            useThemeStyle: true
                        )
                }

                readingStatusDropdown
            }
            .padding(.horizontal, DSSpacing.lg)
            .padding(.top, DSSpacing.lg)
            .offset(y: contentVerticalOffset)

            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity)
        .background(DSColor.backgroundPrimary)
    }

    private var header: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Menu").dsFont(.title2).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                Spacer()
                Button { viewModel.isMenuPresented = false } label: {
                    Image(systemName: "xmark").foregroundStyle(DSColor.textSecondary)
                }
            }
            .padding(.bottom, DSSpacing.md)
            
            Divider()
            .padding(.horizontal, -DSSpacing.lg)
        }
        .padding(.top, DSSpacing.lg)
        .background(DSColor.backgroundPrimary)
    }

    private func menuRow(icon: String, title: String, isHighlighted: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: icon).foregroundStyle(DSColor.brandPrimary)
                Text(title).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(isHighlighted ? DSColor.brandPrimary : DSColor.textPrimary)
                Spacer()
            }
            .padding(.vertical, DSSpacing.md)
            .frame(maxWidth: .infinity)
            .background(isHighlighted ? DSColor.brandPrimaryLight.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
        }
    }

    private func toggleRow(icon: String, activeIcon: String, title: String, isOn: Binding<Bool>, useThemeStyle: Bool = false) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: isOn.wrappedValue ? activeIcon : icon).foregroundStyle(DSColor.brandPrimary)
            Text(title).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
            Spacer()
            if useThemeStyle {
                Toggle("", isOn: isOn).labelsHidden().toggleStyle(DSThemeToggleStyle())
            } else {
                Toggle("", isOn: isOn).labelsHidden().toggleStyle(DSBellToggleStyle())
            }
        }
        .padding(.vertical, DSSpacing.md)
    }

    // MARK: - Reading status dropdown

    private var readingStatusDropdown: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isReadingStatusExpanded.toggle() }
            } label: {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "bookmark.fill")
                    Text(readingStatusLabel(viewModel.readingStatus)).fontWeight(.bold)
                    Image(systemName: isReadingStatusExpanded ? "chevron.up" : "chevron.down")
                }
                .dsFont(.subheadline).fontWeight(.semibold)
                .foregroundStyle(DSColor.brandPrimary)
                .padding(.vertical, DSSpacing.sm)
                .frame(maxWidth: .infinity)
                .overlay(Capsule().strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
            }
            .disabled(viewModel.isUpdatingReadingStatus)

            if isReadingStatusExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(ReadingStatus.allCases, id: \.self) { status in
                        Button {
                            viewModel.updateReadingStatus(to: status)
                            isReadingStatusExpanded = false
                        } label: {
                            HStack {
                                Text(readingStatusLabel(status)).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                                Spacer()
                                if viewModel.readingStatus == status {
                                    Image(systemName: "checkmark").foregroundStyle(DSColor.brandPrimary)
                                }
                            }
                            .padding(.vertical, DSSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    Divider()
                    Button {
                        viewModel.removeFromReadingList()
                        isReadingStatusExpanded = false
                    } label: {
                        Text("Xoá khỏi danh sách")
                            .dsFont(.subheadline).fontWeight(.semibold)
                            .foregroundStyle(DSColor.statusError)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, DSSpacing.sm)
                    }
                }
                .padding(.top, DSSpacing.xs)
            }
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

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "vi_VN")
        f.dateTimeStyle = .named
        return f
    }()
}
