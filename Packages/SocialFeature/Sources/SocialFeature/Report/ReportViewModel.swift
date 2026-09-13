//
//  ReportViewModel.swift
//  SocialFeature
//
//  Created by Loi Nguyen on 13/9/26.
//

// ViewModel for Report Content. Uses FormSubmissionState (not LoadableState)
// because this is a submission action, not data loading for display (consistent with FormSubmissionState's docstring).
//
// Shared between Series Detail (reporting the entire series, chapterId = nil) and Chapter Reader
// (reporting a specific chapter, chapterId has a value).

import CoreArchitecture
import CoreModels
import Foundation
import Repositories

@MainActor
public final class ReportViewModel: BaseViewModel {

    private let seriesId: String
    private let chapterId: String?
    private let seriesRepository: SeriesRepositoryProtocol

    @Published public var selectedReason: ReportReason?
    @Published public private(set) var submissionState: FormSubmissionState = .idle
    /// DSSuccessToastModifier - shares the same Group/Author pattern
    @Published public var successMessage: String?

    public init(seriesId: String, chapterId: String? = nil, seriesRepository: SeriesRepositoryProtocol) {
        self.seriesId = seriesId
        self.chapterId = chapterId
        self.seriesRepository = seriesRepository
        super.init()
    }

    public var canSubmit: Bool {
        selectedReason != nil && !submissionState.isSubmitting
    }

    public func submit() {
        guard let selectedReason, canSubmit else { return }
        submissionState = .submitting

        Task { [weak self] in
            guard let self else { return }
            do {
                let request = ReportRequest(
                    seriesId: self.seriesId,
                    chapterId: self.chapterId,
                    reason: selectedReason.rawValue,
                    note: nil
                )
                try await self.seriesRepository.submitReport(request)
                self.submissionState = .succeeded
                self.successMessage = "Đã gửi báo cáo"
            } catch {
                self.submissionState = .failed(self.mapToAppError(error))
            }
        }
    }

    public func reset() {
        selectedReason = nil
        submissionState = .idle
    }
}
