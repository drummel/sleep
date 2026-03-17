import XCTest
@testable import SleepPath

final class ChronotypeTests: XCTestCase {

    // MARK: - CaseIterable

    func test_allCases_returnsFourChronotypes() {
        XCTAssertEqual(Chronotype.allCases.count, 4)
        XCTAssertTrue(Chronotype.allCases.contains(.lion))
        XCTAssertTrue(Chronotype.allCases.contains(.bear))
        XCTAssertTrue(Chronotype.allCases.contains(.wolf))
        XCTAssertTrue(Chronotype.allCases.contains(.dolphin))
    }

    // MARK: - Display Names

    func test_displayName_lion_returnsLion() {
        XCTAssertEqual(Chronotype.lion.displayName, "Lion")
    }

    func test_displayName_bear_returnsBear() {
        XCTAssertEqual(Chronotype.bear.displayName, "Bear")
    }

    func test_displayName_wolf_returnsWolf() {
        XCTAssertEqual(Chronotype.wolf.displayName, "Wolf")
    }

    func test_displayName_dolphin_returnsDolphin() {
        XCTAssertEqual(Chronotype.dolphin.displayName, "Dolphin")
    }

    func test_displayName_allChronotypes_areNonEmpty() {
        for chronotype in Chronotype.allCases {
            XCTAssertFalse(chronotype.displayName.isEmpty, "\(chronotype) displayName should not be empty")
        }
    }

    // MARK: - Emojis

    func test_emoji_lion_returnsLionEmoji() {
        XCTAssertEqual(Chronotype.lion.emoji, "\u{1F981}")
    }

    func test_emoji_bear_returnsBearEmoji() {
        XCTAssertEqual(Chronotype.bear.emoji, "\u{1F43B}")
    }

    func test_emoji_wolf_returnsWolfEmoji() {
        XCTAssertEqual(Chronotype.wolf.emoji, "\u{1F43A}")
    }

    func test_emoji_dolphin_returnsDolphinEmoji() {
        XCTAssertEqual(Chronotype.dolphin.emoji, "\u{1F42C}")
    }

    func test_emoji_allChronotypes_areNonEmpty() {
        for chronotype in Chronotype.allCases {
            XCTAssertFalse(chronotype.emoji.isEmpty, "\(chronotype) emoji should not be empty")
        }
    }

    // MARK: - Taglines

    func test_tagline_lion_returnsEarlyBird() {
        XCTAssertEqual(Chronotype.lion.tagline, "The Early Bird")
    }

    func test_tagline_bear_returnsSolarTracker() {
        XCTAssertEqual(Chronotype.bear.tagline, "The Solar Tracker")
    }

    func test_tagline_wolf_returnsNightOwl() {
        XCTAssertEqual(Chronotype.wolf.tagline, "The Night Owl")
    }

    func test_tagline_dolphin_returnsLightSleeper() {
        XCTAssertEqual(Chronotype.dolphin.tagline, "The Light Sleeper")
    }

    func test_tagline_allChronotypes_areNonEmpty() {
        for chronotype in Chronotype.allCases {
            XCTAssertFalse(chronotype.tagline.isEmpty, "\(chronotype) tagline should not be empty")
        }
    }

    // MARK: - Descriptions

    func test_description_allChronotypes_areNonEmpty() {
        for chronotype in Chronotype.allCases {
            XCTAssertFalse(chronotype.description.isEmpty, "\(chronotype) description should not be empty")
        }
    }

    func test_description_allChronotypes_haveMeaningfulLength() {
        for chronotype in Chronotype.allCases {
            XCTAssertGreaterThan(
                chronotype.description.count, 50,
                "\(chronotype) description should be at least 50 characters"
            )
        }
    }

    // MARK: - Peak Hours

    func test_peakHoursDescription_lion_returnsMorningHours() {
        XCTAssertEqual(Chronotype.lion.peakHoursDescription, "8 AM - 12 PM")
    }

    func test_peakHoursDescription_bear_returnsMidDayHours() {
        XCTAssertEqual(Chronotype.bear.peakHoursDescription, "10 AM - 2 PM")
    }

    func test_peakHoursDescription_wolf_returnsEveningHours() {
        XCTAssertEqual(Chronotype.wolf.peakHoursDescription, "5 PM - 9 PM")
    }

