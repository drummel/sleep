import Foundation

/// Manages the Patterns/Insights tab — sleep consistency charts, chronotype confidence, and weekly summaries.
///
/// Aggregates sleep, caffeine, and sunlight log data from ``MockDataService``
/// and computes derived insights including average sleep duration, consistency
/// score, social jetlag, and caffeine impact on sleep onset. Supports
/// configurable time-range filtering and provides chart-ready data points.
@Observable
final class PatternsViewModel {

    // MARK: - Data

    /// Sleep logs within the selected time range.
    var sleepLogs: [SleepLog] = []

    /// Caffeine logs within the selected time range.
    var caffeineLogs: [CaffeineLog] = []

    /// Sunlight logs within the selected time range.
    var sunlightLogs: [SunlightLog] = []

    // MARK: - Insights

    /// Average nightly sleep duration in minutes.
    var averageSleepDuration: Int = 0

    /// Sleep consistency score from 0.0 to 100.0.
    var sleepConsistencyScore: Double = 0

    /// Social jetlag in minutes (weekday vs. weekend sleep midpoint difference).
    var socialJetlagMinutes: Int = 0

    /// Estimated minutes of delayed sleep onset attributable to high caffeine days.
    var caffeineImpactMinutes: Int = 0

    /// Confidence in the current chronotype classification (0.0 to 1.0).
    var chronotypeConfidence: Double = 0

    /// The user's current chronotype.
    var currentChronotype: Chronotype = .wolf

    /// A chronotype suggested by recent data if it differs from the current one.
    /// `nil` when data and quiz agree.
    var suggestedChronotype: Chronotype? = nil

    // MARK: - Chart Data

