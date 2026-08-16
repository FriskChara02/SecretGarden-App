//
//  AuthValidatorTests.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 16/8/26.
//

import XCTest
@testable import AuthFeature

final class AuthValidatorTests: XCTestCase {

    func test_validateEmail_validEmail_returnsNil() {
        XCTAssertNil(AuthValidator.validateEmail("test@example.com"))
    }

    func test_validateEmail_missingAtSign_returnsError() {
        XCTAssertNotNil(AuthValidator.validateEmail("testexample.com"))
    }

    func test_validateEmail_empty_returnsError() {
        XCTAssertNotNil(AuthValidator.validateEmail(""))
    }

    func test_validatePassword_shortPassword_returnsError() {
        XCTAssertNotNil(AuthValidator.validatePassword("123"))
    }

    func test_validatePassword_validLength_returnsNil() {
        XCTAssertNil(AuthValidator.validatePassword("12345678"))
    }

    func test_validateConfirmPassword_mismatch_returnsError() {
        XCTAssertNotNil(AuthValidator.validateConfirmPassword("12345678", "87654321"))
    }

    func test_validateConfirmPassword_match_returnsNil() {
        XCTAssertNil(AuthValidator.validateConfirmPassword("12345678", "12345678"))
    }
}
