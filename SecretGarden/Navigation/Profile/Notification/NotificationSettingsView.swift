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
    private let onPolicyTapped: (PolicyKind) -> Void

    init(repository: NotificationSettingsRepositoryProtocol, onPolicyTapped: @escaping (PolicyKind) -> Void) {
        _viewModel = StateObject(wrappedValue: NotificationSettingsViewModel(repository: repository))
        self.onPolicyTapped = onPolicyTapped
    }

    var body: some View {
            VStack(spacing: DSSpacing.lg) {
                sectionTitle
                DSSectionDivider()
                    .padding(.bottom, DSSpacing.md)

                VStack(spacing: DSSpacing.lg) {
                    switch viewModel.state {
                    case .idle, .loading:
                        ProgressView().padding(.top, DSSpacing.xxl)
                    case .failed(let error):
                        VStack(spacing: DSSpacing.md) {
                            Text(error.errorDescription ?? "Đã có lỗi xảy ra.")
                                .font(.system(size: 15))
                                .foregroundStyle(DSColor.textSecondary)
                            DSButton("Thử lại", variant: .primary) { viewModel.load() }
                        }
                        .padding(.top, DSSpacing.xxl)
                    case .loaded(let settings):
                        settingsRows(settings)
                    }
                    if let error = viewModel.actionErrorMessage {
                        Text(error).font(.caption).foregroundStyle(DSColor.statusError)
                    }
                }
                .padding(.horizontal, DSSpacing.md)

                DSSectionDivider()

                GardenFooterView(
                    policyLinks: [GardenFooterLink(title: "Chính sách", action: { onPolicyTapped(.communityRules) })],
                    socialLinks: [
                        GardenFooterLink(title: "Discord", action: {}),
                        GardenFooterLink(title: "Facebook", action: {})
                    ],
                    onPolicyTapped: { onPolicyTapped(.communityRules) }
                )
            }
            .padding(.vertical, DSSpacing.lg)
            .onAppear { viewModel.onAppear() }
        }

    private var sectionTitle: some View {
        HStack {
            Image(systemName: "diamond.inset.filled")
                .font(.system(size: 9))
                .foregroundStyle(DSColor.brandPrimary)
            Text("Thông báo")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DSColor.brandPrimary)
            Image(systemName: "diamond.inset.filled")
                .font(.system(size: 9))
                .foregroundStyle(DSColor.brandPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DSSpacing.md)
    }

    @ViewBuilder
    private func settingsRows(_ settings: NotificationSettings) -> some View {
        toggleRow(
            title: "Nhận thông báo đẩy trên thiết bị này",
            subtitle: settings.pushEnabled ? "Trạng thái: Đang bật trên thiết bị này" : "Trạng thái: Chưa bật trên thiết bị này",
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
        title: String, subtitle: String? = nil, subtitleColor: Color = DSColor.textSecondary,
        isOn: Bool, toggle: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .top) {
            Toggle("", isOn: Binding(get: { isOn }, set: { _ in toggle() }))
                .labelsHidden()
                .toggleStyle(DSBellToggleStyle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 17, weight: .bold)).foregroundStyle(DSColor.textPrimary)
                if let subtitle {
                    Text(subtitle).font(.system(size: 13)).foregroundStyle(subtitleColor)
                }
            }
            Spacer()
        }
        .padding(.vertical, DSSpacing.xs)
    }
}
