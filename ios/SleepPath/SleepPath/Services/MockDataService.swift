import Foundation

// MARK: - Mock Data Service

/// Provides realistic mock data for the SleepPath prototype.
///
/// Generates 30 days of sleep data, caffeine logs, and sunlight logs for a
/// Wolf chronotype user named Alex. All data is deterministically generated
/// from a seeded random source so it remains consistent across app launches.
@Observable
final class MockDataService {

    /// Shared singleton instance.
    static let shared = MockDataService()

    private let calendar = Calendar.current
    private let trajectoryService = TrajectoryService()

    /// Seeded random number generator for deterministic mock data.
    private var rng: SeededRandomNumberGenerator

    // Cached data generated on init.
    private(set) var generatedSleepLogs: [SleepLog] = []
    private(set) var generatedCaffeineLogs: [CaffeineLog] = []
    private(set) var generatedSunlightLogs: [SunlightLog] = []

    private init() {
        self.rng = SeededRandomNumberGenerator(seed: 42)
        generateAllData()
    }

    // MARK: - Public Properties

    /// The mock user profile: a Wolf chronotype named Alex.
    var userProfile: UserProfile {
        UserProfile(
            name: "Alex",
            chronotype: .wolf,
            chronotypeSource: "quiz",
            chronotypeConfidence: 0.85,
            goal: .focus,
            ageRange: .twentySix_35,
            isNightShift: false,
            caffeineSensitivity: .normal,
            healthKitConnected: true,
            notificationsEnabled: true,
            scienceMode: false,
            isProSubscriber: true,
            createdAt: calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        )
    }

    /// Thirty days of realistic sleep data for a Wolf chronotype.
    var sleepLogs: [SleepLog] {
        generatedSleepLogs
    }

    /// Today's trajectory based on mock data.
    var todayTrajectory: DailyTrajectory {
        let today = Date()
        let wake = todayWakeTime(for: today)
        let sleep = todaySleepTime(for: today)

        let blocks = trajectoryService.generateTrajectory(
            chronotype: .wolf,
            wakeTime: wake,
            sleepTime: sleep,
            dataNightsCount: generatedSleepLogs.count
        )

        return DailyTrajectory(
            date: today,
            chronotype: .wolf,
            wakeTime: wake,
            sleepTime: sleep,
            blocks: blocks,
            confidence: trajectoryService.confidenceLevel(dataNightsCount: generatedSleepLogs.count)
        )
    }

    /// Caffeine logs with varied daily patterns.
    var caffeineLogs: [CaffeineLog] {
        generatedCaffeineLogs
    }

    /// Sunlight exposure logs with roughly 70% compliance.
    var sunlightLogs: [SunlightLog] {
        generatedSunlightLogs
    }

    // MARK: - Trajectory Blocks

    /// Generates trajectory blocks for a specific date using the mock user's data.
    func trajectoryBlocks(for date: Date) -> [TrajectoryBlock] {
        trajectoryService.generateTrajectory(
            chronotype: .wolf,
            wakeTime: todayWakeTime(for: date),
            sleepTime: todaySleepTime(for: date),
            dataNightsCount: generatedSleepLogs.count
        )
    }

    // MARK: - Computed Insights

    /// Average sleep duration across all logged nights, in minutes.
    var averageSleepDuration: Int {
        guard !generatedSleepLogs.isEmpty else { return 0 }
        let total = generatedSleepLogs.reduce(0) { $0 + $1.totalSleepMinutes }
        return total / generatedSleepLogs.count
    }

    /// Average sleep onset time (bedtime) across all logged nights.
    var averageSleepOnset: Date {
        guard !generatedSleepLogs.isEmpty else { return Date() }
        let avgMinutesSinceMidnight = generatedSleepLogs.reduce(0.0) { total, log in
            total + minutesSinceMidnight(for: log.bedtime)
        } / Double(generatedSleepLogs.count)
        return dateFromMinutesSinceMidnight(avgMinutesSinceMidnight)
    }

    /// Average wake time across all logged nights.
    var averageWakeTime: Date {
        guard !generatedSleepLogs.isEmpty else { return Date() }
        let avgMinutes = generatedSleepLogs.reduce(0.0) { total, log in
            total + minutesSinceMidnight(for: log.wakeTime)
        } / Double(generatedSleepLogs.count)
        return dateFromMinutesSinceMidnight(avgMinutes)
    }

