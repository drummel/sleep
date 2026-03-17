import SwiftUI

// MARK: - Quiz Result View

struct QuizResultView: View {
    let chronotype: Chronotype
    var onContinue: () -> Void
    var onShare: () -> Void

    @State private var emojiScale: CGFloat = 0.3
    @State private var emojiOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var statsOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0

    var body: some View {
        ZStack {
            SleepTheme.background.ignoresSafeArea()

            // Radial glow behind the emoji
            RadialGradient(
                colors: [
                    SleepTheme.accent.opacity(0.08),
                    Color.clear,
                ],
                center: .center,
                startRadius: 10,
                endRadius: 250
            )
            .ignoresSafeArea()
            .offset(y: -120)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    emojiReveal
                        .opacity(emojiOpacity)
                        .scaleEffect(emojiScale)

                    Spacer().frame(height: 24)

                    headlineSection
                        .opacity(contentOpacity)

                    Spacer().frame(height: 32)

                    descriptionSection
                        .opacity(contentOpacity)

                    Spacer().frame(height: 36)

                    statsSection
                        .opacity(statsOpacity)

                    Spacer().frame(height: 48)

                    buttonSection
                        .opacity(buttonsOpacity)

                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 28)
            }
        }
        .onAppear { runRevealAnimation() }
    }

    // MARK: - Subviews

    private var emojiReveal: some View {
        Text(chronotype.emoji)
            .font(.system(size: 88))
    }

    private var headlineSection: some View {
        VStack(spacing: 8) {
            Text("You're a \(chronotype.displayName) \(chronotype.emoji)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(SleepTheme.textPrimary)

            Text(chronotype.tagline)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(SleepTheme.accentGradient)
        }
    }

    private var descriptionSection: some View {
        Text(chronotype.detailedDescription)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(SleepTheme.textSecondary)
            .multilineTextAlignment(.center)
            .lineSpacing(5)
    }

    private var statsSection: some View {
        VStack(spacing: 14) {
            StatRow(
                icon: "paintbrush.pointed.fill",
                label: "Peak creative hours",
                value: chronotype.peakHoursDescription
            )
            StatRow(
                icon: "cup.and.saucer.fill",
                label: "Ideal caffeine cutoff",
                value: chronotype.idealSleepTime
            )
            StatRow(
                icon: "sunrise.fill",
                label: "Optimal wake time",
                value: chronotype.idealWakeTime
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(SleepTheme.card)
        )
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            Button(action: onContinue) {
                Text("Continue to Setup")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(SleepTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button(action: onShare) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Share Your Chronotype")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(SleepTheme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(SleepTheme.accent.opacity(0.4), lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Animation

    private func runRevealAnimation() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.6, blendDuration: 0)) {
            emojiScale = 1.0
            emojiOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.35)) {
            contentOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.55)) {
            statsOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.75)) {
            buttonsOpacity = 1.0
        }
    }
}

// MARK: - Stat Row

private struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(SleepTheme.accent)
                .frame(width: 32)

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SleepTheme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(SleepTheme.textPrimary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    QuizResultView(
        chronotype: .wolf,
        onContinue: {},
        onShare: {}
    )
}
