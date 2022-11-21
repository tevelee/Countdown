import XCTest
@testable import Countdown

final class WordDefinitionFinderTests: XCTestCase {
    func testExample() async throws {
        XCTAssertEqual(WordDefinitionFinder().define("handle"), "[with object] (verb) feel or manipulate with the hands")
    }
}
