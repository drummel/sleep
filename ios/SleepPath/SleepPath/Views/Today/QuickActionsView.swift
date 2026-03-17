import SwiftUI

struct QuickActionsView: View {
    @Binding var caffeineCount: Int
    @Binding var sunlightLogged: Bool
    var onShareTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(SleepTheme.textPrimary)

            HStack(spacing: 0) {
                Spacer()

                SunlightButton(isLogged: $sunlightLogged)

                Spacer()

                CoffeeButton(count: $caffeineCount)

                Spacer()

                ShareButton(onTap: onShareTapped)

                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(SleepTheme.card)
        )
    }
}

// MARK: - Sunlight Button

private struct SunlightButton: View {
    @Binding var isLogged: Bool
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        isLogged
                            ? Color(red: 60/255, green: 50/255, blue: 15/255)
                            : SleepTheme.cardLight
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isLogged
                                    ? SleepTheme.accent.opacity(0.5)
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )

                if isLogged {
                    ZStack {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 24))
                            .foregroundColor(SleepTheme.accent)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                            .offset(x: 14, y: 12)
                    }
                } else {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 24))
                        .foregroundColor(SleepTheme.accent)
                }
            }
            .scaleEffect(isPressed ? 0.88 : 1.0)

            Text("Sunlight")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SleepTheme.textSecondary)
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    isPressed = false
                    isLogged.toggle()
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isLogged ? "Sunlight logged" : "Log sunlight")
        .accessibilityHint("Tap to toggle sunlight logging")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Coffee Button

private struct CoffeeButton: View {
    @Binding var count: Int
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(
                        count > 0
                            ? Color(red: 40/255, green: 30/255, blue: 15/255)
                            : SleepTheme.cardLight
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                count > 0
                                    ? Color(red: 180/255, green: 130/255, blue: 60/255).opacity(0.5)
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )

                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 22))
                    .foregroundColor(
                        count > 0
                            ? Color(red: 210/255, green: 160/255, blue: 80/255)
                            : SleepTheme.textSecondary
                    )
                    .frame(width: 64, height: 64)

                // Count badge
                if count > 0 {
                    Text("\u{00D7}\(count)")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(red: 160/255, green: 100/255, blue: 30/255))
                        )
                        .offset(x: 4, y: -2)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(isPressed ? 0.88 : 1.0)

            Text("Coffee")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SleepTheme.textSecondary)
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    isPressed = false
                    count += 1
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Log coffee, \(count) so far")
        .accessibilityHint("Tap to add a coffee")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Share Button

private struct ShareButton: View {
    var onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(SleepTheme.cardLight)
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 22))
                        .foregroundColor(SleepTheme.textSecondary)
                        .offset(y: -1)
                )
                .scaleEffect(isPressed ? 0.88 : 1.0)

            Text("Share")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SleepTheme.textSecondary)
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    isPressed = false
                }
                onTap()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Share")
        .accessibilityHint("Tap to share your daily trajectory")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var caffeine = 2
    @Previewable @State var sunlight = false

    ZStack {
        SleepTheme.background.ignoresSafeArea()

        QuickActionsView(
            caffeineCount: $caffeine,
            sunlightLogged: $sunlight,
            onShareTapped: {}
        )
        .padding()
    }
}
