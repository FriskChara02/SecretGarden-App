//
//  CoordinatorTests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import CoreArchitecture
import XCTest

private enum TestRoute: Hashable {
    case a, b, c
}

@MainActor
final class CoordinatorTests: XCTestCase {

    private var sut: Coordinator<TestRoute>!

    override func setUp() {
        super.setUp()
        sut = Coordinator<TestRoute>()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Push / Pop

    func test_initialState_isEmpty() {
        XCTAssertEqual(sut.stackDepth, 0)
        XCTAssertNil(sut.presentedSheet)
        XCTAssertNil(sut.presentedFullScreenCover)
    }

    func test_push_increasesStackDepth() {
        sut.push(.a)
        sut.push(.b)

        XCTAssertEqual(sut.stackDepth, 2)
    }

    func test_pop_decreasesStackDepth() {
        sut.push(.a)
        sut.push(.b)

        sut.pop()

        XCTAssertEqual(sut.stackDepth, 1)
    }

    func test_pop_whenEmpty_doesNothing() {
        sut.pop()

        XCTAssertEqual(sut.stackDepth, 0)
    }

    func test_popToRoot_clearsEntireStack() {
        sut.push(.a)
        sut.push(.b)
        sut.push(.c)

        sut.popToRoot()

        XCTAssertEqual(sut.stackDepth, 0)
    }

    func test_popToRoot_whenAlreadyEmpty_doesNothing() {
        sut.popToRoot()

        XCTAssertEqual(sut.stackDepth, 0)
    }

    // MARK: - Sheet

    func test_presentSheet_setsPresentedSheet() {
        sut.presentSheet(.a)

        XCTAssertEqual(sut.presentedSheet, .a)
    }

    func test_dismissSheet_clearsPresentedSheet() {
        sut.presentSheet(.a)

        sut.dismissSheet()

        XCTAssertNil(sut.presentedSheet)
    }

    // MARK: - Full screen cover

    func test_presentFullScreenCover_setsPresentedFullScreenCover() {
        sut.presentFullScreenCover(.b)

        XCTAssertEqual(sut.presentedFullScreenCover, .b)
    }

    func test_dismissFullScreenCover_clearsPresentedFullScreenCover() {
        sut.presentFullScreenCover(.b)

        sut.dismissFullScreenCover()

        XCTAssertNil(sut.presentedFullScreenCover)
    }

    func test_sheetAndFullScreenCover_areIndependent() {
        sut.presentSheet(.a)
        sut.presentFullScreenCover(.b)

        sut.dismissSheet()

        XCTAssertNil(sut.presentedSheet)
        XCTAssertEqual(sut.presentedFullScreenCover, .b, "Dismiss sheet không được đụng tới fullScreenCover")
    }
}
