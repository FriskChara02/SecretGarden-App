//
//  NetworkErrorMappingTests.swift
//  CoreNetworking
//
//  Created by Loi Nguyen on 14/8/26.
//

import XCTest
import CoreArchitecture
@testable import CoreNetworking

final class NetworkErrorMappingTests: XCTestCase {

    func test_noConnection_mapsToNetworkNoInternet() {
        XCTAssertEqual(NetworkError.noConnection.asAppError(), .network(.noInternetConnection))
    }

    func test_timeout_mapsToNetworkTimeout() {
        XCTAssertEqual(NetworkError.timeout.asAppError(), .network(.timeout))
    }

    func test_serverError401_mapsToUnauthorized_evenWithMessage() {
        let error = NetworkError.serverError(statusCode: 401, errorResponse: ErrorResponse(message: "Token hết hạn", code: nil))
        XCTAssertEqual(error.asAppError(), .unauthorized)
    }

    func test_serverError_withMessage_mapsToNetworkOther() {
        let error = NetworkError.serverError(statusCode: 409, errorResponse: ErrorResponse(message: "Email đã tồn tại", code: "EMAIL_TAKEN"))
        XCTAssertEqual(error.asAppError(), .network(.other("Email đã tồn tại")))
    }

    func test_serverError_withoutMessage_mapsToNetworkServerError() {
        let error = NetworkError.serverError(statusCode: 500, errorResponse: nil)
        XCTAssertEqual(error.asAppError(), .network(.serverError(statusCode: 500)))
    }

    func test_decodingFailed_mapsToAppErrorDecodingFailed() {
        struct DummyError: Error {}
        let error = NetworkError.decodingFailed(underlying: DummyError())
        XCTAssertEqual(error.asAppError(), .decodingFailed)
    }

    func test_unauthorized_mapsDirectly() {
        XCTAssertEqual(NetworkError.unauthorized.asAppError(), .unauthorized)
    }
}
