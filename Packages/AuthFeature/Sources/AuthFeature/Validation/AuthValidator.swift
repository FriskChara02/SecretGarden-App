//
//  AuthValidator.swift
//  AuthFeature
//
//  Created by Loi Nguyen on 16/8/26.
//

// The entire function here is a PURE FUNCTION (no side effects, no dependency on AuthViewModel or Repository)
// -> Testable in isolation; no mocking required. AuthViewModel simply calls these functions rather than implementing the logic itself.
// Validation is centralized to prevent duplication or rule inconsistencies across different parts of the code.

import Foundation

public enum AuthValidator {

    // MARK: - Email

    public static func validateEmail(_ email: String) -> String? {
        guard !email.isEmpty else {
            return "Vui lòng nhập email."
        }
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        let range = NSRange(email.startIndex..., in: email)
        let isValid = regex.firstMatch(in: email, range: range) != nil
        return isValid ? nil : "Email không đúng định dạng."
    }

    // MARK: - Password

    public static func validatePassword(_ password: String) -> String? {
        guard !password.isEmpty else {
            return "Vui lòng nhập mật khẩu."
        }
        guard password.count >= 8 else {
            return "Mật khẩu phải có ít nhất 8 ký tự."
        }
        return nil
    }

    public static func validateConfirmPassword(_ password: String, _ confirmPassword: String) -> String? {
        guard !confirmPassword.isEmpty else {
            return "Vui lòng xác nhận mật khẩu."
        }
        guard password == confirmPassword else {
            return "Mật khẩu xác nhận không khớp."
        }
        return nil
    }

    // MARK: - Username

    public static func validateUsername(_ username: String) -> String? {
        guard !username.isEmpty else {
            return "Vui lòng nhập tên đăng nhập."
        }
        guard username.count >= 3 else {
            return "Tên đăng nhập phải có ít nhất 3 ký tự."
        }
        return nil
    }
}
