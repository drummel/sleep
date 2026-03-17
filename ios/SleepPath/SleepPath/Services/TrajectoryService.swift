import Foundation

// MARK: - Supporting Types

/// A single block in the user's daily trajectory timeline.
struct TrajectoryBlock: Identifiable, Sendable {
    let id = UUID()
    /// The type of event this block represents.
    let type: TrajectoryBlockType
    /// When this block begins.
    let startTime: Date
    /// When this block ends.
    let endTime: Date
    /// The energy state during this block.
    let energyState: EnergyState
    /// A short title for display.
    let title: String
    /// A longer description with actionable advice.
    let subtitle: String
    /// SF Symbol icon name.
    /// Note: This is redundant with `type.icon` but kept as a stored property for API compatibility.
    let icon: String

    /// Duration of this block in minutes.
    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }

    /// Whether this block is currently active (the current time falls within it).
    var isActive: Bool {
        let now = Date()
        return now >= startTime && now < endTime
    }

    /// Whether this block has already passed.
    var isPast: Bool {
        Date() >= endTime
    }

    /// Cached time formatter for display strings.
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    /// A formatted time range string for display (e.g., "9:00 AM - 10:30 AM").
    var formattedTimeRange: String {
        return "\(Self.timeFormatter.string(from: startTime)) - \(Self.timeFormatter.string(from: endTime))"
    }
}

/// Types of trajectory blocks that can appear in a daily timeline.
enum TrajectoryBlockType: String, Sendable, CaseIterable {
    case sunlight
    case caffeineOk
    case peakFocus
    case energyDip
    case caffeineCutoff
    case digitalSunset
    case windDown
    case sleep
    case rising
    case recovery

    /// SF Symbol icon for this block type.
    var icon: String {
        switch self {
        case .sunlight:       return "sun.max.fill"
        case .caffeineOk:     return "cup.and.saucer.fill"
        case .peakFocus:      return "bolt.fill"
        case .energyDip:      return "cloud.sun.fill"
        case .caffeineCutoff: return "cup.and.saucer"
        case .digitalSunset:  return "sunset.fill"
        case .windDown:       return "moon.haze.fill"
        case .sleep:          return "moon.zzz.fill"
        case .rising:         return "sunrise.fill"
        case .recovery:       return "arrow.up.right"
        }
    }

    /// Human-readable display name.
    var displayName: String {
        switch self {
        case .sunlight:       return "Sunlight"
        case .caffeineOk:     return "Caffeine OK"
        case .peakFocus:      return "Peak Focus"
        case .energyDip:      return "Energy Dip"
        case .caffeineCutoff: return "Caffeine Cutoff"
        case .digitalSunset:  return "Digital Sunset"
        case .windDown:       return "Wind Down"
        case .sleep:          return "Sleep"
        case .rising:         return "Rising"
        case .recovery:       return "Recovery"
        }
    }
}

/// Confidence level for a trajectory based on the amount of data available.
enum ConfidenceLevel: String, Sendable {
    case low
    case lowMedium
    case medium
    case mediumHigh
    case high
    case veryHigh

    /// Short display text for the confidence level.
    var displayText: String {
        switch self {
        case .low:        return "Low"
        case .lowMedium:  return "Low-Medium"
        case .medium:     return "Medium"
        case .mediumHigh: return "Medium-High"
        case .high:       return "High"
        case .veryHigh:   return "Very High"
        }
    }

    /// Explanation of what this confidence level means and how to improve it.
    var detailText: String {
        switch self {
        case .low:
            return "Based on your quiz \u{2014} connect Health for better accuracy"
        case .lowMedium:
            return "Based on a few nights of data \u{2014} keep tracking for better accuracy"
        case .medium:
            return "Based on about a week of data \u{2014} your trajectory is improving"
        case .mediumHigh:
            return "Based on two weeks of data \u{2014} your trajectory is getting reliable"
        case .high:
            return "Based on three weeks of data \u{2014} your trajectory is well-calibrated"
        case .veryHigh:
            return "Based on a month of data \u{2014} your trajectory is highly personalized"
        }
    }
}

// MARK: - Trajectory Service

