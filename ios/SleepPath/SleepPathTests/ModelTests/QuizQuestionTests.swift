import XCTest
@testable import SleepPath

final class QuizQuestionTests: XCTestCase {

    // MARK: - Question Count

    func test_allQuestions_hasExactly10Questions() {
        XCTAssertEqual(QuizQuestion.allQuestions.count, 10)
    }

    // MARK: - Question Text

    func test_allQuestions_haveNonEmptyText() {
        for question in QuizQuestion.allQuestions {
            XCTAssertFalse(
                question.text.isEmpty,
                "Question \(question.id) should have non-empty text"
            )
        }
    }

    func test_allQuestions_textEndsWithQuestionMark() {
        for question in QuizQuestion.allQuestions {
            XCTAssertTrue(
                question.text.hasSuffix("?"),
                "Question \(question.id) text should end with a question mark"
            )
        }
    }

    // MARK: - Options Count

    func test_allQuestions_haveExactly4Options() {
        for question in QuizQuestion.allQuestions {
            XCTAssertEqual(
                question.options.count, 4,
                "Question \(question.id) should have exactly 4 options, found \(question.options.count)"
            )
        }
    }

    // MARK: - Option Text

    func test_allOptions_haveNonEmptyText() {
        for question in QuizQuestion.allQuestions {
            for option in question.options {
                XCTAssertFalse(
                    option.text.isEmpty,
                    "Question \(question.id), Option \(option.id) should have non-empty text"
                )
            }
        }
    }

    // MARK: - Option Scores

    func test_allOptions_haveScoresFrom0To3() {
        for question in QuizQuestion.allQuestions {
            for option in question.options {
                XCTAssertTrue(
                    (0...3).contains(option.score),
                    "Question \(question.id), Option \(option.id) score \(option.score) should be 0-3"
                )
            }
        }
    }

    func test_allQuestions_optionScoresCover0Through3() {
        for question in QuizQuestion.allQuestions {
            let scores = Set(question.options.map(\.score))
            XCTAssertEqual(
                scores, Set([0, 1, 2, 3]),
                "Question \(question.id) should have options scoring 0, 1, 2, and 3"
            )
        }
    }

    // MARK: - Question IDs

    func test_questionIDs_areUnique() {
        let ids = QuizQuestion.allQuestions.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "All question IDs should be unique")
    }

    func test_questionIDs_are1Through10() {
        let ids = Set(QuizQuestion.allQuestions.map(\.id))
        let expected = Set(1...10)
        XCTAssertEqual(ids, expected, "Question IDs should be 1 through 10")
    }

    // MARK: - Option IDs

    func test_optionIDs_withinEachQuestion_areUnique() {
        for question in QuizQuestion.allQuestions {
            let optionIds = question.options.map(\.id)
            XCTAssertEqual(
                optionIds.count, Set(optionIds).count,
                "Question \(question.id) should have unique option IDs"
            )
        }
    }

    func test_optionIDs_withinEachQuestion_are0Through3() {
        for question in QuizQuestion.allQuestions {
            let optionIds = Set(question.options.map(\.id))
            XCTAssertEqual(
                optionIds, Set(0...3),
                "Question \(question.id) option IDs should be 0 through 3"
            )
        }
    }

    // MARK: - Score Ranges and Chronotype Mapping

    func test_chronotypeForScore_0_returnsLion() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 0), .lion)
    }

    func test_chronotypeForScore_7_returnsLion() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 7), .lion)
    }

    func test_chronotypeForScore_8_returnsBear() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 8), .bear)
    }

    func test_chronotypeForScore_14_returnsBear() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 14), .bear)
    }

    func test_chronotypeForScore_15_returnsWolf() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 15), .wolf)
    }

    func test_chronotypeForScore_21_returnsWolf() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 21), .wolf)
    }

    func test_chronotypeForScore_22_returnsDolphin() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 22), .dolphin)
    }

    func test_chronotypeForScore_30_returnsDolphin() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 30), .dolphin)
    }

    func test_chronotypeForScore_negativeValue_returnsBear() {
        // Default fallback for out-of-range scores
        XCTAssertEqual(QuizQuestion.chronotype(forScore: -1), .bear)
    }

    func test_chronotypeForScore_over30_returnsBear() {
        XCTAssertEqual(QuizQuestion.chronotype(forScore: 31), .bear)
    }

    // MARK: - Confidence Calculation

    func test_confidence_emptyAnswers_returnsZero() {
        XCTAssertEqual(QuizQuestion.confidence(forAnswers: []), 0)
    }

    func test_confidence_allSameAnswers_returnsOne() {
        // No variance means highest confidence
        let answers = Array(repeating: 2, count: 10)
        XCTAssertEqual(QuizQuestion.confidence(forAnswers: answers), 1.0, accuracy: 0.001)
    }

    func test_confidence_highVariance_returnsLowConfidence() {
        // Alternating extremes creates high variance
        let answers = [0, 3, 0, 3, 0, 3, 0, 3, 0, 3]
        let confidence = QuizQuestion.confidence(forAnswers: answers)
        XCTAssertLessThan(confidence, 0.5, "High variance answers should yield low confidence")
    }

    func test_confidence_lowVariance_returnsHighConfidence() {
        // Answers clustered together
        let answers = [1, 2, 1, 2, 1, 2, 1, 2, 1, 2]
        let confidence = QuizQuestion.confidence(forAnswers: answers)
        XCTAssertGreaterThan(confidence, 0.8, "Low variance answers should yield high confidence")
    }

    func test_confidence_singleAnswer_returnsOne() {
        // Single answer has no variance
        XCTAssertEqual(QuizQuestion.confidence(forAnswers: [2]), 1.0, accuracy: 0.001)
    }

    func test_confidence_returnsValueBetween0And1() {
        let testCases: [[Int]] = [
            [0, 0, 0, 0, 0],
            [3, 3, 3, 3, 3],
            [0, 1, 2, 3, 0],
            [1, 1, 2, 2, 1],
        ]
        for answers in testCases {
            let confidence = QuizQuestion.confidence(forAnswers: answers)
            XCTAssertGreaterThanOrEqual(confidence, 0.0)
            XCTAssertLessThanOrEqual(confidence, 1.0)
        }
    }

    // MARK: - Score Bounds

    func test_minimumPossibleScore_isZero() {
        // All questions answered with score 0
        let minScore = QuizQuestion.allQuestions.count * 0
        XCTAssertEqual(minScore, 0)
    }

    func test_maximumPossibleScore_is30() {
        // All questions answered with score 3
        let maxScore = QuizQuestion.allQuestions.count * 3
        XCTAssertEqual(maxScore, 30)
    }
}
