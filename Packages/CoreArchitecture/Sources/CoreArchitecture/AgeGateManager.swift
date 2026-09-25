//
//  AgeGateManager.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 25/9/26.
//

// Tracks whether the person using this device has confirmed they meet the
// minimum age requirement (16+, per Terms of Service section 3). This is a
// device-level flag, NOT sensitive data — UserDefaults is the right store here,
// not Keychain (which is reserved for tokens/credentials).
//
// Deliberately independent of SessionState (AppRootViewModel): the Age Gate
// applies to Guests just as much as logged-in users, so it must sit ABOVE
// the auth/session layer, not inside it.

import Foundation
import Combine

@MainActor
public final class AgeGateManager: ObservableObject {
    private enum Keys {
        static let hasConfirmedAge = "com.secretgarden.ageGate.hasConfirmedAge"
    }

    @Published public private(set) var hasConfirmedAge: Bool
    @Published public var isDeclined: Bool = false

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasConfirmedAge = defaults.bool(forKey: Keys.hasConfirmedAge)
    }

    public func confirmAge() {
        hasConfirmedAge = true
        defaults.set(true, forKey: Keys.hasConfirmedAge)
    }

    public func declineAge() {
        isDeclined = true
    }
}
