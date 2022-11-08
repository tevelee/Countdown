import XCTest
@testable import Countdown
import ArgumentParser

final class LetterTests: XCTestCase {
    func testExample() async throws {
//        let solver = try await LetterSolver(target: "conondrum", dictionary: URL(fileURLWithPath: "/usr/share/dict/words"))
        let solver = LetterSolver(letters: "gicpisefc", words: ["test", "specific"])
        let match = await solver.findWords().first!
        XCTAssertEqual(match, "specific")
    }
}
