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
    @Environment(\.dismiss) private var dismiss

    public init(seriesId: String, chapterId: String? = nil, seriesRepository: SeriesRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: ReportViewModel(
            seriesId: seriesId,
            chapterId: chapterId,
            seriesRepository: seriesRepository
        ))
    }

    public var body: some View {
        DSDecorativeCard {
            VStack(spacing: DSSpacing.lg) {
                header
                reasonField
                actionButtons
            }
            .padding(DSSpacing.lg)
        }
        .padding(DSSpacing.md)
        .dsSuccessToast(message: $viewModel.successMessage)
        .onChange(of: viewModel.successMessage) { _, newValue in
            // Toast auto-hides after 4s — close the sheet as soon as the toast starts appearing
            if newValue != nil { dismiss() }
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
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
    }

    private var reasonField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Lý do").dsFont(.subheadline).foregroundStyle(DSColor.textPrimary)

            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { isReasonMenuExpanded.toggle() }
                } label: {
                    HStack {
                        Text(viewModel.selectedReason?.displayName ?? "Chọn lý do...")
                            .dsFont(.callout)
                            .foregroundStyle(viewModel.selectedReason == nil ? DSColor.textSecondary : DSColor.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(DSColor.brandPrimary)
                            .rotationEffect(.degrees(isReasonMenuExpanded ? 180 : 0))
                    }
                    .padding(DSSpacing.md)
                    .overlay(RoundedRectangle(cornerRadius: DSRadius.md).strokeBorder(DSColor.brandPrimary, lineWidth: 1.5))
                }

                if isReasonMenuExpanded {
                    VStack(spacing: 0) {
                        ForEach(ReportReason.allCases) { reason in
                            reasonOptionRow(reason)
                            if reason != ReportReason.allCases.last {
                                Divider()
                            }
                        }
                    }
                    .background(DSColor.backgroundPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                    .overlay(RoundedRectangle(cornerRadius: DSRadius.md).strokeBorder(DSColor.borderDefault, lineWidth: 1))
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
            DSButton(
                "Gửi báo cáo",
                variant: .primary,
                isLoading: viewModel.submissionState.isSubmitting
            ) {
                viewModel.submit()
            }
            .disabled(!viewModel.canSubmit)

            DSButton("Hủy", variant: .outline) {
                dismiss()
            }
        }
    }
}
