import Foundation

// MARK: - Chronotype Quiz Result

/// The result of a chronotype calculation from quiz answers.
struct ChronotypeResult: Sendable {
    /// The determined chronotype.
    let chronotype: Chronotype
    /// The raw score from quiz answers (0-30 range).
    let score: Int
    /// Confidence in the result, from 0.0 (low) to 1.0 (high).
    let confidence: Double
    /// Description of the user's peak creative hours.
    let peakCreativeHours: String
    /// Recommended latest caffeine intake time.
    let idealCaffeineCutoff: String
    /// Suggested wake time for this chronotype.
    let optimalWakeTime: String
}

// MARK: - Chronotype Engine

/// Calculates a user's chronotype from quiz answer scores.
///
/// The engine uses a 10-question quiz where each answer scores 0-3 points
/// on the morningness-eveningness spectrum. Special detection logic identifies
/// the Dolphin chronotype based on specific answer combinations.
@Observable
final class ChronotypeEngine {

    // MARK: - Constants

    /// Number of questions in the chronotype quiz.
    static let questionCount = 10

    /// Maximum possible score per question.
    static let maxScorePerQuestion = 3

    /// Total maximum score across all questions.
    static let maxTotalScore = questionCount * maxScorePerQuestion

    /// Score boundaries for each chronotype range.
    private enum ScoreBoundary {
        static let lionUpperBound = 7
        static let bearUpperBound = 14
        static let wolfUpperBound = 21
    }

    /// Question indices used for Dolphin detection (0-indexed).
    private enum DolphinDetection {
        /// Q4: "How quickly do you fall asleep?"
        static let sleepOnsetQuestion = 3
        /// Q7: "What time do you usually go to bed?"
        static let bedtimeQuestion = 6
        /// Minimum sleep onset score for Dolphin detection.
        static let sleepOnsetThreshold = 3
        /// Maximum bedtime score for Dolphin detection.
        static let bedtimeThreshold = 1
        /// Minimum total score for Dolphin detection.
        static let totalScoreThreshold = 10
    }

    // MARK: - Public API

    /// Calculates the chronotype from a set of quiz answers.
    ///
    /// - Parameter answers: An array of tuples containing the question ID (1-based)
    ///   and the score (0-3) for each answer.
    /// - Returns: A ``ChronotypeResult`` with the determined chronotype and metadata.
    func calculateChronotype(answers: [(questionId: Int, score: Int)]) -> ChronotypeResult {
        let totalScore = answers.reduce(0) { $0 + $1.score }
        let clampedScore = min(max(totalScore, 0), Self.maxTotalScore)

        let isDolphin = detectDolphin(answers: answers, totalScore: clampedScore)
        let chronotype: Chronotype

        if isDolphin {
            chronotype = .dolphin
        } else {
            chronotype = chronotypeFromScore(clampedScore)
        }

        let confidence = calculateConfidence(
            score: clampedScore,
            chronotype: chronotype,
            isDolphinOverride: isDolphin
        )

        return ChronotypeResult(
            chronotype: chronotype,
            score: clampedScore,
            confidence: confidence,
            peakCreativeHours: peakCreativeHours(for: chronotype),
            idealCaffeineCutoff: caffeineCutoff(for: chronotype),
            optimalWakeTime: optimalWakeTime(for: chronotype)
        )
    }

    // MARK: - Private Helpers

    /// Determines the base chronotype from a raw score, ignoring Dolphin detection.
    private func chronotypeFromScore(_ score: Int) -> Chronotype {
        switch score {
        case 0...ScoreBoundary.lionUpperBound:
            return .lion
        case (ScoreBoundary.lionUpperBound + 1)...ScoreBoundary.bearUpperBound:
            return .bear
        case (ScoreBoundary.bearUpperBound + 1)...ScoreBoundary.wolfUpperBound:
            return .wolf
        default:
            // Scores above 21 also map to Wolf (the eveningness extreme).
            return .wolf
        }
    }

