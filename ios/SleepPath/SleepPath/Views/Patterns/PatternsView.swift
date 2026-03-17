import SwiftUI
import Charts

struct PatternsView: View {
    @Bindable var viewModel: PatternsViewModel

    @State private var showShareSheet = false

    // Chart data derived from view model
    private var chartData: [SleepDataPoint] {
        viewModel.sleepChartData.map { dataPoint in
            SleepDataPoint(
                date: dataPoint.date,
                hours: Double(dataPoint.duration) / 60.0,
                isConsistent: dataPoint.duration >= 420 && dataPoint.duration <= 510
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    timeRangePicker
                    sleepChart
                    statsGrid
                    chronotypeCard
                    weeklySummaryCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .background(SleepTheme.background.ignoresSafeArea())
            .navigationTitle("Patterns")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Time Range Picker

    private var timeRangePicker: some View {
        Picker("Time Range", selection: Binding(
            get: { viewModel.selectedTimeRange },
            set: { viewModel.updateTimeRange($0) }
        )) {
            ForEach(PatternsViewModel.TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Sleep Chart

    private var sleepChart: some View {
        SleepChartView(
            dataPoints: chartData,
            averageHours: Double(viewModel.averageSleepDuration) / 60.0
        )
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            StatCard(icon: "moon.zzz", value: viewModel.formattedAvgDuration, label: "Average Sleep")
            StatCard(icon: "chart.bar.fill", value: "\(Int(viewModel.sleepConsistencyScore))%", label: "Consistency")
            StatCard(icon: "arrow.left.arrow.right", value: "\(viewModel.socialJetlagMinutes) min", label: "Social Jetlag")
            StatCard(icon: "cup.and.saucer.fill", value: "+\(viewModel.caffeineImpactMinutes) min", label: "Caffeine Impact")
        }
    }

    // MARK: - Chronotype Card

    private var chronotypeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Chronotype Confidence")
                .font(.headline)
                .foregroundStyle(.white)

            HStack {
                Text("Your data points to: \(viewModel.currentChronotype.displayName) \(viewModel.currentChronotype.emoji)")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                Spacer()
            }

            // Confidence bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Confidence")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                    Text("\(Int(viewModel.chronotypeConfidence * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(SleepTheme.amber)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [SleepTheme.amber, SleepTheme.amber.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.chronotypeConfidence, height: 8)
                    }
                }
                .frame(height: 8)
            }

            if viewModel.showChronotypeRecalibration, let suggested = viewModel.suggestedChronotype {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(SleepTheme.amber)
                        .font(.caption)

                    Text("Your patterns suggest you might be a \(suggested.displayName). Consider recalibrating.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(.top, 4)

                SecondaryButton(title: "Recalibrate", icon: "arrow.clockwise", isInline: true) {
                    // Recalibrate action
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(SleepTheme.cardBackground)
        )
    }

    // MARK: - Weekly Summary Card

    private var weeklySummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "text.document.fill")
                    .foregroundStyle(SleepTheme.amber)
                Text("Weekly Summary")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Text(viewModel.weeklySummaryText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)

            SecondaryButton(title: "Share", icon: "square.and.arrow.up") {
                showShareSheet = true
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(SleepTheme.cardBackground)
        )
    }
}

#Preview {
    @Previewable @State var vm = PatternsViewModel()

    PatternsView(viewModel: vm)
        .onAppear { vm.loadData() }
}
