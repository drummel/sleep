import SwiftUI

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = SleepTheme.accent

    private let cardBackground = SleepTheme.card

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBackground)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview {
    StatCard(icon: "moon.zzz", value: "7h 32m", label: "Average Sleep")
        .padding()
        .background(SleepTheme.background)
}
