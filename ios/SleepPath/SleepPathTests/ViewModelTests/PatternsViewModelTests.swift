import XCTest
@testable import SleepPath

final class PatternsViewModelTests: XCTestCase {

    var viewModel: PatternsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = PatternsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - TimeRange Enum

    func test_timeRange_allCases_hasThreeRanges() {
        XCTAssertEqual(PatternsViewModel.TimeRange.allCases.count, 3)
    }

    func test_timeRange_week_daysIs7() {
        XCTAssertEqual(PatternsViewModel.TimeRange.week.days, 7)
    }

    func test_timeRange_twoWeeks_daysIs14() {
        XCTAssertEqual(PatternsViewModel.TimeRange.twoWeeks.days, 14)
    }

    func test_timeRange_month_daysIs30() {
        XCTAssertEqual(PatternsViewModel.TimeRange.month.days, 30)
    }

    func test_timeRange_rawValues() {
        XCTAssertEqual(PatternsViewModel.TimeRange.week.rawValue, "7D")
        XCTAssertEqual(PatternsViewModel.TimeRange.twoWeeks.rawValue, "14D")
        XCTAssertEqual(PatternsViewModel.TimeRange.month.rawValue, "30D")
    }

    // MARK: - Initial State

    func test_initialState_sleepLogsEmpty() {
        XCTAssertTrue(viewModel.sleepLogs.isEmpty)
    }

    func test_initialState_caffeineLogsEmpty() {
        XCTAssertTrue(viewModel.caffeineLogs.isEmpty)
    }

    func test_initialState_sunlightLogsEmpty() {
        XCTAssertTrue(viewModel.sunlightLogs.isEmpty)
    }

    func test_initialState_averageSleepDurationIsZero() {
        XCTAssertEqual(viewModel.averageSleepDuration, 0)
    }

    func test_initialState_sleepConsistencyScoreIsZero() {
        XCTAssertEqual(viewModel.sleepConsistencyScore, 0)
    }

    func test_initialState_selectedTimeRangeIsTwoWeeks() {
        XCTAssertEqual(viewModel.selectedTimeRange, .twoWeeks)
    }

    func test_initialState_currentChronotypeIsWolf() {
        XCTAssertEqual(viewModel.currentChronotype, .wolf)
    }

    func test_initialState_suggestedChronotypeIsNil() {
        XCTAssertNil(viewModel.suggestedChronotype)
    }

    func test_initialState_sleepChartDataEmpty() {
        XCTAssertTrue(viewModel.sleepChartData.isEmpty)
    }

    // MARK: - Load Data

    func test_loadData_populatesSleepLogs() {
        viewModel.loadData()
        XCTAssertFalse(viewModel.sleepLogs.isEmpty)
    }

    func test_loadData_populatesCaffeineLogs() {
        viewModel.loadData()
        XCTAssertFalse(viewModel.caffeineLogs.isEmpty)
    }

    func test_loadData_populatesSunlightLogs() {
        viewModel.loadData()
        XCTAssertFalse(viewModel.sunlightLogs.isEmpty)
    }

    func test_loadData_setsAverageSleepDuration() {
        viewModel.loadData()
        XCTAssertGreaterThan(viewModel.averageSleepDuration, 0)
    }

    func test_loadData_averageSleepDurationIsRealistic() {
        viewModel.loadData()
        let avgHours = Double(viewModel.averageSleepDuration) / 60.0
        XCTAssertGreaterThanOrEqual(avgHours, 5.0)
        XCTAssertLessThanOrEqual(avgHours, 10.0)
    }

    func test_loadData_setsConsistencyScore() {
        viewModel.loadData()
        XCTAssertGreaterThanOrEqual(viewModel.sleepConsistencyScore, 0.0)
        XCTAssertLessThanOrEqual(viewModel.sleepConsistencyScore, 100.0)
    }

    func test_loadData_setsSocialJetlagMinutes() {
        viewModel.loadData()
        XCTAssertGreaterThanOrEqual(viewModel.socialJetlagMinutes, 0)
    }

    func test_loadData_setsCaffeineImpactMinutes() {
        viewModel.loadData()
        XCTAssertGreaterThanOrEqual(viewModel.caffeineImpactMinutes, 0)
    }

