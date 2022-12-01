import XCTest
@testable import Countdown
import ArgumentParser

final class NumbersTests: XCTestCase {
    func testExample() async throws {
        let solver = try NumberSolver(target: 362, numbers: [7, 9, 10, 6, 100, 75])
        var counter = 1
        for try await (reason, solution) in solver.solutions() {
            print("Solution #\(counter): \(reason) \(solution.description)")
            print()
            print(solution.tree())
            print()
            print(solution.steps().joined(separator: "\n"))
            print("---------------------------")
            counter += 1
        }
    }

    func testSteps() async throws {
        let node: Node = try >4 * 5 - (10 - (1 + 2 + 3))
        XCTAssertEqual(node.steps().joined(separator: "\n"), """
            4 * 5 = 20
            20 - 10 + 1 + 2 + 3 = 16
            """)
        XCTAssertEqual(node.description, "4 * 5 - (10 - (1 + 2 + 3))")

        let solver = try NumberSolver(target: 361, numbers: [7, 9, 10, 6, 25, 75])
        let solution = await solver.solutions().first?.solution
        XCTAssertEqual(solution?.steps(groupBy: .precedence).joined(separator: "\n"), """
            75 - 25 - 10 = 40
            40 * 9 = 360
            360 + 7 - 6 = 361
            """)
        XCTAssertEqual(solution?.steps(groupBy: .sameOperations).joined(separator: "\n"), """
            75 - 25 - 10 = 40
            40 * 9 = 360
            360 + 7 = 367
            367 - 6 = 361
            """)
        XCTAssertEqual(solution?.steps(groupBy: .none).joined(separator: "\n"), """
            75 - 25 = 50
            50 - 10 = 40
            40 * 9 = 360
            360 + 7 = 367
            367 - 6 = 361
            """)
    }

    func testDecription() throws {
        let node: Node = try .multiply(.add(.add(100, 75), 6), .subtract(9, 7))
        XCTAssertEqual(node.descriptionFunction(alwaysUseParens: true), "(((100 + 75) + 6) * (9 - 7))")
        XCTAssertEqual(node.descriptionFunction(alwaysUseParens: false), "(100 + 75 + 6) * (9 - 7)")
    }

    func testReduce() throws {
        let node: Node = try .subtract(.subtract(.multiply(50, 9), .add(75, 7)), 6)
        XCTAssertEqual(node.description, "50 * 9 - (75 + 7) - 6")
        XCTAssertEqual(node.reduced().description, "50 * 9 - 75 - 7 - 6")
    }

    func testReduce2() throws {
        let node: Node = try >20 - (10 - (1 + 2 + 3))
        XCTAssertEqual(node.description, "20 - (10 - (1 + 2 + 3))")
        XCTAssertEqual(node.reduced().description, "20 - 10 + 1 + 2 + 3")
    }

    func testSemanticallyEqualNodes_numbersOnly() throws {
        let nodes: [Node] = [
            try .multiply(2, .multiply(3, 4)),
            try .multiply(2, .multiply(4, 3)),
            try .multiply(3, .multiply(2, 4)),
            try .multiply(3, .multiply(4, 2)),
            try .multiply(4, .multiply(2, 3)),
            try .multiply(4, .multiply(3, 2)),

            try .multiply(.multiply(3, 4), 2),
            try .multiply(.multiply(4, 3), 2),
            try .multiply(.multiply(2, 4), 3),
            try .multiply(.multiply(4, 2), 3),
            try .multiply(.multiply(2, 3), 4),
            try .multiply(.multiply(3, 2), 4),
        ]
        for node in nodes {
            if let other = nodes.first(where: { !$0.isSemanticallyEqual(to: node) }) {
                throw "Not equal \(node.description) and \(other.description)"
            }
        }
    }

    func testSemanticallyEqualNodes_commutativeTrees() throws {
        let base: Node = try .multiply(.multiply(20, 30), .multiply(40, 50))
        let nodes: [Node] = [
            try .multiply(.multiply(3, base), 2),
            try .multiply(.multiply(2, base), 3),
            try .multiply(2, .multiply(3, base)),
            try .multiply(3, .multiply(2, base)),

            try .multiply(.multiply(base, 3), 2),
            try .multiply(.multiply(base, 2), 3),
            try .multiply(2, .multiply(base, 3)),
            try .multiply(3, .multiply(base, 2)),

            try .multiply(.multiply(3, 2), base),
            try .multiply(.multiply(2, 3), base),
            try .multiply(base, .multiply(3, 2)),
            try .multiply(base, .multiply(2, 3)),
        ]
        for node in nodes {
            if let other = nodes.first(where: { !$0.isSemanticallyEqual(to: node) }) {
                throw "Not equal \(node.description) and \(other.description)"
            }
        }
    }

    func testSemanticallyEqualNodes_complexTrees() throws {
        let base: Node = try .multiply(.multiply(20, 30), .multiply(40, 50))
        let nodes: [Node] = [
            try .multiply(.multiply(2, 3), .multiply(4, base)),
            try .multiply(.multiply(2, 4), .multiply(3, base)),
            try .multiply(.multiply(3, 4), .multiply(2, base)),
            try .multiply(.multiply(3, 2), .multiply(4, base)),
            try .multiply(.multiply(4, 2), .multiply(3, base)),
            try .multiply(.multiply(4, 3), .multiply(2, base)),
        ]
        for node in nodes {
            if let other = nodes.first(where: { !$0.isSemanticallyEqual(to: node) }) {
                throw "Not equal \(node.description) and \(other.description)"
            }
        }
    }
}

extension AsyncThrowingStream {
    var first: Element? {
        get async {
            do {
                for try await item in self {
                    return item
                }
            } catch {}
            return nil
        }
    }
}
