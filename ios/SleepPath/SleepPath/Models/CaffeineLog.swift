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
        Date.now.timeIntervalSince(timestamp) / 3600
    }

    /// Approximate caffeine remaining as a percentage, assuming a 5-hour half-life.
    var estimatedCaffeineRemainingPercent: Double {
        let halfLife = 5.0
        let hoursElapsed = hoursSinceIntake
        guard hoursElapsed >= 0 else { return 100 }
        return 100 * pow(0.5, hoursElapsed / halfLife)
    }
}
