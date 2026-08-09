//
//  AppErrorTests.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 9/8/26.
//

// Basic unit test for AppError - verify build test target + confirm
// errorDescription returns the correct message and exhibits correct Equatable behavior.

import XCTest
@testable import CoreArchitecture

final class AppErrorTests: XCTestCase {

    func test_networkError_noInternetConnection_hasCorrectMessage() {
        // Given
        let error = AppError.network(.noInternetConnection)

        // When
        let message = error.errorDescription

        // Then
        XCTAssertEqual(message, "Không có kết nối mạng. Vui lòng kiểm tra lại Wi-Fi/4G.")
    }

    func test_unauthorized_hasCorrectMessage() {
        // Given
        let error = AppError.unauthorized

        // Then
        XCTAssertEqual(error.errorDescription, "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.")
    }

    func test_sameErrorCases_areEqual() {
        // Given
        let error1 = AppError.network(.serverError(statusCode: 500))
        let error2 = AppError.network(.serverError(statusCode: 500))

        // Then — verify that Equatable works correctly; this is important for
        // assertEqual(expectedError, actualError) in future Repository/ViewModel unit tests.
        XCTAssertEqual(error1, error2)
    }

    func test_differentErrorCases_areNotEqual() {
        // Given
        let error1 = AppError.network(.serverError(statusCode: 500))
        let error2 = AppError.network(.serverError(statusCode: 404))

        // Then
        XCTAssertNotEqual(error1, error2)
    }

    func test_validationError_returnsCustomMessage() {
        // Given
        let error = AppError.validation("Email không đúng định dạng")

        // Then
        XCTAssertEqual(error.errorDescription, "Email không đúng định dạng")
    }
}
