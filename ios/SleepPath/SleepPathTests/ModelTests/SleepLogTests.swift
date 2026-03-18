import XCTest
@testable import SleepPath

final class SleepLogTests: XCTestCase {

    // MARK: - Helpers

    private func makeSleepLog(
        bedtime: Date? = nil,
        wakeTime: Date? = nil,
        deepSleepMinutes: Int = 90,
        remSleepMinutes: Int = 120,
        coreSleepMinutes: Int = 180,
        awakeMinutes: Int = 30,
        isWeekday: Bool = true
    ) -> SleepLog {
        let calendar = Calendar.current
        let today = Date()
        let bed = bedtime ?? calendar.date(bySettingHour: 22, minute: 30, second: 0, of: today)!
        let wake = wakeTime ?? calendar.date(bySettingHour: 6, minute: 30, second: 0, of: today.addingTimeInterval(86400))!

        return SleepLog(
            bedtime: bed,
            wakeTime: wake,
            deepSleepMinutes: deepSleepMinutes,
            remSleepMinutes: remSleepMinutes,
            coreSleepMinutes: coreSleepMinutes,
            awakeMinutes: awakeMinutes,
            isWeekday: isWeekday
        )
    }

    // MARK: - Initialization

    func test_init_defaultDateIsStartOfWakeDay() {
        let calendar = Calendar.current
        let log = makeSleepLog()
        let startOfWakeDay = calendar.startOfDay(for: log.wakeTime)
        XCTAssertEqual(log.date, startOfWakeDay)
    }

    func test_init_customDate() {
        let customDate = Date(timeIntervalSince1970: 1000000)
        let log = SleepLog(
            date: customDate,
            bedtime: Date(),
            wakeTime: Date().addingTimeInterval(28800),
            deepSleepMinutes: 90,
            remSleepMinutes: 90,
            coreSleepMinutes: 180,
            awakeMinutes: 20,
            isWeekday: true
        )
        XCTAssertEqual(log.date, customDate)
    }

    func test_init_defaultSourceIsMock() {
        let log = makeSleepLog()
        XCTAssertEqual(log.source, "mock")
    }

    func test_init_customSource() {
        let log = SleepLog(
            bedtime: Date(),
            wakeTime: Date().addingTimeInterval(28800),
            deepSleepMinutes: 90,
            remSleepMinutes: 90,
            coreSleepMinutes: 180,
            awakeMinutes: 20,
            isWeekday: true,
            source: "healthkit"
        )
        XCTAssertEqual(log.source, "healthkit")
    }

    // MARK: - Identifiable

    func test_identifiable_uniqueIds() {
        let log1 = makeSleepLog()
        let log2 = makeSleepLog()
        XCTAssertNotEqual(log1.id, log2.id)
    }

    // MARK: - Computed Properties

    func test_totalSleepMinutes_sumsDeepRemAndCore() {
        let log = makeSleepLog(deepSleepMinutes: 90, remSleepMinutes: 120, coreSleepMinutes: 180)
        XCTAssertEqual(log.totalSleepMinutes, 390)
    }

    func test_totalSleepMinutes_excludesAwake() {
        let log = makeSleepLog(deepSleepMinutes: 60, remSleepMinutes: 60, coreSleepMinutes: 60, awakeMinutes: 100)
        XCTAssertEqual(log.totalSleepMinutes, 180)
    }

    func test_timeInBedMinutes_calculatesFromBedToWake() {
        let bedtime = Date()
        let wakeTime = bedtime.addingTimeInterval(8 * 3600) // 8 hours
        let log = SleepLog(
            bedtime: bedtime,
            wakeTime: wakeTime,
            deepSleepMinutes: 90,
            remSleepMinutes: 90,
            coreSleepMinutes: 180,
            awakeMinutes: 20,
            isWeekday: true
        )
        XCTAssertEqual(log.timeInBedMinutes, 480)
    }

    func test_sleepEfficiency_calculatesCorrectly() {
        let bedtime = Date()
        let wakeTime = bedtime.addingTimeInterval(8 * 3600) // 480 min
        let log = SleepLog(
            bedtime: bedtime,
            wakeTime: wakeTime,
            deepSleepMinutes: 96,
            remSleepMinutes: 96,
            coreSleepMinutes: 192,
            awakeMinutes: 96,
            isWeekday: true
        )
        // totalSleep = 384, timeInBed = 480, efficiency = 384/480 * 100 = 80.0
        XCTAssertEqual(log.sleepEfficiency, 80.0, accuracy: 0.01)
    }

