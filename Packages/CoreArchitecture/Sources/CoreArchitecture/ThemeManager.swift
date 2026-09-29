//
//  ThemeManager.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 19/9/26.
//

/// Dark/Light mode for the entire app.
// Any toggle (Reader, Personal tab, Account Settings) reads/writes through here.

import Foundation

@MainActor
public final class ThemeManager: ObservableObject {

    private static let storageKey = "isDarkModeEnabled"
    private let defaults: UserDefaults

    @Published public var isDarkMode: Bool {
        didSet {
            defaults.set(isDarkMode, forKey: Self.storageKey)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isDarkMode = defaults.bool(forKey: Self.storageKey)
    }

    public func toggle() {
        isDarkMode.toggle()
    }
}
