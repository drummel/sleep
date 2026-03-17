import SwiftUI
import Charts

struct SleepDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let hours: Double
    let isConsistent: Bool
}

struct SleepChartView: View {
    let dataPoints: [SleepDataPoint]
    let averageHours: Double

    private let cardBackground = Color(hex: "232946")
    private let accentColor = Color(hex: "f0a500")
    private let consistentColor = Color.green
    private let inconsistentColor = Color(hex: "f0a500")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Duration")
                .font(.headline)
                .foregroundStyle(.white)

            Chart {
                // Average reference line
                RuleMark(y: .value("Average", averageHours))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(.white.opacity(0.3))
                    .annotation(position: .trailing, alignment: .leading) {
                        Text("avg")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.4))
                    }

                // Line connecting data points
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Hours", point.hours)
                    )
                    .foregroundStyle(accentColor.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }

                // Individual data points
                ForEach(dataPoints) { point in
                    PointMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Hours", point.hours)
                    )
                    .foregroundStyle(point.isConsistent ? consistentColor : inconsistentColor)
                    .symbolSize(40)
                }
            }
            .chartYScale(domain: 4...10)
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 2)) { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.1))
                    AxisValueLabel {
                        if let hours = value.as(Double.self) {
                            Text("\(Int(hours))h")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: max(1, dataPoints.count / 6))) { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.05))
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.month(.abbreviated).day())
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.clear)
            }
            .frame(height: 200)

            // Legend
            HStack(spacing: 16) {
                legendItem(color: consistentColor, label: "Consistent")
                legendItem(color: inconsistentColor, label: "Inconsistent")
            }
            .font(.caption2)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBackground)
        )
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Sample data for previews

extension SleepChartView {
    static var sampleData: [SleepDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let hours = Double.random(in: 5.5...8.5)
            let isConsistent = hours >= 7.0 && hours <= 8.5
            return SleepDataPoint(date: date, hours: hours, isConsistent: isConsistent)
        }.reversed()
    }
}

#Preview {
    SleepChartView(
        dataPoints: SleepChartView.sampleData,
        averageHours: 7.3
    )
    .padding()
    .background(Color(hex: "0f0e17"))
}
