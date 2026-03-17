import Foundation

/// Manages the chronotype quiz and onboarding flow state.
///
/// Drives the user through a multi-step onboarding sequence: welcome screen,
/// chronotype quiz, result reveal, optional HealthKit connection, optional
/// notification permissions, and completion. Uses `ChronotypeEngine` to
/// calculate the chronotype result from quiz answers.
@Observable
final class OnboardingViewModel {

    // MARK: - Onboarding Step

    /// The discrete steps of the onboarding flow.
    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case quiz
        case result
        case healthKit
        case notifications
        case complete
    }

    // MARK: - Quiz State

    /// Index of the currently displayed quiz question.
    var currentQuestionIndex: Int = 0

    /// Collected quiz answers as (questionId, score) pairs.
    var answers: [(questionId: Int, score: Int)] = []

    /// Whether all quiz questions have been answered.
    var isQuizComplete: Bool = false

    /// Whether the result screen should be displayed.
    var showResult: Bool = false

    // MARK: - Onboarding State

    /// The current step in the onboarding flow.
    var currentStep: OnboardingStep = .welcome

    /// Whether the user chose to connect HealthKit.
    var healthKitConnected: Bool = false

    /// Whether the user chose to enable notifications.
    var notificationsEnabled: Bool = false

    /// Whether the entire onboarding process is finished.
    var isOnboardingComplete: Bool = false

    // MARK: - Result

    /// The calculated chronotype result, set after the quiz is completed.
    var chronotypeResult: ChronotypeResult?

    // MARK: - Services

    private let chronotypeEngine = ChronotypeEngine()

    // MARK: - Computed Properties

    /// The list of all quiz questions.
    private var questions: [QuizQuestion] {
        QuizQuestion.allQuestions
    }

    /// The question currently being displayed.
    var currentQuestion: QuizQuestion {
        let index = min(currentQuestionIndex, questions.count - 1)
        return questions[index]
    }

    /// Progress through the quiz as a fraction from 0.0 to 1.0.
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(answers.count) / Double(totalQuestions)
    }

    /// Total number of quiz questions.
    var totalQuestions: Int {
        questions.count
    }

    /// Whether the user can navigate back to a previous question.
    var canGoBack: Bool {
        currentQuestionIndex > 0
    }

    // MARK: - Quiz Actions

    /// Records an answer for the current question and advances to the next.
    ///
    /// If the current question was previously answered (via back-navigation),
    /// the old answer is replaced. When all questions are answered the quiz
    /// is marked complete and the result is calculated automatically.
    ///
    /// - Parameter optionScore: The score value of the selected option.
    func answerQuestion(optionScore: Int) {
        let questionId = currentQuestion.id

        // Replace existing answer for this question if re-answering after going back.
        if let existingIndex = answers.firstIndex(where: { $0.questionId == questionId }) {
            answers[existingIndex] = (questionId: questionId, score: optionScore)
        } else {
            answers.append((questionId: questionId, score: optionScore))
        }

        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            isQuizComplete = true
            calculateResult()
        }
    }

    /// Navigates back to the previous quiz question.
    func goBack() {
        guard canGoBack else { return }
        currentQuestionIndex -= 1
    }

    /// Calculates the chronotype from collected answers using `ChronotypeEngine`.
    func calculateResult() {
        chronotypeResult = chronotypeEngine.calculateChronotype(answers: answers)
        showResult = true
    }

    // MARK: - Onboarding Navigation

    /// Advances to the next onboarding step in sequence.
    func proceedToNextStep() {
        guard let nextStepRaw = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }
        currentStep = nextStepRaw
    }

    /// Skips the HealthKit connection step and proceeds.
    func skipHealthKit() {
        healthKitConnected = false
        proceedToNextStep()
    }

    /// Simulates connecting HealthKit (mock) and proceeds.
    func connectHealthKit() {
        healthKitConnected = true
        proceedToNextStep()
    }

    /// Skips the notifications step and proceeds.
    func skipNotifications() {
        notificationsEnabled = false
        proceedToNextStep()
    }

    /// Simulates enabling notifications (mock) and proceeds.
    func enableNotifications() {
        notificationsEnabled = true
        proceedToNextStep()
    }

    /// Marks onboarding as fully complete.
    func completeOnboarding() {
        currentStep = .complete
        isOnboardingComplete = true
    }
}
