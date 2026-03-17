import XCTest
@testable import SleepPath

final class EnergyStateTests: XCTestCase {

    // MARK: - CaseIterable

    func test_allCases_returnsSixStates() {
        XCTAssertEqual(EnergyState.allCases.count, 6)
    }

    func test_allCases_containsAllExpectedStates() {
        let expected: Set<EnergyState> = [.peak, .rising, .dip, .recovery, .windDown, .sleeping]
        let actual = Set(EnergyState.allCases)
        XCTAssertEqual(actual, expected)
    }

    // MARK: - Display Names

    func test_displayName_peak_returnsPeak() {
        XCTAssertEqual(EnergyState.peak.displayName, "Peak")
    }

    func test_displayName_rising_returnsRising() {
        XCTAssertEqual(EnergyState.rising.displayName, "Rising")
    }

    func test_displayName_dip_returnsEnergyDip() {
        XCTAssertEqual(EnergyState.dip.displayName, "Energy Dip")
    }

    func test_displayName_recovery_returnsRecovery() {
        XCTAssertEqual(EnergyState.recovery.displayName, "Recovery")
    }

    func test_displayName_windDown_returnsWindDown() {
        XCTAssertEqual(EnergyState.windDown.displayName, "Wind Down")
    }

    func test_displayName_sleeping_returnsSleeping() {
        XCTAssertEqual(EnergyState.sleeping.displayName, "Sleeping")
    }

    func test_displayName_allStates_areNonEmpty() {
        for state in EnergyState.allCases {
            XCTAssertFalse(state.displayName.isEmpty, "\(state) displayName should not be empty")
        }
    }

    // MARK: - Icons (SF Symbol Names)

    func test_icon_peak_returnsBoltFill() {
        XCTAssertEqual(EnergyState.peak.icon, "bolt.fill")
    }

    func test_icon_rising_returnsSunriseFill() {
        XCTAssertEqual(EnergyState.rising.icon, "sunrise.fill")
    }

    func test_icon_dip_returnsCloudSunFill() {
        XCTAssertEqual(EnergyState.dip.icon, "cloud.sun.fill")
    }

    func test_icon_recovery_returnsArrowUpRight() {
        XCTAssertEqual(EnergyState.recovery.icon, "arrow.up.right")
    }

    func test_icon_windDown_returnsMoonHazeFill() {
        XCTAssertEqual(EnergyState.windDown.icon, "moon.haze.fill")
    }

    func test_icon_sleeping_returnsMoonZzzFill() {
        XCTAssertEqual(EnergyState.sleeping.icon, "moon.zzz.fill")
    }

    func test_icon_allStates_areNonEmpty() {
        for state in EnergyState.allCases {
            XCTAssertFalse(state.icon.isEmpty, "\(state) icon should not be empty")
        }
    }

    func test_icon_allStates_containDotSeparatedFormat() {
        // SF Symbols typically use dot-separated names
        for state in EnergyState.allCases {
            XCTAssertTrue(
                state.icon.contains("."),
                "\(state) icon '\(state.icon)' should be a valid SF Symbol name with dots"
            )
        }
    }

    // MARK: - Descriptions

    func test_description_allStates_areNonEmpty() {
        for state in EnergyState.allCases {
            XCTAssertFalse(state.description.isEmpty, "\(state) description should not be empty")
        }
    }

    func test_description_allStates_haveMeaningfulLength() {
        for state in EnergyState.allCases {
            XCTAssertGreaterThan(
                state.description.count, 20,
                "\(state) description should be at least 20 characters"
            )
        }
    }

    func test_description_peak_mentionsFocusOrClarity() {
        let description = EnergyState.peak.description.lowercased()
        let mentionsRelevantConcept = description.contains("focus") || description.contains("clarity") || description.contains("peak")
        XCTAssertTrue(mentionsRelevantConcept, "Peak description should mention focus, clarity, or peak")
    }

    func test_description_sleeping_mentionsRest() {
        let description = EnergyState.sleeping.description.lowercased()
        let mentionsRest = description.contains("rest") || description.contains("repair") || description.contains("recharge")
        XCTAssertTrue(mentionsRest, "Sleeping description should mention rest, repair, or recharge")
    }

    // MARK: - Suggestions

    func test_suggestion_allStates_areNonEmpty() {
        for state in EnergyState.allCases {
            XCTAssertFalse(state.suggestion.isEmpty, "\(state) suggestion should not be empty")
        }
    }

    func test_suggestion_allStates_haveMeaningfulLength() {
        for state in EnergyState.allCases {
            XCTAssertGreaterThan(
                state.suggestion.count, 15,
                "\(state) suggestion should be at least 15 characters"
            )
        }
    }

    func test_suggestion_peak_mentionsDeepWork() {
        let suggestion = EnergyState.peak.suggestion.lowercased()
        let mentionsWork = suggestion.contains("deep work") || suggestion.contains("hardest task") || suggestion.contains("protect")
        XCTAssertTrue(mentionsWork, "Peak suggestion should mention deep work or hardest task")
    }

    func test_suggestion_dip_mentionsWalkOrRest() {
        let suggestion = EnergyState.dip.suggestion.lowercased()
        let mentionsActivity = suggestion.contains("walk") || suggestion.contains("rest") || suggestion.contains("nap")
        XCTAssertTrue(mentionsActivity, "Dip suggestion should mention walk, rest, or nap")
    }

    func test_suggestion_windDown_mentionsLightsOrScreens() {
        let suggestion = EnergyState.windDown.suggestion.lowercased()
        let mentionsWinding = suggestion.contains("light") || suggestion.contains("screen") || suggestion.contains("bedtime")
        XCTAssertTrue(mentionsWinding, "Wind-down suggestion should mention lights, screens, or bedtime")
    }

    // MARK: - Codable

    func test_codable_allStates_roundTrip() throws {
        for state in EnergyState.allCases {
            let data = try JSONEncoder().encode(state)
            let decoded = try JSONDecoder().decode(EnergyState.self, from: data)
            XCTAssertEqual(decoded, state, "\(state) should round-trip through Codable")
        }
    }

    // MARK: - Uniqueness

    func test_displayNames_areAllUnique() {
        let names = EnergyState.allCases.map(\.displayName)
        XCTAssertEqual(names.count, Set(names).count, "All display names should be unique")
    }

    func test_icons_areAllUnique() {
        let icons = EnergyState.allCases.map(\.icon)
        XCTAssertEqual(icons.count, Set(icons).count, "All icons should be unique")
    }
}
