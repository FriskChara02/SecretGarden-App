//
//  AgeGateManagerTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import CoreArchitecture
import XCTest

@MainActor
final class AgeGateManagerTests: XCTestCase {

    private var defaults: UserDefaults!
    private let suiteName = "AgeGateManagerTests"

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

    func test_init_whenNeverConfirmed_bothFlagsAreFalse() {
        let sut = AgeGateManager(defaults: defaults)

        XCTAssertFalse(sut.hasConfirmedAge)
        XCTAssertFalse(sut.isDeclined)
    }

    func test_confirmAge_setsFlagAndPersistsAcrossLaunches() {
        let sut = AgeGateManager(defaults: defaults)

        sut.confirmAge()

        XCTAssertTrue(sut.hasConfirmedAge)
        let nextLaunch = AgeGateManager(defaults: defaults)
        XCTAssertTrue(nextLaunch.hasConfirmedAge, "Xác nhận tuổi phải được nhớ ở lần mở app sau")
    }

    /// The refusal is NOT saved to the device - this is a current-session state,
    /// not a permanent configuration (unlike confirmAge).
    func test_declineAge_setsFlagButDoesNotPersist() {
        let sut = AgeGateManager(defaults: defaults)

        sut.declineAge()

        XCTAssertTrue(sut.isDeclined)
        let nextLaunch = AgeGateManager(defaults: defaults)
        XCTAssertFalse(nextLaunch.isDeclined)
        XCTAssertFalse(nextLaunch.hasConfirmedAge)
    }

    func test_declineAge_doesNotAffectHasConfirmedAge() {
        let sut = AgeGateManager(defaults: defaults)

        sut.declineAge()

        XCTAssertFalse(sut.hasConfirmedAge)
    }
}
