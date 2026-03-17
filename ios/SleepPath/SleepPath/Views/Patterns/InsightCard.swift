import SwiftUI

struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    var description: String? = nil
    var iconColor: Color = Color(hex: "f0a500")

    private let cardBackground = Color(hex: "232946")

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.15))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))

                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                if let description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.45))
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBackground)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        InsightCard(
            icon: "moon.zzz",
            title: "Average Sleep",
            value: "7h 32m",
            description: "Above your target"
        )
        InsightCard(
            icon: "chart.bar.fill",
            title: "Consistency",
            value: "82%"
        )
    }
    .padding()
    .background(Color(hex: "0f0e17"))
}
