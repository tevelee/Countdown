extension Node {
    @inlinable
    func isSemanticallyEqual(to other: Node) -> Bool {
        if self == other {
            return true
        }
        guard self.value == other.value else {
            return false
        }

        // Commutativity
        if case let .operation(thisOperation, thisLhs, thisRhs, _) = self,
           case let .operation(thatOperation, thatLhs, thatRhs, _) = other,
           thisOperation == thatOperation {
            if thisLhs.isSemanticallyEqual(to: thatLhs),
               thisLhs.isSemanticallyEqual(to: thatRhs) {
                return true
            } else if thisOperation.isCommutative,
               thisLhs.isSemanticallyEqual(to: thatRhs),
               thisRhs.isSemanticallyEqual(to: thatLhs) {
                return true
            }
        }

        if stepValues(groupBy: .precedence) == other.stepValues(groupBy: .precedence) {
            return true
        }

        return false
    }

    @inlinable
    func stepValues(groupBy grouping: Grouping) -> [Int] {
        switch self {
        case let .operation(operation, lhs, rhs, value):
            let lStep = lhs.partialValues(operation: operation, groupBy: grouping)
            let rStep = rhs.partialValues(operation: operation, groupBy: grouping)
            return (lStep + rStep + [value]).sorted()
        case .number:
            return []
        }
    }

    private func partialValues(operation: Operation, groupBy grouping: Grouping) -> [Int] {
        if case let .operation(nextOperation, nextLhs, nextRhs, _) = self, grouping.groupBy(operation, nextOperation) {
            let lhs = nextLhs.partialValues(operation: nextOperation, groupBy: grouping)
            let rhs = nextRhs.partialValues(operation: nextOperation, groupBy: grouping)
            return lhs + rhs
        } else {
            return stepValues(groupBy: grouping)
        }
    }
}

private struct SequentialOperations {
    struct Operand: Equatable {
        let operation: Operation
        let value: Int
    }
    let base: Node
    let op1: Operand
    let op2: Operand

    func isSemanticallyEqual(to other: SequentialOperations) -> Bool {
        switch base {
        case .number:
            return isCompatible(op1.operation, op2.operation)
        case .operation where base.isSemanticallyEqual(to: other.base) && op1 == other.op1 && op2 == other.op2:
            return isCompatible(op1.operation, op2.operation)
        case .operation where base.isSemanticallyEqual(to: other.base) && op1 == other.op2 && op2 == other.op1:
            return isCompatible(op1.operation, op2.operation)
        default:
            return false
        }
    }

    private func isCompatible(_ op1: Operation, _ op2: Operation) -> Bool {
        switch (op1, op2) {
        case (.multiplication, .multiplication),
            (.multiplication, .division),
            (.division, .multiplication),
            (.addition, .addition),
            (.addition, .subtraction),
            (.subtraction, .addition):
            return true
        default:
            return false
        }
    }
    }
