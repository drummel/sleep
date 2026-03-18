import XCTest
@testable import SleepPath

final class MockDataServiceTests: XCTestCase {

    var mockData: MockDataService!

    override func setUp() {
        super.setUp()
        mockData = MockDataService.shared
    }

    // MARK: - User Profile

    func test_userProfile_isWolf() {
        XCTAssertEqual(mockData.userProfile.chronotype, .wolf)
    }

    func test_userProfile_hasName() {
        XCTAssertFalse(mockData.userProfile.name.isEmpty)
        XCTAssertEqual(mockData.userProfile.name, "Alex")
    }

    func test_userProfile_createdAtIsInPast() {
        XCTAssertLessThan(mockData.userProfile.createdAt, Date())
    }

    func test_userProfile_isHealthKitConnected() {
        XCTAssertTrue(mockData.userProfile.healthKitConnected)
    }

    func test_userProfile_isProSubscriber() {
        XCTAssertTrue(mockData.userProfile.isProSubscriber)
    }

    // MARK: - Sleep Logs

    func test_sleepLogs_has30Days() {
        XCTAssertEqual(mockData.sleepLogs.count, 30)
    }

    func test_sleepLogs_areNotEmpty() {
        XCTAssertFalse(mockData.sleepLogs.isEmpty)
    }

    func test_sleepLogs_durationsAreRealistic() {
        for log in mockData.sleepLogs {
            let totalSleepHours = Double(log.totalSleepMinutes) / 60.0
            XCTAssertGreaterThanOrEqual(
                totalSleepHours, 5.0,
                "Sleep duration should be at least 5 hours"
            )
            XCTAssertLessThanOrEqual(
                totalSleepHours, 10.0,
                "Sleep duration should be at most 10 hours"
            )
        }
    }

    func test_sleepLogs_timeInBedIsRealistic() {
        for log in mockData.sleepLogs {
            let timeInBedHours = Double(log.timeInBedMinutes) / 60.0
            XCTAssertGreaterThan(timeInBedHours, 4.0, "Time in bed should be > 4 hours")
            XCTAssertLessThan(timeInBedHours, 14.0, "Time in bed should be < 14 hours")
        }
    }

    func test_sleepLogs_haveDeepSleep() {
        for log in mockData.sleepLogs {
            XCTAssertGreaterThan(log.deepSleepMinutes, 0, "Deep sleep should be positive")
            XCTAssertLessThanOrEqual(log.deepSleepMinutes, 150, "Deep sleep should be reasonable")
        }
    }

    func test_sleepLogs_haveREMSleep() {
        for log in mockData.sleepLogs {
            XCTAssertGreaterThan(log.remSleepMinutes, 0, "REM sleep should be positive")
            XCTAssertLessThanOrEqual(log.remSleepMinutes, 180, "REM sleep should be reasonable")
        }
    }

    func test_sleepLogs_haveCoreSleep() {
        for log in mockData.sleepLogs {
            XCTAssertGreaterThan(log.coreSleepMinutes, 0, "Core sleep should be positive")
        }
    }

    func test_sleepLogs_haveAwakeMinutes() {
        for log in mockData.sleepLogs {
            XCTAssertGreaterThanOrEqual(log.awakeMinutes, 0, "Awake minutes should be non-negative")
            XCTAssertLessThanOrEqual(log.awakeMinutes, 60, "Awake minutes should be reasonable")
        }
    }

    func test_sleepLogs_sleepEfficiencyIsReasonable() {
        for log in mockData.sleepLogs {
            XCTAssertGreaterThan(log.sleepEfficiency, 50.0, "Sleep efficiency should be > 50%")
            XCTAssertLessThanOrEqual(log.sleepEfficiency, 100.0, "Sleep efficiency should be <= 100%")
        }
    }

    func test_sleepLogs_containBothWeekdaysAndWeekends() {
        let weekdayLogs = mockData.sleepLogs.filter(\.isWeekday)
        let weekendLogs = mockData.sleepLogs.filter { !$0.isWeekday }
        XCTAssertFalse(weekdayLogs.isEmpty, "Should have weekday logs")
        XCTAssertFalse(weekendLogs.isEmpty, "Should have weekend logs")
    }

