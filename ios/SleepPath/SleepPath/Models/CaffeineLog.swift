import Foundation

struct CaffeineLog: Identifiable, Sendable {
    let id = UUID()
    let timestamp: Date
    let amountMg: Int
    let source: String

    init(timestamp: Date, amountMg: Int = 95, source: String = "Coffee") {
        self.timestamp = timestamp
        self.amountMg = amountMg
        self.source = source
    }

    /// Hours elapsed since this caffeine intake.
    var hoursSinceIntake: Double {
        hoursSinceIntake(referenceDate: .now)
    }

    /// Hours elapsed since this caffeine intake relative to a reference date.
    func hoursSinceIntake(referenceDate: Date = .now) -> Double {
        referenceDate.timeIntervalSince(timestamp) / 3600
    }

    /// Approximate caffeine remaining as a percentage, assuming a 5-hour half-life.
    var estimatedCaffeineRemainingPercent: Double {
        estimatedCaffeineRemainingPercent(referenceDate: .now)
    }

    /// Approximate caffeine remaining as a percentage relative to a reference date, assuming a 5-hour half-life.
    func estimatedCaffeineRemainingPercent(referenceDate: Date = .now) -> Double {
        let halfLife = 5.0
        let hoursElapsed = hoursSinceIntake(referenceDate: referenceDate)
        guard hoursElapsed >= 0 else { return 100 }
        return 100 * pow(0.5, hoursElapsed / halfLife)
    }
}
