import SwiftUI

// MARK: - HealthKit Permission View

struct HealthKitPermissionView: View {
    var onConnect: () -> Void
    var onSkip: () -> Void

    @State private var appeared = false

    var body: some View {
        ZStack {
            SleepTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                illustrationSection
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.85)

                Spacer().frame(height: 40)

                headlineSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                Spacer().frame(height: 36)

                permissionsSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                Spacer().frame(height: 28)

                privacyBadge
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
        }
    }

    // MARK: - Subviews

    private var illustrationSection: some View {
        ZStack {
            // Soft circular glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.red.opacity(0.08),
                            SleepTheme.amber.opacity(0.04),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)

            HStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(SleepTheme.textTertiary)

                Image(systemName: "applewatch")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(SleepTheme.textSecondary)
            }
        }
    }

    private var headlineSection: some View {
        VStack(spacing: 12) {
            Text("Your Watch already\nknows when you sleep.")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(SleepTheme.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text("Let us sync with Apple Health to build\nyour personalized rhythm.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(SleepTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    private var permissionsSection: some View {
        VStack(spacing: 0) {
            // What we read
            VStack(alignment: .leading, spacing: 14) {
                Text("WHAT WE READ")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(SleepTheme.textTertiary)
                    .tracking(1.2)

                PermissionRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    text: "Sleep times and duration"
                )
                PermissionRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    text: "Sleep stages (if available)"
                )
            }
            .padding(20)

            Divider()
                .overlay(SleepTheme.cardBackgroundLight)

            // What we never do
            VStack(alignment: .leading, spacing: 14) {
                Text("WHAT WE NEVER DO")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(SleepTheme.textTertiary)
                    .tracking(1.2)

                PermissionRow(
                    icon: "xmark.circle.fill",
                    iconColor: .red.opacity(0.7),
                    text: "Send your data to any server"
                )
                PermissionRow(
                    icon: "xmark.circle.fill",
                    iconColor: .red.opacity(0.7),
                    text: "Share with third parties"
                )
                PermissionRow(
                    icon: "xmark.circle.fill",
                    iconColor: .red.opacity(0.7),
                    text: "Use for advertising"
                )
            }
            .padding(20)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(SleepTheme.cardBackground)
        )
    }

    private var privacyBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SleepTheme.amber)

            Text("All your data stays on this device.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(SleepTheme.textTertiary)
        }
        .padding(.top, 4)
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            Button(action: onConnect) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Connect to Apple Health")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(SleepTheme.amberGradient, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            Button(action: onSkip) {
                Text("Maybe Later")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SleepTheme.textTertiary)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
    }
}

// MARK: - Permission Row

private struct PermissionRow: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(SleepTheme.textPrimary)
        }
    }
}

// MARK: - Preview

#Preview {
    HealthKitPermissionView(
        onConnect: {},
        onSkip: {}
    )
}
