//
//  FormSubmissionStateTests.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 16/8/26.
//

import XCTest
@testable import CoreArchitecture

final class FormSubmissionStateTests: XCTestCase {

    func test_isSubmitting_trueOnlyWhenSubmitting() {
        XCTAssertTrue(FormSubmissionState.submitting.isSubmitting)
        XCTAssertFalse(FormSubmissionState.idle.isSubmitting)
        XCTAssertFalse(FormSubmissionState.succeeded.isSubmitting)
        XCTAssertFalse(FormSubmissionState.failed(.unauthorized).isSubmitting)
    }

    func test_error_returnsErrorOnlyWhenFailed() {
        XCTAssertEqual(FormSubmissionState.failed(.unauthorized).error, .unauthorized)
        XCTAssertNil(FormSubmissionState.idle.error)
        XCTAssertNil(FormSubmissionState.succeeded.error)
    }
}
