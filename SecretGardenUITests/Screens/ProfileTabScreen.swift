//
//  ProfileTabScreen.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 30/9/26.
//

import XCTest

/// Page Object for the "Personal" tab in the Guest state - the only entry point to LoginView.
struct ProfileTabScreen {
    let app: XCUIApplication

    private var tabBar: XCUIElement { app.tabBars.firstMatch }
    private var profileTabButton: XCUIElement { app.tabBars.buttons["tabBar.profile"] }
    private var loginButton: XCUIElement { app.buttons["profile.loginButton"] }

    /// From any tab, switch to the Personal tab and tap "Log in" to access the LoginView.
    func navigateToLogin() {
        // Wait for the main tab bar to appear first — the dismissal animation of the Age Gate (fullScreenCover)
        // requires a brief delay before the underlying TabView is ready to accept interactions.
        tabBar.waitAndAssertExists(timeout: 10)
        profileTabButton.waitAndAssertExists(timeout: 10)
        profileTabButton.tap()
        loginButton.waitAndAssertExists(timeout: 10)
        loginButton.tap()
    }
}
