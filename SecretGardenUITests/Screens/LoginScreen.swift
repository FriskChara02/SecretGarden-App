//
//  LoginScreen.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import XCTest

/// Page Object for the Login screen – any test interacting with this screen MUST go through this struct,
/// do not write `app.textFields["..."]` directly throughout the test file.
struct LoginScreen {
    let app: XCUIApplication

    private var emailField: XCUIElement { app.textFields["login.emailField"] }
    private var passwordField: XCUIElement { app.secureTextFields["login.passwordField"] }
    private var submitButton: XCUIElement { app.buttons["login.submitButton"] }
    private var errorText: XCUIElement { app.staticTexts["login.errorText"] }
    private var registerLink: XCUIElement { app.buttons["login.registerLink"] }
    private var forgotPasswordButton: XCUIElement { app.buttons["login.forgotPasswordButton"] }

    /// Confirm that you are actually on the Login screen (wait for the email field to appear).
    @discardableResult
    func waitUntilVisible(timeout: TimeInterval = 5) -> Self {
        emailField.waitAndAssertExists(timeout: timeout)
        return self
    }

    @discardableResult
    func enterEmail(_ email: String) -> Self {
        emailField.tap()
        emailField.typeText(email)
        return self
    }

    @discardableResult
    func enterPassword(_ password: String) -> Self {
        passwordField.tap()
        passwordField.typeText(password)
        return self
    }

    @discardableResult
    func tapLogin() -> Self {
        submitButton.tap()
        return self
    }

    /// High-level aggregate action – the test usually only needs to call this single line.
    @discardableResult
    func login(email: String, password: String) -> Self {
        enterEmail(email)
        enterPassword(password)
        tapLogin()
        return self
    }

    @discardableResult
    func assertErrorMessageAppears(timeout: TimeInterval = 5) -> Self {
        errorText.waitAndAssertExists(timeout: timeout)
        return self
    }

    func tapRegisterLink() {
        registerLink.tap()
    }

    func tapForgotPassword() {
        forgotPasswordButton.tap()
    }
}
