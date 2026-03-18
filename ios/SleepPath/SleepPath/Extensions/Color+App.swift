import SwiftUI

extension Color {
    // MARK: - Brand Colors

    /// Deep navy background (#0f0e17)
    static let appBackground = Color(red: 0.059, green: 0.055, blue: 0.090)

    /// Card background (#232946)
    static let appCard = Color(red: 0.137, green: 0.161, blue: 0.275)

    /// Elevated card background (#2e3354)
    static let appCardElevated = Color(red: 0.180, green: 0.200, blue: 0.329)

    /// Primary accent — warm amber/gold (#f0a500)
    static let appAccent = Color(red: 0.941, green: 0.647, blue: 0.000)

    /// Secondary accent — soft lavender (#a7a9be)
    static let appSecondary = Color(red: 0.655, green: 0.663, blue: 0.745)

    /// Primary text — off-white (#fffffe)
    static let appText = Color(red: 1.0, green: 1.0, blue: 0.996)

    /// Dimmed text (#6b6b8d)
    static let appTextDimmed = Color(red: 0.420, green: 0.420, blue: 0.553)

    // MARK: - Energy State Colors

    /// Peak energy — vibrant green
    static let energyPeak = Color(red: 0.298, green: 0.851, blue: 0.392)

    /// Rising energy — soft teal
    static let energyRising = Color(red: 0.235, green: 0.745, blue: 0.725)

    /// Energy dip — muted amber
    static let energyDip = Color(red: 0.878, green: 0.655, blue: 0.243)

    /// Recovery — calm blue
    static let energyRecovery = Color(red: 0.353, green: 0.525, blue: 0.882)

    /// Wind-down — soft purple
    static let energyWindDown = Color(red: 0.588, green: 0.388, blue: 0.812)

    /// Sleeping — deep indigo
    static let energySleeping = Color(red: 0.275, green: 0.243, blue: 0.525)

    // MARK: - Chronotype Colors

    static let chronotypeLion = Color(red: 1.0, green: 0.757, blue: 0.027)
    static let chronotypeBear = Color(red: 0.710, green: 0.494, blue: 0.271)
    static let chronotypeWolf = Color(red: 0.478, green: 0.376, blue: 0.820)
    static let chronotypeDolphin = Color(red: 0.298, green: 0.686, blue: 0.820)

    // MARK: - Trajectory Block Colors

    static let blockSunlight = Color(red: 1.0, green: 0.843, blue: 0.298)
    static let blockCaffeine = Color(red: 0.608, green: 0.463, blue: 0.294)
    static let blockPeakFocus = Color(red: 0.298, green: 0.851, blue: 0.392)
    static let blockEnergyDip = Color(red: 0.878, green: 0.655, blue: 0.243)
    static let blockDigitalSunset = Color(red: 0.878, green: 0.467, blue: 0.322)
    static let blockWindDown = Color(red: 0.588, green: 0.388, blue: 0.812)
    static let blockSleep = Color(red: 0.275, green: 0.243, blue: 0.525)
    static let blockWake = Color(red: 1.0, green: 0.757, blue: 0.027)

    // MARK: - Functional Colors

    static let success = Color(red: 0.298, green: 0.851, blue: 0.392)
    static let warning = Color(red: 0.878, green: 0.655, blue: 0.243)
    static let destructive = Color(red: 0.906, green: 0.298, blue: 0.298)

}

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
