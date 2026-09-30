//
//  ThemeManagerTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import CoreArchitecture
import XCTest

@MainActor
final class ThemeManagerTests: XCTestCase {

    private var defaults: UserDefaults!
    private let suiteName = "ThemeManagerTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func test_init_whenNeverSet_defaultsToLightMode() {
        let sut = ThemeManager(defaults: defaults)

        XCTAssertFalse(sut.isDarkMode)
    }

    func test_toggle_flipsValueAndPersistsAcrossLaunches() {
        let sut = ThemeManager(defaults: defaults)

        sut.toggle()

        XCTAssertTrue(sut.isDarkMode)
        let nextLaunch = ThemeManager(defaults: defaults)
        XCTAssertTrue(nextLaunch.isDarkMode, "Dark mode phải được nhớ ở lần mở app sau")
    }

    func test_toggle_twice_returnsToOriginalValue() {
        let sut = ThemeManager(defaults: defaults)

        sut.toggle()
        sut.toggle()

        XCTAssertFalse(sut.isDarkMode)
    }

    func test_settingIsDarkModeDirectly_persistsImmediately() {
        let sut = ThemeManager(defaults: defaults)

        sut.isDarkMode = true

        let nextLaunch = ThemeManager(defaults: defaults)
        XCTAssertTrue(nextLaunch.isDarkMode)
    }
}