    func test_sleepEfficiency_zeroTimeInBedReturnsZero() {
        let now = Date()
        let log = SleepLog(
            bedtime: now,
            wakeTime: now,
            deepSleepMinutes: 0,
            remSleepMinutes: 0,
            coreSleepMinutes: 0,
            awakeMinutes: 0,
            isWeekday: true
        )
        XCTAssertEqual(log.sleepEfficiency, 0)
    }

    func test_durationMinutes_totalSleepPlusAwake() {
        let log = makeSleepLog(deepSleepMinutes: 90, remSleepMinutes: 90, coreSleepMinutes: 180, awakeMinutes: 30)
        XCTAssertEqual(log.durationMinutes, 390) // 360 + 30
    }

    func test_formattedDuration_returnsHoursAndMinutes() {
        let log = makeSleepLog(deepSleepMinutes: 90, remSleepMinutes: 120, coreSleepMinutes: 182)
        // totalSleep = 392 min = 6h 32m
        let formatted = log.formattedDuration
        XCTAssertTrue(formatted.contains("h"), "Should contain hours")
        XCTAssertTrue(formatted.contains("m"), "Should contain minutes")
    }

    func test_dateString_formatsAsYYYYMMDD() {
        let log = makeSleepLog()
        let dateString = log.dateString
        // Should match yyyy-MM-dd pattern
        let regex = try! NSRegularExpression(pattern: "^\\d{4}-\\d{2}-\\d{2}$")
        let range = NSRange(dateString.startIndex..<dateString.endIndex, in: dateString)
        XCTAssertNotNil(regex.firstMatch(in: dateString, range: range),
                        "Date string should be in yyyy-MM-dd format, got: \(dateString)")
    }

    func test_sleepOnset_isBedtime() {
        let log = makeSleepLog()
        XCTAssertEqual(log.sleepOnset, log.bedtime)
    }

    func test_isWeekday_storedCorrectly() {
        let weekdayLog = makeSleepLog(isWeekday: true)
        XCTAssertTrue(weekdayLog.isWeekday)

        let weekendLog = makeSleepLog(isWeekday: false)
        XCTAssertFalse(weekendLog.isWeekday)
    }

    // MARK: - Edge Cases

    func test_sleepEfficiency_clampedTo100WhenSleepExceedsTimeInBed() {
        let bedtime = Date()
        let wakeTime = bedtime.addingTimeInterval(4 * 3600) // 240 min in bed
        let log = SleepLog(
            bedtime: bedtime,
            wakeTime: wakeTime,
            deepSleepMinutes: 100,
            remSleepMinutes: 100,
            coreSleepMinutes: 100,
            awakeMinutes: 0,
            isWeekday: true
        )
        // totalSleep = 300 > timeInBed = 240, efficiency should be clamped to 100
        XCTAssertLessThanOrEqual(log.sleepEfficiency, 100.0)
    }

    func test_timeInBedMinutes_bedtimeAfterWakeTimeReturnsZero() {
        let bedtime = Date()
        let wakeTime = bedtime.addingTimeInterval(-3600) // wake before bed (bad data)
        let log = SleepLog(
            bedtime: bedtime,
            wakeTime: wakeTime,
            deepSleepMinutes: 90,
            remSleepMinutes: 90,
            coreSleepMinutes: 90,
            awakeMinutes: 10,
            isWeekday: true
        )
        XCTAssertGreaterThanOrEqual(log.timeInBedMinutes, 0, "Should not return negative")
    }

    func test_totalSleepMinutes_allZeros() {
        let log = makeSleepLog(deepSleepMinutes: 0, remSleepMinutes: 0, coreSleepMinutes: 0)
        XCTAssertEqual(log.totalSleepMinutes, 0)
    }

    func test_durationMinutes_allZeros() {
        let log = makeSleepLog(deepSleepMinutes: 0, remSleepMinutes: 0, coreSleepMinutes: 0, awakeMinutes: 0)
        XCTAssertEqual(log.durationMinutes, 0)
    }
}
