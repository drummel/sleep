import SwiftUI

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var isInline: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    private let accentColor = SleepTheme.accent

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(accentColor)
            .frame(maxWidth: isInline ? nil : .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, isInline ? 24 : 0)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(accentColor, lineWidth: 1.5)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        SecondaryButton(title: "Share Results", icon: "square.and.arrow.up") {}
        SecondaryButton(title: "Retake Quiz", isInline: true) {}
    }
    .padding()
    .background(SleepTheme.background)
}
