//
//  ReportView.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

// Report Violation Modal — dropdown with 4 fixed reasons, Submit/Cancel buttons.
// (SeriesDetailView/ReaderMenuView) via `.sheet(isPresented:)`.

import CoreArchitecture
import CoreModels
import DesignSystem
import Repositories
import SwiftUI

public struct ReportView: View {
    @StateObject private var viewModel: ReportViewModel
    @State private var isReasonMenuExpanded = false
    let onDismiss: () -> Void
    let onSubmitted: (String) -> Void

    public init(
        seriesId: String, chapterId: String? = nil,
        seriesRepository: SeriesRepositoryProtocol,
        onDismiss: @escaping () -> Void,
        onSubmitted: @escaping (String) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: ReportViewModel(
            seriesId: seriesId, chapterId: chapterId, seriesRepository: seriesRepository
        ))
        self.onDismiss = onDismiss
        self.onSubmitted = onSubmitted
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            DSDecorativeCard {
                VStack(spacing: DSSpacing.lg) {
                    header
                    reasonField
                    actionButtons
                }
                .padding(DSSpacing.lg)
            }
            .padding(.horizontal, DSSpacing.xl)
        }
        .onChange(of: viewModel.submissionState) { _, newValue in
            if newValue == .succeeded {
                onSubmitted(viewModel.successMessage ?? "Đã gửi báo cáo")
                onDismiss()
            }
        }
        .alert(
            "Gửi báo cáo thất bại",
            isPresented: Binding(
                get: { viewModel.submissionState.error != nil },
                set: { if !$0 { viewModel.reset() } }
            )
        ) {
            Button("Đóng", role: .cancel) { viewModel.reset() }
        } message: {
            Text(viewModel.submissionState.error?.errorDescription ?? "")
        }
    }

    private var header: some View {
        HStack {
            Spacer()
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "diamond.inset.filled").font(.caption2)
                Text("Báo cáo vi phạm").dsFont(.title3).fontWeight(.bold)
                Image(systemName: "diamond.inset.filled").font(.caption2)
            }
            .foregroundStyle(DSColor.brandPrimary)
            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button { onDismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DSColor.brandPrimary)
                    .frame(width: 26, height: 26)
                    .overlay(Circle().strokeBorder(DSColor.brandPrimary, lineWidth: 1.2))
            }
        }
    }

    private var reasonField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Lý do").dsFont(.subheadline).fontWeight(.bold).foregroundStyle(DSColor.textPrimary)

            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { isReasonMenuExpanded.toggle() }
                } label: {
                    HStack {
                        Text(viewModel.selectedReason?.displayName ?? "Chọn lý do...")
                            .dsFont(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(viewModel.selectedReason == nil ? DSColor.textSecondary : DSColor.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(DSColor.textSecondary)
                            .rotationEffect(.degrees(isReasonMenuExpanded ? 180 : 0))
                    }
                    .padding(DSSpacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .strokeBorder(DSColor.borderDefault, lineWidth: 1.5)
                    )
                }

                if isReasonMenuExpanded {
                    VStack(spacing: 0) {
                        ForEach(ReportReason.allCases) { reason in
                            reasonOptionRow(reason)
                            if reason != ReportReason.allCases.last { Divider() }
                        }
                    }
                    .background(DSColor.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                    .overlay(RoundedRectangle(cornerRadius: DSRadius.md).strokeBorder(Color.black, lineWidth: 1.5))
                    .padding(.top, DSSpacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private func reasonOptionRow(_ reason: ReportReason) -> some View {
        Button {
            viewModel.selectedReason = reason
            withAnimation(.easeInOut(duration: 0.15)) { isReasonMenuExpanded = false }
        } label: {
            HStack {
                Text(reason.displayName)
                    .dsFont(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(reason == viewModel.selectedReason ? DSColor.brandPrimary : DSColor.textPrimary)
                Spacer()
                if reason == viewModel.selectedReason {
                    Image(systemName: "checkmark").foregroundStyle(DSColor.brandPrimary)
                }
            }
            .padding(DSSpacing.md)
            .background(reason == viewModel.selectedReason ? DSColor.brandPrimary.opacity(0.08) : Color.clear)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: DSSpacing.sm) {
            DSButton("Gửi báo cáo", variant: .primary, isLoading: viewModel.submissionState.isSubmitting) {
                viewModel.submit()
            }
            .disabled(!viewModel.canSubmit)

            Button("Hủy") { onDismiss() }
                .dsFont(.headline)
                .foregroundStyle(DSColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.md)
                .background(DSColor.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        }
    }
}
