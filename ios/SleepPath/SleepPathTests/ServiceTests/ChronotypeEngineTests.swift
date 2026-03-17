import XCTest
@testable import SleepPath

final class ChronotypeEngineTests: XCTestCase {

    var engine: ChronotypeEngine!

    override func setUp() {
        super.setUp()
        engine = ChronotypeEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Creates a uniform set of 10 answers with the given score for each.
    private func uniformAnswers(score: Int) -> [(questionId: Int, score: Int)] {
        (1...10).map { (questionId: $0, score: score) }
    }

    /// Creates 10 answers with the given total score distributed evenly.
    private func answersWithTotal(_ total: Int) -> [(questionId: Int, score: Int)] {
        var answers: [(questionId: Int, score: Int)] = []
        var remaining = total
        for questionId in 1...10 {
            let score: Int
            if questionId == 10 {
                score = max(0, min(3, remaining))
            } else {
                score = max(0, min(3, remaining / (10 - questionId + 1)))
            }
            answers.append((questionId: questionId, score: score))
            remaining -= score
        }
        return answers
    }

    // MARK: - All-Low Scores (Lion)

    func test_calculateChronotype_allZeroScores_returnsLion() {
        let answers = uniformAnswers(score: 0)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .lion)
        XCTAssertEqual(result.score, 0)
    }

