import XCTest
import ViewInspector
@testable import SleepPath

final class QuizResultViewTests: XCTestCase {

    // MARK: - Content Display

    func test_displaysChronotypeEmoji() throws {
        let sut = QuizResultView(chronotype: .wolf, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains(Chronotype.wolf.emoji))
    }

    func test_displaysChronotypeDisplayName() throws {
        let sut = QuizResultView(chronotype: .lion, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Lion"))
    }

    func test_displaysYoureAPrefix() throws {
        let sut = QuizResultView(chronotype: .bear, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("You're a"))
    }

    func test_displaysTagline() throws {
        let sut = QuizResultView(chronotype: .dolphin, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains(Chronotype.dolphin.tagline))
    }

    func test_displaysDetailedDescription() throws {
        let sut = QuizResultView(chronotype: .wolf, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        // Detailed description should contain some substring
        XCTAssertTrue(combined.count > 100, "Should have substantial text content")
    }

    func test_displaysContinueToSetupButton() throws {
        let sut = QuizResultView(chronotype: .wolf, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Continue to Setup"))
    }

    func test_displaysShareButton() throws {
        let sut = QuizResultView(chronotype: .wolf, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Share Your Chronotype"))
    }

    func test_displaysStatRows() throws {
        let sut = QuizResultView(chronotype: .wolf, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Peak creative hours"))
        XCTAssertTrue(combined.contains("Ideal bedtime"))
        XCTAssertTrue(combined.contains("Optimal wake time"))
    }

    func test_displaysChronotypeSpecificPeakHours() throws {
        let sut = QuizResultView(chronotype: .wolf, onContinue: {}, onShare: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains(Chronotype.wolf.peakHoursDescription))
    }

    // MARK: - All Chronotypes Render

    func test_allChronotypes_renderWithoutError() throws {
        for chronotype in Chronotype.allCases {
            let sut = QuizResultView(chronotype: chronotype, onContinue: {}, onShare: {})
            XCTAssertNoThrow(try sut.inspect(), "QuizResultView should render for \(chronotype)")
        }
    }

    func test_allChronotypes_displayCorrectName() throws {
        for chronotype in Chronotype.allCases {
            let sut = QuizResultView(chronotype: chronotype, onContinue: {}, onShare: {})
            let texts = try sut.inspect().findAll(ViewType.Text.self)
            let combined = try texts.map { try $0.string() }.joined(separator: " ")
            XCTAssertTrue(
                combined.contains(chronotype.displayName),
                "Should display \(chronotype.displayName)"
            )
        }
    }
}