/// Generates a daily energy trajectory based on the user's chronotype and sleep schedule.
///
/// The trajectory is a sequence of time blocks throughout the day, each representing
/// a distinct energy state or actionable moment (e.g., peak focus, caffeine cutoff).
@Observable
final class TrajectoryService {

    // MARK: - Chronotype-Specific Offsets (in minutes from wake time)

    /// Offsets from wake time for chronotype-specific events.
    private struct ChronotypeOffsets {
        /// Minutes after wake for first peak focus window.
        let peakFocus1: Int
        /// Minutes after wake for second peak focus window, if any.
        let peakFocus2: Int?
        /// Minutes after wake for the energy dip.
        let energyDip: Int
        /// Minutes after wake for caffeine OK (delayed caffeine).
        let caffeineOk: Int
        /// Minutes before sleep for caffeine cutoff.
        let caffeineCutoffBeforeSleep: Int
        /// Minutes before sleep for wind-down start.
        let windDownBeforeSleep: Int

        static func offsets(for chronotype: Chronotype) -> ChronotypeOffsets {
            switch chronotype {
            case .lion:
                return ChronotypeOffsets(
                    peakFocus1: 120,       // wake+2h
                    peakFocus2: 480,       // wake+8h
                    energyDip: 360,        // wake+6h
                    caffeineOk: 90,        // wake+90min
                    caffeineCutoffBeforeSleep: 480,  // sleep-8h
                    windDownBeforeSleep: 45          // sleep-45min
                )
            case .bear:
                return ChronotypeOffsets(
                    peakFocus1: 180,       // wake+3h
                    peakFocus2: nil,       // no second peak
                    energyDip: 360,        // wake+6h
                    caffeineOk: 90,        // wake+90min
                    caffeineCutoffBeforeSleep: 480,  // sleep-8h
                    windDownBeforeSleep: 45          // sleep-45min
                )
            case .wolf:
                return ChronotypeOffsets(
                    peakFocus1: 300,       // wake+5h
                    peakFocus2: 600,       // wake+10h
                    energyDip: 480,        // wake+8h
                    caffeineOk: 90,        // wake+90min
                    caffeineCutoffBeforeSleep: 480,  // sleep-8h
                    windDownBeforeSleep: 45          // sleep-45min
                )
            case .dolphin:
                return ChronotypeOffsets(
                    peakFocus1: 180,       // wake+3h
                    peakFocus2: nil,       // no second peak
                    energyDip: 300,        // wake+5h
                    caffeineOk: 120,       // wake+120min (longer delay for Dolphin)
                    caffeineCutoffBeforeSleep: 600,  // sleep-10h
                    windDownBeforeSleep: 60          // sleep-60min
                )
            }
        }
    }

    // MARK: - Shared Offsets (in minutes)

    /// Minutes after wake for the sunlight window.
    private let sunlightOffset = 15
    /// Duration of the sunlight window in minutes.
    private let sunlightDuration = 45
    /// Minutes before sleep for digital sunset.
    private let digitalSunsetBeforeSleep = 120
    /// Duration of a peak focus block in minutes.
    private let peakFocusDuration = 90
    /// Duration of an energy dip block in minutes.
    private let energyDipDuration = 60

    // MARK: - Public API

