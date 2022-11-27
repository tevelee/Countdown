@testable import Countdown

extension Node: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(value)
    }
}

extension Node {
    static func add(_ lhs: Node, _ rhs: Node) throws -> Node {
        try operation(.addition, lhs: lhs, rhs: rhs)
    }

    static func multiply(_ lhs: Node, _ rhs: Node) throws -> Node {
        try operation(.multiplication, lhs: lhs, rhs: rhs)
    }

    static func divide(_ lhs: Node, _ rhs: Node) throws -> Node {
        try operation(.division, lhs: lhs, rhs: rhs)
    }

    static func subtract(_ lhs: Node, _ rhs: Node) throws -> Node {
        try operation(.subtraction, lhs: lhs, rhs: rhs)
    }

    private static func operation(_ operation: Operation, lhs: Node, rhs: Node) throws -> Node {
        let value = try operation.perform(lhs.value, rhs.value)
        return .operation(operation: operation, lhs: lhs, rhs: rhs, value: value)
    }
}

prefix operator >
extension Int {
    static prefix func >(number: Int) -> Node {
        .number(number)
    }
}

func +(lhs: Node, rhs: Node) throws -> Node {
    try .add(lhs, rhs)
}

func -(lhs: Node, rhs: Node) throws -> Node {
    try .subtract(lhs, rhs)
}

func *(lhs: Node, rhs: Node) throws -> Node {
    try .multiply(lhs, rhs)
}

func /(lhs: Node, rhs: Node) throws -> Node {
    try .divide(lhs, rhs)
}
