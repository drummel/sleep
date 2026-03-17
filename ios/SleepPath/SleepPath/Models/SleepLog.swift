import Foundation

struct SleepLog: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let bedtime: Date
    let wakeTime: Date
    let deepSleepMinutes: Int
    let remSleepMinutes: Int
    let coreSleepMinutes: Int
    let awakeMinutes: Int
    let isWeekday: Bool
    let source: String

    init(
        date: Date? = nil,
        bedtime: Date,
        wakeTime: Date,
        deepSleepMinutes: Int,
        remSleepMinutes: Int,
        coreSleepMinutes: Int,
        awakeMinutes: Int,
        isWeekday: Bool,
        source: String = "mock"
    ) {
        self.date = date ?? Calendar.current.startOfDay(for: wakeTime)
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.deepSleepMinutes = deepSleepMinutes
        self.remSleepMinutes = remSleepMinutes
        self.coreSleepMinutes = coreSleepMinutes
        self.awakeMinutes = awakeMinutes
        self.isWeekday = isWeekday
        self.source = source
    }

    /// Total sleep duration in minutes (excludes awake time).
    var totalSleepMinutes: Int {
        deepSleepMinutes + remSleepMinutes + coreSleepMinutes
    }

    /// Total time in bed in minutes.
    var timeInBedMinutes: Int {
        let minutes = Int(wakeTime.timeIntervalSince(bedtime) / 60)
        return max(0, minutes)
    }

    /// Sleep efficiency as a percentage (0-100).
    var sleepEfficiency: Double {
        guard timeInBedMinutes > 0 else { return 0 }
        let value = Double(totalSleepMinutes) / Double(timeInBedMinutes) * 100
        return min(max(value, 0), 100)
    }

    /// Duration in minutes including awake time.
    var durationMinutes: Int {
        totalSleepMinutes + awakeMinutes
    }

    /// Formatted sleep duration string like "7h 32m".
    var formattedDuration: String {
        TimeInterval.formatMinutes(totalSleepMinutes)
    }

    private static let dateStringFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Date string in YYYY-MM-DD format.
    var dateString: String {
        Self.dateStringFormatter.string(from: date)
    }

    /// The sleep onset date (alias for bedtime).
    var sleepOnset: Date { bedtime }
}
