import XCTest
@testable import SleepPath

/// Tests for the MockDataService acting as the sleep data layer.
///
/// Covers data generation correctness, edge cases, computed insights,
/// and data integrity constraints that a real SleepDataService must satisfy.
final class SleepDataServiceTests: XCTestCase {

    var service: MockDataService!

    override func setUp() {
        super.setUp()
        service = MockDataService.shared
    }

    // MARK: - Data Generation Integrity

    func test_sleepLogs_allHaveUniqueIds() {
        let ids = service.sleepLogs.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All sleep log IDs should be unique")
    }

    func test_caffeineLogs_allHaveUniqueIds() {
        let ids = service.caffeineLogs.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All caffeine log IDs should be unique")
    }

    func test_sunlightLogs_allHaveUniqueIds() {
        let ids = service.sunlightLogs.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "All sunlight log IDs should be unique")
    }

    func test_sleepLogs_datesSpan30Days() {
        let calendar = Calendar.current
        guard let earliest = service.sleepLogs.min(by: { $0.bedtime < $1.bedtime }),
              let latest = service.sleepLogs.max(by: { $0.bedtime < $1.bedtime }) else {
            XCTFail("Should have sleep logs")
            return
        }
        let daysBetween = calendar.dateComponents([.day], from: earliest.bedtime, to: latest.bedtime).day ?? 0
        XCTAssertGreaterThanOrEqual(daysBetween, 28, "Sleep logs should span approximately 30 days")
    }

    func test_sleepLogs_allDatesAreInPast() {
        let now = Date()
        for log in service.sleepLogs {
            XCTAssertLessThan(log.bedtime, now, "Bedtime should be in the past")
        }
    }

    func test_caffeineLogs_allTimestampsAreInPast() {
        let now = Date()
        for log in service.caffeineLogs {
            XCTAssertLessThan(log.timestamp, now, "Caffeine timestamp should be in the past")
        }
    }

    func test_sunlightLogs_allDatesAreInPast() {
        let now = Date()
        for log in service.sunlightLogs {
            XCTAssertLessThan(log.date, now, "Sunlight date should be in the past")
        }
    }

    // MARK: - Computed Insights Correctness

    func test_averageSleepDuration_matchesManualCalculation() {
        let logs = service.sleepLogs
        let expected = logs.reduce(0) { $0 + $1.totalSleepMinutes } / logs.count
        XCTAssertEqual(service.averageSleepDuration, expected)
    }

    func test_socialJetlagMinutes_isNonNegative() {
        XCTAssertGreaterThanOrEqual(service.socialJetlagMinutes, 0)
    }

    func test_caffeineImpactMinutes_isNonNegative() {
        XCTAssertGreaterThanOrEqual(service.caffeineImpactMinutes, 0)
    }

    func test_sleepConsistencyScore_isBetween0And100() {
        let score = service.sleepConsistencyScore
        XCTAssertGreaterThanOrEqual(score, 0)
        XCTAssertLessThanOrEqual(score, 100)
    }

    // MARK: - Trajectory Generation

    func test_trajectoryBlocks_forDate_generatesMultipleBlocks() {
        let blocks = service.trajectoryBlocks(for: Date())
        XCTAssertGreaterThan(blocks.count, 5, "Should generate several trajectory blocks")
    }

    func test_trajectoryBlocks_forDate_areChronologicallyOrdered() {
        let blocks = service.trajectoryBlocks(for: Date())
        for i in 1..<blocks.count {
            XCTAssertLessThanOrEqual(
                blocks[i - 1].startTime, blocks[i].startTime,
                "Block \(i - 1) should start before block \(i)"
            )
        }
    }

    func test_trajectoryBlocks_forDate_containsRequiredBlockTypes() {
        let blocks = service.trajectoryBlocks(for: Date())
        let types = Set(blocks.map(\.type))
        XCTAssertTrue(types.contains(.sleep), "Should have a sleep block")
        XCTAssertTrue(types.contains(.peakFocus), "Should have a peak focus block")
        XCTAssertTrue(types.contains(.caffeineCutoff), "Should have a caffeine cutoff block")
        XCTAssertTrue(types.contains(.windDown), "Should have a wind-down block")
    }

    func test_trajectoryBlocks_blocksDontOverlap() {
        let blocks = service.trajectoryBlocks(for: Date())
        for i in 1..<blocks.count {
            XCTAssertLessThanOrEqual(
                blocks[i - 1].endTime, blocks[i].startTime,
                "Block \(i - 1) end should not overlap block \(i) start"
            )
        }
    }

    func test_trajectoryBlocks_allBlocksHavePositiveDuration() {
        let blocks = service.trajectoryBlocks(for: Date())
        for block in blocks {
            XCTAssertGreaterThan(block.durationMinutes, 0, "Block '\(block.title)' should have positive duration")
        }
    }

    // MARK: - Today Trajectory Consistency

    func test_todayTrajectory_wakeTimeIsBeforeSleepTime() {
        let trajectory = service.todayTrajectory
        XCTAssertLessThan(trajectory.wakeTime, trajectory.sleepTime)
    }

    func test_todayTrajectory_dateIsToday() {
        XCTAssertTrue(Calendar.current.isDateInToday(service.todayTrajectory.date))
    }

    func test_todayTrajectory_confidenceReflectsDataVolume() {
        // 30 nights of data should give very high confidence
        XCTAssertEqual(service.todayTrajectory.confidence, .veryHigh)
    }

    // MARK: - Cross-Data Relationships

    func test_caffeineLogs_morningServingsBeforeNoon() {
        let calendar = Calendar.current
        let firstOfDay = Dictionary(grouping: service.caffeineLogs) {
            calendar.startOfDay(for: $0.timestamp)
        }.compactMapValues(\.first)

        for (_, log) in firstOfDay {
            let hour = calendar.component(.hour, from: log.timestamp)
            XCTAssertGreaterThanOrEqual(hour, 8, "First coffee should be after 8 AM")
            XCTAssertLessThanOrEqual(hour, 11, "First coffee should be before noon")
        }
    }

    func test_sunlightLogs_durationsWithinExpectedRange() {
        for log in service.sunlightLogs {
            XCTAssertGreaterThanOrEqual(log.durationMinutes, 5, "Sunlight should be at least 5 min")
            XCTAssertLessThanOrEqual(log.durationMinutes, 30, "Sunlight should be at most 30 min")
        }
    }

    // MARK: - Determinism

    func test_deterministicGeneration_sleepLogCountIsConsistent() {
        // Accessing shared twice should return same data
        let count1 = MockDataService.shared.sleepLogs.count
        let count2 = MockDataService.shared.sleepLogs.count
        XCTAssertEqual(count1, count2)
    }

    func test_deterministicGeneration_firstSleepLogIsConsistent() {
        let log1 = MockDataService.shared.sleepLogs.first
        let log2 = MockDataService.shared.sleepLogs.first
        XCTAssertEqual(log1?.deepSleepMinutes, log2?.deepSleepMinutes)
        XCTAssertEqual(log1?.remSleepMinutes, log2?.remSleepMinutes)
    }

    // MARK: - Sleep Efficiency Constraints

    func test_sleepLogs_totalSleepLessThanOrEqualTimeInBed() {
        for log in service.sleepLogs {
            XCTAssertLessThanOrEqual(
                log.totalSleepMinutes, log.timeInBedMinutes,
                "Total sleep (\(log.totalSleepMinutes)) should not exceed time in bed (\(log.timeInBedMinutes))"
            )
        }
    }

    func test_sleepLogs_sleepStagesArePositive() {
        for log in service.sleepLogs {
            XCTAssertGreaterThan(log.deepSleepMinutes, 0)
            XCTAssertGreaterThan(log.remSleepMinutes, 0)
            XCTAssertGreaterThan(log.coreSleepMinutes, 0)
            XCTAssertGreaterThanOrEqual(log.awakeMinutes, 0)
        }
    }
}
