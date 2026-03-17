import SwiftUI

// MARK: - Quiz View

struct QuizView: View {
    @Binding var currentQuestionIndex: Int
    @Binding var answers: [Int: Int]
    var onComplete: () -> Void
    var onBack: (() -> Void)?

    private let questions = QuizQuestion.allQuestions

    @State private var selectedOptionID: Int?
    @State private var isTransitioning = false
    @State private var transitionDirection: TransitionDirection = .forward

    private enum TransitionDirection {
        case forward, backward
    }

    private var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }

    private var progress: CGFloat {
        CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count)
    }

    var body: some View {
        ZStack {
            SleepTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                quizHeader
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                Spacer().frame(height: 32)

                questionContent
                    .id(currentQuestion.id)
                    .transition(questionTransition)
                    .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    // MARK: - Header

    private var quizHeader: some View {
        VStack(spacing: 16) {
            HStack {
                if currentQuestionIndex > 0 {
                    Button {
                        goBack()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(SleepTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                } else if let onBack {
                    Button {
                        onBack()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(SleepTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(SleepTheme.textTertiary)
            }

            ProgressBarView(progress: progress)
        }
    }

    // MARK: - Question Content

    private var questionContent: some View {
        VStack(spacing: 28) {
            Text(currentQuestion.text)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(SleepTheme.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(4)

            VStack(spacing: 12) {
                ForEach(currentQuestion.options) { option in
                    OptionCard(
                        option: option,
                        isSelected: selectedOptionID == option.id,
                        action: { selectOption(option) }
                    )
                }
            }
        }
    }

    private var questionTransition: AnyTransition {
        switch transitionDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }

    // MARK: - Actions

    private func selectOption(_ option: QuizOption) {
        guard !isTransitioning else { return }

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        selectedOptionID = option.id
        answers[currentQuestion.id] = option.score

        isTransitioning = true

        // Auto-advance after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            advanceToNext()
        }
    }

    private func advanceToNext() {
        transitionDirection = .forward

        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentQuestionIndex += 1
            }
            selectedOptionID = nil
        } else {
            onComplete()
        }

        isTransitioning = false
    }

    private func goBack() {
        guard currentQuestionIndex > 0, !isTransitioning else { return }

        transitionDirection = .backward

        withAnimation(.easeInOut(duration: 0.35)) {
            currentQuestionIndex -= 1
        }

        // Restore previous selection
        if let previousAnswer = answers[questions[currentQuestionIndex].id] {
            let question = questions[currentQuestionIndex]
            selectedOptionID = question.options.first { $0.score == previousAnswer }?.id
        } else {
            selectedOptionID = nil
        }
    }
}

// MARK: - Progress Bar

private struct ProgressBarView: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(SleepTheme.cardBackground)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(SleepTheme.amberGradient)
                    .frame(width: geometry.size.width * progress, height: 6)
                    .animation(.easeInOut(duration: 0.35), value: progress)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Option Card

private struct OptionCard: View {
    let option: QuizOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(option.text)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .black : SleepTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.black.opacity(0.6))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? SleepTheme.amber : SleepTheme.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.clear : SleepTheme.cardBackgroundLight,
                        lineWidth: 1
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    QuizView(
        currentQuestionIndex: .constant(2),
        answers: .constant([:]),
        onComplete: {},
        onBack: {}
    )
}
