import XCTest
import ViewInspector
@testable import SleepPath

final class HealthKitPermissionViewTests: XCTestCase {

    // MARK: - Content Display

    func test_displaysHeadline() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Watch already"))
    }

    func test_displaysSubheadline() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Apple Health"))
    }

    func test_displaysWhatWeReadSection() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("WHAT WE READ"))
        XCTAssertTrue(combined.contains("Sleep times and duration"))
        XCTAssertTrue(combined.contains("Sleep stages"))
    }

    func test_displaysWhatWeNeverDoSection() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("WHAT WE NEVER DO"))
        XCTAssertTrue(combined.contains("Send your data to any server"))
        XCTAssertTrue(combined.contains("Share with third parties"))
        XCTAssertTrue(combined.contains("Use for advertising"))
    }

    func test_displaysPrivacyBadge() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("data stays on this device"))
    }

    func test_displaysConnectButton() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Connect to Apple Health"))
    }

    func test_displaysMaybeLaterButton() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Maybe Later"))
    }

    func test_rendersWithoutError() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        XCTAssertNoThrow(try sut.inspect())
    }
}
