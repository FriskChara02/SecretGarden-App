//
//  AuthCoordinatorTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

@testable import SecretGarden
import XCTest

@MainActor
final class AuthCoordinatorTests: XCTestCase {

    func test_initialState_isLogin() {
        let sut = AuthCoordinator()

        XCTAssertNil(sut.currentRoute)
    }

    func test_show_register_setsGivenRoute() {
        let sut = AuthCoordinator()

        sut.show(.register)

        XCTAssertEqual(sut.currentRoute, .register)
    }

    func test_show_forgotPassword_setsGivenRoute() {
        let sut = AuthCoordinator()

        sut.show(.forgotPassword)

        XCTAssertEqual(sut.currentRoute, .forgotPassword)
    }

    func test_showLogin_resetsToNilFromAnyRoute() {
        let sut = AuthCoordinator()
        sut.show(.register)

        sut.showLogin()

        XCTAssertNil(sut.currentRoute)
    }

    /// Auth is a replacement flow, not a stack
    /// calling show() a second time must completely replace the current route, not stack on top of it.
    func test_show_replacesCurrentRouteRatherThanStacking() {
        let sut = AuthCoordinator()
        sut.show(.register)

        sut.show(.forgotPassword)

        XCTAssertEqual(sut.currentRoute, .forgotPassword)
    }
}
