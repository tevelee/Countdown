import Foundation

final class NumberSolver {
    private let target: Int
    private let numbers: [Int]
    private let operations: [Operation]

    init(target: Int,
         numbers: [Int],
         operations: [Operation] = [.multiplication, .addition, .subtraction, .division]) throws {
//        guard numbers.count == 6 else {
//            throw "There should be 6 numbers"
//        }
        guard numbers.allSatisfy({ $0 > 0 }) else {
            throw "All numbers should be positive integers"
        }
        guard !operations.isEmpty else {
            throw "There should be at least one operation to work with"
        }
        self.target = target
        self.numbers = numbers.sorted().reversed()
        self.operations = operations
    }

    func solutions() -> AsyncThrowingStream<(reason: String, solution: Node), Error> {
        .async { continuation in
            var solutions: Set<Node> = []
            await self.build(availableNodes: self.numbers.map(Node.number)) { solution in
                guard !solutions.contains(solution) else { return }
                var reason = "Found a new solution"
                for existing in solutions where solution.isSemanticallyEqual(to: existing) {
                    if solution.isLessComplex(than: existing) {
                        reason = "Found a less complex solution instead of [\(existing.steps().joined(separator: ", "))]"
                        solutions.remove(existing)
                        break
                    } else {
                        return
                    }
                }
                solutions.insert(solution)
                continuation.yield((reason, solution))
            }
            if solutions.isEmpty {
                continuation.finish(throwing: "Cannot be solved")
            } else {
                continuation.finish()
            }
        }
    }

    private func build(availableNodes: [Node], result: (Node) async -> Void) async {
        guard !Task.isCancelled, !availableNodes.isEmpty else {
            return
        }
        if let node = availableNodes.first(where: { $0.value == target }) {
            await result(node.reduced())
            // return // TODO: do we need to early return or let's wait for a less complex solution in the same tree?
        }
        for index1 in availableNodes.startIndex ..< availableNodes.endIndex {
            for index2 in index1.advanced(by: 1) ..< availableNodes.endIndex {
                let lhs = availableNodes[index1]
                let rhs = availableNodes[index2]
                for operation in operations {
                    guard let computedValue = try? operation.perform(lhs.value, rhs.value) else {
                        continue
                    }
                    let isTrivial = computedValue == lhs.value || computedValue == rhs.value
                    if isTrivial || computedValue == 0 {
                        continue
                    }
                    let node = Node.operation(operation: operation, lhs: lhs, rhs: rhs, value: computedValue)
                    var availableNodesForNextIteration = availableNodes
                    availableNodesForNextIteration.remove(at: index2)
                    availableNodesForNextIteration.remove(at: index1)
                    availableNodesForNextIteration.insert(node, at: 0)
                    await build(availableNodes: availableNodesForNextIteration, result: result)
                }
            }
        }
    }
}

extension String: Error {}
