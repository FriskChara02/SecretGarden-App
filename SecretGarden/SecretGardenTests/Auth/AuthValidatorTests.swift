//
//  AuthValidatorTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import AuthFeature
import XCTest

final class AuthValidatorTests: XCTestCase {

    // MARK: - Email

    func test_validateEmail_empty_returnsRequiredMessage() {
        XCTAssertEqual(AuthValidator.validateEmail(""), "Vui lòng nhập email.")
    }

    func test_validateEmail_invalidFormats_returnFormatMessage() {
        let invalid = ["abc", "abc@", "@example.com", "a@b", "a@b.c", "a b@example.com", "a@@example.com", " "]
        for email in invalid {
            XCTAssertEqual(AuthValidator.validateEmail(email), "Email không đúng định dạng.", "email: '\(email)'")
        }
    }

    func test_validateEmail_validFormats_returnNil() {
        let valid = ["frisk@example.com", "a.b+tag@sub.example.co", "user_name@example.io", "A-B@Ex-ample.COM"]
        for email in valid {
            XCTAssertNil(AuthValidator.validateEmail(email), "email: '\(email)'")
        }
    }

    // MARK: - Password

    func test_validatePassword_empty_returnsRequiredMessage() {
        XCTAssertEqual(AuthValidator.validatePassword(""), "Vui lòng nhập mật khẩu.")
    }

    func test_validatePassword_sevenCharacters_isTooShort() {
        XCTAssertEqual(AuthValidator.validatePassword("1234567"), "Mật khẩu phải có ít nhất 8 ký tự.")
    }

    func test_validatePassword_eightCharacters_isValid() {
        XCTAssertNil(AuthValidator.validatePassword("12345678"))
    }

    // MARK: - Confirm password

    func test_validateConfirmPassword_empty_returnsRequiredMessage() {
        XCTAssertEqual(AuthValidator.validateConfirmPassword("12345678", ""), "Vui lòng xác nhận mật khẩu.")
    }

    func test_validateConfirmPassword_mismatch_returnsMismatchMessage() {
        XCTAssertEqual(AuthValidator.validateConfirmPassword("12345678", "12345679"), "Mật khẩu xác nhận không khớp.")
    }

    func test_validateConfirmPassword_match_returnsNil() {
        XCTAssertNil(AuthValidator.validateConfirmPassword("12345678", "12345678"))
    }

    // MARK: - Username

    func test_validateUsername_empty_returnsRequiredMessage() {
        XCTAssertEqual(AuthValidator.validateUsername(""), "Vui lòng nhập tên đăng nhập.")
    }

    func test_validateUsername_twoCharacters_isTooShort() {
        XCTAssertEqual(AuthValidator.validateUsername("ab"), "Tên đăng nhập phải có ít nhất 3 ký tự.")
    }

    func test_validateUsername_threeCharacters_isValid() {
        XCTAssertNil(AuthValidator.validateUsername("abc"))
    }
}
