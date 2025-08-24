import XCTest
@testable import HouseholdTasksWidget

final class WidgetProviderTests: XCTestCase {
    func testTimelineProvidesEntry() {
        let provider = Provider()
        let exp = expectation(description: "timeline")
        provider.getTimeline(in: .init()) { timeline in
            XCTAssertGreaterThan(timeline.entries.count, 0)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
