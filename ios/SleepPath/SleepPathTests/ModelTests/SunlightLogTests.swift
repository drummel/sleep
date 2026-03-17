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

    func test_init_storesExactDate() {
        let specificDate = Date(timeIntervalSince1970: 1700000000)
        let log = SunlightLog(date: specificDate, durationMinutes: 20)
        XCTAssertEqual(log.date.timeIntervalSince1970, 1700000000, accuracy: 0.001)
    }

    // MARK: - Identifiable

    func test_identifiable_uniqueIds() {
        let log1 = SunlightLog(date: Date(), durationMinutes: 10)
        let log2 = SunlightLog(date: Date(), durationMinutes: 10)
        XCTAssertNotEqual(log1.id, log2.id)
    }

    // MARK: - withinRecommendedWindow

    func test_withinRecommendedWindow_trueWhenSetToTrue() {
        let log = SunlightLog(date: Date(), durationMinutes: 15, withinRecommendedWindow: true)
        XCTAssertTrue(log.withinRecommendedWindow)
    }

    func test_withinRecommendedWindow_falseWhenSetToFalse() {
        let log = SunlightLog(date: Date(), durationMinutes: 15, withinRecommendedWindow: false)
        XCTAssertFalse(log.withinRecommendedWindow)
    }

    // MARK: - Edge Cases

    func test_zeroDurationMinutes() {
        let log = SunlightLog(date: Date(), durationMinutes: 0)
        XCTAssertEqual(log.durationMinutes, 0)
    }

    func test_negativeDurationMinutes_accepted() {
        let log = SunlightLog(date: Date(), durationMinutes: -5)
        XCTAssertEqual(log.durationMinutes, -5)
    }

    func test_largeDurationMinutes() {
        let log = SunlightLog(date: Date(), durationMinutes: 1440) // 24 hours
        XCTAssertEqual(log.durationMinutes, 1440)
    }

    func test_distantPastDate() {
        let log = SunlightLog(date: .distantPast, durationMinutes: 10)
        XCTAssertEqual(log.date, .distantPast)
    }

    func test_distantFutureDate() {
        let log = SunlightLog(date: .distantFuture, durationMinutes: 10)
        XCTAssertEqual(log.date, .distantFuture)
    }
}
