import Foundation

/// Manages the state and actions for the Today (Home) tab.
///
/// Displays the user's daily energy trajectory, current energy state,
/// caffeine and sunlight tracking, and contextual suggestions. All data
/// is sourced from `MockDataService` and `TrajectoryService` during the
/// prototype phase.
@Observable
final class TodayViewModel {

    // MARK: - State

    /// The ordered list of trajectory blocks for today.
    var trajectoryBlocks: [TrajectoryBlock] = []

    /// The user's current energy state based on the time of day.
    var currentEnergyState: EnergyState = .rising

    /// Seconds until the next energy state transition.
    var timeUntilNextChange: TimeInterval = 0

    /// Seconds until the caffeine cutoff time, or zero if past cutoff.
    var caffeineCutoffCountdown: TimeInterval = 0

    /// Number of caffeine servings logged today.
    var todayCaffeineCount: Int = 0

    /// Whether sunlight has been logged today.
    var hasSunlightToday: Bool = false

    /// Confidence level of the trajectory based on available data.
    var confidenceLevel: ConfidenceLevel = .high

    /// The user's chronotype.
    var chronotype: Chronotype = .wolf

    // MARK: - Services

    private let trajectoryService = TrajectoryService()
    private let mockData = MockDataService.shared

    // MARK: - Computed Properties

    /// A contextual suggestion based on the current energy state.
    var energySuggestion: String {
        currentEnergyState.suggestion
    }

    private static let blockTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    /// A short description of the next upcoming trajectory block.
    var nextBlockDescription: String {
        let now = Date()
        guard let nextBlock = trajectoryBlocks.first(where: { $0.startTime > now }) else {
            return "No more blocks today"
        }

        let timeString = Self.blockTimeFormatter.string(from: nextBlock.startTime)
        return "\(nextBlock.title) at \(timeString)"
    }

    /// Human-readable text for the caffeine cutoff countdown.
    var caffeineCutoffText: String {
        if caffeineCutoffCountdown <= 0 {
            return "Past cutoff"
        }
        let hours = Int(caffeineCutoffCountdown) / 3600
        let minutes = (Int(caffeineCutoffCountdown) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m until cutoff"
        }
        return "\(minutes)m until cutoff"
    }

    /// Human-readable text for the confidence level.
    var confidenceText: String {
        confidenceLevel.detailText
    }

    /// Formatted string for time until the next energy state change.
    var formattedTimeUntilChange: String {
        if timeUntilNextChange <= 0 {
            return "Now"
        }
        let hours = Int(timeUntilNextChange) / 3600
        let minutes = (Int(timeUntilNextChange) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    // MARK: - Actions

    /// Loads today's trajectory and refreshes all derived state.
    func loadToday() {
        chronotype = mockData.userProfile.chronotype

        let trajectory = mockData.todayTrajectory
        trajectoryBlocks = trajectory.blocks
        confidenceLevel = trajectory.confidence

        refreshEnergyState()

        // Caffeine countdown: find the caffeine cutoff block.
        let now = Date()
        if let cutoffBlock = trajectoryBlocks.first(where: { $0.type == .caffeineCutoff }) {
            let remaining = cutoffBlock.startTime.timeIntervalSince(now)
            caffeineCutoffCountdown = max(0, remaining)
        } else {
            caffeineCutoffCountdown = 0
        }

        // Today's caffeine count from mock data.
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)
        todayCaffeineCount = mockData.caffeineLogs.filter {
            calendar.isDate($0.timestamp, inSameDayAs: todayStart)
        }.count

        // Today's sunlight from mock data.
        hasSunlightToday = mockData.sunlightLogs.contains {
            calendar.isDate($0.date, inSameDayAs: todayStart)
        }
    }

    /// Logs a caffeine intake for the current time.
    func logCaffeine() {
        todayCaffeineCount += 1

        // Re-evaluate the cutoff warning.
        let now = Date()
        if let cutoffBlock = trajectoryBlocks.first(where: { $0.type == .caffeineCutoff }) {
            let remaining = cutoffBlock.startTime.timeIntervalSince(now)
            caffeineCutoffCountdown = max(0, remaining)
        }
    }

    /// Logs sunlight exposure for the current time.
    func logSunlight() {
        hasSunlightToday = true
    }

    /// Refreshes the current energy state and time-until-next-change
    /// based on the current time and loaded trajectory.
    func refreshEnergyState() {
        let now = Date()
        currentEnergyState = trajectoryService.currentEnergyState(
            trajectory: trajectoryBlocks,
            at: now
        )
        timeUntilNextChange = trajectoryService.timeUntilNextStateChange(
            trajectory: trajectoryBlocks,
            at: now
        ) ?? 0
    }
}