    /// Generates a complete daily trajectory of time blocks.
    ///
    /// - Parameters:
    ///   - chronotype: The user's chronotype.
    ///   - wakeTime: The time the user woke up (or plans to wake up).
    ///   - sleepTime: The time the user plans to go to sleep.
    ///   - dataNightsCount: Number of nights of sleep data available, used for confidence.
    /// - Returns: An array of ``TrajectoryBlock`` sorted by start time.
    func generateTrajectory(
        chronotype: Chronotype,
        wakeTime: Date,
        sleepTime: Date,
        dataNightsCount: Int
    ) -> [TrajectoryBlock] {
        let offsets = ChronotypeOffsets.offsets(for: chronotype)
        var blocks: [TrajectoryBlock] = []

        // --- Sunlight Window ---
        let sunlightStart = wakeTime.addingTimeInterval(TimeInterval(sunlightOffset * 60))
        let sunlightEnd = sunlightStart.addingTimeInterval(TimeInterval(sunlightDuration * 60))
        blocks.append(TrajectoryBlock(
            type: .sunlight,
            startTime: sunlightStart,
            endTime: sunlightEnd,
            energyState: .rising,
            title: "Get Sunlight",
            subtitle: "Step outside for 10+ minutes of natural light to anchor your circadian clock.",
            icon: TrajectoryBlockType.sunlight.icon
        ))

        // --- Rising Phase (wake to first event) ---
        let risingEnd = min(sunlightStart, wakeTime.addingTimeInterval(TimeInterval(offsets.caffeineOk * 60)))
        if risingEnd > wakeTime {
            blocks.append(TrajectoryBlock(
                type: .rising,
                startTime: wakeTime,
                endTime: risingEnd,
                energyState: .rising,
                title: "Rising",
                subtitle: "Your energy is building. Ease into the day with light tasks.",
                icon: TrajectoryBlockType.rising.icon
            ))
        }

        // --- Caffeine OK ---
        let caffeineOkTime = wakeTime.addingTimeInterval(TimeInterval(offsets.caffeineOk * 60))
        blocks.append(TrajectoryBlock(
            type: .caffeineOk,
            startTime: caffeineOkTime,
            endTime: caffeineOkTime.addingTimeInterval(15 * 60),
            energyState: .rising,
            title: "Caffeine OK",
            subtitle: "Your cortisol has settled \u{2014} caffeine will be most effective now.",
            icon: TrajectoryBlockType.caffeineOk.icon
        ))

        // --- Peak Focus 1 ---
        let peak1Start = wakeTime.addingTimeInterval(TimeInterval(offsets.peakFocus1 * 60))
        let peak1End = peak1Start.addingTimeInterval(TimeInterval(peakFocusDuration * 60))
        blocks.append(TrajectoryBlock(
            type: .peakFocus,
            startTime: peak1Start,
            endTime: peak1End,
            energyState: .peak,
            title: "Peak Focus",
            subtitle: "Your mental clarity is at its highest. Tackle your most demanding work now.",
            icon: TrajectoryBlockType.peakFocus.icon
        ))

        // --- Energy Dip ---
        let dipStart = wakeTime.addingTimeInterval(TimeInterval(offsets.energyDip * 60))
        let dipEnd = dipStart.addingTimeInterval(TimeInterval(energyDipDuration * 60))
        blocks.append(TrajectoryBlock(
            type: .energyDip,
            startTime: dipStart,
            endTime: dipEnd,
            energyState: .dip,
            title: "Energy Dip",
            subtitle: "A natural dip in alertness. Take a walk, nap, or handle routine tasks.",
            icon: TrajectoryBlockType.energyDip.icon
        ))

        // --- Recovery (after dip) ---
        let recoveryEnd: Date
        if let peak2Offset = offsets.peakFocus2 {
            recoveryEnd = wakeTime.addingTimeInterval(TimeInterval(peak2Offset * 60))
        } else {
            recoveryEnd = dipEnd.addingTimeInterval(90 * 60)
        }
        if recoveryEnd > dipEnd {
            blocks.append(TrajectoryBlock(
                type: .recovery,
                startTime: dipEnd,
                endTime: recoveryEnd,
                energyState: .recovery,
                title: "Recovery",
                subtitle: "Energy rebounds after the dip. Good for creative work and collaboration.",
                icon: TrajectoryBlockType.recovery.icon
            ))
        }

        // --- Peak Focus 2 (Lion and Wolf only) ---
        if let peak2Offset = offsets.peakFocus2 {
            let peak2Start = wakeTime.addingTimeInterval(TimeInterval(peak2Offset * 60))
            let peak2End = peak2Start.addingTimeInterval(TimeInterval(peakFocusDuration * 60))
            if peak2Start < sleepTime {
                blocks.append(TrajectoryBlock(
                    type: .peakFocus,
                    startTime: peak2Start,
                    endTime: min(peak2End, sleepTime),
                    energyState: .peak,
                    title: "Second Wind",
                    subtitle: "Another window of heightened focus. Use it for creative or analytical work.",
                    icon: TrajectoryBlockType.peakFocus.icon
                ))
            }
        }

        // --- Caffeine Cutoff ---
        let caffeineCutoffTime = sleepTime.addingTimeInterval(TimeInterval(-offsets.caffeineCutoffBeforeSleep * 60))
        blocks.append(TrajectoryBlock(
            type: .caffeineCutoff,
            startTime: caffeineCutoffTime,
            endTime: caffeineCutoffTime.addingTimeInterval(15 * 60),
            energyState: .recovery,
            title: "Caffeine Cutoff",
            subtitle: "No more caffeine after this point to protect tonight's sleep quality.",
            icon: TrajectoryBlockType.caffeineCutoff.icon
        ))

        // --- Digital Sunset ---
        let digitalSunsetTime = sleepTime.addingTimeInterval(TimeInterval(-digitalSunsetBeforeSleep * 60))
        blocks.append(TrajectoryBlock(
            type: .digitalSunset,
            startTime: digitalSunsetTime,
            endTime: digitalSunsetTime.addingTimeInterval(15 * 60),
            energyState: .windDown,
            title: "Digital Sunset",
            subtitle: "Reduce screen brightness and blue light. Switch to relaxing activities.",
            icon: TrajectoryBlockType.digitalSunset.icon
        ))

        // --- Wind Down ---
        let windDownStart = sleepTime.addingTimeInterval(TimeInterval(-offsets.windDownBeforeSleep * 60))
        blocks.append(TrajectoryBlock(
            type: .windDown,
            startTime: windDownStart,
            endTime: sleepTime,
            energyState: .windDown,
            title: "Wind Down",
            subtitle: "Start your bedtime routine. Dim lights, cool the room, and relax.",
            icon: TrajectoryBlockType.windDown.icon
        ))

        // --- Sleep ---
        let sleepEnd = sleepTime.addingTimeInterval(8 * 3600)
        blocks.append(TrajectoryBlock(
            type: .sleep,
            startTime: sleepTime,
            endTime: sleepEnd,
            energyState: .sleeping,
            title: "Sleep",
            subtitle: "Time for rest. Your body repairs, consolidates memories, and recharges.",
            icon: TrajectoryBlockType.sleep.icon
        ))

        return blocks.sorted { $0.startTime < $1.startTime }
    }

