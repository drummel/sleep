import XCTest
import ViewInspector
@testable import SleepPath

final class QuickActionsViewTests: XCTestCase {

    func test_displaysQuickActionsTitle() throws {
        var caffeineCount = 0
        var sunlightLogged = false
        let sut = QuickActionsView(
            caffeineCount: Binding(get: { caffeineCount }, set: { caffeineCount = $0 }),
            sunlightLogged: Binding(get: { sunlightLogged }, set: { sunlightLogged = $0 }),
            onShareTapped: {}
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("Quick Actions"))
    }

    func test_displaysSunlightLabel() throws {
        var caffeineCount = 0
        var sunlightLogged = false
        let sut = QuickActionsView(
            caffeineCount: Binding(get: { caffeineCount }, set: { caffeineCount = $0 }),
            sunlightLogged: Binding(get: { sunlightLogged }, set: { sunlightLogged = $0 }),
            onShareTapped: {}
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("Sunlight"))
    }

    func test_displaysCoffeeLabel() throws {
        var caffeineCount = 0
        var sunlightLogged = false
        let sut = QuickActionsView(
            caffeineCount: Binding(get: { caffeineCount }, set: { caffeineCount = $0 }),
            sunlightLogged: Binding(get: { sunlightLogged }, set: { sunlightLogged = $0 }),
            onShareTapped: {}
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("Coffee"))
    }

    func test_displaysShareLabel() throws {
        var caffeineCount = 0
        var sunlightLogged = false
        let sut = QuickActionsView(
            caffeineCount: Binding(get: { caffeineCount }, set: { caffeineCount = $0 }),
            sunlightLogged: Binding(get: { sunlightLogged }, set: { sunlightLogged = $0 }),
            onShareTapped: {}
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("Share"))
    }

    func test_rendersWithoutError() throws {
        var caffeineCount = 2
        var sunlightLogged = true
        let sut = QuickActionsView(
            caffeineCount: Binding(get: { caffeineCount }, set: { caffeineCount = $0 }),
            sunlightLogged: Binding(get: { sunlightLogged }, set: { sunlightLogged = $0 }),
            onShareTapped: {}
        )
        XCTAssertNoThrow(try sut.inspect())
    }
}
