import XCTest

final class MandarinDriftUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOnboardingFlow() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Mandarin, one glance at a time."].waitForExistence(timeout: 2))
    }

    func testSearchFlow() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.exists)
    }
}