    /// Determines the current energy state based on the trajectory and a given time.
    ///
    /// - Parameters:
    ///   - trajectory: The day's trajectory blocks.
    ///   - time: The time to evaluate.
    /// - Returns: The ``EnergyState`` at the given time, defaulting to `.rising` if
    ///   no block covers the time.
    func currentEnergyState(trajectory: [TrajectoryBlock], at time: Date) -> EnergyState {
        // Find the block that contains the current time.
        if let currentBlock = trajectory.last(where: { $0.startTime <= time && $0.endTime > time }) {
            return currentBlock.energyState
        }

        // If between blocks, infer from the nearest preceding block.
        if let previousBlock = trajectory.last(where: { $0.endTime <= time }) {
            // Transitional: use the previous block's state or recovery.
            switch previousBlock.energyState {
            case .peak:     return .recovery
            case .dip:      return .recovery
            case .sleeping: return .rising
            default:        return previousBlock.energyState
            }
        }

        // Before the first block (just woke up).
        return .rising
    }

    /// Calculates the time until the next state change in the trajectory.
    ///
    /// - Parameters:
    ///   - trajectory: The day's trajectory blocks.
    ///   - time: The current time.
    /// - Returns: The time interval until the next block starts, or `nil` if
    ///   there are no more blocks today.
    func timeUntilNextStateChange(trajectory: [TrajectoryBlock], at time: Date) -> TimeInterval? {
        let upcomingBlocks = trajectory.filter { $0.startTime > time }
        guard let nextBlock = upcomingBlocks.first else { return nil }
        return nextBlock.startTime.timeIntervalSince(time)
    }

    /// Determines the confidence level based on how many nights of data are available.
    ///
    /// - Parameter dataNightsCount: The number of nights of sleep data recorded.
    /// - Returns: A ``ConfidenceLevel`` reflecting data quality.
    func confidenceLevel(dataNightsCount: Int) -> ConfidenceLevel {
        switch dataNightsCount {
        case 0:       return .low
        case 1...3:   return .lowMedium
        case 4...7:   return .medium
        case 8...14:  return .mediumHigh
        case 15...21: return .high
        default:      return .veryHigh
        }
    }
}
