import XCTest
@testable import SleepPath

final class CaffeineLogTests: XCTestCase {

    // MARK: - Initialization

    func test_init_defaultAmountIs95() {
        let log = CaffeineLog(timestamp: Date())
        XCTAssertEqual(log.amountMg, 95)
    }

    func test_init_defaultSourceIsCoffee() {
        let log = CaffeineLog(timestamp: Date())
        XCTAssertEqual(log.source, "Coffee")
    }

    func test_init_customValues() {
        let timestamp = Date()
        let log = CaffeineLog(timestamp: timestamp, amountMg: 150, source: "Espresso")
        XCTAssertEqual(log.timestamp, timestamp)
        XCTAssertEqual(log.amountMg, 150)
        XCTAssertEqual(log.source, "Espresso")
    }

    // MARK: - Identifiable

    func test_identifiable_uniqueIds() {
        let log1 = CaffeineLog(timestamp: Date())
        let log2 = CaffeineLog(timestamp: Date())
        XCTAssertNotEqual(log1.id, log2.id)
    }

    // MARK: - Hours Since Intake

    func test_hoursSinceIntake_recentTimestamp() {
        let oneHourAgo = Date.now.addingTimeInterval(-3600)
        let log = CaffeineLog(timestamp: oneHourAgo)
        XCTAssertEqual(log.hoursSinceIntake, 1.0, accuracy: 0.05)
    }

    func test_hoursSinceIntake_fiveHoursAgo() {
        let fiveHoursAgo = Date.now.addingTimeInterval(-5 * 3600)
        let log = CaffeineLog(timestamp: fiveHoursAgo)
        XCTAssertEqual(log.hoursSinceIntake, 5.0, accuracy: 0.05)
    }

    // MARK: - Estimated Caffeine Remaining

    func test_estimatedCaffeineRemaining_atIntakeTime() {
        let log = CaffeineLog(timestamp: Date.now)
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent, 100.0, accuracy: 1.0)
    }

    func test_estimatedCaffeineRemaining_afterOneHalfLife() {
        let fiveHoursAgo = Date.now.addingTimeInterval(-5 * 3600)
        let log = CaffeineLog(timestamp: fiveHoursAgo)
        // After 1 half-life (5h), should be ~50%
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent, 50.0, accuracy: 2.0)
    }

    func test_estimatedCaffeineRemaining_afterTwoHalfLives() {
        let tenHoursAgo = Date.now.addingTimeInterval(-10 * 3600)
        let log = CaffeineLog(timestamp: tenHoursAgo)
        // After 2 half-lives (10h), should be ~25%
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent, 25.0, accuracy: 2.0)
    }

    func test_estimatedCaffeineRemaining_futureTimestampReturnsFull() {
        let futureTimestamp = Date.now.addingTimeInterval(3600) // 1 hour in future
        let log = CaffeineLog(timestamp: futureTimestamp)
        // Guard catches negative hours, returns 100
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent, 100.0, accuracy: 0.01)
    }

    func test_estimatedCaffeineRemaining_decreasesOverTime() {
        let recent = CaffeineLog(timestamp: Date.now.addingTimeInterval(-1 * 3600))
        let older = CaffeineLog(timestamp: Date.now.addingTimeInterval(-5 * 3600))
        XCTAssertGreaterThan(recent.estimatedCaffeineRemainingPercent,
                             older.estimatedCaffeineRemainingPercent)
    }

    func test_estimatedCaffeineRemaining_neverNegative() {
        let veryOld = CaffeineLog(timestamp: Date.now.addingTimeInterval(-100 * 3600))
        XCTAssertGreaterThanOrEqual(veryOld.estimatedCaffeineRemainingPercent, 0)
    }
}
