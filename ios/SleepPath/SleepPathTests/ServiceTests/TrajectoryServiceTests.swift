import XCTest
@testable import SleepPath

final class TrajectoryServiceTests: XCTestCase {

    var service: TrajectoryService!

    override func setUp() {
        super.setUp()
        service = TrajectoryService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeWakeTime(hour: Int = 7, minute: Int = 0) -> Date {
        Date.today(hour: hour, minute: minute)
    }

    private func makeSleepTime(hour: Int = 23, minute: Int = 0) -> Date {
        Date.today(hour: hour, minute: minute)
    }

    private func generateDefaultTrajectory(
        chronotype: Chronotype = .bear,
        wakeHour: Int = 7,
        sleepHour: Int = 23
    ) -> [TrajectoryBlock] {
        service.generateTrajectory(
            chronotype: chronotype,
            wakeTime: makeWakeTime(hour: wakeHour),
            sleepTime: makeSleepTime(hour: sleepHour),
            dataNightsCount: 15
        )
    }

    // MARK: - Block Generation

    func test_generateTrajectory_lion_returnsNonEmptyBlocks() {
        let blocks = generateDefaultTrajectory(chronotype: .lion, wakeHour: 6, sleepHour: 22)
        XCTAssertFalse(blocks.isEmpty)
    }

    func test_generateTrajectory_bear_returnsExpectedBlocks() {
        let blocks = generateDefaultTrajectory(chronotype: .bear)
        // Bear has no second peak focus, so should have: sunlight, rising, caffeineOk,
        // peakFocus, energyDip, recovery, caffeineCutoff, digitalSunset, windDown, sleep
        XCTAssertGreaterThanOrEqual(blocks.count, 8)
    }

    func test_generateTrajectory_wolf_includesTwoPeakFocusBlocks() {
        let blocks = generateDefaultTrajectory(chronotype: .wolf, wakeHour: 9, sleepHour: 24)
        // Use hour 0 of next day for midnight sleep
        let wolfBlocks = service.generateTrajectory(
            chronotype: .wolf,
            wakeTime: makeWakeTime(hour: 9),
            sleepTime: Date.today(hour: 23, minute: 59),
            dataNightsCount: 10
        )
        let peakBlocks = wolfBlocks.filter { $0.type == .peakFocus }
        XCTAssertEqual(peakBlocks.count, 2, "Wolf should have 2 peak focus blocks")
    }

    func test_generateTrajectory_lion_includesTwoPeakFocusBlocks() {
        let blocks = generateDefaultTrajectory(chronotype: .lion, wakeHour: 6, sleepHour: 22)
        let peakBlocks = blocks.filter { $0.type == .peakFocus }
        XCTAssertEqual(peakBlocks.count, 2, "Lion should have 2 peak focus blocks")
    }

    func test_generateTrajectory_bear_includesOnePeakFocusBlock() {
        let blocks = generateDefaultTrajectory(chronotype: .bear)
        let peakBlocks = blocks.filter { $0.type == .peakFocus }
        XCTAssertEqual(peakBlocks.count, 1, "Bear should have 1 peak focus block")
    }

    func test_generateTrajectory_dolphin_includesOnePeakFocusBlock() {
        let blocks = generateDefaultTrajectory(chronotype: .dolphin, wakeHour: 7, sleepHour: 23)
        let peakBlocks = blocks.filter { $0.type == .peakFocus }
        XCTAssertEqual(peakBlocks.count, 1, "Dolphin should have 1 peak focus block")
    }

    // MARK: - Block Ordering

    func test_generateTrajectory_blocksAreChronological() {
        for chronotype in Chronotype.allCases {
            let blocks = generateDefaultTrajectory(chronotype: chronotype)
            for i in 1..<blocks.count {
                XCTAssertLessThanOrEqual(
                    blocks[i - 1].startTime, blocks[i].startTime,
                    "\(chronotype): block \(i - 1) '\(blocks[i - 1].title)' should start before block \(i) '\(blocks[i].title)'"
                )
            }
        }
    }

    // MARK: - Sunlight Window

    func test_generateTrajectory_sunlightStartsAfterWake() {
        let wakeTime = makeWakeTime(hour: 7)
        let blocks = service.generateTrajectory(
            chronotype: .bear,
            wakeTime: wakeTime,
            sleepTime: makeSleepTime(hour: 23),
            dataNightsCount: 10
        )

        guard let sunlightBlock = blocks.first(where: { $0.type == .sunlight }) else {
            XCTFail("Trajectory should contain a sunlight block")
            return
        }

        // Sunlight should start 15 minutes after wake
        let expectedStart = wakeTime.addingTimeInterval(15 * 60)
        XCTAssertEqual(
            sunlightBlock.startTime.timeIntervalSince1970,
            expectedStart.timeIntervalSince1970,
            accuracy: 1.0,
            "Sunlight should start 15 minutes after wake time"
        )
    }

    func test_generateTrajectory_sunlightDuration_is45Minutes() {
        let blocks = generateDefaultTrajectory()
        guard let sunlightBlock = blocks.first(where: { $0.type == .sunlight }) else {
            XCTFail("Should have sunlight block")
            return
        }
        XCTAssertEqual(sunlightBlock.durationMinutes, 45)
    }

    // MARK: - Caffeine Cutoff

    func test_generateTrajectory_caffeineCutoff8HoursBeforeSleep() {
        let sleepTime = makeSleepTime(hour: 23)
        let blocks = service.generateTrajectory(
            chronotype: .bear,
            wakeTime: makeWakeTime(hour: 7),
            sleepTime: sleepTime,
            dataNightsCount: 10
        )

        guard let cutoffBlock = blocks.first(where: { $0.type == .caffeineCutoff }) else {
            XCTFail("Trajectory should contain a caffeine cutoff block")
            return
        }

        // Bear: caffeine cutoff is 8 hours before sleep
        let expectedCutoff = sleepTime.addingTimeInterval(-8 * 3600)
        XCTAssertEqual(
            cutoffBlock.startTime.timeIntervalSince1970,
            expectedCutoff.timeIntervalSince1970,
            accuracy: 1.0,
            "Caffeine cutoff should be 8 hours before sleep for Bear"
        )
    }

    func test_generateTrajectory_dolphin_caffeineCutoff10HoursBeforeSleep() {
        let sleepTime = makeSleepTime(hour: 23)
        let blocks = service.generateTrajectory(
            chronotype: .dolphin,
            wakeTime: makeWakeTime(hour: 7),
            sleepTime: sleepTime,
            dataNightsCount: 10
        )

        guard let cutoffBlock = blocks.first(where: { $0.type == .caffeineCutoff }) else {
            XCTFail("Should have caffeine cutoff block")
            return
        }

        let expectedCutoff = sleepTime.addingTimeInterval(-10 * 3600)
        XCTAssertEqual(
            cutoffBlock.startTime.timeIntervalSince1970,
            expectedCutoff.timeIntervalSince1970,
            accuracy: 1.0,
            "Caffeine cutoff should be 10 hours before sleep for Dolphin"
        )
    }

    // MARK: - Block Types

    func test_generateTrajectory_containsSleepBlock() {
        let blocks = generateDefaultTrajectory()
        let sleepBlocks = blocks.filter { $0.type == .sleep }
        XCTAssertEqual(sleepBlocks.count, 1, "Should have exactly one sleep block")
    }

    func test_generateTrajectory_containsWindDownBlock() {
        let blocks = generateDefaultTrajectory()
        let windDownBlocks = blocks.filter { $0.type == .windDown }
        XCTAssertEqual(windDownBlocks.count, 1, "Should have exactly one wind-down block")
    }

    func test_generateTrajectory_containsDigitalSunsetBlock() {
        let blocks = generateDefaultTrajectory()
        let digitalSunsetBlocks = blocks.filter { $0.type == .digitalSunset }
        XCTAssertEqual(digitalSunsetBlocks.count, 1, "Should have exactly one digital sunset block")
    }

    func test_generateTrajectory_containsEnergyDipBlock() {
        let blocks = generateDefaultTrajectory()
        let dipBlocks = blocks.filter { $0.type == .energyDip }
        XCTAssertEqual(dipBlocks.count, 1, "Should have exactly one energy dip block")
    }

    func test_generateTrajectory_allBlocksHaveNonEmptyTitles() {
        let blocks = generateDefaultTrajectory()
        for block in blocks {
            XCTAssertFalse(block.title.isEmpty, "Block of type \(block.type) should have a non-empty title")
        }
    }

    func test_generateTrajectory_allBlocksHaveNonEmptySubtitles() {
        let blocks = generateDefaultTrajectory()
        for block in blocks {
            XCTAssertFalse(block.subtitle.isEmpty, "Block of type \(block.type) should have a non-empty subtitle")
        }
    }

    func test_generateTrajectory_allBlocksHaveNonEmptyIcons() {
        let blocks = generateDefaultTrajectory()
        for block in blocks {
            XCTAssertFalse(block.icon.isEmpty, "Block of type \(block.type) should have a non-empty icon")
        }
    }

    func test_generateTrajectory_allBlocksHavePositiveDuration() {
        let blocks = generateDefaultTrajectory()
        for block in blocks {
            XCTAssertGreaterThan(
                block.endTime, block.startTime,
                "Block '\(block.title)' endTime should be after startTime"
            )
        }
    }

    // MARK: - Energy State Determination

    func test_currentEnergyState_duringPeakBlock_returnsPeak() {
        let blocks = generateDefaultTrajectory(chronotype: .bear)
        guard let peakBlock = blocks.first(where: { $0.type == .peakFocus }) else {
            XCTFail("Should have a peak focus block")
            return
        }

        // Check energy state at the midpoint of the peak block
        let midpoint = peakBlock.startTime.addingTimeInterval(
            peakBlock.endTime.timeIntervalSince(peakBlock.startTime) / 2
        )
        let state = service.currentEnergyState(trajectory: blocks, at: midpoint)
        XCTAssertEqual(state, .peak)
    }

    func test_currentEnergyState_duringDipBlock_returnsDip() {
        let blocks = generateDefaultTrajectory(chronotype: .bear)
        guard let dipBlock = blocks.first(where: { $0.type == .energyDip }) else {
            XCTFail("Should have an energy dip block")
            return
        }

        let midpoint = dipBlock.startTime.addingTimeInterval(
            dipBlock.endTime.timeIntervalSince(dipBlock.startTime) / 2
        )
        let state = service.currentEnergyState(trajectory: blocks, at: midpoint)
        XCTAssertEqual(state, .dip)
    }

    func test_currentEnergyState_duringSleepBlock_returnsSleeping() {
        let blocks = generateDefaultTrajectory(chronotype: .bear)
        guard let sleepBlock = blocks.first(where: { $0.type == .sleep }) else {
            XCTFail("Should have a sleep block")
            return
        }

        let midpoint = sleepBlock.startTime.addingTimeInterval(60 * 60) // 1 hour into sleep
        let state = service.currentEnergyState(trajectory: blocks, at: midpoint)
        XCTAssertEqual(state, .sleeping)
    }

    func test_currentEnergyState_beforeFirstBlock_returnsRising() {
        let wakeTime = makeWakeTime(hour: 7)
        let blocks = service.generateTrajectory(
            chronotype: .bear,
            wakeTime: wakeTime,
            sleepTime: makeSleepTime(hour: 23),
            dataNightsCount: 10
        )

        // Way before wake time
        let earlyMorning = Date.today(hour: 3)
        let state = service.currentEnergyState(trajectory: blocks, at: earlyMorning)
        XCTAssertEqual(state, .rising, "Before any blocks should default to rising")
    }

    func test_currentEnergyState_duringWindDown_returnsWindDown() {
        let blocks = generateDefaultTrajectory(chronotype: .bear)
        guard let windDownBlock = blocks.first(where: { $0.type == .windDown }) else {
            XCTFail("Should have a wind-down block")
            return
        }

        let midpoint = windDownBlock.startTime.addingTimeInterval(
            windDownBlock.endTime.timeIntervalSince(windDownBlock.startTime) / 2
        )
        let state = service.currentEnergyState(trajectory: blocks, at: midpoint)
        XCTAssertEqual(state, .windDown)
    }

    // MARK: - Confidence Levels

    func test_confidenceLevel_0Nights_returnsLow() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 0), .low)
    }

    func test_confidenceLevel_1Night_returnsLowMedium() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 1), .lowMedium)
    }

    func test_confidenceLevel_3Nights_returnsLowMedium() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 3), .lowMedium)
    }

    func test_confidenceLevel_4Nights_returnsMedium() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 4), .medium)
    }

    func test_confidenceLevel_7Nights_returnsMedium() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 7), .medium)
    }

    func test_confidenceLevel_8Nights_returnsMediumHigh() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 8), .mediumHigh)
    }

    func test_confidenceLevel_14Nights_returnsMediumHigh() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 14), .mediumHigh)
    }

    func test_confidenceLevel_15Nights_returnsHigh() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 15), .high)
    }

    func test_confidenceLevel_21Nights_returnsHigh() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 21), .high)
    }

    func test_confidenceLevel_22PlusNights_returnsVeryHigh() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 22), .veryHigh)
    }

    func test_confidenceLevel_100Nights_returnsVeryHigh() {
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 100), .veryHigh)
    }

    // MARK: - Time Until Next Change

    func test_timeUntilNextChange_returnsPositiveInterval() {
        let wakeTime = makeWakeTime(hour: 7)
        let blocks = service.generateTrajectory(
            chronotype: .bear,
            wakeTime: wakeTime,
            sleepTime: makeSleepTime(hour: 23),
            dataNightsCount: 10
        )

        // Pick a time before most blocks
        let earlyTime = Date.today(hour: 7, minute: 5)
        let interval = service.timeUntilNextStateChange(trajectory: blocks, at: earlyTime)
        XCTAssertNotNil(interval)
        if let interval = interval {
            XCTAssertGreaterThan(interval, 0, "Time until next change should be positive")
        }
    }

    func test_timeUntilNextChange_afterAllBlocks_returnsNil() {
        let blocks = generateDefaultTrajectory(chronotype: .bear)
        guard let lastBlock = blocks.last else {
            XCTFail("Should have blocks")
            return
        }

        // After the last block starts
        let afterAll = lastBlock.startTime.addingTimeInterval(24 * 3600)
        let interval = service.timeUntilNextStateChange(trajectory: blocks, at: afterAll)
        XCTAssertNil(interval, "Should return nil when no more blocks ahead")
    }

    // MARK: - Sleep Block Duration

    func test_generateTrajectory_sleepBlockIs8Hours() {
        let blocks = generateDefaultTrajectory()
        guard let sleepBlock = blocks.first(where: { $0.type == .sleep }) else {
            XCTFail("Should have a sleep block")
            return
        }
        let durationHours = sleepBlock.endTime.timeIntervalSince(sleepBlock.startTime) / 3600
        XCTAssertEqual(durationHours, 8.0, accuracy: 0.01, "Sleep block should be 8 hours")
    }

    // MARK: - Wind Down Timing

    func test_generateTrajectory_bear_windDownIs45MinBeforeSleep() {
        let sleepTime = makeSleepTime(hour: 23)
        let blocks = service.generateTrajectory(
            chronotype: .bear,
            wakeTime: makeWakeTime(hour: 7),
            sleepTime: sleepTime,
            dataNightsCount: 10
        )

        guard let windDownBlock = blocks.first(where: { $0.type == .windDown }) else {
            XCTFail("Should have wind-down block")
            return
        }

        let expectedStart = sleepTime.addingTimeInterval(-45 * 60)
        XCTAssertEqual(
            windDownBlock.startTime.timeIntervalSince1970,
            expectedStart.timeIntervalSince1970,
            accuracy: 1.0,
            "Bear wind-down should start 45 minutes before sleep"
        )
        XCTAssertEqual(
            windDownBlock.endTime.timeIntervalSince1970,
            sleepTime.timeIntervalSince1970,
            accuracy: 1.0,
            "Wind-down should end at sleep time"
        )
    }

    // MARK: - Digital Sunset Timing

    func test_generateTrajectory_digitalSunsetIs2HoursBeforeSleep() {
        let sleepTime = makeSleepTime(hour: 23)
        let blocks = service.generateTrajectory(
            chronotype: .bear,
            wakeTime: makeWakeTime(hour: 7),
            sleepTime: sleepTime,
            dataNightsCount: 10
        )

        guard let digitalSunset = blocks.first(where: { $0.type == .digitalSunset }) else {
            XCTFail("Should have digital sunset block")
            return
        }

        let expectedStart = sleepTime.addingTimeInterval(-120 * 60)
        XCTAssertEqual(
            digitalSunset.startTime.timeIntervalSince1970,
            expectedStart.timeIntervalSince1970,
            accuracy: 1.0,
            "Digital sunset should start 2 hours before sleep"
        )
    }
}
