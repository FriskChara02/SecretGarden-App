import XCTest
@testable import AuthFeature

final class AuthFeatureTests: XCTestCase {
    func test_placeholder_versionIsSet() {
        XCTAssertEqual(AuthFeaturePlaceholder.version, "0.0.1")
    }
}
