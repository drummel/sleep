import SwiftUI

// MARK: - Notification Permission View

struct NotificationPermissionView: View {
    var onAllow: () -> Void
    var onSkip: () -> Void

    @State private var appeared = false
    @State private var bellBounce = false

    var body: some View {
        ZStack {
            SleepTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                iconSection
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.8)

                Spacer().frame(height: 40)

                headlineSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                Spacer().frame(height: 36)

                nudgeList
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                Spacer().frame(height: 24)

                promiseText
                    .opacity(appeared ? 1 : 0)

                Spacer()

                buttonSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.1)) {
                appeared = true
            }
            // Trigger bell bounce after appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                bellBounce = true
            }
        }
    }

    // MARK: - Subviews

    private var iconSection: some View {
        ZStack {
            // Soft glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            SleepTheme.accent.opacity(0.12),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 68, weight: .light))
                .foregroundStyle(SleepTheme.accentGradient)
                .symbolEffect(.bounce, value: bellBounce)
        }
    }

    private var headlineSection: some View {
        VStack(spacing: 12) {
            Text("Can we nudge you at\nthe right moments?")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(SleepTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("We'll only ping you for things\nthat matter to your rhythm.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(SleepTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    private var nudgeList: some View {
        VStack(spacing: 0) {
            NudgeRow(
                emoji: "\u{2600}\u{FE0F}",
                title: "Sunlight window",
                subtitle: "Get outside to set your circadian clock"
            )

            Divider().overlay(SleepTheme.cardLight)

            NudgeRow(
                emoji: "\u{2615}",
                title: "Caffeine cutoff",
                subtitle: "Your last-call for coffee today"
            )

            Divider().overlay(SleepTheme.cardLight)

            NudgeRow(
                emoji: "\u{1F319}",
                title: "Wind-down time",
                subtitle: "Start dimming lights and screens"
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(SleepTheme.card)
        )
    }

    private var promiseText: some View {
        HStack(spacing: 8) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 13))
                .foregroundColor(SleepTheme.accent)

            Text("Nothing else. We promise.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(SleepTheme.textTertiary)
        }
        .padding(.top, 4)
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            Button(action: onAllow) {
                HStack(spacing: 8) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Allow Notifications")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(SleepTheme.accentGradient, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button(action: onSkip) {
                Text("Not Now")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SleepTheme.textTertiary)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Nudge Row

private struct NudgeRow: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Text(emoji)
                .font(.system(size: 28))
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(SleepTheme.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(SleepTheme.textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Preview

#Preview {
    NotificationPermissionView(
        onAllow: {},
        onSkip: {}
    )
}