    func test_peakHoursDescription_dolphin_returnsLatemorningHours() {
        XCTAssertEqual(Chronotype.dolphin.peakHoursDescription, "10 AM - 12 PM")
    }

    func test_peakHoursDescription_allChronotypes_areNonEmpty() {
        for chronotype in Chronotype.allCases {
            XCTAssertFalse(chronotype.peakHoursDescription.isEmpty, "\(chronotype) peakHoursDescription should not be empty")
        }
    }

    // MARK: - Ideal Wake Times

    func test_idealWakeTime_lion_returns530AM() {
        XCTAssertEqual(Chronotype.lion.idealWakeTime, "5:30 AM")
    }

    func test_idealWakeTime_bear_returns700AM() {
        XCTAssertEqual(Chronotype.bear.idealWakeTime, "7:00 AM")
    }

    func test_idealWakeTime_wolf_returns830AM() {
        XCTAssertEqual(Chronotype.wolf.idealWakeTime, "8:30 AM")
    }

    func test_idealWakeTime_dolphin_returns630AM() {
        XCTAssertEqual(Chronotype.dolphin.idealWakeTime, "6:30 AM")
    }

    // MARK: - Ideal Sleep Times

    func test_idealSleepTime_lion_returns930PM() {
        XCTAssertEqual(Chronotype.lion.idealSleepTime, "9:30 PM")
    }

    func test_idealSleepTime_bear_returns1100PM() {
        XCTAssertEqual(Chronotype.bear.idealSleepTime, "11:00 PM")
    }

    func test_idealSleepTime_wolf_returns1200AM() {
        XCTAssertEqual(Chronotype.wolf.idealSleepTime, "12:00 AM")
    }

    func test_idealSleepTime_dolphin_returns1130PM() {
        XCTAssertEqual(Chronotype.dolphin.idealSleepTime, "11:30 PM")
    }

    // MARK: - Accent Color Names

    func test_accentColorName_lion_returnsLionGold() {
        XCTAssertEqual(Chronotype.lion.accentColorName, "lionGold")
    }

    func test_accentColorName_bear_returnsBearGreen() {
        XCTAssertEqual(Chronotype.bear.accentColorName, "bearGreen")
    }

    func test_accentColorName_wolf_returnsWolfIndigo() {
        XCTAssertEqual(Chronotype.wolf.accentColorName, "wolfIndigo")
    }

    func test_accentColorName_dolphin_returnsDolphinTeal() {
        XCTAssertEqual(Chronotype.dolphin.accentColorName, "dolphinTeal")
    }

    func test_accentColorName_allChronotypes_areNonEmpty() {
        for chronotype in Chronotype.allCases {
            XCTAssertFalse(chronotype.accentColorName.isEmpty, "\(chronotype) accentColorName should not be empty")
        }
    }

    // MARK: - Codable

    func test_codable_encodeDecode_lion_roundTrips() throws {
        let original = Chronotype.lion
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Chronotype.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_codable_encodeDecode_bear_roundTrips() throws {
        let original = Chronotype.bear
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Chronotype.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_codable_encodeDecode_wolf_roundTrips() throws {
        let original = Chronotype.wolf
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Chronotype.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_codable_encodeDecode_dolphin_roundTrips() throws {
        let original = Chronotype.dolphin
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Chronotype.self, from: data)
        XCTAssertEqual(decoded, original)
    }

    func test_codable_allChronotypes_roundTrip() throws {
        for chronotype in Chronotype.allCases {
            let data = try JSONEncoder().encode(chronotype)
            let decoded = try JSONDecoder().decode(Chronotype.self, from: data)
            XCTAssertEqual(decoded, chronotype, "\(chronotype) should round-trip through Codable")
        }
    }

    func test_codable_rawValue_encodesAsExpectedString() throws {
        let data = try JSONEncoder().encode(Chronotype.wolf)
        let jsonString = String(data: data, encoding: .utf8)
        XCTAssertEqual(jsonString, "\"wolf\"")
    }

    func test_codable_decodesFromRawValueString() throws {
        let jsonData = "\"lion\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(Chronotype.self, from: jsonData)
        XCTAssertEqual(decoded, .lion)
    }

    func test_codable_invalidString_throwsError() {
        let jsonData = "\"unicorn\"".data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(Chronotype.self, from: jsonData))
    }
}
