import XCTest
import ViewInspector
@testable import SleepPath

final class CaffeineCutoffBannerTests: XCTestCase {

    // MARK: - Before Cutoff

    func test_beforeCutoff_showsCaffeineOkText() throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(2 * 3600) // 2 hours from now
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff, currentTime: now)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Caffeine OK"))
    }

    func test_beforeCutoff_showsTimeUntilCutoff() throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(2 * 3600 + 15 * 60) // 2h 15m
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff, currentTime: now)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("until cutoff"))
    }

    func test_beforeCutoff_showsCupIcon() throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(3600)
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff, currentTime: now)
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    // MARK: - After Cutoff

    func test_afterCutoff_showsPastCutoffText() throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(-3600) // 1 hour ago
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff, currentTime: now)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Past caffeine cutoff"))
    }

    func test_afterCutoff_showsXmarkIcon() throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(-3600)
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff, currentTime: now)
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    // MARK: - Edge Case

    func test_exactlyCutoffTime_showsPastCutoff() throws {
        let now = Date()
        let sut = CaffeineCutoffBanner(cutoffTime: now, currentTime: now)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Past caffeine cutoff"))
    }

    func test_minutesOnlyWhenLessThanOneHour() throws {
        let now = Date()
        let cutoff = now.addingTimeInterval(45 * 60) // 45 minutes
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff, currentTime: now)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("m until cutoff"))
        // Should not contain "h" for hours
        XCTAssertFalse(combined.contains("h "))
    }
}
