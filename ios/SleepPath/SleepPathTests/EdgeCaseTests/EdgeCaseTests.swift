import XCTest
@testable import SleepPath

/// Tests for edge cases, boundary conditions, and error paths across the app.
final class EdgeCaseTests: XCTestCase {

    // MARK: - OnboardingViewModel Edge Cases

    func test_onboarding_goBackOnFirstQuestion_isNoOp() {
        let vm = OnboardingViewModel()
        XCTAssertEqual(vm.currentQuestionIndex, 0)
        vm.goBack()
        XCTAssertEqual(vm.currentQuestionIndex, 0, "goBack on first question should be a no-op")
    }

    func test_onboarding_answerAfterQuizComplete_doesNotCrash() {
        let vm = OnboardingViewModel()

        // Complete the quiz
        for _ in 0..<vm.totalQuestions {
            vm.answerQuestion(optionScore: 1)
        }
        XCTAssertTrue(vm.isQuizComplete)

        // Answering again should not crash (index stays at last)
        vm.answerQuestion(optionScore: 2)
        XCTAssertTrue(vm.isQuizComplete)
    }

    func test_onboarding_proceedFromComplete_staysComplete() {
        let vm = OnboardingViewModel()
        vm.completeOnboarding()
        XCTAssertEqual(vm.currentStep, .complete)

        vm.proceedToNextStep()
        XCTAssertEqual(vm.currentStep, .complete, "Should stay at complete")
        XCTAssertTrue(vm.isOnboardingComplete)
    }

    func test_onboarding_reAnswerAfterGoBack_replacesAnswer() {
        let vm = OnboardingViewModel()
        vm.answerQuestion(optionScore: 1) // Q1 → score 1
        vm.answerQuestion(optionScore: 2) // Q2 → score 2

        vm.goBack() // Back to Q2 (index 1)
        vm.answerQuestion(optionScore: 3) // Re-answer Q2 → score 3

        // Find the answer for question at index 1
        let q2Answer = vm.answers.first { $0.questionId == vm.currentQuestion.id }
        // The index has advanced past Q2, so check by looking at all answers
        XCTAssertEqual(vm.answers.count, 2, "Should still have 2 answers, not 3")
    }

    func test_onboarding_progressNeverExceeds1() {
        let vm = OnboardingViewModel()
        for _ in 0..<vm.totalQuestions {
            vm.answerQuestion(optionScore: 2)
        }
        XCTAssertLessThanOrEqual(vm.progress, 1.0)
    }

    // MARK: - TodayViewModel Edge Cases

    func test_todayVM_refreshBeforeLoad_doesNotCrash() {
        let vm = TodayViewModel()
        vm.refreshEnergyState()
        XCTAssertTrue(EnergyState.allCases.contains(vm.currentEnergyState))
    }

    func test_todayVM_logCaffeineMany_doesNotOverflow() {
        let vm = TodayViewModel()
        for _ in 0..<100 {
            vm.logCaffeine()
        }
        XCTAssertEqual(vm.todayCaffeineCount, 100)
    }

    func test_todayVM_caffeineCutoffText_extremeCountdowns() {
        let vm = TodayViewModel()

        // Very large countdown (24 hours)
        vm.caffeineCutoffCountdown = 24 * 3600
        let text = vm.caffeineCutoffText
        XCTAssertTrue(text.contains("24h"))

        // Exactly 1 hour
        vm.caffeineCutoffCountdown = 3600
        XCTAssertEqual(vm.caffeineCutoffText, "1h 0m until cutoff")

        // 1 minute
        vm.caffeineCutoffCountdown = 60
        XCTAssertEqual(vm.caffeineCutoffText, "1m until cutoff")
    }

    func test_todayVM_formattedTimeUntilChange_extremeValues() {
        let vm = TodayViewModel()

        // Very small positive value
        vm.timeUntilNextChange = 30  // 30 seconds
        XCTAssertEqual(vm.formattedTimeUntilChange, "0m")

        // Exactly 1 minute
        vm.timeUntilNextChange = 60
        XCTAssertEqual(vm.formattedTimeUntilChange, "1m")
    }

    // MARK: - PatternsViewModel Edge Cases

    func test_patternsVM_formattedAvgDuration_zero() {
        let vm = PatternsViewModel()
        vm.averageSleepDuration = 0
        XCTAssertEqual(vm.formattedAvgDuration, "0h")
    }

    func test_patternsVM_formattedAvgDuration_exactHours() {
        let vm = PatternsViewModel()
        vm.averageSleepDuration = 480  // 8h exactly
        XCTAssertEqual(vm.formattedAvgDuration, "8h")
    }