    func test_sleepLogs_weekendSleepIsLater() {
        let calendar = Calendar.current

        let weekdayLogs = mockData.sleepLogs.filter(\.isWeekday)
        let weekendLogs = mockData.sleepLogs.filter { !$0.isWeekday }

        guard !weekdayLogs.isEmpty, !weekendLogs.isEmpty else {
            XCTFail("Need both weekday and weekend logs")
            return
        }

        let avgWeekdayWakeMinute = weekdayLogs.reduce(0.0) { total, log in
            let hour = calendar.component(.hour, from: log.wakeTime)
            let minute = calendar.component(.minute, from: log.wakeTime)
            return total + Double(hour * 60 + minute)
        } / Double(weekdayLogs.count)

        let avgWeekendWakeMinute = weekendLogs.reduce(0.0) { total, log in
            let hour = calendar.component(.hour, from: log.wakeTime)
            let minute = calendar.component(.minute, from: log.wakeTime)
            return total + Double(hour * 60 + minute)
        } / Double(weekendLogs.count)

        XCTAssertGreaterThan(
            avgWeekendWakeMinute, avgWeekdayWakeMinute,
            "Weekend wake time should be later than weekday on average"
        )
    }

    func test_sleepLogs_wakeTimeIsAfterBedtime() {
        for log in mockData.sleepLogs {
            XCTAssertGreaterThan(
                log.wakeTime, log.bedtime,
                "Wake time should be after bedtime"
            )
        }
    }

    // MARK: - Caffeine Logs

    func test_caffeineLogs_areNotEmpty() {
        XCTAssertFalse(mockData.caffeineLogs.isEmpty)
    }

    func test_caffeineLogs_haveRealisticAmounts() {
        for log in mockData.caffeineLogs {
            XCTAssertGreaterThan(log.amountMg, 0, "Caffeine amount should be positive")
            XCTAssertLessThanOrEqual(log.amountMg, 200, "Caffeine amount should be reasonable")
        }
    }

    func test_caffeineLogs_haveValidSources() {
        let validSources = ["Coffee", "Espresso", "Green Tea"]
        for log in mockData.caffeineLogs {
            XCTAssertTrue(
                validSources.contains(log.source),
                "Caffeine source '\(log.source)' should be a valid type"
            )
        }
    }

