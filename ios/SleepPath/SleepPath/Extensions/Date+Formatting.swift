import Foundation

extension Date {
    // MARK: - Cached Formatters

    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private static let time24Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    private static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    // MARK: - Time Formatting

    /// Format as "7:30 AM"
    var shortTimeString: String {
        Date.shortTimeFormatter.string(from: self)
    }

    /// Format as "07:30"
    var time24String: String {
        Date.time24Formatter.string(from: self)
    }

    /// Format as "Mar 17"
    var shortDateString: String {
        Date.shortDateFormatter.string(from: self)
    }

    /// Format as "2026-03-17"
    var isoDateString: String {
        Date.isoDateFormatter.string(from: self)
    }

    /// Format as "Monday, March 17"
    var fullDateString: String {
        Date.fullDateFormatter.string(from: self)
    }

    // MARK: - Date Construction

    /// Create a date from today at a specific hour and minute
    static func today(hour: Int, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }

    /// Create a date relative to today by days offset
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    /// Create a date at a specific time on a day offset from today
    static func daysAgo(_ days: Int, hour: Int, minute: Int = 0) -> Date {
        let day = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components) ?? day
    }

    // MARK: - Date Arithmetic

    /// Add hours to this date
    func addingHours(_ hours: Double) -> Date {
        self.addingTimeInterval(hours * 3600)
    }

    /// Add minutes to this date
    func addingMinutes(_ minutes: Double) -> Date {
        self.addingTimeInterval(minutes * 60)
    }

    /// Subtract hours from this date
    func subtractingHours(_ hours: Double) -> Date {
        self.addingTimeInterval(-hours * 3600)
    }

    /// Minutes between this date and another
    func minutesUntil(_ other: Date) -> Int {
        Int(other.timeIntervalSince(self) / 60)
    }

    /// Hours and minutes between this date and another, formatted
    func timeUntilFormatted(_ other: Date) -> String {
        let totalMinutes = minutesUntil(other)
        if totalMinutes < 0 { return "Past" }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    // MARK: - Comparisons

    /// Whether this date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Whether this date is on a weekend
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }

    /// The hour component (0-23)
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    /// The minute component (0-59)
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
}

// MARK: - TimeInterval Formatting

extension TimeInterval {
    /// Format as "2h 15m"
    var hoursMinutesString: String {
        let totalMinutes = Int(self / 60)
        let hours = totalMinutes / 60
        let minutes = abs(totalMinutes % 60)
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    /// Format duration in minutes as "7h 32m"
    static func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        }
        return "\(mins)m"
    }
}
