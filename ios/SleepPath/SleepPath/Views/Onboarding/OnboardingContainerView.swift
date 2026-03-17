import SwiftUI

// MARK: - Onboarding Container View

struct OnboardingContainerView: View {
    var onComplete: () -> Void

    @State private var viewModel = OnboardingViewModel()
    @State private var quizCurrentQuestionIndex: Int = 0
    @State private var quizAnswers: [Int: Int] = [:]

    var body: some View {
        ZStack {
            SleepTheme.background.ignoresSafeArea()

            Group {
                switch viewModel.currentStep {
                case .welcome:
                    welcomeStep

                case .quiz:
                    quizStep

                case .result:
                    quizResultStep

                case .healthKit:
                    healthKitStep

                case .notifications:
                    notificationsStep

                case .complete:
                    Color.clear
                        .onAppear {
                            onComplete()
                        }
                }
            }
            .transition(stepTransition)
        }
    }

    // MARK: - Step Views

    private var welcomeStep: some View {
        WelcomeView(
            onGetStarted: {
                withAnimation(.easeInOut(duration: 0.4)) {
                    viewModel.currentStep = .quiz
                }
            },
            onAlreadyTookQuiz: {
                withAnimation(.easeInOut(duration: 0.4)) {
                    viewModel.currentStep = .healthKit
                }
            }
        )
    }

    private var quizStep: some View {
        QuizView(
            currentQuestionIndex: $quizCurrentQuestionIndex,
            answers: $quizAnswers,
            onComplete: {
                // Convert quiz answers to the format expected by the canonical view model
                let answerTuples: [(questionId: Int, score: Int)] = quizAnswers.map { (questionId: $0.key, score: $0.value) }
                viewModel.answers = answerTuples
                viewModel.isQuizComplete = true
                viewModel.calculateResult()
                withAnimation(.easeInOut(duration: 0.4)) {
                    viewModel.currentStep = .result
                }
            },
            onBack: {
                withAnimation(.easeInOut(duration: 0.4)) {
                    viewModel.currentStep = .welcome
                }
            }
        )
    }

    private var quizResultStep: some View {
        QuizResultView(
            chronotype: viewModel.chronotypeResult?.chronotype ?? .bear,
            onContinue: {
                withAnimation(.easeInOut(duration: 0.4)) {
                    viewModel.currentStep = .healthKit
                }
            },
            onShare: {
                shareChronotype()
            }
        )
    }

    private var healthKitStep: some View {
        HealthKitPermissionView(
            onConnect: {
                viewModel.connectHealthKit()
            },
            onSkip: {
                viewModel.skipHealthKit()
            }
        )
    }

    private var notificationsStep: some View {
        NotificationPermissionView(
            onAllow: {
                viewModel.enableNotifications()
            },
            onSkip: {
                viewModel.skipNotifications()
            }
        )
    }

    // MARK: - Transition

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    // MARK: - Sharing

    private func shareChronotype() {
        guard let result = viewModel.chronotypeResult else { return }
        let type = result.chronotype
        let text = "I'm a \(type.emoji) \(type.displayName) chronotype \u{2014} \(type.tagline)! Find yours with SleepPath."

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        // iPad popover support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(
                x: rootVC.view.bounds.midX,
                y: rootVC.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        rootVC.present(activityVC, animated: true)
    }
}

// MARK: - Preview

#Preview {
    OnboardingContainerView(onComplete: {})
}
