//
//  CoordinatorTests.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 19/8/26.
//

import XCTest
@testable import CoreArchitecture

// Mock route for testing - does not depend on any actual domain models.
private enum TestRoute: Hashable {
    case screenA
    case screenB(id: String)
    case screenC
}

final class CoordinatorTests: XCTestCase {

    func test_push_addsRouteToPath() {
        let sut = Coordinator<TestRoute>()

        sut.push(.screenA)

        XCTAssertEqual(sut.stackDepth, 1)
    }

    func test_push_multipleRoutes_increasesDepthCorrectly() {
        let sut = Coordinator<TestRoute>()

        sut.push(.screenA)
        sut.push(.screenB(id: "123"))
        sut.push(.screenC)

        XCTAssertEqual(sut.stackDepth, 3)
    }

    func test_pop_removesTopRoute() {
        let sut = Coordinator<TestRoute>()
        sut.push(.screenA)
        sut.push(.screenB(id: "123"))

        sut.pop()

        XCTAssertEqual(sut.stackDepth, 1)
    }

    func test_pop_onEmptyPath_doesNothing() {
        let sut = Coordinator<TestRoute>()

        sut.pop()

        XCTAssertEqual(sut.stackDepth, 0)
    }

    func test_popToRoot_clearsEntirePath() {
        let sut = Coordinator<TestRoute>()
        sut.push(.screenA)
        sut.push(.screenB(id: "123"))
        sut.push(.screenC)

        sut.popToRoot()

        XCTAssertEqual(sut.stackDepth, 0)
    }

    func test_popToRoot_onEmptyPath_doesNothing() {
        let sut = Coordinator<TestRoute>()

        sut.popToRoot()

        XCTAssertEqual(sut.stackDepth, 0)
    }

    func test_presentSheet_setsPresentedSheet() {
        let sut = Coordinator<TestRoute>()

        sut.presentSheet(.screenA)

        XCTAssertEqual(sut.presentedSheet, .screenA)
    }

    func test_dismissSheet_clearsPresentedSheet() {
        let sut = Coordinator<TestRoute>()
        sut.presentSheet(.screenA)

        sut.dismissSheet()

        XCTAssertNil(sut.presentedSheet)
    }

    func test_presentFullScreenCover_setsPresentedFullScreenCover() {
        let sut = Coordinator<TestRoute>()

        sut.presentFullScreenCover(.screenC)

        XCTAssertEqual(sut.presentedFullScreenCover, .screenC)
    }

    func test_dismissFullScreenCover_clearsPresentedFullScreenCover() {
        let sut = Coordinator<TestRoute>()
        sut.presentFullScreenCover(.screenC)

        sut.dismissFullScreenCover()

        XCTAssertNil(sut.presentedFullScreenCover)
    }

    func test_sheetAndFullScreenCover_areIndependent() {
        let sut = Coordinator<TestRoute>()

        sut.presentSheet(.screenA)
        sut.presentFullScreenCover(.screenC)

        XCTAssertEqual(sut.presentedSheet, .screenA)
        XCTAssertEqual(sut.presentedFullScreenCover, .screenC)

        sut.dismissSheet()

        XCTAssertNil(sut.presentedSheet)
        XCTAssertEqual(sut.presentedFullScreenCover, .screenC) // unaffected
    }
}
