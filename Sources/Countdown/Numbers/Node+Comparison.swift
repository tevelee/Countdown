extension Node {
    func isShorter(than other: Node) -> Bool {
        compare(to: other, by: [
            { $0.steps().count },
            { $0.steps().map(\.count).reduce(into: 0, +=) }
        ])
    }

    func isLessComplex(than other: Node) -> Bool {
        compare(to: other, by: [
            { $0.complexity() },
            { $0.steps().count },
            { $0.steps().map(\.count).reduce(into: 0, +=) }
        ])
    }

    private func compare(to other: Node, by criteria: [(Node) -> Int]) -> Bool {
        for criterion in criteria {
            if criterion(self) < criterion(other) {
                return true
            } else if criterion(self) > criterion(other) {
                return false
            }
        }
        return false
    }

    private func complexity(scores: [Operation: Int] = [
        .addition: 1,
        .subtraction: 2,
        .multiplication: 5,
        .division: 10
    ], depth: Int = 0) -> Int {
        switch self {
        case .number:
            return 0
        case let .operation(operation, lhs, rhs, value):
            var operationScore = scores[operation] ?? 0
            if operation == .division {
                operationScore = rhs.value == 2 ? 2 : rhs.value == 3 ? 4 : 10
            }
            let valueScore = value.isMultiple(of: 10) ? 0 : value.isMultiple(of: 2) ? 2 : value.isMultiple(of: 5) ? 8 : 10
            let depthScore = depth
            return operationScore + valueScore + depthScore
                + lhs.complexity(scores: scores, depth: depth + 1)
                + rhs.complexity(scores: scores, depth: depth + 1)
        }
    }
}
