import XCTest
import ViewInspector
@testable import SleepPath

final class InsightCardTests: XCTestCase {

    func test_displaysTitle() throws {
        let sut = InsightCard(icon: "moon.zzz", title: "Average Sleep", value: "7h 32m")
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("Average Sleep"))
    }

    func test_displaysValue() throws {
        let sut = InsightCard(icon: "moon.zzz", title: "Average Sleep", value: "7h 32m")
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("7h 32m"))
    }

    func test_displaysDescription_whenProvided() throws {
        let sut = InsightCard(
            icon: "moon.zzz",
            title: "Average Sleep",
            value: "7h 32m",
            description: "Above your target"
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("Above your target"))
    }

    func test_noDescription_whenNil() throws {
        let sut = InsightCard(icon: "moon.zzz", title: "Sleep", value: "7h")
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        // Should only have title and value (2 texts)
        XCTAssertEqual(texts.count, 2)
    }

    func test_displaysIcon() throws {
        let sut = InsightCard(icon: "chart.bar.fill", title: "Consistency", value: "82%")
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }
}
