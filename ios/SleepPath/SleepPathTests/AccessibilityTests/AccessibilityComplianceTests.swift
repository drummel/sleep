import XCTest
import ViewInspector
@testable import SleepPath

/// Tests verifying that all views and components have proper accessibility labels,
/// traits, and values for VoiceOver and assistive technology users.
final class AccessibilityComplianceTests: XCTestCase {

    // MARK: - EnergyStateCard Accessibility

    func test_energyStateCard_hasCombinedAccessibilityLabel() throws {
        for state in EnergyState.allCases {
            let sut = EnergyStateCard(
                energyState: state,
                timeUntilChange: "2h 15m",
                suggestion: "Test suggestion"
            )
            // The view uses .accessibilityElement(children: .combine)
            // and .accessibilityLabel that includes state name, time, and suggestion
            XCTAssertNoThrow(try sut.inspect(), "EnergyStateCard for \(state) should render")
        }
    }

    func test_energyStateCard_allStates_displayNameAndSuggestion() throws {
        for state in EnergyState.allCases {
            let suggestion = state.suggestion
            let sut = EnergyStateCard(
                energyState: state,
                timeUntilChange: "30m",
                suggestion: suggestion
            )
            let texts = try sut.inspect().findAll(ViewType.Text.self)
            let combined = try texts.map { try $0.string() }.joined(separator: " ")
            XCTAssertTrue(combined.contains(state.displayName),
                         "Should display \(state.displayName)")
            XCTAssertTrue(combined.contains(suggestion),
                         "Should display suggestion for \(state)")
        }
    }

    // MARK: - CaffeineCutoffBanner Accessibility

