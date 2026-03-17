import XCTest
@testable import SleepPath

final class OnboardingViewModelTests: XCTestCase {

    var viewModel: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        viewModel = OnboardingViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_currentStepIsWelcome() {
        XCTAssertEqual(viewModel.currentStep, .welcome)
    }

    func test_initialState_currentQuestionIndexIsZero() {
        XCTAssertEqual(viewModel.currentQuestionIndex, 0)
    }

    func test_initialState_isQuizCompleteIsFalse() {
        XCTAssertFalse(viewModel.isQuizComplete)
    }

    func test_initialState_answersIsEmpty() {
        XCTAssertTrue(viewModel.answers.isEmpty)
    }

    func test_initialState_showResultIsFalse() {
        XCTAssertFalse(viewModel.showResult)
    }

    func test_initialState_chronotypeResultIsNil() {
        XCTAssertNil(viewModel.chronotypeResult)
    }

    func test_initialState_isOnboardingCompleteIsFalse() {
        XCTAssertFalse(viewModel.isOnboardingComplete)
    }

    func test_initialState_healthKitConnectedIsFalse() {
        XCTAssertFalse(viewModel.healthKitConnected)
    }

    func test_initialState_notificationsEnabledIsFalse() {
        XCTAssertFalse(viewModel.notificationsEnabled)
    }

    func test_initialState_progressIsZero() {
        XCTAssertEqual(viewModel.progress, 0.0)
    }

    // MARK: - Question Progression

    func test_answerQuestion_advancesToNextQuestion() {
        viewModel.answerQuestion(optionScore: 1)
        XCTAssertEqual(viewModel.currentQuestionIndex, 1)
    }

    func test_answerQuestion_recordsAnswer() {
        viewModel.answerQuestion(optionScore: 2)
        XCTAssertEqual(viewModel.answers.count, 1)
        XCTAssertEqual(viewModel.answers[0].score, 2)
    }

    func test_answerQuestion_secondQuestion_advancesIndex() {
        viewModel.answerQuestion(optionScore: 1)
        viewModel.answerQuestion(optionScore: 2)
        XCTAssertEqual(viewModel.currentQuestionIndex, 2)
        XCTAssertEqual(viewModel.answers.count, 2)
    }

    func test_answerQuestion_recordsCorrectQuestionId() {
        viewModel.answerQuestion(optionScore: 1)
        XCTAssertEqual(viewModel.answers[0].questionId, 1) // Questions are 1-indexed
    }

    // MARK: - Going Back

    func test_goBack_decreasesQuestionIndex() {
        viewModel.answerQuestion(optionScore: 1) // Go to question 2
        viewModel.goBack()
        XCTAssertEqual(viewModel.currentQuestionIndex, 0)
    }

    func test_goBack_onFirstQuestion_doesNothing() {
        viewModel.goBack()
        XCTAssertEqual(viewModel.currentQuestionIndex, 0)
    }

    func test_goBack_preservesExistingAnswers() {
        viewModel.answerQuestion(optionScore: 1)
        viewModel.answerQuestion(optionScore: 2)
        viewModel.goBack()
        XCTAssertEqual(viewModel.answers.count, 2, "Going back should not remove answers")
    }

    func test_goBack_multipleSteps_worksCorrectly() {
        viewModel.answerQuestion(optionScore: 0)
        viewModel.answerQuestion(optionScore: 1)
        viewModel.answerQuestion(optionScore: 2)
        viewModel.goBack()
        viewModel.goBack()
        XCTAssertEqual(viewModel.currentQuestionIndex, 1)
    }

    // MARK: - Re-answering After Going Back

    func test_answerQuestion_afterGoingBack_replacesExistingAnswer() {
        viewModel.answerQuestion(optionScore: 1) // Answer Q1 with 1
        viewModel.goBack()
        viewModel.answerQuestion(optionScore: 3) // Re-answer Q1 with 3
        XCTAssertEqual(viewModel.answers.count, 1, "Should replace, not add")
        XCTAssertEqual(viewModel.answers[0].score, 3, "Score should be updated")
    }

