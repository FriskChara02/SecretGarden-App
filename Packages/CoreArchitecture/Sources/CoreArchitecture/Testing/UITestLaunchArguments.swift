//
//  UITestLaunchArguments.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 29/9/26.
//

// Launch-argument flags used EXCLUSIVELY by XCUITest to reset the app to a clean, controlled state
// before each test run (completely distinct from Debug Mocks).
// These flags are passed via XCUIApplication().launchArguments and are NEVER enabled when
// a real user opens the app (including manually installed Debug/Staging builds), because Xcode
// only attaches them when the XCUITest target is actually executed.

import Foundation

public enum UITestLaunchArguments {

    private static let arguments = ProcessInfo.processInfo.arguments

    /// Upon launch: the app must clear the Keychain and the age verification flag BEFORE displaying any UI -
    /// accurately simulating a "fresh install" for each XCUITest run.
    public static var shouldResetState: Bool {
        arguments.contains("--uitesting-reset-state")
    }

    public enum MockAuthOutcome: String {
        case success
        case failure
    }

    /// Force the login/register results of AuthRepositoryDebugMock - to enable UI test coverage
    /// for the "incorrect password" scenario, which the default Debug Mock cannot generate (as it always succeeds).
    public static var mockAuthOutcome: MockAuthOutcome? {
        guard let raw = arguments.first(where: { $0.hasPrefix("--uitesting-mock-auth-outcome=") }) else {
            return nil
        }
        let value = raw.replacingOccurrences(of: "--uitesting-mock-auth-outcome=", with: "")
        return MockAuthOutcome(rawValue: value)
    }
}
