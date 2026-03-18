import SwiftUI

// MARK: - Card Styling

extension View {
    /// Apply standard app card styling
    func appCard(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    /// Apply elevated card styling with subtle shadow
    func appCardElevated(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color.appCardElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    /// Apply the app's standard screen background
    func appBackground() -> some View {
        self
            .background(Color.appBackground)
    }

    /// Haptic feedback on tap
    func hapticOnTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                UIImpactFeedbackGenerator(style: style).impactOccurred()
            }
        )
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Shimmer Effect

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.1),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: phase * 400 - 200)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Fade In Animation

struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

extension View {
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}
