import SwiftUI

struct CaffeineCutoffBanner: View {
    let cutoffTime: Date
    let currentTime: Date

    private var isPastCutoff: Bool {
        currentTime >= cutoffTime
    }

    private var timeUntilCutoff: String {
        guard !isPastCutoff else { return "" }
        let interval = cutoffTime.timeIntervalSince(currentTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m until cutoff"
        }
        return "\(minutes)m until cutoff"
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isPastCutoff ? "xmark.circle.fill" : "cup.and.saucer.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isPastCutoff ? bannerRed : bannerGreen)

            if isPastCutoff {
                Text("Past caffeine cutoff \u{2014} protect tonight\u{2019}s sleep")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(bannerRed)
            } else {
                Text("Caffeine OK \u{2014} \(timeUntilCutoff)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(bannerGreen)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isPastCutoff ? bannerRedBg : bannerGreenBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isPastCutoff
                                ? bannerRed.opacity(0.25)
                                : bannerGreen.opacity(0.25),
                            lineWidth: 1
                        )
                )
        )
    }

    // MARK: - Colors

    private var bannerGreen: Color {
        Color(red: 80/255, green: 210/255, blue: 130/255)
    }

    private var bannerGreenBg: Color {
        Color(red: 15/255, green: 35/255, blue: 20/255)
    }

    private var bannerRed: Color {
        Color(red: 240/255, green: 100/255, blue: 100/255)
    }

    private var bannerRedBg: Color {
        Color(red: 40/255, green: 15/255, blue: 15/255)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        SleepTheme.background.ignoresSafeArea()

        VStack(spacing: 16) {
            CaffeineCutoffBanner(
                cutoffTime: Date().addingTimeInterval(3600 * 2.25),
                currentTime: Date()
            )

            CaffeineCutoffBanner(
                cutoffTime: Date().addingTimeInterval(-3600),
                currentTime: Date()
            )
        }
        .padding()
    }
}
