import Foundation

struct SunlightLog: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let durationMinutes: Int
    let withinRecommendedWindow: Bool

    init(date: Date, durationMinutes: Int, withinRecommendedWindow: Bool = false) {
        self.date = date
        self.durationMinutes = durationMinutes
        self.withinRecommendedWindow = withinRecommendedWindow
    }

    /// Whether the sunlight exposure was within the ideal 30-minute post-wake window.
    var isWithinIdealWindow: Bool {
        withinRecommendedWindow
    }
}
