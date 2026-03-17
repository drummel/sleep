import XCTest
import ViewInspector
@testable import SleepPath

final class WelcomeViewTests: XCTestCase {

    // MARK: - Content Display

    func test_displaysSleepPathTitle() throws {
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("SleepPath"))
    }

    func test_displaysSubtitle() throws {
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("biology"))
    }

    func test_displaysValuePropositions() throws {
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("chronotype"))
        XCTAssertTrue(combined.contains("personalized daily rhythm"))
        XCTAssertTrue(combined.contains("real data"))
    }

    func test_displaysGetStartedButton() throws {
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Get Started"))
    }

    func test_displaysAlreadyTookQuizButton() throws {
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("already took the quiz"))
    }

    func test_displaysMoonStarsIcon() throws {
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        let images = try sut.inspect().findAll(ViewType.Image.self)
        XCTAssertGreaterThan(images.count, 0, "Should display at least one icon")
    }

    // MARK: - Renders Without Error

    func test_allChronotypes_renderWelcomeViewWithoutError() throws {
        // WelcomeView doesn't depend on chronotype, but verifying it renders cleanly
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        XCTAssertNoThrow(try sut.inspect())
    }
}
