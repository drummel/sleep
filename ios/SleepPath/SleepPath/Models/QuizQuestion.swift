import Foundation

struct QuizQuestion: Identifiable {
    let id: Int
    let text: String
    let options: [QuizOption]
}

struct QuizOption: Identifiable {
    let id: Int
    let text: String
    let score: Int
}

// MARK: - Quiz Data

extension QuizQuestion {

    /// All 10 chronotype quiz questions. Option scores range from 0 (morning-type) to 3 (evening-type).
    static let allQuestions: [QuizQuestion] = [
        QuizQuestion(
            id: 1,
            text: "What time would you naturally wake up if you had nothing planned?",
            options: [
                QuizOption(id: 0, text: "Before 6:00 AM", score: 0),
                QuizOption(id: 1, text: "6:00 - 7:30 AM", score: 1),
                QuizOption(id: 2, text: "7:30 - 9:00 AM", score: 2),
                QuizOption(id: 3, text: "After 9:00 AM", score: 3),
            ]
        ),
        QuizQuestion(
            id: 2,
            text: "What time would you naturally fall asleep if you had no obligations the next day?",
            options: [
                QuizOption(id: 0, text: "Before 9:00 PM", score: 0),
                QuizOption(id: 1, text: "9:00 - 10:30 PM", score: 1),
                QuizOption(id: 2, text: "10:30 PM - 12:00 AM", score: 2),
                QuizOption(id: 3, text: "After 12:00 AM", score: 3),
            ]
        ),
        QuizQuestion(
            id: 3,
            text: "How do you feel when you have to wake up at 6:00 AM?",
            options: [
                QuizOption(id: 0, text: "Wide awake and ready to go", score: 0),
                QuizOption(id: 1, text: "Fine after a few minutes", score: 1),
                QuizOption(id: 2, text: "Groggy but functional", score: 2),
                QuizOption(id: 3, text: "Miserable \u{2014} I can barely function", score: 3),
            ]
        ),
        QuizQuestion(
            id: 4,
            text: "When do you feel your peak mental energy during the day?",
            options: [
                QuizOption(id: 0, text: "Early morning (6 - 9 AM)", score: 0),
                QuizOption(id: 1, text: "Late morning (9 AM - 12 PM)", score: 1),
                QuizOption(id: 2, text: "Afternoon (12 - 5 PM)", score: 2),
                QuizOption(id: 3, text: "Evening or night (after 5 PM)", score: 3),
            ]
        ),
        QuizQuestion(
            id: 5,
            text: "If you had an important exam or presentation, when would you prefer to schedule it?",
            options: [
                QuizOption(id: 0, text: "First thing in the morning", score: 0),
                QuizOption(id: 1, text: "Late morning", score: 1),
                QuizOption(id: 2, text: "Early afternoon", score: 2),
                QuizOption(id: 3, text: "Late afternoon or evening", score: 3),
            ]
        ),
        QuizQuestion(
            id: 6,
            text: "How would you describe your appetite in the first hour after waking?",
            options: [
                QuizOption(id: 0, text: "Very hungry \u{2014} I need breakfast immediately", score: 0),
                QuizOption(id: 1, text: "Moderately hungry", score: 1),
                QuizOption(id: 2, text: "Not very hungry \u{2014} I can wait a while", score: 2),
                QuizOption(id: 3, text: "No appetite at all until later", score: 3),
            ]
        ),
        QuizQuestion(
            id: 7,
            text: "How easily do you fall asleep at night?",
            options: [
                QuizOption(id: 0, text: "I'm out within minutes", score: 0),
                QuizOption(id: 1, text: "Usually within 15 minutes", score: 1),
                QuizOption(id: 2, text: "It takes me a while to wind down", score: 2),
                QuizOption(id: 3, text: "I often lie awake for a long time", score: 3),
            ]
        ),
        QuizQuestion(
            id: 8,
            text: "How do you feel about your sleep quality in general?",
            options: [
                QuizOption(id: 0, text: "I sleep deeply and wake refreshed", score: 0),
                QuizOption(id: 1, text: "Generally good with occasional off nights", score: 1),
                QuizOption(id: 2, text: "Inconsistent \u{2014} some nights great, others not", score: 2),
                QuizOption(id: 3, text: "I'm a light sleeper and wake up often", score: 3),
            ]
        ),
        QuizQuestion(
            id: 9,
            text: "If you could structure your ideal workday, when would you start?",
            options: [
                QuizOption(id: 0, text: "6:00 - 7:00 AM", score: 0),
                QuizOption(id: 1, text: "8:00 - 9:00 AM", score: 1),
                QuizOption(id: 2, text: "10:00 - 11:00 AM", score: 2),
                QuizOption(id: 3, text: "After 11:00 AM", score: 3),
            ]
        ),
        QuizQuestion(
            id: 10,
            text: "How often do you use an alarm clock to wake up on workdays?",
            options: [
                QuizOption(id: 0, text: "Never \u{2014} I wake up naturally before it", score: 0),
                QuizOption(id: 1, text: "I set one but often wake before it", score: 1),
                QuizOption(id: 2, text: "I rely on it and hit snooze occasionally", score: 2),
                QuizOption(id: 3, text: "I need multiple alarms to get up", score: 3),
            ]
        ),
    ]

    /// Determines a chronotype from the total quiz score (sum of all option scores, 0-30).
    static func chronotype(forScore score: Int) -> Chronotype {
        switch score {
        case 0...7:
            return .lion
        case 8...14:
            return .bear
        case 15...21:
            return .wolf
        case 22...30:
            return .dolphin
        default:
            return .bear
        }
    }

    /// Calculates confidence level based on answer consistency (0.0 to 1.0).
    static func confidence(forAnswers answers: [Int]) -> Double {
        guard !answers.isEmpty else { return 0 }
        let mean = Double(answers.reduce(0, +)) / Double(answers.count)
        let variance = answers.reduce(0.0) { $0 + pow(Double($1) - mean, 2) } / Double(answers.count)
        // Lower variance = higher confidence. Max variance for 0-3 range is ~2.25.
        let normalizedVariance = min(variance / 2.25, 1.0)
        return 1.0 - normalizedVariance
    }
}
