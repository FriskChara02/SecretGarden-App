//
//  NotificationSettingsView.swift
//  CoreModels
//
//  Created by Loi Nguyen on 19/9/26.
//

import CoreModels
import CoreArchitecture
import DesignSystem
import Repositories
import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel: NotificationSettingsViewModel

    init(repository: NotificationSettingsRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: NotificationSettingsViewModel(repository: repository))
    }

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            sectionTitle

            switch viewModel.state {
            case .idle, .loading:
                ProgressView().padding(.top, DSSpacing.xxl)
            case .failed(let error):
                VStack(spacing: DSSpacing.md) {
                    Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                        .dsFont(.subheadline).foregroundStyle(DSColor.textSecondary)
                    DSButton("Thử lại", variant: .primary) { viewModel.load() }
                }
                .padding(.top, DSSpacing.xxl)
            case .loaded(let settings):
                settingsRows(settings)
            }

            if let error = viewModel.actionErrorMessage {
                Text(error).dsFont(.footnote).foregroundStyle(DSColor.statusError)
            }
        }
        .padding(DSSpacing.lg)
        .onAppear { viewModel.onAppear() }
    }

    private var sectionTitle: some View {
        HStack {
            Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
            Text("Thông báo").dsFont(.headline).fontWeight(.bold).foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.inset.filled").font(.system(size: 8)).foregroundStyle(DSColor.brandPrimary)
        }
    }

    @ViewBuilder
    private func settingsRows(_ settings: NotificationSettings) -> some View {
        toggleRow(
            title: "Nhận thông báo đẩy trên thiết bị này",
            subtitle: settings.pushEnabled ? "Trạng thái: Đang bật trên thiết bị này" : "Trạng thái: Đang tắt",
            subtitleColor: settings.pushEnabled ? DSColor.statusSuccess : DSColor.textSecondary,
            isOn: settings.pushEnabled,
            toggle: { viewModel.toggle(\.pushEnabled) }
        )
        Divider()
        toggleRow(
            title: "Khi có chương mới từ truyện bạn theo dõi",
            isOn: settings.followedSeriesNewChapter,
            toggle: { viewModel.toggle(\.followedSeriesNewChapter) }
        )
        toggleRow(
            title: "Khi có truyện mới từ team bạn theo dõi",
            isOn: settings.followedGroupNewChapter,
            toggle: { viewModel.toggle(\.followedGroupNewChapter) }
        )
        toggleRow(
            title: "Khi có trả lời bình luận của bạn",
            isOn: settings.commentReply,
            toggle: { viewModel.toggle(\.commentReply) }
        )
        toggleRow(
            title: "Khi có lượt thích bình luận của bạn",
            isOn: settings.commentLike,
            toggle: { viewModel.toggle(\.commentLike) }
        )
        toggleRow(
            title: "Khi có người nhắc đến bạn trong bình luận",
            isOn: settings.mention,
            toggle: { viewModel.toggle(\.mention) }
        )
    }

    private func toggleRow(
        title: String,
        subtitle: String? = nil,
        subtitleColor: Color = DSColor.textSecondary,
        isOn: Bool,
        toggle: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)
                if let subtitle {
                    Text(subtitle).dsFont(.caption).foregroundStyle(subtitleColor)
                }
            }
            Spacer()
            Toggle("", isOn: Binding(get: { isOn }, set: { _ in toggle() }))
                .labelsHidden()
                .toggleStyle(DSBellToggleStyle())
        }
        .padding(.vertical, DSSpacing.xs)
    }
}
