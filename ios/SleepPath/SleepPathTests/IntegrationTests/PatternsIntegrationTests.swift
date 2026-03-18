import XCTest
@testable import SleepPath

/// Integration tests verifying that PatternsViewModel correctly aggregates
/// and derives insights from the underlying mock data.
final class PatternsIntegrationTests: XCTestCase {

    // MARK: - Time Range Filtering

    func test_weekRange_hasFewerLogsThanMonth() {
        let vm = PatternsViewModel()

        vm.updateTimeRange(.week)
        let weekCount = vm.sleepLogs.count

        vm.updateTimeRange(.month)
        let monthCount = vm.sleepLogs.count

        XCTAssertLessThanOrEqual(weekCount, monthCount,
                                 "Week should have <= logs compared to month")
    }

    func test_twoWeeksRange_isBetweenWeekAndMonth() {
        let vm = PatternsViewModel()

        vm.updateTimeRange(.week)
        let weekCount = vm.sleepLogs.count

        vm.updateTimeRange(.twoWeeks)
        let twoWeekCount = vm.sleepLogs.count

        vm.updateTimeRange(.month)
        let monthCount = vm.sleepLogs.count

        XCTAssertLessThanOrEqual(weekCount, twoWeekCount)
        XCTAssertLessThanOrEqual(twoWeekCount, monthCount)
    }

    // MARK: - Insights Derived from Data

    func test_loadData_averageSleepDuration_derivedFromSleepLogs() {
        let vm = PatternsViewModel()
        vm.loadData()

        guard !vm.sleepLogs.isEmpty else {
            XCTFail("Should have sleep logs after loading")
            return
        }

        let manualAvg = vm.sleepLogs.reduce(0) { $0 + $1.totalSleepMinutes } / vm.sleepLogs.count
        XCTAssertEqual(vm.averageSleepDuration, manualAvg)
    }

    func test_loadData_chartData_matchesSleepLogCount() {
        let vm = PatternsViewModel()
        vm.loadData()

        // Chart data should have same count as sleep logs (or close, since it's the same filtered set)
        XCTAssertEqual(vm.sleepChartData.count, vm.sleepLogs.count)
    }

    func test_loadData_chartData_isSortedByDate() {
        let vm = PatternsViewModel()
        vm.loadData()

        for i in 1..<vm.sleepChartData.count {
            XCTAssertLessThanOrEqual(vm.sleepChartData[i - 1].date, vm.sleepChartData[i].date)
        }
    }

    // MARK: - Chronotype Confidence from Data Volume

    func test_monthOfData_givesHighChronotypeConfidence() {
        let vm = PatternsViewModel()
        vm.updateTimeRange(.month)

        // 30 days of data should give high confidence
        XCTAssertGreaterThanOrEqual(vm.chronotypeConfidence, 0.85)
    }

    func test_weekOfData_givesLowerChronotypeConfidence() {
        let vm = PatternsViewModel()
        vm.updateTimeRange(.week)

        XCTAssertLessThan(vm.chronotypeConfidence, 0.85)
    }

    // MARK: - Weekly Summary Text Contains All Insights

    func test_weeklySummary_containsAverageDuration() {
        let vm = PatternsViewModel()
        vm.loadData()

        let summary = vm.weeklySummaryText
        let hours = vm.averageSleepDuration / 60
        XCTAssertTrue(summary.contains("\(hours)h"))
    }

    func test_weeklySummary_containsConsistencyScore() {
        let vm = PatternsViewModel()
        vm.loadData()

        let summary = vm.weeklySummaryText
        let scoreInt = Int(vm.sleepConsistencyScore)
        XCTAssertTrue(summary.contains("\(scoreInt)%"))
    }

    // MARK: - Social Jetlag Reflects Weekday/Weekend Difference

    func test_socialJetlag_isReasonableForMockData() {
        let vm = PatternsViewModel()
        vm.updateTimeRange(.month)

        // Wolf chronotype with weekday/weekend variation should have measurable jetlag
        XCTAssertGreaterThanOrEqual(vm.socialJetlagMinutes, 0)
        XCTAssertLessThanOrEqual(vm.socialJetlagMinutes, 180)
    }

    // MARK: - Formatted Output Consistency

    func test_formattedAvgDuration_matchesRawValue() {
        let vm = PatternsViewModel()
        vm.loadData()

        let hours = vm.averageSleepDuration / 60
        let mins = vm.averageSleepDuration % 60
        let expected = mins == 0 ? "\(hours)h" : "\(hours)h \(mins)m"
        XCTAssertEqual(vm.formattedAvgDuration, expected)
    }

    // MARK: - Consistency Description Matches Score Range

    func test_consistencyDescription_matchesScoreBracket() {
        let vm = PatternsViewModel()
        vm.loadData()

        let score = vm.sleepConsistencyScore
        let desc = vm.consistencyDescription

        switch score {
        case 90...100: XCTAssertEqual(desc, "Excellent")
        case 75..<90: XCTAssertEqual(desc, "Good")
        case 60..<75: XCTAssertEqual(desc, "Fair")
        case 40..<60: XCTAssertEqual(desc, "Inconsistent")
        default: XCTAssertEqual(desc, "Needs work")
        }
    }
}