    func test_loadData_setsChronotypeConfidence() {
        viewModel.loadData()
        XCTAssertGreaterThan(viewModel.chronotypeConfidence, 0.0)
        XCTAssertLessThanOrEqual(viewModel.chronotypeConfidence, 1.0)
    }

    func test_loadData_setsCurrentChronotype() {
        viewModel.loadData()
        XCTAssertEqual(viewModel.currentChronotype, .wolf)
    }

    func test_loadData_populatesChartData() {
        viewModel.loadData()
        XCTAssertFalse(viewModel.sleepChartData.isEmpty)
    }

    func test_loadData_chartDataSortedByDate() {
        viewModel.loadData()
        let dates = viewModel.sleepChartData.map { $0.date }
        for i in 1..<dates.count {
            XCTAssertLessThanOrEqual(dates[i - 1], dates[i])
        }
    }

    // MARK: - Update Time Range

    func test_updateTimeRange_changesSelectedRange() {
        viewModel.updateTimeRange(.week)
        XCTAssertEqual(viewModel.selectedTimeRange, .week)
    }

    func test_updateTimeRange_reloadsData() {
        viewModel.updateTimeRange(.week)
        XCTAssertFalse(viewModel.sleepLogs.isEmpty)
    }

    func test_updateTimeRange_weekHasFewerLogsThanMonth() {
        viewModel.updateTimeRange(.week)
        let weekCount = viewModel.sleepLogs.count

        viewModel.updateTimeRange(.month)
        let monthCount = viewModel.sleepLogs.count

        XCTAssertLessThanOrEqual(weekCount, monthCount)
    }

    func test_updateTimeRange_allRangesLoadSuccessfully() {
        for range in PatternsViewModel.TimeRange.allCases {
            viewModel.updateTimeRange(range)
            XCTAssertFalse(viewModel.sleepLogs.isEmpty, "\(range) should have sleep logs")
        }
    }

    // MARK: - Formatted Average Duration

    func test_formattedAvgDuration_zeroReturns0h() {
        viewModel.averageSleepDuration = 0
        XCTAssertEqual(viewModel.formattedAvgDuration, "0h")
    }

    func test_formattedAvgDuration_exactHours() {
        viewModel.averageSleepDuration = 420 // 7 * 60
        XCTAssertEqual(viewModel.formattedAvgDuration, "7h")
    }

    func test_formattedAvgDuration_hoursAndMinutes() {
        viewModel.averageSleepDuration = 452 // 7h 32m
        XCTAssertEqual(viewModel.formattedAvgDuration, "7h 32m")
    }

    func test_formattedAvgDuration_afterLoad_containsHours() {
        viewModel.loadData()
        XCTAssertTrue(viewModel.formattedAvgDuration.contains("h"))
    }

    // MARK: - Consistency Description

    func test_consistencyDescription_excellent() {
        viewModel.sleepConsistencyScore = 95
        XCTAssertEqual(viewModel.consistencyDescription, "Excellent")
    }

    func test_consistencyDescription_excellentAt90() {
        viewModel.sleepConsistencyScore = 90
        XCTAssertEqual(viewModel.consistencyDescription, "Excellent")
    }

    func test_consistencyDescription_good() {
        viewModel.sleepConsistencyScore = 80
        XCTAssertEqual(viewModel.consistencyDescription, "Good")
    }

    func test_consistencyDescription_goodAt75() {
        viewModel.sleepConsistencyScore = 75
        XCTAssertEqual(viewModel.consistencyDescription, "Good")
    }

    func test_consistencyDescription_fair() {
        viewModel.sleepConsistencyScore = 65
        XCTAssertEqual(viewModel.consistencyDescription, "Fair")
    }

    func test_consistencyDescription_inconsistent() {
        viewModel.sleepConsistencyScore = 50
        XCTAssertEqual(viewModel.consistencyDescription, "Inconsistent")
    }

    func test_consistencyDescription_needsWork() {
        viewModel.sleepConsistencyScore = 30
        XCTAssertEqual(viewModel.consistencyDescription, "Needs work")
    }

    func test_consistencyDescription_at100() {
        viewModel.sleepConsistencyScore = 100
        XCTAssertEqual(viewModel.consistencyDescription, "Excellent")
    }

