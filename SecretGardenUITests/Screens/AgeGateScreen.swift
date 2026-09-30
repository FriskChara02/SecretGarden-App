//
//  AgeGateScreen.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 30/9/26.
//

import XCTest

/// Page Object for the Age Gate screen - which always appears before any other screen after
/// launchForUITesting() resets the state - so EVERY UI test must call confirmAge()
/// immediately after the app launches, before interacting with any other Page Object.
struct AgeGateScreen {
    let app: XCUIApplication

    private var confirmButton: XCUIElement { app.buttons["ageGate.confirmButton"] }

    func confirmAge(timeout: TimeInterval = 5) {
        confirmButton.waitAndAssertExists(timeout: timeout)
        confirmButton.tap()
    }
}
