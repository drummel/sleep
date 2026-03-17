import XCTest
import ViewInspector
@testable import SleepPath

final class NotificationPermissionViewTests: XCTestCase {

    // MARK: - Content Display

    func test_displaysHeadline() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("nudge you"))
    }

    func test_displaysSubheadline() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("rhythm"))
    }

    func test_displaysSunlightNudge() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Sunlight window"))
        XCTAssertTrue(combined.contains("circadian clock"))
    }

    func test_displaysCaffeineNudge() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Caffeine cutoff"))
        XCTAssertTrue(combined.contains("last-call"))
    }

    func test_displaysWindDownNudge() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Wind-down time"))
        XCTAssertTrue(combined.contains("dimming lights"))
    }

    func test_displaysPromiseText() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Nothing else"))
    }

    func test_displaysAllowButton() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Allow Notifications"))
    }

    func test_displaysNotNowButton() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Not Now"))
    }

    func test_rendersWithoutError() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        XCTAssertNoThrow(try sut.inspect())
    }
}
