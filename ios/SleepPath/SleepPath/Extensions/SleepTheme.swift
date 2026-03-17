import SwiftUI

enum SleepTheme {
    static let background = Color.appBackground
    static let card = Color.appCard
    static let cardElevated = Color.appCardElevated
    static let accent = Color.appAccent
    static let textPrimary = Color.appText
    static let textSecondary = Color.appSecondary
    static let textTertiary = Color.appTextDimmed
    static let destructive = Color.destructive
    static let success = Color.success

    static let amberGradient = LinearGradient(
        colors: [Color.appAccent, Color(red: 0.929, green: 0.537, blue: 0.067)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let titleGradient = LinearGradient(
        colors: [
            Color(red: 255/255, green: 200/255, blue: 100/255),
            Color(red: 255/255, green: 160/255, blue: 60/255),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
