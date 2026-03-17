import XCTest
@testable import SleepPath

final class SunlightLogTests: XCTestCase {

    // MARK: - Initialization

    func test_init_storesAllProperties() {
        let date = Date()
        let log = SunlightLog(date: date, durationMinutes: 15, withinRecommendedWindow: true)
        XCTAssertEqual(log.date, date)
        XCTAssertEqual(log.durationMinutes, 15)
        XCTAssertTrue(log.withinRecommendedWindow)
    }

    func test_init_defaultWithinRecommendedWindowIsFalse() {
        let log = SunlightLog(date: Date(), durationMinutes: 10)
        XCTAssertFalse(log.withinRecommendedWindow)
    }

    // MARK: - Identifiable

    func test_identifiable_uniqueIds() {
        let log1 = SunlightLog(date: Date(), durationMinutes: 10)
        let log2 = SunlightLog(date: Date(), durationMinutes: 10)
        XCTAssertNotEqual(log1.id, log2.id)
    }

    // MARK: - isWithinIdealWindow

    func test_isWithinIdealWindow_returnsTrueWhenRecommended() {
        let log = SunlightLog(date: Date(), durationMinutes: 15, withinRecommendedWindow: true)
        XCTAssertTrue(log.isWithinIdealWindow)
    }

    func test_isWithinIdealWindow_returnsFalseWhenNotRecommended() {
        let log = SunlightLog(date: Date(), durationMinutes: 15, withinRecommendedWindow: false)
        XCTAssertFalse(log.isWithinIdealWindow)
    }

    func test_isWithinIdealWindow_matchesWithinRecommendedWindow() {
        let logTrue = SunlightLog(date: Date(), durationMinutes: 10, withinRecommendedWindow: true)
        XCTAssertEqual(logTrue.isWithinIdealWindow, logTrue.withinRecommendedWindow)

        let logFalse = SunlightLog(date: Date(), durationMinutes: 10, withinRecommendedWindow: false)
        XCTAssertEqual(logFalse.isWithinIdealWindow, logFalse.withinRecommendedWindow)
    }
}