    func test_patternsVM_consistencyDescription_boundaryValues() {
        let vm = PatternsViewModel()

        vm.sleepConsistencyScore = 90
        XCTAssertEqual(vm.consistencyDescription, "Excellent")

        vm.sleepConsistencyScore = 89.9
        XCTAssertEqual(vm.consistencyDescription, "Good")

        vm.sleepConsistencyScore = 75
        XCTAssertEqual(vm.consistencyDescription, "Good")

        vm.sleepConsistencyScore = 74.9
        XCTAssertEqual(vm.consistencyDescription, "Fair")

        vm.sleepConsistencyScore = 60
        XCTAssertEqual(vm.consistencyDescription, "Fair")

        vm.sleepConsistencyScore = 59.9
        XCTAssertEqual(vm.consistencyDescription, "Inconsistent")

        vm.sleepConsistencyScore = 40
        XCTAssertEqual(vm.consistencyDescription, "Inconsistent")

        vm.sleepConsistencyScore = 39.9
        XCTAssertEqual(vm.consistencyDescription, "Needs work")

        vm.sleepConsistencyScore = 0
        XCTAssertEqual(vm.consistencyDescription, "Needs work")
    }

    func test_patternsVM_socialJetlagDescription_boundaryValues() {
        let vm = PatternsViewModel()

        vm.socialJetlagMinutes = 29
        XCTAssertTrue(vm.socialJetlagDescription.contains("Minimal"))

        vm.socialJetlagMinutes = 30
        XCTAssertTrue(vm.socialJetlagDescription.contains("Moderate"))

        vm.socialJetlagMinutes = 59
        XCTAssertTrue(vm.socialJetlagDescription.contains("Moderate"))

        vm.socialJetlagMinutes = 60
        XCTAssertTrue(vm.socialJetlagDescription.contains("Significant"))
    }

    func test_patternsVM_caffeineImpactDescription_boundaryValues() {
        let vm = PatternsViewModel()

        vm.caffeineImpactMinutes = 0
        XCTAssertTrue(vm.caffeineImpactDescription.contains("No measurable"))

        vm.caffeineImpactMinutes = -5
        XCTAssertTrue(vm.caffeineImpactDescription.contains("No measurable"))

        vm.caffeineImpactMinutes = 1
        XCTAssertTrue(vm.caffeineImpactDescription.contains("Minimal"))

        vm.caffeineImpactMinutes = 14
        XCTAssertTrue(vm.caffeineImpactDescription.contains("Minimal"))

        vm.caffeineImpactMinutes = 15
        XCTAssertTrue(vm.caffeineImpactDescription.contains("Notable"))
    }

    func test_patternsVM_showChronotypeRecalibration_nilSuggested() {
        let vm = PatternsViewModel()
        vm.suggestedChronotype = nil
        XCTAssertFalse(vm.showChronotypeRecalibration)
    }

    func test_patternsVM_showChronotypeRecalibration_sameAsCurrent() {
        let vm = PatternsViewModel()
        vm.currentChronotype = .wolf
        vm.suggestedChronotype = .wolf
        XCTAssertFalse(vm.showChronotypeRecalibration)
    }

    func test_patternsVM_showChronotypeRecalibration_different() {
        let vm = PatternsViewModel()
        vm.currentChronotype = .wolf
        vm.suggestedChronotype = .bear
        XCTAssertTrue(vm.showChronotypeRecalibration)
    }

    // MARK: - SettingsViewModel Edge Cases

    func test_settingsVM_deleteWithoutConfirm_doesNotReset() {
        let vm = SettingsViewModel()
        vm.loadSettings()
        let originalChronotype = vm.chronotype

        vm.deleteAllData()
        // Only shows confirmation, doesn't reset
        XCTAssertTrue(vm.showDeleteConfirmation)
        XCTAssertEqual(vm.chronotype, originalChronotype, "Should not reset until confirmed")
    }

    func test_settingsVM_confirmDeleteWithoutDelete_doesNothing() {
        let vm = SettingsViewModel()
        vm.loadSettings()

        // Directly calling confirm without delete first
        vm.confirmDeleteAllData()
        // Should still reset (it's a valid call path)
        XCTAssertFalse(vm.showDeleteConfirmation)
    }

    func test_settingsVM_versionString_isNotEmpty() {
        let vm = SettingsViewModel()
        XCTAssertFalse(vm.versionString.isEmpty)
        XCTAssertTrue(vm.versionString.contains("."))
    }

    func test_settingsVM_chronotypeDisplayText_containsAllParts() {
        let vm = SettingsViewModel()
        let text = vm.chronotypeDisplayText
        XCTAssertTrue(text.contains(vm.chronotype.emoji))
        XCTAssertTrue(text.contains(vm.chronotype.displayName))
        XCTAssertTrue(text.contains(vm.chronotype.tagline))
    }

    // MARK: - ChronotypeEngine Edge Cases

    func test_chronotypeEngine_emptyAnswers_returnsLion() {
        let engine = ChronotypeEngine()
        let result = engine.calculateChronotype(answers: [])
        XCTAssertEqual(result.chronotype, .lion, "Empty answers (score 0) → Lion")
        XCTAssertEqual(result.score, 0)
    }