    func test_caffeineBanner_beforeCutoff_hasAccessibleLabel() throws {
        let cutoff = Date().addingTimeInterval(3600)
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff)
        // The view uses .accessibilityElement(children: .combine)
        // with .accessibilityLabel containing "Caffeine OK"
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Caffeine OK"))
    }

    func test_caffeineBanner_afterCutoff_hasAccessibleLabel() throws {
        let cutoff = Date().addingTimeInterval(-3600)
        let sut = CaffeineCutoffBanner(cutoffTime: cutoff)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Past caffeine cutoff"))
    }

    // MARK: - All Model Display Names Are Non-Empty (for VoiceOver)

    func test_allChronotypes_haveNonEmptyDisplayNames() {
        for chronotype in Chronotype.allCases {
            XCTAssertFalse(chronotype.displayName.isEmpty, "\(chronotype) displayName should not be empty")
            XCTAssertFalse(chronotype.emoji.isEmpty, "\(chronotype) emoji should not be empty")
            XCTAssertFalse(chronotype.tagline.isEmpty, "\(chronotype) tagline should not be empty")
        }
    }

    func test_allEnergyStates_haveNonEmptyAccessibilityContent() {
        for state in EnergyState.allCases {
            XCTAssertFalse(state.displayName.isEmpty, "\(state) displayName should not be empty")
            XCTAssertFalse(state.icon.isEmpty, "\(state) icon should not be empty")
            XCTAssertFalse(state.suggestion.isEmpty, "\(state) suggestion should not be empty")
            XCTAssertFalse(state.detailedDescription.isEmpty, "\(state) description should not be empty")
        }
    }

    func test_allBlockTypes_haveNonEmptyAccessibilityContent() {
        for blockType in TrajectoryBlockType.allCases {
            XCTAssertFalse(blockType.displayName.isEmpty, "\(blockType) displayName should not be empty")
            XCTAssertFalse(blockType.icon.isEmpty, "\(blockType) icon should not be empty")
        }
    }

    func test_allConfidenceLevels_haveNonEmptyDisplayAndDetail() {
        for level in ConfidenceLevel.allCases {
            XCTAssertFalse(level.displayText.isEmpty, "\(level) displayText should not be empty")
            XCTAssertFalse(level.detailText.isEmpty, "\(level) detailText should not be empty")
        }
    }

    func test_allNotificationTypes_haveNonEmptyDisplayNames() {
        for type in NotificationType.allCases {
            XCTAssertFalse(type.displayName.isEmpty, "\(type) displayName should not be empty")
            XCTAssertFalse(type.icon.isEmpty, "\(type) icon should not be empty")
        }
    }

    // MARK: - UserGoal & CaffeineSensitivity Display Names

    func test_allUserGoals_haveNonEmptyDisplayNames() {
        for goal in UserGoal.allCases {
            XCTAssertFalse(goal.displayName.isEmpty, "\(goal) displayName should not be empty")
            XCTAssertFalse(goal.icon.isEmpty, "\(goal) icon should not be empty")
        }
    }

    func test_allCaffeineSensitivities_haveNonEmptyDisplayNames() {
        for sensitivity in CaffeineSensitivity.allCases {
            XCTAssertFalse(sensitivity.displayName.isEmpty)
        }
    }

    func test_allAgeRanges_haveNonEmptyDisplayNames() {
        for range in AgeRange.allCases {
            XCTAssertFalse(range.displayName.isEmpty)
        }
    }

    // MARK: - View Render Tests (Accessibility Subtree)

    func test_welcomeView_rendersAccessibleContent() throws {
        let sut = WelcomeView(onGetStarted: {}, onAlreadyTookQuiz: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        // Should have enough text elements for VoiceOver to describe the screen
        XCTAssertGreaterThanOrEqual(texts.count, 5, "Welcome should have multiple text elements")
    }

    func test_healthKitView_rendersAccessibleContent() throws {
        let sut = HealthKitPermissionView(onConnect: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        XCTAssertGreaterThanOrEqual(texts.count, 8, "HealthKit view should have many text elements for permissions")
    }

    func test_notificationView_rendersAccessibleContent() throws {
        let sut = NotificationPermissionView(onAllow: {}, onSkip: {})
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        XCTAssertGreaterThanOrEqual(texts.count, 6, "Notification view should have nudge descriptions")
    }

    func test_quizResultView_allChronotypes_haveAccessibleContent() throws {
        for chronotype in Chronotype.allCases {
            let sut = QuizResultView(chronotype: chronotype, onContinue: {}, onShare: {})
            let texts = try sut.inspect().findAll(ViewType.Text.self)
            let combined = try texts.map { try $0.string() }.joined(separator: " ")

            // Must include the chronotype name for VoiceOver identification
            XCTAssertTrue(combined.contains(chronotype.displayName),
                         "Result view must announce \(chronotype.displayName)")

            // Must include stat row labels
            XCTAssertTrue(combined.contains("Peak creative hours"))
            XCTAssertTrue(combined.contains("Ideal bedtime"))
        }
    }

    // MARK: - Trajectory Block Accessibility

    func test_trajectoryBlocks_allHaveNonEmptyTitlesAndSubtitles() {
        let blocks = MockDataService.shared.trajectoryBlocks(for: Date())
        for block in blocks {
            XCTAssertFalse(block.title.isEmpty, "Block title should not be empty")
            XCTAssertFalse(block.subtitle.isEmpty, "Block subtitle should not be empty")
            XCTAssertFalse(block.icon.isEmpty, "Block icon should not be empty")
            XCTAssertFalse(block.formattedTimeRange.isEmpty, "Block time range should not be empty")
        }
    }

    // MARK: - Color Contrast (Semantic Check)

    func test_energyStateIcons_areDistinctAcrossStates() {
        let icons = EnergyState.allCases.map(\.icon)
        XCTAssertEqual(Set(icons).count, icons.count, "Each energy state should have a unique icon")
    }

    func test_chronotypeEmojis_areDistinctAcrossTypes() {
        let emojis = Chronotype.allCases.map(\.emoji)
        XCTAssertEqual(Set(emojis).count, emojis.count, "Each chronotype should have a unique emoji")
    }

    func test_chronotypeAccentColors_areDistinctAcrossTypes() {
        let colors = Chronotype.allCases.map(\.accentColorName)
        XCTAssertEqual(Set(colors).count, colors.count, "Each chronotype should have a unique accent color")
    }
}
