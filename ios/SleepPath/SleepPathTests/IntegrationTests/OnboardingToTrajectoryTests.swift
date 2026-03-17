import XCTest
@testable import SleepPath

/// Integration tests verifying that the onboarding quiz result correctly flows
/// into trajectory generation and the Today view model.
final class OnboardingToTrajectoryTests: XCTestCase {

    // MARK: - Quiz → Chronotype → Trajectory Flow

    func test_quizAllZeros_producesLion_andGeneratesTrajectory() {
        let onboarding = OnboardingViewModel()
        let trajectoryService = TrajectoryService()

        // Answer all questions with score 0 → Lion
        for _ in 0..<onboarding.totalQuestions {
            onboarding.answerQuestion(optionScore: 0)
        }

        XCTAssertTrue(onboarding.isQuizComplete)
        XCTAssertNotNil(onboarding.chronotypeResult)
        XCTAssertEqual(onboarding.chronotypeResult?.chronotype, .lion)

        // Use the resulting chronotype to generate a trajectory
        let blocks = trajectoryService.generateTrajectory(
            chronotype: onboarding.chronotypeResult!.chronotype,
            wakeTime: Date.todayAtHour(6),
            sleepTime: Date.todayAtHour(22),
            dataNightsCount: 0
        )

        XCTAssertFalse(blocks.isEmpty, "Lion trajectory should have blocks")
        XCTAssertTrue(blocks.contains { $0.type == .peakFocus })
        XCTAssertTrue(blocks.contains { $0.type == .sleep })
    }

    func test_quizAllTwos_producesWolf_andGeneratesTrajectory() {
        let onboarding = OnboardingViewModel()
        let trajectoryService = TrajectoryService()

        for _ in 0..<onboarding.totalQuestions {
            onboarding.answerQuestion(optionScore: 2)
        }

        XCTAssertEqual(onboarding.chronotypeResult?.chronotype, .wolf)

        let blocks = trajectoryService.generateTrajectory(
            chronotype: .wolf,
            wakeTime: Date.todayAtHour(9),
            sleepTime: Date.todayAtHour(0),
            dataNightsCount: 0
        )

        XCTAssertFalse(blocks.isEmpty)
        // Wolf should have evening peak focus
        let peakBlock = blocks.first { $0.type == .peakFocus }
        XCTAssertNotNil(peakBlock)
    }

    func test_quizAllOnes_producesBear_andGeneratesTrajectory() {
        let onboarding = OnboardingViewModel()
        let trajectoryService = TrajectoryService()

        for _ in 0..<onboarding.totalQuestions {
            onboarding.answerQuestion(optionScore: 1)
        }

        XCTAssertEqual(onboarding.chronotypeResult?.chronotype, .bear)

        let blocks = trajectoryService.generateTrajectory(
            chronotype: .bear,
            wakeTime: Date.todayAtHour(7),
            sleepTime: Date.todayAtHour(23),
            dataNightsCount: 0
        )

        XCTAssertFalse(blocks.isEmpty)
        XCTAssertTrue(blocks.contains { $0.type == .caffeineCutoff })
    }

    // MARK: - Full Onboarding Flow → TodayViewModel

    func test_fullOnboardingFlow_feedsIntoTodayViewModel() {
        let onboarding = OnboardingViewModel()

        // Step 1: Welcome → Quiz
        onboarding.currentStep = .quiz

        // Step 2: Answer all quiz questions
        for _ in 0..<onboarding.totalQuestions {
            onboarding.answerQuestion(optionScore: 2)
        }
        XCTAssertTrue(onboarding.isQuizComplete)
        XCTAssertNotNil(onboarding.chronotypeResult)

        // Step 3: Result → HealthKit
        onboarding.proceedToNextStep() // result → healthKit
        XCTAssertEqual(onboarding.currentStep, .healthKit)

        // Step 4: Skip HealthKit
        onboarding.skipHealthKit()
        XCTAssertEqual(onboarding.currentStep, .notifications)
        XCTAssertFalse(onboarding.healthKitConnected)

        // Step 5: Enable notifications
        onboarding.enableNotifications()
        XCTAssertEqual(onboarding.currentStep, .complete)
        XCTAssertTrue(onboarding.isOnboardingComplete)
        XCTAssertTrue(onboarding.notificationsEnabled)

        // Step 6: Now the app would load TodayViewModel
        let todayVM = TodayViewModel()
        todayVM.loadToday()

        XCTAssertFalse(todayVM.trajectoryBlocks.isEmpty, "Today should load trajectory after onboarding")
        XCTAssertTrue(EnergyState.allCases.contains(todayVM.currentEnergyState))
    }

    // MARK: - Onboarding Skip Path

    func test_alreadyTookQuiz_skipPath_reachesComplete() {
        let onboarding = OnboardingViewModel()

        // "I already took the quiz" → goes to healthKit step
        onboarding.currentStep = .healthKit

        // Connect HealthKit
        onboarding.connectHealthKit()
        XCTAssertTrue(onboarding.healthKitConnected)
        XCTAssertEqual(onboarding.currentStep, .notifications)

        // Skip notifications
        onboarding.skipNotifications()
        XCTAssertEqual(onboarding.currentStep, .complete)
        XCTAssertTrue(onboarding.isOnboardingComplete)
    }

    // MARK: - Chronotype Result Metadata Flows to UI

    func test_chronotypeResult_hasAllFieldsNeededForResultScreen() {
        let onboarding = OnboardingViewModel()

        for _ in 0..<onboarding.totalQuestions {
            onboarding.answerQuestion(optionScore: 1)
        }

        let result = onboarding.chronotypeResult
        XCTAssertNotNil(result)
        XCTAssertFalse(result!.peakCreativeHours.isEmpty)
        XCTAssertFalse(result!.idealCaffeineCutoff.isEmpty)
        XCTAssertFalse(result!.optimalWakeTime.isEmpty)
        XCTAssertGreaterThan(result!.confidence, 0)
        XCTAssertLessThanOrEqual(result!.confidence, 1.0)
    }

    // MARK: - Confidence Grows with Data

    func test_confidenceIncreasesAsDataAccumulates() {
        let trajectoryService = TrajectoryService()

        let lowConf = trajectoryService.confidenceLevel(dataNightsCount: 0)
        let midConf = trajectoryService.confidenceLevel(dataNightsCount: 10)
        let highConf = trajectoryService.confidenceLevel(dataNightsCount: 30)

        XCTAssertLessThan(lowConf.rawValue, midConf.rawValue)
        XCTAssertLessThan(midConf.rawValue, highConf.rawValue)
    }
}
