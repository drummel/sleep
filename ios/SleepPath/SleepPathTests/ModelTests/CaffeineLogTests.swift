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

    func test_init_zeroAmount() {
        let log = CaffeineLog(timestamp: Date(), amountMg: 0)
        XCTAssertEqual(log.amountMg, 0)
    }

    // MARK: - Identifiable

    func test_identifiable_uniqueIds() {
        let log1 = CaffeineLog(timestamp: Date())
        let log2 = CaffeineLog(timestamp: Date())
        XCTAssertNotEqual(log1.id, log2.id)
    }

    // MARK: - Hours Since Intake (deterministic with referenceDate)

    func test_hoursSinceIntake_oneHour() {
        let intake = Date(timeIntervalSince1970: 1000)
        let reference = Date(timeIntervalSince1970: 4600) // 1 hour later
        let log = CaffeineLog(timestamp: intake)
        XCTAssertEqual(log.hoursSinceIntake(referenceDate: reference), 1.0, accuracy: 0.01)
    }

    func test_hoursSinceIntake_fiveHours() {
        let intake = Date(timeIntervalSince1970: 1000)
        let reference = Date(timeIntervalSince1970: 19000) // 5 hours later
        let log = CaffeineLog(timestamp: intake)
        XCTAssertEqual(log.hoursSinceIntake(referenceDate: reference), 5.0, accuracy: 0.01)
    }

    func test_hoursSinceIntake_zeroWhenSameTime() {
        let time = Date(timeIntervalSince1970: 1000)
        let log = CaffeineLog(timestamp: time)
        XCTAssertEqual(log.hoursSinceIntake(referenceDate: time), 0.0, accuracy: 0.001)
    }

    func test_hoursSinceIntake_negativeForFutureTimestamp() {
        let intake = Date(timeIntervalSince1970: 10000)
        let reference = Date(timeIntervalSince1970: 1000) // before intake
        let log = CaffeineLog(timestamp: intake)
        XCTAssertLessThan(log.hoursSinceIntake(referenceDate: reference), 0)
    }

    // MARK: - Estimated Caffeine Remaining (deterministic)

    func test_caffeineRemaining_atIntakeTime_is100() {
        let time = Date(timeIntervalSince1970: 1000)
        let log = CaffeineLog(timestamp: time)
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent(referenceDate: time), 100.0, accuracy: 0.01)
    }

    func test_caffeineRemaining_afterOneHalfLife_is50() {
        let intake = Date(timeIntervalSince1970: 1000)
        let reference = intake.addingTimeInterval(5 * 3600)
        let log = CaffeineLog(timestamp: intake)
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent(referenceDate: reference), 50.0, accuracy: 0.01)
    }

    func test_caffeineRemaining_afterTwoHalfLives_is25() {
        let intake = Date(timeIntervalSince1970: 1000)
        let reference = intake.addingTimeInterval(10 * 3600)
        let log = CaffeineLog(timestamp: intake)
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent(referenceDate: reference), 25.0, accuracy: 0.01)
    }

    func test_caffeineRemaining_afterThreeHalfLives_is12point5() {
        let intake = Date(timeIntervalSince1970: 1000)
        let reference = intake.addingTimeInterval(15 * 3600)
        let log = CaffeineLog(timestamp: intake)
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent(referenceDate: reference), 12.5, accuracy: 0.01)
    }

    func test_caffeineRemaining_futureTimestamp_returns100() {
        let intake = Date(timeIntervalSince1970: 10000)
        let reference = Date(timeIntervalSince1970: 1000)
        let log = CaffeineLog(timestamp: intake)
        XCTAssertEqual(log.estimatedCaffeineRemainingPercent(referenceDate: reference), 100.0, accuracy: 0.01)
    }

    func test_caffeineRemaining_decreasesOverTime() {
        let intake = Date(timeIntervalSince1970: 1000)
        let log = CaffeineLog(timestamp: intake)
        let early = log.estimatedCaffeineRemainingPercent(referenceDate: intake.addingTimeInterval(1 * 3600))
        let later = log.estimatedCaffeineRemainingPercent(referenceDate: intake.addingTimeInterval(5 * 3600))
        XCTAssertGreaterThan(early, later)
    }

    func test_caffeineRemaining_neverNegative() {
        let intake = Date(timeIntervalSince1970: 1000)
        let reference = intake.addingTimeInterval(100 * 3600)
        let log = CaffeineLog(timestamp: intake)
        XCTAssertGreaterThanOrEqual(log.estimatedCaffeineRemainingPercent(referenceDate: reference), 0)
    }

    func test_caffeineRemaining_alwaysLessThanOrEqual100() {
        let intake = Date(timeIntervalSince1970: 1000)
        let log = CaffeineLog(timestamp: intake)
        for hours in stride(from: 0.0, through: 48.0, by: 1.0) {
            let ref = intake.addingTimeInterval(hours * 3600)
            let remaining = log.estimatedCaffeineRemainingPercent(referenceDate: ref)
            XCTAssertLessThanOrEqual(remaining, 100.0)
        }
    }
}
