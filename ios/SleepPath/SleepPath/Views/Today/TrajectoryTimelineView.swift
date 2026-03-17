import SwiftUI

struct TrajectoryTimelineView: View {
    let blocks: [TrajectoryBlock]

    @State private var expandedBlockID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your Day")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(SleepTheme.textPrimary)
                .padding(.bottom, 16)

            ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
                TrajectoryTimelineRow(
                    block: block,
                    isExpanded: expandedBlockID == block.id,
                    isLast: index == blocks.count - 1
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if expandedBlockID == block.id {
                            expandedBlockID = nil
                        } else {
                            expandedBlockID = block.id
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(SleepTheme.card)
        )
    }
}

// MARK: - Timeline Row

private struct TrajectoryTimelineRow: View {
    let block: TrajectoryBlock
    let isExpanded: Bool
    let isLast: Bool

    private var dotColor: Color {
        if block.isActive {
            return SleepTheme.accent
        } else if block.isPast {
            return SleepTheme.textTertiary
        }
        return SleepTheme.textSecondary
    }

    private var rowOpacity: Double {
        block.isPast ? 0.5 : 1.0
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline indicator
            VStack(spacing: 0) {
                // Dot
                ZStack {
                    if block.isActive {
                        Circle()
                            .fill(SleepTheme.accent.opacity(0.3))
                            .frame(width: 20, height: 20)

                        Circle()
                            .fill(SleepTheme.accent)
                            .frame(width: 10, height: 10)
                    } else if block.isPast {
                        Circle()
                            .fill(SleepTheme.textTertiary)
                            .frame(width: 8, height: 8)
                    } else {
                        Circle()
                            .strokeBorder(SleepTheme.textSecondary, lineWidth: 1.5)
                            .frame(width: 10, height: 10)
                    }
                }
                .frame(width: 20, height: 20)

                // Vertical line
                if !isLast {
                    Rectangle()
                        .fill(
                            block.isActive
                                ? SleepTheme.accent.opacity(0.4)
                                : SleepTheme.textTertiary.opacity(0.3)
                        )
                        .frame(width: 1.5)
                        .frame(minHeight: isExpanded ? 70 : 36)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: block.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(block.isActive ? SleepTheme.accent : iconColor)
                        .frame(width: 20)

                    Text(block.title)
                        .font(.system(size: 15, weight: block.isActive ? .bold : .semibold))
                        .foregroundColor(
                            block.isActive
                                ? SleepTheme.textPrimary
                                : SleepTheme.textPrimary.opacity(rowOpacity)
                        )

                    if block.isActive {
                        Text("NOW")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(SleepTheme.accent)
                            )
                    }

                    Spacer()

                    Text(block.formattedTimeRange)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(SleepTheme.textTertiary.opacity(rowOpacity))
                }

                // Expanded context
                if isExpanded {
                    Text(contextText(for: block.type))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(SleepTheme.textSecondary)
                        .lineSpacing(3)
                        .padding(.top, 4)
                        .padding(.leading, 28)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, isLast ? 0 : 8)
        }
        .padding(.vertical, 2)
        .background(
            block.isActive
                ? RoundedRectangle(cornerRadius: 12)
                    .fill(SleepTheme.accent.opacity(0.06))
                    .padding(.horizontal, -8)
                    .padding(.vertical, -4)
                : nil
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(block.title), \(block.formattedTimeRange)\(block.isActive ? ", current" : "")")
        .accessibilityHint("Tap for details")
        .accessibilityAddTraits(.isButton)
    }

    private var iconColor: Color {
        if block.isPast {
            return SleepTheme.textTertiary
        }
        return SleepTheme.textSecondary
    }

    private func contextText(for type: TrajectoryBlockType) -> String {
        switch type {
        case .rising:
            "Rise consistently at this time to anchor your circadian rhythm."
        case .sunlight:
            "Get bright light in your eyes within 30 minutes of waking to suppress melatonin."
        case .caffeineOk:
            "Cortisol has settled. Coffee now works with your biology, not against it."
        case .peakFocus:
            "Your highest cognitive performance window. Tackle your hardest, most important work."
        case .energyDip:
            "A natural dip in alertness. Rest, walk, or do light tasks \u{2014} don't fight it."
        case .caffeineCutoff:
            "No more caffeine from here. It takes 8\u{2013}10 hours to fully metabolize."
        case .digitalSunset:
            "Reduce screen brightness and blue light to let melatonin production begin."
        case .windDown:
            "Start your sleep routine: dim lights, cool the room, unwind mentally."
        case .sleep:
            "Aim to be in bed by this time. Consistency is more powerful than duration."
        case .recovery:
            "Energy rebounds after the dip. Good for creative work and collaboration."
        }
    }
}

// MARK: - Preview

#Preview {
    let now = Date()
    let blocks = [
        TrajectoryBlock(
            type: .rising,
            startTime: now.addingTimeInterval(-3600 * 4),
            endTime: now.addingTimeInterval(-3600 * 3.5),
            energyState: .rising,
            title: "Wake Up",
            subtitle: "Rise consistently to anchor your circadian rhythm.",
            icon: TrajectoryBlockType.rising.icon
        ),
        TrajectoryBlock(
            type: .sunlight,
            startTime: now.addingTimeInterval(-3600 * 3.5),
            endTime: now.addingTimeInterval(-3600 * 3),
            energyState: .rising,
            title: "Get Sunlight",
            subtitle: "Step outside for 10+ minutes of natural light.",
            icon: TrajectoryBlockType.sunlight.icon
        ),
        TrajectoryBlock(
            type: .caffeineOk,
            startTime: now.addingTimeInterval(-3600 * 3),
            endTime: now.addingTimeInterval(-3600),
            energyState: .rising,
            title: "Caffeine OK",
            subtitle: "Your cortisol has settled.",
            icon: TrajectoryBlockType.caffeineOk.icon
        ),
        TrajectoryBlock(
            type: .peakFocus,
            startTime: now.addingTimeInterval(-1800),
            endTime: now.addingTimeInterval(3600),
            energyState: .peak,
            title: "Peak Focus",
            subtitle: "Your mental clarity is at its highest.",
            icon: TrajectoryBlockType.peakFocus.icon
        ),
        TrajectoryBlock(
            type: .energyDip,
            startTime: now.addingTimeInterval(3600),
            endTime: now.addingTimeInterval(3600 * 2.5),
            energyState: .dip,
            title: "Energy Dip",
            subtitle: "A natural dip in alertness.",
            icon: TrajectoryBlockType.energyDip.icon
        ),
        TrajectoryBlock(
            type: .windDown,
            startTime: now.addingTimeInterval(3600 * 8),
            endTime: now.addingTimeInterval(3600 * 9),
            energyState: .windDown,
            title: "Wind Down",
            subtitle: "Start your bedtime routine.",
            icon: TrajectoryBlockType.windDown.icon
        ),
        TrajectoryBlock(
            type: .sleep,
            startTime: now.addingTimeInterval(3600 * 9),
            endTime: now.addingTimeInterval(3600 * 10),
            energyState: .sleeping,
            title: "Sleep",
            subtitle: "Time for rest.",
            icon: TrajectoryBlockType.sleep.icon
        ),
    ]

    ZStack {
        SleepTheme.background.ignoresSafeArea()
        ScrollView {
            TrajectoryTimelineView(blocks: blocks)
                .padding()
        }
    }
}
