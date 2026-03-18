import SwiftUI

struct TodayView: View {
    @Bindable var viewModel: TodayViewModel

    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Energy State Card
                    EnergyStateCard(
                        energyState: viewModel.currentEnergyState,
                        timeUntilChange: viewModel.formattedTimeUntilChange,
                        suggestion: viewModel.energySuggestion
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                    // Caffeine Cutoff Banner
                    CaffeineCutoffBanner(
                        cutoffTime: caffeineCutoffTime
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                    // Daily Trajectory Timeline
                    TrajectoryTimelineView(blocks: viewModel.trajectoryBlocks)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    // Quick Actions
                    QuickActionsView(
                        caffeineCount: Binding(
                            get: { viewModel.todayCaffeineCount },
                            set: { _ in viewModel.logCaffeine() }
                        ),
                        sunlightLogged: Binding(
                            get: { viewModel.hasSunlightToday },
                            set: { _ in viewModel.logSunlight() }
                        ),
                        onShareTapped: {}
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                    // Confidence Indicator
                    ConfidenceIndicator(
                        level: viewModel.confidenceLevel,
                        nightsCount: viewModel.trajectoryBlocks.count
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .background(SleepTheme.background.ignoresSafeArea())
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    /// Derive caffeine cutoff time from the trajectory blocks.
    private var caffeineCutoffTime: Date {
        if let cutoffBlock = viewModel.trajectoryBlocks.first(where: { $0.type == .caffeineCutoff }) {
            return cutoffBlock.startTime
        }
        return Date().addingTimeInterval(3600 * 3)
    }
}

// MARK: - Confidence Indicator

private struct ConfidenceIndicator: View {
    let level: ConfidenceLevel
    let nightsCount: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: confidenceIcon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(confidenceColor)

            Text(confidenceText)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SleepTheme.textTertiary)
        }
        .padding(.top, 4)
    }

    private var confidenceText: String {
        switch level {
        case .high, .veryHigh:
            "Based on \(nightsCount) nights of data \u{2014} high confidence"
        case .medium, .mediumHigh:
            "Based on \(nightsCount) nights of data \u{2014} building confidence"
        case .low, .lowMedium:
            "Based on quiz results \u{2014} log sleep to improve accuracy"
        }
    }

    private var confidenceIcon: String {
        switch level {
        case .high, .veryHigh: "checkmark.seal.fill"
        case .medium, .mediumHigh: "chart.line.uptrend.xyaxis"
        case .low, .lowMedium: "questionmark.circle"
        }
    }

    private var confidenceColor: Color {
        switch level {
        case .high, .veryHigh: Color(red: 80/255, green: 210/255, blue: 130/255)
        case .medium, .mediumHigh: SleepTheme.accent
        case .low, .lowMedium: SleepTheme.textTertiary
        }
    }
}

// MARK: - Preview

#Preview("Today - Peak Energy") {
    @Previewable @State var viewModel = TodayViewModel()

    TodayView(viewModel: viewModel)
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.loadToday()
        }
}
