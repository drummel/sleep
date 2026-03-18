import XCTest
@testable import SleepPath

final class UserProfileTests: XCTestCase {

    // MARK: - UserProfile

    func test_userProfile_storesAllProperties() {
        let date = Date()
        let profile = UserProfile(
            name: "Test User",
            chronotype: .lion,
            chronotypeSource: "quiz",
            chronotypeConfidence: 0.85,
            goal: .energy,
            ageRange: .thirtySix_45,
            isNightShift: true,
            caffeineSensitivity: .high,
            healthKitConnected: false,
            notificationsEnabled: true,
            scienceMode: true,
            isProSubscriber: false,
            createdAt: date
        )

        XCTAssertEqual(profile.name, "Test User")
        XCTAssertEqual(profile.chronotype, .lion)
        XCTAssertEqual(profile.chronotypeSource, "quiz")
        XCTAssertEqual(profile.chronotypeConfidence, 0.85)
        XCTAssertEqual(profile.goal, .energy)
        XCTAssertEqual(profile.ageRange, .thirtySix_45)
        XCTAssertTrue(profile.isNightShift)
        XCTAssertEqual(profile.caffeineSensitivity, .high)
        XCTAssertFalse(profile.healthKitConnected)
        XCTAssertTrue(profile.notificationsEnabled)
        XCTAssertTrue(profile.scienceMode)
        XCTAssertFalse(profile.isProSubscriber)
        XCTAssertEqual(profile.createdAt, date)
    }

    func test_userProfile_chronotypeValueAlias() {
        let profile = UserProfile(
            name: "Test", chronotype: .dolphin, chronotypeSource: "quiz",
            chronotypeConfidence: 0.9, goal: .focus, ageRange: nil,
            isNightShift: false, caffeineSensitivity: .normal,
            healthKitConnected: true, notificationsEnabled: true,
            scienceMode: false, isProSubscriber: true, createdAt: Date()
        )
        XCTAssertEqual(profile.chronotypeValue, profile.chronotype)
    }

    func test_userProfile_goalValueAlias() {
        let profile = UserProfile(
            name: "Test", chronotype: .bear, chronotypeSource: "quiz",
            chronotypeConfidence: 0.7, goal: .sleep, ageRange: nil,
            isNightShift: false, caffeineSensitivity: .low,
            healthKitConnected: false, notificationsEnabled: false,
            scienceMode: false, isProSubscriber: false, createdAt: Date()
        )
        XCTAssertEqual(profile.goalValue, profile.goal)
    }

    func test_userProfile_ageRangeCanBeNil() {
        let profile = UserProfile(
            name: "Test", chronotype: .wolf, chronotypeSource: "quiz",
            chronotypeConfidence: 0.5, goal: .all, ageRange: nil,
            isNightShift: false, caffeineSensitivity: .normal,
            healthKitConnected: false, notificationsEnabled: false,
            scienceMode: false, isProSubscriber: false, createdAt: Date()
        )
        XCTAssertNil(profile.ageRange)
    }

    // MARK: - UserGoal

    func test_userGoal_allCasesCount() {
        XCTAssertEqual(UserGoal.allCases.count, 4)
    }

    func test_userGoal_displayNames() {
        XCTAssertEqual(UserGoal.focus.displayName, "Improve Focus")
        XCTAssertEqual(UserGoal.sleep.displayName, "Better Sleep")
        XCTAssertEqual(UserGoal.energy.displayName, "More Energy")
        XCTAssertEqual(UserGoal.all.displayName, "All of the Above")
    }

    func test_userGoal_icons() {
        XCTAssertEqual(UserGoal.focus.icon, "scope")
        XCTAssertEqual(UserGoal.sleep.icon, "moon.fill")
        XCTAssertEqual(UserGoal.energy.icon, "bolt.fill")
        XCTAssertEqual(UserGoal.all.icon, "star.fill")
    }

    func test_userGoal_rawValues() {
        XCTAssertEqual(UserGoal.focus.rawValue, "focus")
        XCTAssertEqual(UserGoal.sleep.rawValue, "sleep")
        XCTAssertEqual(UserGoal.energy.rawValue, "energy")
        XCTAssertEqual(UserGoal.all.rawValue, "all")
    }

    func test_userGoal_codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for goal in UserGoal.allCases {
            let data = try encoder.encode(goal)
            let decoded = try decoder.decode(UserGoal.self, from: data)
            XCTAssertEqual(decoded, goal)
        }
    }

    func test_userGoal_displayNamesAreUnique() {
        let names = UserGoal.allCases.map { $0.displayName }
        XCTAssertEqual(Set(names).count, names.count, "Display names should be unique")
    }

    func test_userGoal_iconsAreUnique() {
        let icons = UserGoal.allCases.map { $0.icon }
        XCTAssertEqual(Set(icons).count, icons.count, "Icons should be unique")
    }

    // MARK: - CaffeineSensitivity

    func test_caffeineSensitivity_allCasesCount() {
        XCTAssertEqual(CaffeineSensitivity.allCases.count, 3)
    }

    func test_caffeineSensitivity_displayNames() {
        XCTAssertEqual(CaffeineSensitivity.low.displayName, "Low")
        XCTAssertEqual(CaffeineSensitivity.normal.displayName, "Normal")
        XCTAssertEqual(CaffeineSensitivity.high.displayName, "High")
    }

    func test_caffeineSensitivity_rawValues() {
        XCTAssertEqual(CaffeineSensitivity.low.rawValue, "low")
        XCTAssertEqual(CaffeineSensitivity.normal.rawValue, "normal")
        XCTAssertEqual(CaffeineSensitivity.high.rawValue, "high")
    }

    func test_caffeineSensitivity_codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for sensitivity in CaffeineSensitivity.allCases {
            let data = try encoder.encode(sensitivity)
            let decoded = try decoder.decode(CaffeineSensitivity.self, from: data)
            XCTAssertEqual(decoded, sensitivity)
        }
    }

    // MARK: - AgeRange

    func test_ageRange_allCasesCount() {
        XCTAssertEqual(AgeRange.allCases.count, 5)
    }

    func test_ageRange_displayNameEqualsRawValue() {
        for ageRange in AgeRange.allCases {
            XCTAssertEqual(ageRange.displayName, ageRange.rawValue)
        }
    }

    func test_ageRange_rawValues() {
        XCTAssertEqual(AgeRange.eighteen_25.rawValue, "18-25")
        XCTAssertEqual(AgeRange.twentySix_35.rawValue, "26-35")
        XCTAssertEqual(AgeRange.thirtySix_45.rawValue, "36-45")
        XCTAssertEqual(AgeRange.fortySix_55.rawValue, "46-55")
        XCTAssertEqual(AgeRange.fiftyFivePlus.rawValue, "55+")
    }

    func test_ageRange_codable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for range in AgeRange.allCases {
            let data = try encoder.encode(range)
            let decoded = try decoder.decode(AgeRange.self, from: data)
            XCTAssertEqual(decoded, range)
        }
    }
}
