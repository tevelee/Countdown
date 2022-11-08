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
    ]) -> Int {
        switch self {
        case .number:
            return 0
        case let .operation(operation, lhs, rhs, _):
            let score = scores[operation] ?? 0
            return lhs.complexity(scores: scores) + rhs.complexity(scores: scores) + score
        }
    }
}