    func test_calculateChronotype_allLowScores_returnsLion() {
        // All scores of 0 => total = 0, which is in Lion range (0-7)
        let answers = uniformAnswers(score: 0)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .lion)
    }

    // MARK: - Medium-Low Scores (Bear)

    func test_calculateChronotype_allOnes_returnsBear() {
        // All scores of 1 => total = 10, which is in Bear range (8-14)
        let answers = uniformAnswers(score: 1)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .bear)
        XCTAssertEqual(result.score, 10)
    }

    // MARK: - Medium-High Scores (Wolf)

    func test_calculateChronotype_allTwos_returnsWolf() {
        // All scores of 2 => total = 20, which is in Wolf range (15-21)
        let answers = uniformAnswers(score: 2)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .wolf)
        XCTAssertEqual(result.score, 20)
    }

    // MARK: - High Scores (Wolf, since Dolphin is pattern-based)

    func test_calculateChronotype_allThrees_returnsWolf() {
        // All scores of 3 => total = 30, but no Dolphin pattern (Q4=3, Q7=3 fails bedtime <= 1)
        let answers = uniformAnswers(score: 3)
        let result = engine.calculateChronotype(answers: answers)
        // Q7 score is 3 which is > 1, so Dolphin is NOT detected; falls through to Wolf
        XCTAssertEqual(result.chronotype, .wolf)
        XCTAssertEqual(result.score, 30)
    }

    // MARK: - Dolphin Detection

    func test_calculateChronotype_dolphinPattern_returnsDolphin() {
        // Dolphin: Q4 score >= 3, Q7 score <= 1, total > 10
        var answers: [(questionId: Int, score: Int)] = []
        for questionId in 1...10 {
            let score: Int
            switch questionId {
            case 4: score = 3   // Sleep onset: takes long time
            case 7: score = 1   // Bedtime: relatively early
            default: score = 2  // Other answers moderate
            }
            answers.append((questionId: questionId, score: score))
        }
        // Total: 8 * 2 + 3 + 1 = 20, which is > 10
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .dolphin)
    }

    func test_calculateChronotype_dolphinPattern_q7Score0_returnsDolphin() {
        var answers: [(questionId: Int, score: Int)] = []
        for questionId in 1...10 {
            let score: Int
            switch questionId {
            case 4: score = 3
            case 7: score = 0
            default: score = 2
            }
            answers.append((questionId: questionId, score: score))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .dolphin)
    }

    func test_calculateChronotype_dolphinPattern_totalTooLow_doesNotReturnDolphin() {
        // Total must be > 10 for Dolphin detection
        var answers: [(questionId: Int, score: Int)] = []
        for questionId in 1...10 {
            let score: Int
            switch questionId {
            case 4: score = 3
            case 7: score = 0
            default: score = 0  // Keep total low
            }
            answers.append((questionId: questionId, score: score))
        }
        // Total: 8 * 0 + 3 + 0 = 3, which is <= 10
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertNotEqual(result.chronotype, .dolphin)
        XCTAssertEqual(result.chronotype, .lion) // Score 3 is in Lion range
    }

    func test_calculateChronotype_dolphinPattern_q4TooLow_doesNotReturnDolphin() {
        // Q4 must be >= 3
        var answers: [(questionId: Int, score: Int)] = []
        for questionId in 1...10 {
            let score: Int
            switch questionId {
            case 4: score = 2   // Below threshold
            case 7: score = 1
            default: score = 2
            }
            answers.append((questionId: questionId, score: score))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertNotEqual(result.chronotype, .dolphin)
    }

    func test_calculateChronotype_dolphinPattern_q7TooHigh_doesNotReturnDolphin() {
        // Q7 must be <= 1
        var answers: [(questionId: Int, score: Int)] = []
        for questionId in 1...10 {
            let score: Int
            switch questionId {
            case 4: score = 3
            case 7: score = 2   // Above threshold
            default: score = 2
            }
            answers.append((questionId: questionId, score: score))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertNotEqual(result.chronotype, .dolphin)
    }

    // MARK: - Boundary Scores

    func test_calculateChronotype_scoreOf7_returnsLion() {
        // Score 7: upper boundary of Lion range
        var answers: [(questionId: Int, score: Int)] = []
        // 7 questions with score 1, 3 with score 0 = total 7
        for questionId in 1...10 {
            answers.append((questionId: questionId, score: questionId <= 7 ? 1 : 0))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .lion)
        XCTAssertEqual(result.score, 7)
    }

    func test_calculateChronotype_scoreOf8_returnsBear() {
        // Score 8: lower boundary of Bear range
        var answers: [(questionId: Int, score: Int)] = []
        // 8 questions with score 1, 2 with score 0 = total 8
        for questionId in 1...10 {
            answers.append((questionId: questionId, score: questionId <= 8 ? 1 : 0))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .bear)
        XCTAssertEqual(result.score, 8)
    }

    func test_calculateChronotype_scoreOf14_returnsBear() {
        // Score 14: upper boundary of Bear range
        var answers: [(questionId: Int, score: Int)] = []
        // 4 questions with score 2, 6 with score 1 = 8 + 6 = 14
        for questionId in 1...10 {
            answers.append((questionId: questionId, score: questionId <= 4 ? 2 : 1))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .bear)
        XCTAssertEqual(result.score, 14)
    }

    func test_calculateChronotype_scoreOf15_returnsWolf() {
        // Score 15: lower boundary of Wolf range
        var answers: [(questionId: Int, score: Int)] = []
        // 5 questions with score 2, 5 with score 1 = 10 + 5 = 15
        for questionId in 1...10 {
            answers.append((questionId: questionId, score: questionId <= 5 ? 2 : 1))
        }
        let result = engine.calculateChronotype(answers: answers)
        // Note: Dolphin detection could fire if Q4 and Q7 match pattern.
        // Q4 gets score 2 (< 3), so Dolphin won't fire.
        XCTAssertEqual(result.chronotype, .wolf)
        XCTAssertEqual(result.score, 15)
    }

    // MARK: - Confidence

    func test_calculateChronotype_clearResult_hasHighConfidence() {
        // Score in the middle of a range should yield high confidence
        // Lion range center: ~3-4
        let answers = uniformAnswers(score: 0) // Total = 0, center-ish of Lion
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertGreaterThanOrEqual(result.confidence, 0.45)
    }

    func test_calculateChronotype_centerOfBearRange_hasHighConfidence() {
        // Bear range is 8-14, center is 11
        var answers: [(questionId: Int, score: Int)] = []
        // Total = 11: one question with score 2, nine with score 1
        for questionId in 1...10 {
            answers.append((questionId: questionId, score: questionId == 1 ? 2 : 1))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .bear)
        XCTAssertGreaterThan(result.confidence, 0.7, "Center of Bear range should have high confidence")
    }

    func test_calculateChronotype_boundaryResult_hasLowerConfidence() {
        // Score at boundary between Lion and Bear (7 or 8)
        var answers: [(questionId: Int, score: Int)] = []
        for questionId in 1...10 {
            answers.append((questionId: questionId, score: questionId <= 8 ? 1 : 0))
        }
        // Total = 8 (lower edge of Bear range)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .bear)
        XCTAssertLessThanOrEqual(result.confidence, 0.65, "Boundary score should have lower confidence")
    }

    func test_calculateChronotype_dolphin_hasModerateConfidence() {
        var answers: [(questionId: Int, score: Int)] = []
        for questionId in 1...10 {
            let score: Int
            switch questionId {
            case 4: score = 3
            case 7: score = 1
            default: score = 2
            }
            answers.append((questionId: questionId, score: score))
        }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .dolphin)
        XCTAssertEqual(result.confidence, 0.65, "Dolphin should have 0.65 confidence")
    }

    func test_calculateChronotype_confidence_isWithinValidRange() {
        // Test various score distributions
        let testCases: [[(questionId: Int, score: Int)]] = [
            uniformAnswers(score: 0),
            uniformAnswers(score: 1),
            uniformAnswers(score: 2),
            uniformAnswers(score: 3),
        ]
        for answers in testCases {
            let result = engine.calculateChronotype(answers: answers)
            XCTAssertGreaterThanOrEqual(result.confidence, 0.0)
            XCTAssertLessThanOrEqual(result.confidence, 1.0)
        }
    }

    // MARK: - Result Properties

    func test_calculateChronotype_wolfResult_hasPeakCreativeHours() {
        let answers = uniformAnswers(score: 2)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .wolf)
        XCTAssertEqual(result.peakCreativeHours, "5:00 PM - 9:00 PM")
    }

    func test_calculateChronotype_lionResult_hasPeakCreativeHours() {
        let answers = uniformAnswers(score: 0)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .lion)
        XCTAssertEqual(result.peakCreativeHours, "6:00 AM - 10:00 AM")
    }

    func test_calculateChronotype_bearResult_hasPeakCreativeHours() {
        let answers = uniformAnswers(score: 1)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.chronotype, .bear)
        XCTAssertEqual(result.peakCreativeHours, "10:00 AM - 2:00 PM")
    }

    func test_calculateChronotype_result_hasOptimalWakeTime() {
        let answers = uniformAnswers(score: 2) // Wolf
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.optimalWakeTime, "8:30 AM")
    }

    func test_calculateChronotype_result_hasCaffeineCutoff() {
        let answers = uniformAnswers(score: 2) // Wolf
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.idealCaffeineCutoff, "4:00 PM")
    }

    func test_calculateChronotype_lionResult_hasEarlyCaffeineCutoff() {
        let answers = uniformAnswers(score: 0)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.idealCaffeineCutoff, "1:00 PM")
    }

    func test_calculateChronotype_bearResult_hasCaffeineCutoff() {
        let answers = uniformAnswers(score: 1)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.idealCaffeineCutoff, "2:00 PM")
    }

    func test_calculateChronotype_lionResult_hasOptimalWakeTime() {
        let answers = uniformAnswers(score: 0)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.optimalWakeTime, "5:30 AM")
    }

    func test_calculateChronotype_bearResult_hasOptimalWakeTime() {
        let answers = uniformAnswers(score: 1)
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.optimalWakeTime, "7:00 AM")
    }

    // MARK: - Score Clamping

    func test_calculateChronotype_negativeScores_areClamped() {
        let answers: [(questionId: Int, score: Int)] = (1...10).map { (questionId: $0, score: -5) }
        let result = engine.calculateChronotype(answers: answers)
        XCTAssertEqual(result.score, 0, "Negative total should be clamped to 0")
        XCTAssertEqual(result.chronotype, .lion)
    }

    // MARK: - Result Struct Completeness

    func test_calculateChronotype_resultHasAllProperties() {
        let answers = uniformAnswers(score: 1)
        let result = engine.calculateChronotype(answers: answers)

        XCTAssertFalse(result.peakCreativeHours.isEmpty)
        XCTAssertFalse(result.idealCaffeineCutoff.isEmpty)
        XCTAssertFalse(result.optimalWakeTime.isEmpty)
        XCTAssertGreaterThanOrEqual(result.score, 0)
        XCTAssertLessThanOrEqual(result.score, 30)
        XCTAssertGreaterThanOrEqual(result.confidence, 0.0)
        XCTAssertLessThanOrEqual(result.confidence, 1.0)
    }
}
