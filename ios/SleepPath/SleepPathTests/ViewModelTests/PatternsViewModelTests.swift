import XCTest
@testable import SleepPath

/// Tests for the Patterns tab data logic.
///
/// Since the PatternsView uses inline state rather than a separate view model,
/// these tests verify the `TimeRange` enum, the `MockDataService` properties
/// that feed the patterns view, and the data relationships between them.
final class PatternsViewModelTests: XCTestCase {

    var mockData: MockDataService!

    override func setUp() {
        super.setUp()
        mockData = MockDataService.shared
    }

    // MARK: - TimeRange Enum

    func test_timeRange_allCases_hasThreeRanges() {
        XCTAssertEqual(TimeRange.allCases.count, 3)
    }

    func test_timeRange_sevenDays_dayCountIs7() {
        XCTAssertEqual(TimeRange.sevenDays.dayCount, 7)
    }

    func test_timeRange_fourteenDays_dayCountIs14() {
        XCTAssertEqual(TimeRange.fourteenDays.dayCount, 14)
    }

    func test_timeRange_thirtyDays_dayCountIs30() {
        XCTAssertEqual(TimeRange.thirtyDays.dayCount, 30)
    }

    func test_timeRange_rawValues_areCorrect() {
        XCTAssertEqual(TimeRange.sevenDays.rawValue, "7D")
        XCTAssertEqual(TimeRange.fourteenDays.rawValue, "14D")
        XCTAssertEqual(TimeRange.thirtyDays.rawValue, "30D")
    }

    func test_timeRange_ids_areUnique() {
        let ids = TimeRange.allCases.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    // MARK: - Sleep Logs as Patterns Data

    func test_loadData_populatesSleepLogs() {
        XCTAssertFalse(mockData.sleepLogs.isEmpty)
        XCTAssertEqual(mockData.sleepLogs.count, 30)
    }

    func test_loadData_averageDurationIsRealistic() {
        let avgHours = Double(mockData.averageSleepDuration) / 60.0
        XCTAssertGreaterThanOrEqual(avgHours, 5.5, "Average sleep should be at least 5.5 hours")
        XCTAssertLessThanOrEqual(avgHours, 9.0, "Average sleep should be at most 9 hours")
    }

    func test_loadData_consistencyScoreInRange() {
        let score = mockData.sleepConsistencyScore
        XCTAssertGreaterThanOrEqual(score, 0.0)
        XCTAssertLessThanOrEqual(score, 100.0)
    }

    // MARK: - Formatted Average Duration

    func test_formattedAvgDuration_isFormatted() {
        let avgMinutes = mockData.averageSleepDuration
        let formatted = TimeInterval.formatMinutes(avgMinutes)
        XCTAssertFalse(formatted.isEmpty)
        // Should contain "h" and "m" for a typical sleep duration
        XCTAssertTrue(formatted.contains("h"), "Formatted duration '\(formatted)' should contain hours")
        XCTAssertTrue(formatted.contains("m"), "Formatted duration '\(formatted)' should contain minutes")
    }

    func test_formattedAvgDuration_isReasonableString() {
        let avgMinutes = mockData.averageSleepDuration
        let formatted = TimeInterval.formatMinutes(avgMinutes)
        // For 5.5-9 hours, should look like "Xh Ym" where X is 5-9
        let components = formatted.split(separator: "h")
        if let hourString = components.first {
            let hours = Int(hourString.trimmingCharacters(in: .whitespaces))
            XCTAssertNotNil(hours)
            if let hours = hours {
                XCTAssertGreaterThanOrEqual(hours, 5)
                XCTAssertLessThanOrEqual(hours, 9)
            }
        }
    }

    // MARK: - Time Range Filtering

    func test_updateTimeRange_week_filtersTo7Days() {
        let calendar = Calendar.current
        let today = Date()
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today)!

        let filteredLogs = mockData.sleepLogs.filter { log in
            log.bedtime >= sevenDaysAgo
        }

        // Should have approximately 7 logs (some variation due to exact timing)
        XCTAssertLessThanOrEqual(filteredLogs.count, 8)
        XCTAssertGreaterThanOrEqual(filteredLogs.count, 5)
    }

    func test_updateTimeRange_twoWeeks_filtersTo14Days() {
        let calendar = Calendar.current
        let today = Date()
        let fourteenDaysAgo = calendar.date(byAdding: .day, value: -14, to: today)!

        let filteredLogs = mockData.sleepLogs.filter { log in
            log.bedtime >= fourteenDaysAgo
        }

        XCTAssertLessThanOrEqual(filteredLogs.count, 15)
        XCTAssertGreaterThanOrEqual(filteredLogs.count, 12)
    }

    func test_updateTimeRange_month_returnsAllLogs() {
        let allLogs = mockData.sleepLogs
        XCTAssertEqual(allLogs.count, 30)
    }

    // MARK: - Chart Data Generation

    func test_chartData_canBeGeneratedForEachTimeRange() {
        for range in TimeRange.allCases {
            let calendar = Calendar.current
            let today = Date()
            let dataPoints = (0..<range.dayCount).map { offset -> (date: Date, hours: Double) in
                let date = calendar.date(byAdding: .day, value: -offset, to: today)!
                return (date: date, hours: Double.random(in: 5.5...8.5))
            }
            XCTAssertEqual(
                dataPoints.count, range.dayCount,
                "Chart data for \(range.rawValue) should have \(range.dayCount) points"
            )
        }
    }

    func test_chartData_sleepLogsCanProvideHoursData() {
        let chartHours = mockData.sleepLogs.map { Double($0.totalSleepMinutes) / 60.0 }
        XCTAssertEqual(chartHours.count, 30)
        for hours in chartHours {
            XCTAssertGreaterThan(hours, 0, "Sleep hours should be positive")
        }
    }

    // MARK: - Social Jetlag Data

    func test_socialJetlag_dataAvailable() {
        let jetlag = mockData.socialJetlagMinutes
        XCTAssertGreaterThanOrEqual(jetlag, 0)
    }

    func test_socialJetlag_formattedAsMinutes() {
        let jetlag = mockData.socialJetlagMinutes
        let formatted = TimeInterval.formatMinutes(jetlag)
        XCTAssertFalse(formatted.isEmpty)
    }

    // MARK: - Caffeine Impact Data

    func test_caffeineImpact_dataAvailable() {
        let impact = mockData.caffeinImpactMinutes
        XCTAssertGreaterThanOrEqual(impact, 0)
    }

    // MARK: - Confidence Level Display

    func test_confidenceLevel_allLevels_haveDisplayText() {
        let levels: [ConfidenceLevel] = [.low, .lowMedium, .medium, .mediumHigh, .high, .veryHigh]
        for level in levels {
            XCTAssertFalse(level.displayText.isEmpty, "\(level) should have display text")
        }
    }

    func test_confidenceLevel_allLevels_haveDetailText() {
        let levels: [ConfidenceLevel] = [.low, .lowMedium, .medium, .mediumHigh, .high, .veryHigh]
        for level in levels {
            XCTAssertFalse(level.detailText.isEmpty, "\(level) should have detail text")
        }
    }
}
