import XCTest
@testable import Countdown
import ArgumentParser

final class ConondrumsTests: XCTestCase {
    func testExample() async throws {
        let solver = try await ConondrumSolver(target: "irbd", dictionary: URL(fileURLWithPath: "/usr/share/dict/words"))
        let match = await solver.findAnagrams().first!
        XCTAssertEqual(match, "bird")
    }
}