    // MARK: - Quiz Completion

    func test_answerAllQuestions_completesQuiz() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertTrue(viewModel.isQuizComplete)
    }

    func test_answerAllQuestions_setsShowResult() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertTrue(viewModel.showResult)
    }

    func test_answerAllQuestions_setsChronotypeResult() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertNotNil(viewModel.chronotypeResult)
    }

    func test_answerAllQuestions_allLow_producesLion() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 0)
        }
        XCTAssertEqual(viewModel.chronotypeResult?.chronotype, .lion)
    }

    func test_answerAllQuestions_allOnes_producesBear() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertEqual(viewModel.chronotypeResult?.chronotype, .bear)
    }

    func test_answerAllQuestions_allTwos_producesWolf() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 2)
        }
        XCTAssertEqual(viewModel.chronotypeResult?.chronotype, .wolf)
    }

    func test_answerAllQuestions_has10Answers() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertEqual(viewModel.answers.count, 10)
    }

    func test_answerAllQuestions_lastQuestionDoesNotAdvanceIndex() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertEqual(viewModel.currentQuestionIndex, 9, "Should stay at last question index")
    }

    // MARK: - Calculate Result

    func test_calculateResult_setsChronotypeResult() {
        // Manually set up answers
        for i in 0..<10 {
            viewModel.answers.append((questionId: i + 1, score: 2))
        }
        viewModel.calculateResult()
        XCTAssertNotNil(viewModel.chronotypeResult)
        XCTAssertTrue(viewModel.showResult)
    }

    func test_calculateResult_resultHasScore() {
        for i in 0..<10 {
            viewModel.answers.append((questionId: i + 1, score: 1))
        }
        viewModel.calculateResult()
        XCTAssertEqual(viewModel.chronotypeResult?.score, 10)
    }

    func test_calculateResult_resultHasConfidence() {
        for i in 0..<10 {
            viewModel.answers.append((questionId: i + 1, score: 1))
        }
        viewModel.calculateResult()
        XCTAssertNotNil(viewModel.chronotypeResult?.confidence)
        XCTAssertGreaterThan(viewModel.chronotypeResult!.confidence, 0)
    }

    // MARK: - Step Progression

    func test_proceedToNextStep_fromWelcome_goesToQuiz() {
        viewModel.proceedToNextStep()
        XCTAssertEqual(viewModel.currentStep, .quiz)
    }

    func test_proceedToNextStep_fromQuiz_goesToResult() {
        viewModel.currentStep = .quiz
        viewModel.proceedToNextStep()
        XCTAssertEqual(viewModel.currentStep, .result)
    }

    func test_proceedToNextStep_fromResult_goesToHealthKit() {
        viewModel.currentStep = .result
        viewModel.proceedToNextStep()
        XCTAssertEqual(viewModel.currentStep, .healthKit)
    }

    func test_proceedToNextStep_fromHealthKit_goesToNotifications() {
        viewModel.currentStep = .healthKit
        viewModel.proceedToNextStep()
        XCTAssertEqual(viewModel.currentStep, .notifications)
    }

    func test_proceedToNextStep_fromNotifications_goesToComplete() {
        viewModel.currentStep = .notifications
        viewModel.proceedToNextStep()
        XCTAssertEqual(viewModel.currentStep, .complete)
    }

    func test_proceedToNextStep_fromComplete_staysComplete() {
        viewModel.currentStep = .complete
        viewModel.proceedToNextStep()
        XCTAssertEqual(viewModel.currentStep, .complete)
        XCTAssertTrue(viewModel.isOnboardingComplete)
    }

    // MARK: - HealthKit Actions

    func test_connectHealthKit_setsConnectedTrue() {
        viewModel.currentStep = .healthKit
        viewModel.connectHealthKit()
        XCTAssertTrue(viewModel.healthKitConnected)
    }

    func test_connectHealthKit_advancesStep() {
        viewModel.currentStep = .healthKit
        viewModel.connectHealthKit()
        XCTAssertEqual(viewModel.currentStep, .notifications)
    }

    func test_skipHealthKit_setsConnectedFalse() {
        viewModel.currentStep = .healthKit
        viewModel.skipHealthKit()
        XCTAssertFalse(viewModel.healthKitConnected)
    }

    func test_skipHealthKit_advancesStep() {
        viewModel.currentStep = .healthKit
        viewModel.skipHealthKit()
        XCTAssertEqual(viewModel.currentStep, .notifications)
    }

    // MARK: - Notification Actions

    func test_enableNotifications_setsEnabledTrue() {
        viewModel.currentStep = .notifications
        viewModel.enableNotifications()
        XCTAssertTrue(viewModel.notificationsEnabled)
    }

    func test_enableNotifications_advancesStep() {
        viewModel.currentStep = .notifications
        viewModel.enableNotifications()
        XCTAssertEqual(viewModel.currentStep, .complete)
    }

    func test_skipNotifications_setsEnabledFalse() {
        viewModel.currentStep = .notifications
        viewModel.skipNotifications()
        XCTAssertFalse(viewModel.notificationsEnabled)
    }

    func test_skipNotifications_advancesStep() {
        viewModel.currentStep = .notifications
        viewModel.skipNotifications()
        XCTAssertEqual(viewModel.currentStep, .complete)
    }

    // MARK: - Complete Onboarding

    func test_completeOnboarding_setsStepToComplete() {
        viewModel.completeOnboarding()
        XCTAssertEqual(viewModel.currentStep, .complete)
    }

    func test_completeOnboarding_setsIsOnboardingCompleteTrue() {
        viewModel.completeOnboarding()
        XCTAssertTrue(viewModel.isOnboardingComplete)
    }

    // MARK: - Progress Calculation

    func test_progress_afterZeroAnswers_returnsZero() {
        XCTAssertEqual(viewModel.progress, 0.0, accuracy: 0.001)
    }

    func test_progress_afterOneAnswer_returns01() {
        viewModel.answerQuestion(optionScore: 1)
        XCTAssertEqual(viewModel.progress, 0.1, accuracy: 0.001)
    }

    func test_progress_afterFiveAnswers_returns05() {
        for _ in 0..<5 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.001)
    }

    func test_progress_afterAllAnswers_returns10() {
        for _ in 0..<10 {
            viewModel.answerQuestion(optionScore: 1)
        }
        XCTAssertEqual(viewModel.progress, 1.0, accuracy: 0.001)
    }

    // MARK: - Can Go Back

    func test_canGoBack_onFirstQuestion_returnsFalse() {
        XCTAssertFalse(viewModel.canGoBack)
    }

    func test_canGoBack_onSecondQuestion_returnsTrue() {
        viewModel.answerQuestion(optionScore: 1)
        XCTAssertTrue(viewModel.canGoBack)
    }

    func test_canGoBack_afterGoingBackToFirst_returnsFalse() {
        viewModel.answerQuestion(optionScore: 1)
        viewModel.goBack()
        XCTAssertFalse(viewModel.canGoBack)
    }

    // MARK: - Total Questions

    func test_totalQuestions_isTen() {
        XCTAssertEqual(viewModel.totalQuestions, 10)
    }

    // MARK: - Current Question

    func test_currentQuestion_initiallyIsFirstQuestion() {
        XCTAssertEqual(viewModel.currentQuestion.id, 1)
    }

    func test_currentQuestion_afterAnswer_isSecondQuestion() {
        viewModel.answerQuestion(optionScore: 1)
        XCTAssertEqual(viewModel.currentQuestion.id, 2)
    }
}