    /// Sleep consistency score from 0 to 100.
    var sleepConsistencyScore: Double {
        guard generatedSleepLogs.count >= 2 else { return 50.0 }

        let bedtimeMinutes = generatedSleepLogs.map { minutesSinceMidnight(for: $0.bedtime) }
        let wakeMinutes = generatedSleepLogs.map { minutesSinceMidnight(for: $0.wakeTime) }

        let bedtimeStdDev = standardDeviation(bedtimeMinutes)
        let wakeStdDev = standardDeviation(wakeMinutes)

        let avgStdDev = (bedtimeStdDev + wakeStdDev) / 2.0
        let score = max(0, min(100, 100 - (avgStdDev / 90.0 * 100)))
        return score
    }

    /// Social jetlag in minutes: difference between weekday and weekend sleep midpoints.
    var socialJetlagMinutes: Int {
        let weekdayLogs = generatedSleepLogs.filter { $0.isWeekday }
        let weekendLogs = generatedSleepLogs.filter { !$0.isWeekday }

        guard !weekdayLogs.isEmpty, !weekendLogs.isEmpty else { return 0 }

        let weekdayMidpoint = weekdayLogs.reduce(0.0) { $0 + sleepMidpoint($1) }
            / Double(weekdayLogs.count)
        let weekendMidpoint = weekendLogs.reduce(0.0) { $0 + sleepMidpoint($1) }
            / Double(weekendLogs.count)

        return Int(abs(weekendMidpoint - weekdayMidpoint))
    }

    /// Average sleep onset delay on high-caffeine days vs. normal days, in minutes.
    var caffeinImpactMinutes: Int {
        var caffeineByDay: [String: Int] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for log in generatedCaffeineLogs {
            let key = dateFormatter.string(from: log.timestamp)
            caffeineByDay[key, default: 0] += 1
        }

        var highCaffeineBedtimes: [Double] = []
        var normalBedtimes: [Double] = []

        for sleepLog in generatedSleepLogs {
            let key = dateFormatter.string(from: sleepLog.bedtime)
            let count = caffeineByDay[key] ?? 0
            let bedtimeMinutes = minutesSinceMidnight(for: sleepLog.bedtime)

            if count >= 3 {
                highCaffeineBedtimes.append(bedtimeMinutes)
            } else {
                normalBedtimes.append(bedtimeMinutes)
            }
        }

        guard !highCaffeineBedtimes.isEmpty, !normalBedtimes.isEmpty else { return 15 }

        let highAvg = highCaffeineBedtimes.reduce(0, +) / Double(highCaffeineBedtimes.count)
        let normalAvg = normalBedtimes.reduce(0, +) / Double(normalBedtimes.count)

        return max(0, Int(highAvg - normalAvg))
    }

    // MARK: - Data Generation

    private mutating func generateAllData() {
        generatedSleepLogs = generateSleepLogs()
        generatedCaffeineLogs = generateCaffeineLogs()
        generatedSunlightLogs = generateSunlightLogs()
    }

    private mutating func generateSleepLogs() -> [SleepLog] {
        var logs: [SleepLog] = []
        let today = Date()

        for dayOffset in (1...30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            let weekday = calendar.component(.weekday, from: date)
            let isWeekday = (2...6).contains(weekday)

            // Wolf: sleep around 12:30 AM, wake around 8:00 AM.
            // Weekdays slightly earlier due to alarm, weekends drift later.
            let baseBedtimeMinutes: Double = isWeekday ? 750 : 780
            let baseWakeMinutes: Double = isWeekday ? 450 : 510

            let bedtimeVariation = Double(Int.random(in: -30...30, using: &rng))
            let wakeVariation = Double(Int.random(in: -30...30, using: &rng))

            let bedtimeMinutes = baseBedtimeMinutes + bedtimeVariation
            let wakeMinutes = baseWakeMinutes + wakeVariation

            let bedtime = setTime(minutesSinceMidnight: bedtimeMinutes, on: date, isPastMidnight: true)
            let wakeTime = setTime(minutesSinceMidnight: wakeMinutes, on: date, isPastMidnight: false)

            let deep = Int.random(in: 60...90, using: &rng)
            let rem = Int.random(in: 90...120, using: &rng)
            let core = Int.random(in: 180...240, using: &rng)
            let awake = Int.random(in: 15...30, using: &rng)

            logs.append(SleepLog(
                date: date,
                bedtime: bedtime,
                wakeTime: wakeTime,
                deepSleepMinutes: deep,
                remSleepMinutes: rem,
                coreSleepMinutes: core,
                awakeMinutes: awake,
                isWeekday: isWeekday
            ))
        }

        return logs
    }

