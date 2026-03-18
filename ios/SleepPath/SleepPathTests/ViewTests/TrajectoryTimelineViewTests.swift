import XCTest
import ViewInspector
@testable import SleepPath

final class TrajectoryTimelineViewTests: XCTestCase {

    private func makeBlock(
        type: TrajectoryBlockType,
        startOffset: TimeInterval,
        endOffset: TimeInterval,
        title: String
    ) -> TrajectoryBlock {
        let now = Date()
        return TrajectoryBlock(
            type: type,
            startTime: now.addingTimeInterval(startOffset),
            endTime: now.addingTimeInterval(endOffset),
            energyState: .rising,
            title: title,
            subtitle: "Test subtitle",
            icon: type.icon
        )
    }

    // MARK: - Content Display

    func test_displaysYourDayHeader() throws {
        let blocks = [makeBlock(type: .rising, startOffset: -3600, endOffset: 0, title: "Wake Up")]
        let sut = TrajectoryTimelineView(blocks: blocks)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Your Day"))
    }

    func test_displaysBlockTitles() throws {
        let blocks = [
            makeBlock(type: .rising, startOffset: -7200, endOffset: -6000, title: "Wake Up"),
            makeBlock(type: .peakFocus, startOffset: -3600, endOffset: 3600, title: "Peak Focus"),
        ]
        let sut = TrajectoryTimelineView(blocks: blocks)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        XCTAssertTrue(combined.contains("Wake Up"))
        XCTAssertTrue(combined.contains("Peak Focus"))
    }

    func test_displaysBlockIcons() throws {
        let blocks = [makeBlock(type: .sunlight, startOffset: -3600, endOffset: 0, title: "Sunlight")]
        let sut = TrajectoryTimelineView(blocks: blocks)
        let images = try sut.inspect().findAll(ViewType.Image.self)
        XCTAssertGreaterThan(images.count, 0, "Should display block icons")
    }

    // MARK: - Empty & Single Block

    func test_emptyBlocks_rendersWithoutError() throws {
        let sut = TrajectoryTimelineView(blocks: [])
        XCTAssertNoThrow(try sut.inspect())
    }

    func test_singleBlock_rendersWithoutError() throws {
        let blocks = [makeBlock(type: .sleep, startOffset: 3600, endOffset: 7200, title: "Sleep")]
        let sut = TrajectoryTimelineView(blocks: blocks)
        XCTAssertNoThrow(try sut.inspect())
    }

    // MARK: - All Block Types Render

    func test_allBlockTypes_renderWithoutError() throws {
        for blockType in TrajectoryBlockType.allCases {
            let blocks = [makeBlock(type: blockType, startOffset: 0, endOffset: 3600, title: blockType.displayName)]
            let sut = TrajectoryTimelineView(blocks: blocks)
            XCTAssertNoThrow(try sut.inspect(), "Should render \(blockType) without error")
        }
    }

    // MARK: - Full Trajectory Render

    func test_fullDayTrajectory_rendersWithoutError() throws {
        let blocks = MockDataService.shared.trajectoryBlocks(for: Date())
        let sut = TrajectoryTimelineView(blocks: blocks)
        XCTAssertNoThrow(try sut.inspect())
    }

    func test_fullDayTrajectory_displaysAllBlockTitles() throws {
        let blocks = MockDataService.shared.trajectoryBlocks(for: Date())
        let sut = TrajectoryTimelineView(blocks: blocks)
        let texts = try sut.inspect().findAll(ViewType.Text.self)
        let combined = try texts.map { try $0.string() }.joined(separator: " ")
        for block in blocks {
            XCTAssertTrue(combined.contains(block.title), "Should display '\(block.title)'")
        }
    }
}
