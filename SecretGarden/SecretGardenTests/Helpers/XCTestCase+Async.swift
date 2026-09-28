//
//  XCTestCase+Async.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 28/9/26.
//

import XCTest

extension XCTestCase {

    /// Wait until `condition` is true (checked every 10ms), fail the test if `timeout` is exceeded.
    @MainActor
    func waitUntil(
        timeout: TimeInterval = 2,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ condition: () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            if Date() > deadline {
                XCTFail("Quá \(timeout)s mà điều kiện vẫn chưa đúng", file: file, line: line)
                return
            }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
}
