import SwiftUI

struct EnergyStateCard: View {
    let energyState: EnergyState
    let timeUntilChange: String
    let suggestion: String

    @State private var isPulsing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                // Energy icon with animated glow
                ZStack {
                    Circle()
                        .fill(iconGlowColor.opacity(isPulsing ? 0.25 : 0.1))
                        .frame(width: 64, height: 64)
                        .scaleEffect(isPulsing ? 1.15 : 1.0)

                    Image(systemName: energyState.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(iconColor)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(iconBackgroundColor)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(energyState.displayName)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(SleepTheme.textPrimary)

                    Text(timeUntilChange)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SleepTheme.textSecondary)
                }

                Spacer()
            }

            // Suggestion
            Text(suggestion)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(SleepTheme.textSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(cardGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(borderColor, lineWidth: 1)
                )
        )
        .onAppear {
            guard energyState == .peak else { return }
            withAnimation(
                .easeInOut(duration: 1.6)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(energyState.displayName) energy. \(timeUntilChange). \(suggestion)")
    }

    // MARK: - Computed Colors

    private var cardGradient: LinearGradient {
        switch energyState {
        case .peak:
            LinearGradient(
                colors: [
                    Color(red: 40/255, green: 35/255, blue: 15/255),
                    SleepTheme.card,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rising:
            LinearGradient(
                colors: [
                    Color(red: 35/255, green: 30/255, blue: 20/255),
                    SleepTheme.card,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dip:
            LinearGradient(
                colors: [
                    Color(red: 25/255, green: 28/255, blue: 40/255),
                    SleepTheme.card,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .recovery:
            LinearGradient(
                colors: [
                    Color(red: 20/255, green: 35/255, blue: 30/255),
                    SleepTheme.card,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .windDown:
            LinearGradient(
                colors: [
                    Color(red: 25/255, green: 20/255, blue: 40/255),
                    SleepTheme.card,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sleeping:
            LinearGradient(
                colors: [
                    Color(red: 15/255, green: 15/255, blue: 35/255),
                    SleepTheme.card,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var iconColor: Color {
        switch energyState {
        case .peak: SleepTheme.accent
        case .rising: Color(red: 255/255, green: 200/255, blue: 100/255)
        case .dip: Color(red: 140/255, green: 160/255, blue: 200/255)
        case .recovery: Color(red: 100/255, green: 210/255, blue: 160/255)
        case .windDown: Color(red: 160/255, green: 130/255, blue: 220/255)
        case .sleeping: Color(red: 100/255, green: 120/255, blue: 200/255)
        }
    }

    private var iconGlowColor: Color {
        iconColor
    }

    private var iconBackgroundColor: Color {
        iconColor.opacity(0.15)
    }

    private var borderColor: Color {
        iconColor.opacity(0.2)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        SleepTheme.background.ignoresSafeArea()

        VStack(spacing: 16) {
            EnergyStateCard(
                energyState: .peak,
                timeUntilChange: "2h 15m until your dip",
                suggestion: "Deep work window \u{2014} protect the next 90 minutes for your hardest task."
            )

            EnergyStateCard(
                energyState: .dip,
                timeUntilChange: "45m until recovery",
                suggestion: "Take a 10\u{2013}20 minute walk or do a non-sleep deep rest session."
            )
        }
        .padding()
    }
}
