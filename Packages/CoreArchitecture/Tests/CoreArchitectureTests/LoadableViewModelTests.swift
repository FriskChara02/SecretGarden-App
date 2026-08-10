//
//  LoadableViewModelTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 10/8/26.
//

// Verify that the state machine transitions correctly (idle -> loading -> loaded/failed), and
// that BaseViewModel.mapToAppError() correctly maps unexpected errors to .unknown.
//
// Note: Use Task.sleep() to wait for the ViewModel's async task to complete.

import XCTest
@testable import CoreArchitecture

private struct DummyContent: Equatable {
    let value: Int
}

final class LoadableViewModelTests: XCTestCase {

    @MainActor
    func test_initialState_isIdle() {
        // Given / When
        let viewModel = LoadableViewModel<DummyContent>()

        // Then
        XCTAssertEqual(viewModel.state, .idle)
    }

    @MainActor
    func test_load_success_updatesStateToLoaded() async throws {
        // Given
        let viewModel = LoadableViewModel<DummyContent>()
        let expectedContent = DummyContent(value: 42)

        // When
        viewModel.load {
            expectedContent
        }
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertEqual(viewModel.state, .loaded(expectedContent))
    }

    @MainActor
    func test_load_failure_updatesStateToFailed() async throws {
        // Given
        let viewModel = LoadableViewModel<DummyContent>()

        // When
        viewModel.load {
            throw AppError.notFound
        }
        try await Task.sleep(nanoseconds: 200_000_000)

        // Then
        XCTAssertEqual(viewModel.state, .failed(.notFound))
    }

    @MainActor
    func test_load_calledTwiceQuickly_onlyLastResultWins() async throws {
        // Given — Simulate a user clicking "Reload" twice in succession, with the first click being slower than the second.
        let viewModel = LoadableViewModel<DummyContent>()

        // When
        viewModel.load {
            try await Task.sleep(nanoseconds: 300_000_000) // simulate slow requests
            return DummyContent(value: 1)
        }
        viewModel.load {
            DummyContent(value: 2) // Quick request, placed later but completed earlier
        }
        try await Task.sleep(nanoseconds: 500_000_000)

        // Then — the result of the FIRST call must be cancelled (CancellationError), not
        // overwrite the result of the second call.
        XCTAssertEqual(viewModel.state, .loaded(DummyContent(value: 2)))
    }

    @MainActor
    func test_mapToAppError_wrapsUnknownErrorTypes() {
        // Given
        struct SomeRandomError: Error {}
        let viewModel = BaseViewModel()

        // When
        let mapped = viewModel.mapToAppError(SomeRandomError())

        // Then
        if case .unknown = mapped {
            // pass
        } else {
            XCTFail("Lỗi lạ phải được map về .unknown, không được giữ nguyên kiểu gốc")
        }
    }

    @MainActor
    func test_mapToAppError_keepsAppErrorUnchanged() {
        // Given
        let viewModel = BaseViewModel()

        // When
        let mapped = viewModel.mapToAppError(AppError.unauthorized)

        // Then — AppError is already properly formatted, keep it as is, do not wrap it in .unknown.
        XCTAssertEqual(mapped, .unauthorized)
    }
}
