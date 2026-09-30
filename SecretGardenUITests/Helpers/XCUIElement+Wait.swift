//
//  XCUIElement+Wait.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 29/9/26.
//

import XCTest

extension XCUIElement {

    /// Wait for the element to appear and then assert – combine the two steps or condense them into a single line in each test case.
    @discardableResult
    func waitAndAssertExists(
        timeout: TimeInterval = 5,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> XCUIElement {
        XCTAssertTrue(waitForExistence(timeout: timeout), "Không tìm thấy phần tử: \(self)", file: file, line: line)
        return self
    }
}
