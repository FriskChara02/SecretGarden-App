//
//  SearchUITests.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 30/9/26.
//

import XCTest
import CoreArchitecture

final class SearchUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Switch from the Home tab to the Search tab, confirm that arrived at the correct screen.
    private func launchAndOpenSearch(mockAuthOutcome: UITestLaunchArguments.MockAuthOutcome? = nil) -> (app: XCUIApplication, screen: SearchScreen) {
        let app = XCUIApplication()
        app.launchForUITesting(mockAuthOutcome: mockAuthOutcome)
        AgeGateScreen(app: app).confirmAge()
        app.tabBars.buttons["Tìm kiếm"].waitAndAssertExists(timeout: 10)
        app.tabBars.buttons["Tìm kiếm"].tap()
        let screen = SearchScreen(app: app).waitUntilVisible()
        return (app, screen)
    }

    func test_typingQuery_switchesFromHistoryToResultsViewImmediately() {
        let (_, screen) = launchAndOpenSearch()

        screen.typeQuery("yuri")

        // Switch to the results mode almost INSTANTLY - independent of network call debouncing.
        XCTAssertTrue(screen.isShowingResultsMode(timeout: 1), "Gõ ký tự phải rời khỏi màn lịch sử ngay, không đợi debounce")
    }

    func test_typingQuery_eventuallyShowsSearchResponseAfterDebounce() {
        let (_, screen) = launchAndOpenSearch()

        screen.typeQuery("yuri")

        XCTAssertTrue(
            screen.waitForSearchResponse(timeout: 5),
            "Sau khoảng debounce, phải có phản hồi tìm kiếm (kết quả hoặc empty state)"
        )
    }

    func test_clearingQuery_returnsToHistoryView() {
        let (_, screen) = launchAndOpenSearch()
        screen.typeQuery("yuri")
        XCTAssertTrue(screen.isShowingResultsMode(timeout: 2))

        screen.tapClear()

        XCTAssertFalse(screen.isShowingResultsMode(timeout: 1), "Xoá hết nội dung phải quay lại màn lịch sử")
    }
}