    /// A single data point for the sleep chart.
    struct SleepDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let sleepOnset: Date
        let wakeTime: Date
        let duration: Int // minutes
    }

    /// Sleep data points formatted for chart rendering.
    var sleepChartData: [SleepDataPoint] = []

    // MARK: - Time Range

    /// Selectable time ranges for filtering data.
    enum TimeRange: String, CaseIterable {
        case week = "7D"
        case twoWeeks = "14D"
        case month = "30D"

        /// The number of days this range covers.
        var days: Int {
            switch self {
            case .week: return 7
            case .twoWeeks: return 14
            case .month: return 30
            }
        }
    }

    /// The currently selected time range for data display.
    var selectedTimeRange: TimeRange = .twoWeeks

    // MARK: - Services

    private let mockData = MockDataService.shared

    // MARK: - Computed Properties

    /// Formatted average sleep duration (e.g., "7h 32m").
    var formattedAvgDuration: String {
        let hours = averageSleepDuration / 60
        let minutes = averageSleepDuration % 60
        if minutes == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(minutes)m"
    }

    /// A qualitative label for the sleep consistency score.
    var consistencyDescription: String {
        switch sleepConsistencyScore {
        case 90...100: return "Excellent"
        case 75..<90: return "Good"
        case 60..<75: return "Fair"
        case 40..<60: return "Inconsistent"
        default: return "Needs work"
        }
    }

    /// A qualitative description of social jetlag severity.
    var socialJetlagDescription: String {
        if socialJetlagMinutes < 30 {
            return "Minimal \u{2014} your weekday and weekend sleep are well aligned."
        } else if socialJetlagMinutes < 60 {
            return "Moderate \u{2014} about \(socialJetlagMinutes) minutes shift between weekdays and weekends."
        } else {
            return "Significant \u{2014} \(socialJetlagMinutes) minute gap. Your body is adjusting to two different schedules."
        }
    }

    /// A qualitative description of caffeine's impact on sleep.
    var caffeineImpactDescription: String {
        if caffeineImpactMinutes <= 0 {
            return "No measurable caffeine impact on your sleep onset."
        } else if caffeineImpactMinutes < 15 {
            return "Minimal impact \u{2014} you fell asleep about \(caffeineImpactMinutes) minutes later on high-caffeine days."
        } else {
            return "Notable \u{2014} you fell asleep \(caffeineImpactMinutes) minutes later on days with afternoon caffeine."
        }
    }

    /// Whether the UI should prompt the user to consider recalibrating their chronotype.
    var showChronotypeRecalibration: Bool {
        suggestedChronotype != nil && suggestedChronotype != currentChronotype
    }

    /// A brief natural-language summary of the selected period's patterns.
    var weeklySummaryText: String {
        let avgHours = averageSleepDuration / 60
        let avgMins = averageSleepDuration % 60
        return "This period you averaged \(avgHours)h \(avgMins)m of sleep with a consistency score of \(Int(sleepConsistencyScore))%. Your chronotype confidence is at \(Int(chronotypeConfidence * 100))%."
    }

    // MARK: - Actions

    /// Loads all data from the mock service and computes derived insights.
    func loadData() {
        let calendar = Calendar.current
        let now = Date()
        let cutoff = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: now) ?? now

        // Load and filter data to the selected time range.
        sleepLogs = mockData.sleepLogs.filter { $0.bedtime >= cutoff }
        caffeineLogs = mockData.caffeineLogs.filter { $0.timestamp >= cutoff }
        sunlightLogs = mockData.sunlightLogs.filter { $0.date >= cutoff }

        // Profile info.
        currentChronotype = mockData.userProfile.chronotype

        // Compute insights from the full dataset (via MockDataService).
        averageSleepDuration = mockData.averageSleepDuration
        sleepConsistencyScore = mockData.sleepConsistencyScore
        socialJetlagMinutes = mockData.socialJetlagMinutes
        caffeineImpactMinutes = mockData.caffeinImpactMinutes

        // Confidence based on data volume.
        computeChronotypeConfidence()

        // Build chart data.
        updateChartData()
    }

    /// Updates the selected time range and reloads data.
    /// - Parameter range: The new time range to apply.
    func updateTimeRange(_ range: TimeRange) {
        selectedTimeRange = range
        loadData()
    }

    // MARK: - Private

    private func computeChronotypeConfidence() {
        let nightCount = sleepLogs.count
        let baseConfidence: Double
        switch nightCount {
        case 0..<3: baseConfidence = 0.40
        case 3..<7: baseConfidence = 0.55
        case 7..<14: baseConfidence = 0.70
        case 14..<21: baseConfidence = 0.85
        default: baseConfidence = 0.92
        }
        chronotypeConfidence = baseConfidence

        evaluateSuggestedChronotype()
    }

    /// Checks whether the user's actual sleep pattern suggests a different chronotype
    /// than the one assigned by the quiz.
    private func evaluateSuggestedChronotype() {
        guard sleepLogs.count >= 7 else {
            suggestedChronotype = nil
            return
        }

        let calendar = Calendar.current
        let avgBedtimeHour = sleepLogs.reduce(0.0) { total, log in
            var hour = Double(calendar.component(.hour, from: log.bedtime))
            // Normalize past-midnight hours so 1 AM = 25.
            if hour < 6 { hour += 24 }
            return total + hour
        } / Double(sleepLogs.count)

        let suggested: Chronotype
        switch avgBedtimeHour {
        case ..<22: suggested = .lion
        case 22..<23.5: suggested = .bear
        default: suggested = .wolf
        }

        suggestedChronotype = (suggested != currentChronotype) ? suggested : nil
    }

    private func updateChartData() {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: Date()) ?? Date()

        let filteredLogs = sleepLogs.filter { $0.bedtime >= cutoff }

        sleepChartData = filteredLogs.map { log in
            SleepDataPoint(
                date: log.bedtime,
                sleepOnset: log.bedtime,
                wakeTime: log.wakeTime,
                duration: log.totalSleepMinutes
            )
        }
        .sorted { $0.date < $1.date }
    }
}
