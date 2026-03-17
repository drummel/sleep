import XCTest
import ViewInspector
@testable import SleepPath

final class ComponentViewTests: XCTestCase {

    // MARK: - PrimaryButton

    func test_primaryButton_displaysTitle() throws {
        let sut = PrimaryButton(title: "Get Started") {}
        let button = try sut.inspect().find(ViewType.Button.self)
        let text = try button.find(ViewType.Text.self)
        XCTAssertEqual(try text.string(), "Get Started")
    }

    func test_primaryButton_displaysIcon_whenProvided() throws {
        let sut = PrimaryButton(title: "Continue", icon: "arrow.right") {}
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    func test_primaryButton_noIcon_whenNil() throws {
        let sut = PrimaryButton(title: "Continue") {}
        XCTAssertThrowsError(try sut.inspect().find(ViewType.Image.self))
    }

    // MARK: - SecondaryButton

    func test_secondaryButton_displaysTitle() throws {
        let sut = SecondaryButton(title: "Share Results") {}
        let button = try sut.inspect().find(ViewType.Button.self)
        let text = try button.find(ViewType.Text.self)
        XCTAssertEqual(try text.string(), "Share Results")
    }

    func test_secondaryButton_displaysIcon_whenProvided() throws {
        let sut = SecondaryButton(title: "Share", icon: "square.and.arrow.up") {}
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    func test_secondaryButton_noIcon_whenNil() throws {
        let sut = SecondaryButton(title: "Share") {}
        XCTAssertThrowsError(try sut.inspect().find(ViewType.Image.self))
    }

    // MARK: - StatCard

    func test_statCard_displaysValue() throws {
        let sut = StatCard(icon: "moon.zzz", value: "7h 32m", label: "Average Sleep")
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("7h 32m"))
    }

    func test_statCard_displaysLabel() throws {
        let sut = StatCard(icon: "moon.zzz", value: "7h 32m", label: "Average Sleep")
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("Average Sleep"))
    }

    func test_statCard_displaysIcon() throws {
        let sut = StatCard(icon: "moon.zzz", value: "7h 32m", label: "Average Sleep")
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }
}
