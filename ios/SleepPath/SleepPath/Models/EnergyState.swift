import Foundation

enum EnergyState: String, Codable, CaseIterable {
    case peak
    case rising
    case dip
    case recovery
    case windDown
    case sleeping

    var displayName: String {
        switch self {
        case .peak: "Peak"
        case .rising: "Rising"
        case .dip: "Energy Dip"
        case .recovery: "Recovery"
        case .windDown: "Wind Down"
        case .sleeping: "Sleeping"
        }
    }

    var icon: String {
        switch self {
        case .peak: "bolt.fill"
        case .rising: "sunrise.fill"
        case .dip: "cloud.sun.fill"
        case .recovery: "arrow.up.right"
        case .windDown: "moon.haze.fill"
        case .sleeping: "moon.zzz.fill"
        }
    }

    var detailedDescription: String {
        switch self {
        case .peak:
            "You're in your peak energy window. Mental clarity and focus are at their highest."
        case .rising:
            "Your energy is building toward its peak. A great time to ease into demanding tasks."
        case .dip:
            "A natural dip in alertness. This is normal and temporary — lean into lighter work or rest."
        case .recovery:
            "Your energy is rebounding after the dip. Good for creative thinking and collaboration."
        case .windDown:
            "Your body is preparing for sleep. Start reducing stimulation and bright light."
        case .sleeping:
            "Time for rest. Your body is repairing, consolidating memories, and recharging."
        }
    }

    var suggestion: String {
        switch self {
        case .peak:
            "Deep work window \u{2014} protect the next 90 minutes for your hardest task."
        case .rising:
            "Plan your priorities now so you're ready to execute at peak."
        case .dip:
            "Take a 10\u{2013}20 minute walk or do a non-sleep deep rest session."
        case .recovery:
            "Good time for brainstorming, meetings, or creative exploration."
        case .windDown:
            "Dim the lights, put screens away, and start your bedtime routine."
        case .sleeping:
            "Stay off your phone \u{2014} your next peak starts with quality rest tonight."
        }
    }
}
