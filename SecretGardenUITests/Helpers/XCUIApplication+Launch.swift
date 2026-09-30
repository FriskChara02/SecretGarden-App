//
//  XCUIApplication+Launch.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import XCTest
import CoreArchitecture

extension XCUIApplication {

    /// Launch the app in a clean state (not logged in, age not yet verified),
    /// exactly like a "fresh install" – used for ALL UI tests, unless the test
    /// specifically intends to check the "app previously opened" state :DD
    func launchForUITesting(mockAuthOutcome: UITestLaunchArguments.MockAuthOutcome? = nil) {
        launchArguments = ["--uitesting-reset-state"]
        if let mockAuthOutcome {
            launchArguments.append("--uitesting-mock-auth-outcome=\(mockAuthOutcome.rawValue)")
        }
        launch()
    }
}
