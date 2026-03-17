import Foundation

// MARK: - UserProfile

struct UserProfile: Sendable {
    var name: String
    var chronotype: Chronotype
    var chronotypeSource: String
    var chronotypeConfidence: Double
    var goal: UserGoal
    var ageRange: AgeRange?
    var isNightShift: Bool
    var caffeineSensitivity: CaffeineSensitivity
    var healthKitConnected: Bool
    var notificationsEnabled: Bool
    var scienceMode: Bool
    var isProSubscriber: Bool
    var createdAt: Date

    // Convenience accessors matching the ViewModel patterns
    var chronotypeValue: Chronotype { chronotype }
    var goalValue: UserGoal { goal }
}

// MARK: - UserGoal

enum UserGoal: String, Codable, CaseIterable {
    case focus
    case sleep
    case energy
    case all

    var displayName: String {
        switch self {
        case .focus: "Improve Focus"
        case .sleep: "Better Sleep"
        case .energy: "More Energy"
        case .all: "All of the Above"
        }
    }

    var icon: String {
        switch self {
        case .focus: "scope"
        case .sleep: "moon.fill"
        case .energy: "bolt.fill"
        case .all: "star.fill"
        }
    }
}

// MARK: - CaffeineSensitivity

enum CaffeineSensitivity: String, Codable, CaseIterable {
    case low
    case normal
    case high

    var displayName: String {
        switch self {
        case .low: "Low"
        case .normal: "Normal"
        case .high: "High"
        }
    }
}

// MARK: - AgeRange

enum AgeRange: String, Codable, CaseIterable {
    case eighteen_25 = "18-25"
    case twentySix_35 = "26-35"
    case thirtySix_45 = "36-45"
    case fortySix_55 = "46-55"
    case fiftyFivePlus = "55+"

    var displayName: String { rawValue }
}
