//
//  SearchScreen.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 30/9/26.
//

import XCTest

struct SearchScreen {
    let app: XCUIApplication

    private var searchField: XCUIElement { app.textFields["search.bar.field"] }
    private var clearButton: XCUIElement { app.buttons["search.bar.clearButton"] }
    private var clearHistoryButton: XCUIElement { app.buttons["search.clearHistoryButton"] }

    /// true if in the "history view" state (the Clear History button exists - it only appears when there is ≥1 item,
    /// so this is merely a secondary signal, the primary signal is the ABSENCE of the Grid/List toggle).
    private var gridToggleButton: XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'grid'")).firstMatch
    }

    @discardableResult
    func waitUntilVisible(timeout: TimeInterval = 10) -> Self {
        searchField.waitAndAssertExists(timeout: timeout)
        return self
    }

    /// Type character by character (without submitting) - used to test debounce/instant state transitions.
    @discardableResult
    func typeQuery(_ text: String) -> Self {
        searchField.tap()
        searchField.typeText(text)
        return self
    }

    @discardableResult
    func submitQuery(_ text: String) -> Self {
        typeQuery(text)
        searchField.typeText("\n") // .onSubmit via keyboard, equivalent to pressing the "Search" button
        return self
    }

    func tapClear() {
        clearButton.tap()
    }

    func historyRow(forQuery query: String) -> XCUIElement {
        app.buttons["search.historyRow.\(query)"]
    }

    /// true when the UI has exited the history screen - indicated by the appearance of the Grid/List toggle
    /// (isShowingHistory updates immediately when the text is non-empty, it does NOT wait for the debounce).
    func isShowingResultsMode(timeout: TimeInterval = 2) -> Bool {
        gridToggleButton.waitForExistence(timeout: timeout)
    }

    /// Wait for the actual search response (after debouncing) - either a result set or an empty state.
    func waitForSearchResponse(timeout: TimeInterval = 5) -> Bool {
        let anyResultCard = app.otherElements.matching(
            NSPredicate(format: "identifier BEGINSWITH 'search.resultCard.'")
        ).firstMatch
        let emptyState = app.staticTexts["Không tìm thấy kết quả"]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if anyResultCard.exists || emptyState.exists { return true }
        }
        return false
    }
}
