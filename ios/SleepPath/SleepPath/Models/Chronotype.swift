import Foundation

enum Chronotype: String, Codable, CaseIterable {
    case lion
    case bear
    case wolf
    case dolphin

    var displayName: String {
        switch self {
        case .lion: "Lion"
        case .bear: "Bear"
        case .wolf: "Wolf"
        case .dolphin: "Dolphin"
        }
    }

    var emoji: String {
        switch self {
        case .lion: "\u{1F981}"
        case .bear: "\u{1F43B}"
        case .wolf: "\u{1F43A}"
        case .dolphin: "\u{1F42C}"
        }
    }

    var tagline: String {
        switch self {
        case .lion: "The Early Bird"
        case .bear: "The Solar Tracker"
        case .wolf: "The Night Owl"
        case .dolphin: "The Light Sleeper"
        }
    }

    var detailedDescription: String {
        switch self {
        case .lion:
            "Lions are the early risers who hit peak performance before most people finish breakfast. "
            + "You thrive in the quiet morning hours and tend to wind down naturally by evening. "
            + "Your energy curve favors front-loading your most demanding work."
        case .bear:
            "Bears follow the solar cycle, rising and sleeping with a rhythm that mirrors the sun. "
            + "You represent the most common chronotype and feel most productive during mid-morning to early afternoon. "
            + "Your energy is steady and predictable throughout the day."
        case .wolf:
            "Wolves come alive when others are winding down, with creativity and focus peaking in the late afternoon and evening. "
            + "You prefer a later wake time and often do your best thinking after dark. "
            + "Traditional 9-to-5 schedules can feel like swimming upstream."
        case .dolphin:
            "Dolphins are light sleepers with an irregular rhythm that can make consistent rest a challenge. "
            + "You tend to be highly intelligent and detail-oriented, but your alertness can spike unpredictably. "
            + "Optimizing your environment and routine is key to unlocking sustained focus."
        }
    }

    var peakHoursDescription: String {
        switch self {
        case .lion: "8 AM - 12 PM"
        case .bear: "10 AM - 2 PM"
        case .wolf: "5 PM - 9 PM"
        case .dolphin: "10 AM - 12 PM"
        }
    }

    var idealWakeTime: String {
        switch self {
        case .lion: "5:30 AM"
        case .bear: "7:00 AM"
        case .wolf: "8:30 AM"
        case .dolphin: "6:30 AM"
        }
    }

    var idealSleepTime: String {
        switch self {
        case .lion: "9:30 PM"
        case .bear: "11:00 PM"
        case .wolf: "12:00 AM"
        case .dolphin: "11:30 PM"
        }
    }

    var accentColorName: String {
        switch self {
        case .lion: "lionGold"
        case .bear: "bearGreen"
        case .wolf: "wolfIndigo"
        case .dolphin: "dolphinTeal"
        }
    }
}
