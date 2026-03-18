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
}