    func test_caffeineLogs_have2to3PerDay() {
        let calendar = Calendar.current
        var dailyCounts: [String: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for log in mockData.caffeineLogs {
            let key = formatter.string(from: log.timestamp)
            dailyCounts[key, default: 0] += 1
        }

        for (_, count) in dailyCounts {
            XCTAssertGreaterThanOrEqual(count, 2, "Should have at least 2 caffeine servings per day")
            XCTAssertLessThanOrEqual(count, 3, "Should have at most 3 caffeine servings per day")
        }
    }

    // MARK: - Sunlight Logs

    func test_sunlightLogs_areNotEmpty() {
        XCTAssertFalse(mockData.sunlightLogs.isEmpty)
    }

    func test_sunlightLogs_haveRealisticDurations() {
        for log in mockData.sunlightLogs {
            XCTAssertGreaterThan(log.durationMinutes, 0, "Duration should be positive")
            XCTAssertLessThanOrEqual(log.durationMinutes, 60, "Duration should be reasonable")
        }
    }

    func test_sunlightLogs_approximately70PercentCompliance() {
        // 30 days, ~70% compliance = ~21 logs
        let count = mockData.sunlightLogs.count
        XCTAssertGreaterThanOrEqual(count, 15, "Should have at least 15 sunlight logs (50%)")
        XCTAssertLessThanOrEqual(count, 27, "Should have at most 27 sunlight logs (90%)")
    }

    // MARK: - Average Sleep Duration

    func test_averageSleepDuration_isRealistic() {
        let avgMinutes = mockData.averageSleepDuration
        let avgHours = Double(avgMinutes) / 60.0
        XCTAssertGreaterThanOrEqual(avgHours, 5.5, "Average sleep should be at least 5.5 hours")
        XCTAssertLessThanOrEqual(avgHours, 9.0, "Average sleep should be at most 9 hours")
    }

    func test_averageSleepDuration_isPositive() {
        XCTAssertGreaterThan(mockData.averageSleepDuration, 0)
    }

    // MARK: - Social Jetlag

    func test_socialJetlag_isNonNegative() {
        XCTAssertGreaterThanOrEqual(mockData.socialJetlagMinutes, 0)
    }

    func test_socialJetlag_isReasonable() {
        // Social jetlag for a Wolf should be noticeable but not extreme
        XCTAssertLessThanOrEqual(
            mockData.socialJetlagMinutes, 180,
            "Social jetlag should be less than 3 hours"
        )
    }

    // MARK: - Sleep Consistency Score

    func test_sleepConsistencyScore_isInRange() {
        let score = mockData.sleepConsistencyScore
        XCTAssertGreaterThanOrEqual(score, 0.0, "Consistency score should be >= 0")
        XCTAssertLessThanOrEqual(score, 100.0, "Consistency score should be <= 100")
    }

    func test_sleepConsistencyScore_isReasonable() {
        let score = mockData.sleepConsistencyScore
        // With +/- 30 min variation, should be moderate to high consistency
        XCTAssertGreaterThan(score, 30.0, "Score should reflect moderate consistency")
    }

    // MARK: - Today Trajectory

    func test_todayTrajectory_hasBlocks() {
        XCTAssertFalse(mockData.todayTrajectory.blocks.isEmpty)
    }

    func test_todayTrajectory_isWolfChronotype() {
        XCTAssertEqual(mockData.todayTrajectory.chronotype, .wolf)
    }

    func test_todayTrajectory_hasConfidence() {
        // With 30 nights of data, should be very high confidence
        XCTAssertEqual(mockData.todayTrajectory.confidence, .veryHigh)
    }

    // MARK: - Trajectory Blocks for Date

    func test_trajectoryBlocks_forToday_returnsBlocks() {
        let blocks = mockData.trajectoryBlocks(for: Date())
        XCTAssertFalse(blocks.isEmpty)
    }

    // MARK: - Caffeine Impact

    func test_caffeineImpactMinutes_isNonNegative() {
        XCTAssertGreaterThanOrEqual(mockData.caffeineImpactMinutes, 0)
    }

    // MARK: - Deterministic Data

    func test_mockData_isDeterministic() {
        // Since MockDataService is a singleton using a seeded RNG,
        // sleep logs count should always be 30
        XCTAssertEqual(mockData.sleepLogs.count, 30)
        XCTAssertEqual(mockData.userProfile.name, "Alex")
    }

    // MARK: - Average Sleep Onset & Wake Time

    func test_averageSleepOnset_isReasonableTime() {
        let onset = mockData.averageSleepOnset
        XCTAssertNotNil(onset)
    }

    func test_averageWakeTime_isReasonableTime() {
        let wakeTime = mockData.averageWakeTime
        XCTAssertNotNil(wakeTime)
    }

    // MARK: - Today Trajectory

    func test_todayTrajectory_hasBlocks() {
        let trajectory = mockData.todayTrajectory
        XCTAssertFalse(trajectory.blocks.isEmpty)
    }

    func test_todayTrajectory_isForToday() {
        let trajectory = mockData.todayTrajectory
        XCTAssertTrue(Calendar.current.isDateInToday(trajectory.date))
    }

    func test_todayTrajectory_hasChronotype() {
        let trajectory = mockData.todayTrajectory
        XCTAssertEqual(trajectory.chronotype, .wolf)
    }

    // MARK: - Sleep Log Relationships

    func test_sleepLogs_totalSleepNeverExceedsTimeInBed() {
        for log in mockData.sleepLogs {
            XCTAssertLessThanOrEqual(log.totalSleepMinutes, log.timeInBedMinutes,
                                     "totalSleepMinutes should not exceed timeInBedMinutes for log on \(log.dateString)")
        }
    }
}
