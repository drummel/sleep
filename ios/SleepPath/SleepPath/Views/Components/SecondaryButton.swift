import SwiftUI

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var isInline: Bool = false
    let action: () -> Void

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
            .foregroundStyle(SleepTheme.accent)
            .frame(maxWidth: isInline ? nil : .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, isInline ? 24 : 0)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(SleepTheme.accent, lineWidth: 1.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
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