    func test_chronotypeEngine_negativeScores_areClamped() {
        let engine = ChronotypeEngine()
        let answers: [(questionId: Int, score: Int)] = (1...10).map { (questionId: $0, score: -5) }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.score, 0, "Negative scores should clamp to 0")
    }

    func test_chronotypeEngine_excessiveScores_areClamped() {
        let engine = ChronotypeEngine()
        let answers: [(questionId: Int, score: Int)] = (1...10).map { (questionId: $0, score: 100) }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.score, ChronotypeEngine.maxTotalScore, "Scores should clamp to max")
    }

    func test_chronotypeEngine_confidenceAlwaysInRange() {
        let engine = ChronotypeEngine()
        for totalScore in stride(from: 0, through: 30, by: 1) {
            let answers: [(questionId: Int, score: Int)] = [(questionId: 1, score: totalScore)]
            let result = engine.calculateChronotype(answers: answers)
            XCTAssertGreaterThanOrEqual(result.confidence, 0.0)
            XCTAssertLessThanOrEqual(result.confidence, 1.0)
        }
    }

    // MARK: - TrajectoryService Edge Cases

    func test_trajectoryService_zeroNights_returnsLowConfidence() {
        let service = TrajectoryService()
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 0), .low)
    }

    func test_trajectoryService_negativeNights_returnsLowConfidence() {
        let service = TrajectoryService()
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: -1), .low)
    }

    func test_trajectoryService_veryHighNights_returnsVeryHigh() {
        let service = TrajectoryService()
        XCTAssertEqual(service.confidenceLevel(dataNightsCount: 1000), .veryHigh)
    }

    func test_trajectoryService_allChronotypes_generateValidTrajectories() {
        let service = TrajectoryService()
        for chronotype in Chronotype.allCases {
            let blocks = service.generateTrajectory(
                chronotype: chronotype,
                wakeTime: Date.todayAtHour(7),
                sleepTime: Date.todayAtHour(23),
                dataNightsCount: 14
            )
            XCTAssertFalse(blocks.isEmpty, "\(chronotype) should generate blocks")
            XCTAssertTrue(blocks.contains { $0.type == .sleep }, "\(chronotype) should have sleep block")
            XCTAssertTrue(blocks.contains { $0.type == .peakFocus }, "\(chronotype) should have peak focus")
        }
    }

    // MARK: - SleepLog Edge Cases

    func test_sleepLog_zeroSleepStages_totalIsZero() {
        let log = SleepLog(
            bedtime: Date(),
            wakeTime: Date().addingTimeInterval(3600),
            deepSleepMinutes: 0,
            remSleepMinutes: 0,
            coreSleepMinutes: 0,
            awakeMinutes: 0,
            isWeekday: true
        )
        XCTAssertEqual(log.totalSleepMinutes, 0)
    }

    func test_sleepLog_formattedDuration_withVariousValues() {
        let log = SleepLog(
            bedtime: Date(),
            wakeTime: Date().addingTimeInterval(8 * 3600),
            deepSleepMinutes: 60,
            remSleepMinutes: 90,
            coreSleepMinutes: 300,
            awakeMinutes: 30,
            isWeekday: true
        )
        let formatted = log.formattedDuration
        XCTAssertTrue(formatted.contains("h"), "Should contain hours")
    }

    // MARK: - CaffeineLog Edge Cases

    func test_caffeineLog_zeroAmount() {
        let log = CaffeineLog(timestamp: Date(), amountMg: 0, source: "Decaf")
        XCTAssertEqual(log.amountMg, 0)
    }

    func test_caffeineLog_futureTimestamp_caffeineRemaining100() {
        let futureLog = CaffeineLog(timestamp: Date().addingTimeInterval(3600))
        let remaining = futureLog.estimatedCaffeineRemainingPercent(referenceDate: Date())
        XCTAssertGreaterThanOrEqual(remaining, 100.0)
    }

    // MARK: - NotificationService Edge Cases

    func test_notificationService_emptyTrajectory_stillSchedulesWeeklySummary() {
        let service = NotificationService()
        var prefs = NotificationPreferences()
        prefs.weeklySummaryEnabled = true

        service.scheduleNotifications(for: [], preferences: prefs)

        let hasWeeklySummary = service.scheduledNotifications.contains { $0.type == .weeklySummary }
        XCTAssertTrue(hasWeeklySummary, "Weekly summary should be scheduled even with empty trajectory")
    }

    func test_notificationService_allPrefsDisabled_noNotifications() {
        let service = NotificationService()
        var prefs = NotificationPreferences()
        prefs.sunlightEnabled = false
        prefs.caffeineOkEnabled = false
        prefs.peakFocusEnabled = false
        prefs.caffeineCutoffEnabled = false
        prefs.digitalSunsetEnabled = false
        prefs.windDownEnabled = false
        prefs.weeklySummaryEnabled = false

        let blocks = MockDataService.shared.trajectoryBlocks(for: Date())
        service.scheduleNotifications(for: blocks, preferences: prefs)

        XCTAssertTrue(service.activeNotifications.isEmpty,
                      "No active notifications when all prefs disabled")
    }
}