    private mutating func generateCaffeineLogs() -> [CaffeineLog] {
        var logs: [CaffeineLog] = []
        let today = Date()

        for dayOffset in (1...30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            let servings = Int.random(in: 2...3, using: &rng)

            // First coffee: around 9:00-9:30 AM
            let firstMinute = Int.random(in: 540...570, using: &rng)
            let firstCoffee = setTime(minutesSinceMidnight: Double(firstMinute), on: date, isPastMidnight: false)
            logs.append(CaffeineLog(
                timestamp: firstCoffee,
                amountMg: Int.random(in: 80...120, using: &rng),
                source: Bool.random(using: &rng) ? "Coffee" : "Espresso"
            ))

            // Second coffee: around 11:30 AM-12:30 PM
            let secondMinute = Int.random(in: 690...750, using: &rng)
            let secondCoffee = setTime(minutesSinceMidnight: Double(secondMinute), on: date, isPastMidnight: false)
            logs.append(CaffeineLog(
                timestamp: secondCoffee,
                amountMg: Int.random(in: 80...120, using: &rng),
                source: "Coffee"
            ))

            // Third coffee some days: around 2:00-3:30 PM
            if servings >= 3 {
                let thirdMinute = Int.random(in: 840...930, using: &rng)
                let thirdCoffee = setTime(minutesSinceMidnight: Double(thirdMinute), on: date, isPastMidnight: false)
                logs.append(CaffeineLog(
                    timestamp: thirdCoffee,
                    amountMg: Int.random(in: 40...100, using: &rng),
                    source: Bool.random(using: &rng) ? "Green Tea" : "Coffee"
                ))
            }
        }

        return logs
    }

    private mutating func generateSunlightLogs() -> [SunlightLog] {
        var logs: [SunlightLog] = []
        let today = Date()

        for dayOffset in (1...30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            // ~70% compliance
            let didGetSunlight = Int.random(in: 1...10, using: &rng) <= 7
            guard didGetSunlight else { continue }

            let withinWindow = Int.random(in: 1...10, using: &rng) <= 6
            let duration = withinWindow
                ? Int.random(in: 10...30, using: &rng)
                : Int.random(in: 5...20, using: &rng)

            logs.append(SunlightLog(
                date: date,
                durationMinutes: duration,
                withinRecommendedWindow: withinWindow
            ))
        }

        return logs
    }

    // MARK: - Date Helpers

    private func todayWakeTime(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let isWeekday = (2...6).contains(weekday)
        let wakeMinutes: Double = isWeekday ? 450 : 510
        return setTime(minutesSinceMidnight: wakeMinutes, on: date, isPastMidnight: false)
    }

    private func todaySleepTime(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let isWeekday = (2...6).contains(weekday)
        let sleepMinutes: Double = isWeekday ? 750 : 780
        return setTime(minutesSinceMidnight: sleepMinutes, on: date, isPastMidnight: true)
    }

    private func setTime(minutesSinceMidnight: Double, on date: Date, isPastMidnight: Bool) -> Date {
        let totalMinutes = Int(minutesSinceMidnight)
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60

        if isPastMidnight && hour >= 24 {
            let adjustedHour = hour - 24
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = adjustedHour
            components.minute = minute
            let result = calendar.date(from: components) ?? date
            return calendar.date(byAdding: .day, value: 1, to: result) ?? result
        } else {
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = hour
            components.minute = minute
            return calendar.date(from: components) ?? date
        }
    }

    private func minutesSinceMidnight(for date: Date) -> Double {
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let totalMinutes = Double(hour * 60 + minute)
        // Times between midnight and 6 AM are "late night"
        if hour < 6 {
            return totalMinutes + 1440
        }
        return totalMinutes
    }

    private func dateFromMinutesSinceMidnight(_ minutes: Double) -> Date {
        var adjustedMinutes = minutes
        if adjustedMinutes >= 1440 {
            adjustedMinutes -= 1440
        }
        let hour = Int(adjustedMinutes) / 60
        let minute = Int(adjustedMinutes) % 60

        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }

    private func sleepMidpoint(_ log: SleepLog) -> Double {
        let bedtime = minutesSinceMidnight(for: log.bedtime)
        let wakeTime = minutesSinceMidnight(for: log.wakeTime)
        let adjustedWake = wakeTime < bedtime ? wakeTime + 1440 : wakeTime
        return (bedtime + adjustedWake) / 2.0
    }

    private func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let sumOfSquares = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) }
        return (sumOfSquares / Double(values.count)).squareRoot()
    }
}

// MARK: - Seeded Random Number Generator

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