    /// Checks whether the answer pattern indicates Dolphin chronotype.
    ///
    /// Dolphin detection fires when:
    /// - Q4 (sleep onset) score is 3 (takes a long time to fall asleep)
    /// - Q7 (bedtime) score is <= 1 (relatively early bedtime)
    /// - Total score is above 10 (not a clear Lion)
    private func detectDolphin(answers: [(questionId: Int, score: Int)], totalScore: Int) -> Bool {
        guard totalScore > DolphinDetection.totalScoreThreshold else { return false }

        let q4Score = answers.first { $0.questionId == 4 }?.score
        let q7Score = answers.first { $0.questionId == 7 }?.score

        guard let sleepOnset = q4Score, let bedtime = q7Score else { return false }

        return sleepOnset >= DolphinDetection.sleepOnsetThreshold
            && bedtime <= DolphinDetection.bedtimeThreshold
    }

    /// Calculates confidence based on how clearly the score falls within a range.
    ///
    /// Scores near the center of a range yield high confidence. Scores near
    /// boundaries yield lower confidence. Dolphin overrides get a slight
    /// penalty since the detection is pattern-based rather than score-based.
    private func calculateConfidence(score: Int, chronotype: Chronotype, isDolphinOverride: Bool) -> Double {
        if isDolphinOverride {
            // Dolphin detection is pattern-based, so confidence is moderate.
            return 0.65
        }

        // Calculate distance from nearest boundary as a fraction of range width.
        let (rangeLow, rangeHigh): (Int, Int)
        switch chronotype {
        case .lion:
            rangeLow = 0
            rangeHigh = ScoreBoundary.lionUpperBound
        case .bear:
            rangeLow = ScoreBoundary.lionUpperBound + 1
            rangeHigh = ScoreBoundary.bearUpperBound
        case .wolf:
            rangeLow = ScoreBoundary.bearUpperBound + 1
            rangeHigh = Self.maxTotalScore
        case .dolphin:
            return 0.65
        }

        let rangeWidth = Double(rangeHigh - rangeLow)
        guard rangeWidth > 0 else { return 0.5 }

        let distanceFromLow = Double(score - rangeLow)
        let distanceFromHigh = Double(rangeHigh - score)
        let distanceFromNearestEdge = min(distanceFromLow, distanceFromHigh)

        // Normalize: center of range = 1.0, edge = 0.0.
        let normalizedDistance = distanceFromNearestEdge / (rangeWidth / 2.0)

        // Map to confidence range: 0.45 (at boundary) to 0.95 (at center).
        let confidence = 0.45 + normalizedDistance * 0.50
        return min(max(confidence, 0.45), 0.95)
    }

    /// Returns a human-readable peak creative hours string for a chronotype.
    private func peakCreativeHours(for chronotype: Chronotype) -> String {
        switch chronotype {
        case .lion:    return "6:00 AM - 10:00 AM"
        case .bear:    return "10:00 AM - 2:00 PM"
        case .wolf:    return "5:00 PM - 9:00 PM"
        case .dolphin: return "10:00 AM - 12:00 PM"
        }
    }

    /// Returns the ideal caffeine cutoff time for a chronotype.
    private func caffeineCutoff(for chronotype: Chronotype) -> String {
        switch chronotype {
        case .lion:    return "1:00 PM"
        case .bear:    return "2:00 PM"
        case .wolf:    return "4:00 PM"
        case .dolphin: return "1:00 PM"
        }
    }

    /// Returns the optimal wake time for a chronotype.
    private func optimalWakeTime(for chronotype: Chronotype) -> String {
        switch chronotype {
        case .lion:    return "5:30 AM"
        case .bear:    return "7:00 AM"
        case .wolf:    return "8:30 AM"
        case .dolphin: return "6:30 AM"
        }
    }
}
