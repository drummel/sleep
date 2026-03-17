import XCTest
import ViewInspector
@testable import SleepPath

final class EnergyStateCardTests: XCTestCase {

    // MARK: - Content Display

    func test_displaysEnergyStateName() throws {
        let sut = EnergyStateCard(
            energyState: .peak,
            timeUntilChange: "2h 15m until your dip",
            suggestion: "Deep work window."
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains(EnergyState.peak.displayName))
    }

    func test_displaysTimeUntilChange() throws {
        let sut = EnergyStateCard(
            energyState: .rising,
            timeUntilChange: "45m until peak",
            suggestion: "Ease into the day."
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains("45m until peak"))
    }

    func test_displaysSuggestion() throws {
        let suggestion = "Take a walk or nap."
        let sut = EnergyStateCard(
            energyState: .dip,
            timeUntilChange: "30m until recovery",
            suggestion: suggestion
        )
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let textValues = try texts.map { try $0.string() }
        XCTAssertTrue(textValues.contains(suggestion))
    }

    func test_displaysIcon() throws {
        let sut = EnergyStateCard(
            energyState: .peak,
            timeUntilChange: "2h",
            suggestion: "Focus."
        )
        let image = try sut.inspect().find(ViewType.Image.self)
        XCTAssertNotNil(image)
    }

    // MARK: - All Energy States Render

    func test_allEnergyStatesRenderWithoutError() throws {
        for state in EnergyState.allCases {
            let sut = EnergyStateCard(
                energyState: state,
                timeUntilChange: "1h",
                suggestion: "Test suggestion"
            )
            XCTAssertNoThrow(try sut.inspect(), "\(state) should render without error")
        }
    }
}
