enum Node: Hashable {
    indirect case operation(operation: Operation, lhs: Node, rhs: Node, value: Int)
    case number(Int)

    var value: Int {
        switch self {
        case let .number(value):
            return value
        case let .operation(_, _, _, value):
            return value
        }
    }

    var operation: Operation? {
        if case .operation(let operation, _, _, _) = self {
            return operation
        }
        return nil
    }

    func steps(groupBy grouping: Grouping = .precedence) -> [String] {
        switch reduced() {
        case let .operation(operation, lhs, rhs, value):
            let lStep = lhs.partialResult(operation: operation, groupBy: grouping)
            let rStep = rhs.partialResult(operation: operation, groupBy: grouping)
            let rhsNeedsParens = !operation.isCommutative && rhs.operation.map { $0.precedence == operation.precedence } ?? false
            return lStep.steps + rStep.steps + ["\(lStep.result) \(operation.sign) \(rStep.result.usingParens(rhsNeedsParens)) = \(value)"]
        case .number:
            return []
        }
    }

    private func partialResult(operation: Operation, groupBy grouping: Grouping) -> (steps: [String], result: String) {
        if case let .operation(nextOperation, nextLhs, nextRhs, _) = self, grouping.groupBy(operation, nextOperation) {
            let lhs = nextLhs.partialResult(operation: nextOperation, groupBy: grouping)
            let rhs = nextRhs.partialResult(operation: nextOperation, groupBy: grouping)
            let rhsNeedsParens = !nextOperation.isCommutative && nextRhs.operation.map { $0.precedence == nextOperation.precedence } ?? false
            let content = "\(lhs.result) \(nextOperation.sign) \(rhs.result.usingParens(rhsNeedsParens))"
            return (lhs.steps + rhs.steps, content)
        } else {
            return (steps(groupBy: grouping), String(value))
        }
    }

    func reduced() -> Node {
        let reducedNode = _reduced()
        if reducedNode == self {
            return self
        } else {
            return reducedNode.reduced()
        }
    }

    private func _reduced() -> Node {
        if case let .operation(operation, lhs, rhs, value) = self {
            if case let .operation(childOperation, childLhs, childRhs, _) = rhs,
                operation.precedence == childOperation.precedence,
               case .operationWhenAppliedTwice(let switchedOperation) = operation.commutativity {
                let childLhs = childLhs.reduced()
                let childRhs = childRhs.reduced()
                if operation == childOperation {
                    if let childValue = try? operation.perform(childRhs.value, childLhs.value) { // 5 - (1 - 2)  -->  5 + (2 - 1)
                        let newRhs: Node = .operation(operation: operation, lhs: childRhs, rhs: childLhs, value: childValue)
                        return .operation(operation: switchedOperation, lhs: lhs, rhs: newRhs, value: value)
                    } else if let childValue = try? operation.perform(lhs.value, childLhs.value) { // 5 - (1 - 2)  -->  (5 - 1) + 2
                        let newLhs: Node = .operation(operation: operation, lhs: lhs, rhs: childLhs, value: childValue)
                        return .operation(operation: switchedOperation, lhs: newLhs, rhs: childRhs, value: value)
                    }
                } else if childOperation.isCommutative {
                    if let childValue = try? operation.perform(lhs.value, childLhs.value) { // 5 - (1 + 2)  -->  (5 - 1) - 2
                        let newLhs: Node = .operation(operation: operation, lhs: lhs, rhs: childLhs, value: childValue)
                        return .operation(operation: operation, lhs: newLhs, rhs: childRhs, value: value)
                    } else if let childValue = try? operation.perform(lhs.value, childRhs.value) { // 5 - (1 + 2)  -->  (5 - 2) - 1
                        let newLhs: Node = .operation(operation: operation, lhs: lhs, rhs: childRhs, value: childValue)
                        return .operation(operation: operation, lhs: newLhs, rhs: childLhs, value: value)
                    }
                }
            } else {
                return .operation(operation: operation, lhs: lhs.reduced(), rhs: rhs.reduced(), value: value)
            }
        }
        return self
    }
}

struct Grouping {
    let groupBy: (Operation, Operation) -> Bool

    static let none = Grouping { _, _ in false }
    static let sameOperations = Grouping(groupBy: ==)
    static let precedence = Grouping { $0.precedence == $1.precedence }
}

extension Node: CustomStringConvertible {
    var description: String {
        descriptionFunction()
    }

    func descriptionFunction(alwaysUseParens: Bool = false) -> String {
        switch self {
        case let .number(value):
            return String(value)
        case let .operation(operation, lhs, rhs, _):
            let lDescription = lhs.descriptionFunction(alwaysUseParens: alwaysUseParens)
            let rDescription = rhs.descriptionFunction(alwaysUseParens: alwaysUseParens)
            if alwaysUseParens {
                return "\(lDescription) \(operation.sign) \(rDescription)".usingParens()
            } else {
                let (lhsNeedsParens, rhsNeedsParens) = needsParens(parent: operation, lhs: lhs, rhs: rhs)
                return "\(lDescription.usingParens(lhsNeedsParens)) \(operation.sign) \(rDescription.usingParens(rhsNeedsParens))"
            }
        }
    }

    private func needsParens(parent: Operation, lhs: Node, rhs: Node) -> (lhs: Bool, rhs: Bool) {
        var lhsNeedsParens = false
        if case let .operation(child, _, _, _) = lhs,
           child.precedence < parent.precedence {
            lhsNeedsParens = true
        }
        var rhsNeedsParens = false
        if case let .operation(child, _, _, _) = rhs,
           child.precedence < parent.precedence || !parent.isCommutative {
            rhsNeedsParens = true
        }
        return (lhsNeedsParens, rhsNeedsParens)
    }
}

private extension String {
    func usingParens(_ useParens: Bool = true) -> String {
        useParens ? "(\(self))" : self
    }
}
