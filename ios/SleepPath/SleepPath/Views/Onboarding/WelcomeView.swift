import SwiftUI

// MARK: - Welcome View

struct WelcomeView: View {
    var onGetStarted: () -> Void
    var onAlreadyTookQuiz: () -> Void

    @State private var logoAppeared = false
    @State private var titleAppeared = false
    @State private var propsAppeared = false
    @State private var buttonsAppeared = false

    var body: some View {
        ZStack {
            SleepTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                logoSection
                    .opacity(logoAppeared ? 1 : 0)
                    .scaleEffect(logoAppeared ? 1 : 0.7)
                    .offset(y: logoAppeared ? 0 : 20)

                Spacer()
                    .frame(height: 40)

                titleSection
                    .opacity(titleAppeared ? 1 : 0)
                    .offset(y: titleAppeared ? 0 : 15)

                Spacer()
                    .frame(height: 48)

                valuePropsSection
                    .opacity(propsAppeared ? 1 : 0)
                    .offset(y: propsAppeared ? 0 : 20)

                Spacer()

                buttonSection
                    .opacity(buttonsAppeared ? 1 : 0)
                    .offset(y: buttonsAppeared ? 0 : 20)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
        .onAppear { runEntryAnimation() }
    }

    // MARK: - Subviews

    private var logoSection: some View {
        ZStack {
            // Soft glow behind the icon
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            SleepTheme.accent.opacity(0.15),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)

            Image(systemName: "moon.stars.fill")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(SleepTheme.accentGradient)
                .symbolEffect(.pulse, options: .repeating, value: logoAppeared)
        }
    }

    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("SleepPath")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(SleepTheme.titleGradient)

            Text("Your biology has a schedule.\nStart following it.")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(SleepTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    private var valuePropsSection: some View {
        VStack(spacing: 20) {
            ValuePropRow(
                icon: "sparkles",
                text: "Discover your chronotype"
            )
            ValuePropRow(
                icon: "clock",
                text: "Get a personalized daily rhythm"
            )
            ValuePropRow(
                icon: "chart.line.uptrend.xyaxis",
                text: "Watch it adapt to your real data"
            )
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 16) {
            Button(action: onGetStarted) {
                Text("Get Started")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(SleepTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button(action: onAlreadyTookQuiz) {
                Text("I already took the quiz")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SleepTheme.textTertiary)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Animation

    private func runEntryAnimation() {
        withAnimation(.easeOut(duration: 0.7)) {
            logoAppeared = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.25)) {
            titleAppeared = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.45)) {
            propsAppeared = true
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.65)) {
            buttonsAppeared = true
        }
    }
}

// MARK: - Value Prop Row

private struct ValuePropRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(SleepTheme.accent)
                .frame(width: 44, height: 44)
                .background(SleepTheme.card, in: RoundedRectangle(cornerRadius: 12))

            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(SleepTheme.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview

#Preview {
    WelcomeView(
        onGetStarted: {},
        onAlreadyTookQuiz: {}
    )
}
