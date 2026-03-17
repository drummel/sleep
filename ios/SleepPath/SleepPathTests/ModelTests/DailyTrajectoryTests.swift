import XCTest
@testable import SleepPath

final class DailyTrajectoryTests: XCTestCase {

    // MARK: - Helpers

    private func makeSampleTrajectory() -> DailyTrajectory {
        let calendar = Calendar.current
        let today = Date()
        let wakeTime = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: today)!
        let sleepTime = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: today)!

        let service = TrajectoryService()
        let blocks = service.generateTrajectory(
            chronotype: .bear,
            wakeTime: wakeTime,
            sleepTime: sleepTime,
            dataNightsCount: 14
        )

        return DailyTrajectory(
            date: today,
            chronotype: .bear,
            wakeTime: wakeTime,
            sleepTime: sleepTime,
            blocks: blocks,
            confidence: .mediumHigh
        )
    }

    // MARK: - Properties

    func test_dailyTrajectory_storesDate() {
        let trajectory = makeSampleTrajectory()
        XCTAssertNotNil(trajectory.date)
    }

    func test_dailyTrajectory_storesChronotype() {
        let trajectory = makeSampleTrajectory()
        XCTAssertEqual(trajectory.chronotype, .bear)
    }

    func test_dailyTrajectory_storesWakeTime() {
        let trajectory = makeSampleTrajectory()
        let hour = Calendar.current.component(.hour, from: trajectory.wakeTime)
        XCTAssertEqual(hour, 7)
    }

    func test_dailyTrajectory_storesSleepTime() {
        let trajectory = makeSampleTrajectory()
        let hour = Calendar.current.component(.hour, from: trajectory.sleepTime)
        XCTAssertEqual(hour, 23)
    }

    func test_dailyTrajectory_storesBlocks() {
        let trajectory = makeSampleTrajectory()
        XCTAssertFalse(trajectory.blocks.isEmpty)
    }

    func test_dailyTrajectory_storesConfidence() {
        let trajectory = makeSampleTrajectory()
        XCTAssertEqual(trajectory.confidence, .mediumHigh)
    }

    // MARK: - TrajectoryBlockType

    func test_trajectoryBlockType_allCasesCount() {
        XCTAssertEqual(TrajectoryBlockType.allCases.count, 10)
    }

    func test_trajectoryBlockType_allCasesHaveIcons() {
        for type in TrajectoryBlockType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "\(type) should have an icon")
        }
    }

    func test_trajectoryBlockType_allCasesHaveDisplayNames() {
        for type in TrajectoryBlockType.allCases {
            XCTAssertFalse(type.displayName.isEmpty, "\(type) should have a display name")
        }
    }

    func test_trajectoryBlockType_displayNames() {
        XCTAssertEqual(TrajectoryBlockType.sunlight.displayName, "Sunlight")
        XCTAssertEqual(TrajectoryBlockType.caffeineOk.displayName, "Caffeine OK")
        XCTAssertEqual(TrajectoryBlockType.peakFocus.displayName, "Peak Focus")
        XCTAssertEqual(TrajectoryBlockType.energyDip.displayName, "Energy Dip")
        XCTAssertEqual(TrajectoryBlockType.caffeineCutoff.displayName, "Caffeine Cutoff")
        XCTAssertEqual(TrajectoryBlockType.digitalSunset.displayName, "Digital Sunset")
        XCTAssertEqual(TrajectoryBlockType.windDown.displayName, "Wind Down")
        XCTAssertEqual(TrajectoryBlockType.sleep.displayName, "Sleep")
        XCTAssertEqual(TrajectoryBlockType.rising.displayName, "Rising")
        XCTAssertEqual(TrajectoryBlockType.recovery.displayName, "Recovery")
    }

    func test_trajectoryBlockType_icons() {
        XCTAssertEqual(TrajectoryBlockType.sunlight.icon, "sun.max.fill")
        XCTAssertEqual(TrajectoryBlockType.caffeineOk.icon, "cup.and.saucer.fill")
        XCTAssertEqual(TrajectoryBlockType.peakFocus.icon, "bolt.fill")
        XCTAssertEqual(TrajectoryBlockType.energyDip.icon, "cloud.sun.fill")
        XCTAssertEqual(TrajectoryBlockType.caffeineCutoff.icon, "cup.and.saucer")
        XCTAssertEqual(TrajectoryBlockType.digitalSunset.icon, "sunset.fill")
        XCTAssertEqual(TrajectoryBlockType.windDown.icon, "moon.haze.fill")
        XCTAssertEqual(TrajectoryBlockType.sleep.icon, "moon.zzz.fill")
        XCTAssertEqual(TrajectoryBlockType.rising.icon, "sunrise.fill")
        XCTAssertEqual(TrajectoryBlockType.recovery.icon, "arrow.up.right")
    }

    func test_trajectoryBlockType_displayNamesAreUnique() {
        let names = TrajectoryBlockType.allCases.map { $0.displayName }
        XCTAssertEqual(Set(names).count, names.count)
    }

    // MARK: - ConfidenceLevel

    func test_confidenceLevel_displayTexts() {
        XCTAssertEqual(ConfidenceLevel.low.displayText, "Low")
        XCTAssertEqual(ConfidenceLevel.lowMedium.displayText, "Low-Medium")
        XCTAssertEqual(ConfidenceLevel.medium.displayText, "Medium")
        XCTAssertEqual(ConfidenceLevel.mediumHigh.displayText, "Medium-High")
        XCTAssertEqual(ConfidenceLevel.high.displayText, "High")
        XCTAssertEqual(ConfidenceLevel.veryHigh.displayText, "Very High")
    }

    func test_confidenceLevel_detailTextsAreNotEmpty() {
        let levels: [ConfidenceLevel] = [.low, .lowMedium, .medium, .mediumHigh, .high, .veryHigh]
        for level in levels {
            XCTAssertFalse(level.detailText.isEmpty, "\(level) should have detail text")
        }
    }

    func test_confidenceLevel_rawValues() {
        XCTAssertEqual(ConfidenceLevel.low.rawValue, "low")
        XCTAssertEqual(ConfidenceLevel.lowMedium.rawValue, "lowMedium")
        XCTAssertEqual(ConfidenceLevel.medium.rawValue, "medium")
        XCTAssertEqual(ConfidenceLevel.mediumHigh.rawValue, "mediumHigh")
        XCTAssertEqual(ConfidenceLevel.high.rawValue, "high")
        XCTAssertEqual(ConfidenceLevel.veryHigh.rawValue, "veryHigh")
    }

    // MARK: - TrajectoryBlock

    func test_trajectoryBlock_durationMinutes() {
        let start = Date()
        let end = start.addingTimeInterval(90 * 60) // 90 minutes
        let block = TrajectoryBlock(
            type: .peakFocus,
            startTime: start,
            endTime: end,
            energyState: .peak,
            title: "Peak Focus",
            subtitle: "Test",
            icon: "bolt.fill"
        )
        XCTAssertEqual(block.durationMinutes, 90)
    }

    func test_trajectoryBlock_formattedTimeRange_containsDash() {
        let start = Date()
        let end = start.addingTimeInterval(60 * 60)
        let block = TrajectoryBlock(
            type: .sunlight,
            startTime: start,
            endTime: end,
            energyState: .rising,
            title: "Test",
            subtitle: "Test",
            icon: "sun.max.fill"
        )
        XCTAssertTrue(block.formattedTimeRange.contains(" - "))
    }

    func test_trajectoryBlock_identifiable_uniqueIds() {
        let now = Date()
        let block1 = TrajectoryBlock(
            type: .sunlight, startTime: now, endTime: now.addingTimeInterval(3600),
            energyState: .rising, title: "T", subtitle: "S", icon: "sun.max.fill"
        )
        let block2 = TrajectoryBlock(
            type: .sunlight, startTime: now, endTime: now.addingTimeInterval(3600),
            energyState: .rising, title: "T", subtitle: "S", icon: "sun.max.fill"
        )
        XCTAssertNotEqual(block1.id, block2.id)
    }
}
