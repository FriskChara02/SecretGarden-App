//
//  ArchitectureBaseTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import CoreArchitecture
import XCTest

// MARK: - State types (pure, non-async)

final class StateTypesTests: XCTestCase {

    func test_formSubmissionState_isSubmitting_isOnlyTrueForSubmitting() {
        XCTAssertTrue(FormSubmissionState.submitting.isSubmitting)
        XCTAssertFalse(FormSubmissionState.idle.isSubmitting)
        XCTAssertFalse(FormSubmissionState.succeeded.isSubmitting)
        XCTAssertFalse(FormSubmissionState.failed(.notFound).isSubmitting)
    }

    func test_formSubmissionState_error_isOnlyPresentForFailed() {
        XCTAssertEqual(FormSubmissionState.failed(.unauthorized).error, .unauthorized)
        XCTAssertNil(FormSubmissionState.idle.error)
        XCTAssertNil(FormSubmissionState.submitting.error)
        XCTAssertNil(FormSubmissionState.succeeded.error)
    }

    func test_loadableState_value_isOnlyPresentWhenLoaded() {
        XCTAssertEqual(LoadableState<Int>.loaded(7).value, 7)
        XCTAssertNil(LoadableState<Int>.idle.value)
        XCTAssertNil(LoadableState<Int>.loading.value)
        XCTAssertNil(LoadableState<Int>.failed(.notFound).value)
    }

    func test_loadableState_isLoading_isOnlyTrueForLoading() {
        XCTAssertTrue(LoadableState<Int>.loading.isLoading)
        XCTAssertFalse(LoadableState<Int>.idle.isLoading)
        XCTAssertFalse(LoadableState<Int>.loaded(1).isLoading)
    }

    func test_loadableState_error_isOnlyPresentForFailed() {
        XCTAssertEqual(LoadableState<Int>.failed(.decodingFailed).error, .decodingFailed)
        XCTAssertNil(LoadableState<Int>.loaded(1).error)
    }
}

// MARK: - BaseViewModel

@MainActor
final class BaseViewModelTests: XCTestCase {

    func test_runTask_success_runsOperationAndDoesNotCallOnError() async {
        let sut = BaseViewModel()
        var didRun = false
        var receivedError: AppError?

        sut.runTask({ didRun = true }, onError: { receivedError = $0 })

        await waitUntil { didRun }
        XCTAssertNil(receivedError)
    }

    func test_runTask_appError_isPassedThroughUnchanged() async {
        let sut = BaseViewModel()
        var receivedError: AppError?

        sut.runTask({ throw AppError.notFound }, onError: { receivedError = $0 })

        await waitUntil { receivedError != nil }
        XCTAssertEqual(receivedError, .notFound)
    }

    func test_runTask_nonAppError_isMappedToUnknown() async {
        struct Boom: Error {}
        let sut = BaseViewModel()
        var receivedError: AppError?

        sut.runTask({ throw Boom() }, onError: { receivedError = $0 })

        await waitUntil { receivedError != nil }
        guard case .unknown(let message)? = receivedError else {
            return XCTFail("Expected .unknown, got \(String(describing: receivedError))")
        }
        XCTAssertTrue(message.contains("Boom"))
    }

    func test_runTask_startingSecondTask_cancelsFirstWithoutCallingOnError() async throws {
        let sut = BaseViewModel()
        var firstCompleted = false
        var secondCompleted = false
        var errors: [AppError] = []

        sut.runTask({
            try await Task.sleep(nanoseconds: 5_000_000_000)
            firstCompleted = true
        }, onError: { errors.append($0) })
        sut.runTask({ secondCompleted = true }, onError: { errors.append($0) })

        await waitUntil { secondCompleted }
        try await Task.sleep(nanoseconds: 100_000_000) // Allow the old task time to handle its cancellation.

        XCTAssertFalse(firstCompleted)
        XCTAssertTrue(errors.isEmpty, "Task bị huỷ chủ đích không được báo lỗi")
    }

    func test_mapToAppError_keepsAppErrorAndWrapsOthers() {
        struct Boom: Error {}
        let sut = BaseViewModel()

        XCTAssertEqual(sut.mapToAppError(AppError.unauthorized), .unauthorized)
        guard case .unknown = sut.mapToAppError(Boom()) else {
            return XCTFail("Expected .unknown")
        }
    }
}

// MARK: - LoadableViewModel

@MainActor
final class LoadableViewModelTests: XCTestCase {

    func test_load_success_movesFromLoadingToLoaded() async {
        let sut = LoadableViewModel<[String]>()
        XCTAssertEqual(sut.state, .idle)

        sut.load { ["a"] }

        XCTAssertEqual(sut.state, .loading)
        await waitUntil { sut.state == .loaded(["a"]) }
    }

    func test_load_appErrorFailure_movesToFailedWithSameError() async {
        let sut = LoadableViewModel<[String]>()

        sut.load { throw AppError.notFound }

        await waitUntil { sut.state == .failed(.notFound) }
    }

    func test_load_nonAppErrorFailure_movesToFailedUnknown() async {
        struct Boom: Error {}
        let sut = LoadableViewModel<[String]>()

        sut.load { throw Boom() }

        await waitUntil { sut.state.error != nil }
        guard case .unknown? = sut.state.error else {
            return XCTFail("Expected .unknown, got \(sut.state)")
        }
    }

    func test_load_secondCallSupersedesFirst_slowFirstResultNeverOverwrites() async throws {
        let sut = LoadableViewModel<[String]>()

        sut.load {
            try await Task.sleep(nanoseconds: 300_000_000)
            return ["old"]
        }
        sut.load { ["new"] }

        await waitUntil { sut.state == .loaded(["new"]) }
        try await Task.sleep(nanoseconds: 400_000_000) // more than 300ms longer than the previous call
        XCTAssertEqual(sut.state, .loaded(["new"]))
    }
}