    func test_consistencyDescription_atZero() {
        viewModel.sleepConsistencyScore = 0
        XCTAssertEqual(viewModel.consistencyDescription, "Needs work")
    }

    // MARK: - Social Jetlag Description

    func test_socialJetlagDescription_minimal() {
        viewModel.socialJetlagMinutes = 15
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("Minimal"))
    }

    func test_socialJetlagDescription_moderate() {
        viewModel.socialJetlagMinutes = 45
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("Moderate"))
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("45"))
    }

    func test_socialJetlagDescription_significant() {
        viewModel.socialJetlagMinutes = 90
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("Significant"))
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("90"))
    }

    func test_socialJetlagDescription_atZero() {
        viewModel.socialJetlagMinutes = 0
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("Minimal"))
    }

    func test_socialJetlagDescription_boundary30() {
        viewModel.socialJetlagMinutes = 30
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("Moderate"))
    }

    func test_socialJetlagDescription_boundary60() {
        viewModel.socialJetlagMinutes = 60
        XCTAssertTrue(viewModel.socialJetlagDescription.contains("Significant"))
    }

    // MARK: - Caffeine Impact Description

    func test_caffeineImpactDescription_noImpact() {
        viewModel.caffeineImpactMinutes = 0
        XCTAssertTrue(viewModel.caffeineImpactDescription.contains("No measurable"))
    }

    func test_caffeineImpactDescription_negativeValue() {
        viewModel.caffeineImpactMinutes = -5
        XCTAssertTrue(viewModel.caffeineImpactDescription.contains("No measurable"))
    }

    func test_caffeineImpactDescription_minimal() {
        viewModel.caffeineImpactMinutes = 10
        XCTAssertTrue(viewModel.caffeineImpactDescription.contains("Minimal"))
        XCTAssertTrue(viewModel.caffeineImpactDescription.contains("10"))
    }

    func test_caffeineImpactDescription_notable() {
        viewModel.caffeineImpactMinutes = 25
        XCTAssertTrue(viewModel.caffeineImpactDescription.contains("Notable"))
        XCTAssertTrue(viewModel.caffeineImpactDescription.contains("25"))
    }

    func test_caffeineImpactDescription_boundary15() {
        viewModel.caffeineImpactMinutes = 15
        XCTAssertTrue(viewModel.caffeineImpactDescription.contains("Notable"))
    }

    // MARK: - Show Chronotype Recalibration

    func test_showChronotypeRecalibration_falseWhenNilSuggested() {
        viewModel.suggestedChronotype = nil
        XCTAssertFalse(viewModel.showChronotypeRecalibration)
    }

    func test_showChronotypeRecalibration_falseWhenSameAsCurrent() {
        viewModel.currentChronotype = .wolf
        viewModel.suggestedChronotype = .wolf
        XCTAssertFalse(viewModel.showChronotypeRecalibration)
    }

    func test_showChronotypeRecalibration_trueWhenDifferent() {
        viewModel.currentChronotype = .wolf
        viewModel.suggestedChronotype = .lion
        XCTAssertTrue(viewModel.showChronotypeRecalibration)
    }

    // MARK: - Weekly Summary Text

    func test_weeklySummaryText_containsAverageDuration() {
        viewModel.averageSleepDuration = 452
        viewModel.sleepConsistencyScore = 85
        viewModel.chronotypeConfidence = 0.70
        let text = viewModel.weeklySummaryText
        XCTAssertTrue(text.contains("7h 32m"))
    }

    func test_weeklySummaryText_containsConsistencyScore() {
        viewModel.averageSleepDuration = 420
        viewModel.sleepConsistencyScore = 85
        viewModel.chronotypeConfidence = 0.70
        let text = viewModel.weeklySummaryText
        XCTAssertTrue(text.contains("85%"))
    }

    func test_weeklySummaryText_containsConfidence() {
        viewModel.averageSleepDuration = 420
        viewModel.sleepConsistencyScore = 85
        viewModel.chronotypeConfidence = 0.70
        let text = viewModel.weeklySummaryText
        XCTAssertTrue(text.contains("70%"))
    }
}
