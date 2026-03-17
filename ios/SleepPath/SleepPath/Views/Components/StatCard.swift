import SwiftUI

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    var iconColor: Color = Color(hex: "f0a500")

    private let cardBackground = Color(hex: "232946")

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
    }
}

#Preview {
    StatCard(icon: "moon.zzz", value: "7h 32m", label: "Average Sleep")
        .padding()
        .background(Color(hex: "0f0e17"))
}
