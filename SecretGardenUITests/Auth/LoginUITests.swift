//
//  LoginUITests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import XCTest
import CoreArchitecture

final class LoginUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false // Stop immediately if a step fails, do not attempt to execute subsequent steps on an incorrect UI state.
    }

    func test_login_withValidCredentials_navigatesAwayFromLoginScreen() {
        let app = XCUIApplication()
        app.launchForUITesting(mockAuthOutcome: .success)
        AgeGateScreen(app: app).confirmAge()
        ProfileTabScreen(app: app).navigateToLogin()
        let loginScreen = LoginScreen(app: app).waitUntilVisible()

        loginScreen.login(email: "frisk@example.com", password: "password123")

        // Upon successful login and navigation away from the Login page, the field no longer exists.
        XCTAssertFalse(
            app.textFields["login.emailField"].waitForExistence(timeout: 1),
            "Sau khi đăng nhập thành công, màn Login phải biến mất"
        )
    }

    func test_login_withInvalidCredentials_staysOnLoginAndShowsError() {
        let app = XCUIApplication()
        app.launchForUITesting(mockAuthOutcome: .failure)
        AgeGateScreen(app: app).confirmAge()
        ProfileTabScreen(app: app).navigateToLogin()
        let loginScreen = LoginScreen(app: app).waitUntilVisible()

        loginScreen.login(email: "wrong@example.com", password: "wrongpassword")

        loginScreen.assertErrorMessageAppears()
        XCTAssertTrue(app.textFields["login.emailField"].exists, "Đăng nhập sai phải ở lại màn Login")
    }

    func test_tappingRegisterLink_navigatesToRegisterScreen() {
        let app = XCUIApplication()
        app.launchForUITesting()
        AgeGateScreen(app: app).confirmAge()
        ProfileTabScreen(app: app).navigateToLogin()
        let loginScreen = LoginScreen(app: app).waitUntilVisible()

        loginScreen.tapRegisterLink()

        // The Register screen has a Username field, the Login screen does not this is sufficient to confirm navigation to the correct screen.
        XCTAssertTrue(
            app.textFields["register.usernameField"].waitForExistence(timeout: 5),
            "Chưa gắn identifier cho RegisterView — sẽ làm nếu cần thêm bài test Register"
        )
    }
}
