struct Operation {
    let sign: String
    let precedence: Int
    let commutativity: Commutativity
    let perform: (Int, Int) throws -> Int

    enum Commutativity {
        case commutative
        indirect case operationWhenAppliedTwice(Operation)
        case none
    }

    var isCommutative: Bool {
        if case .commutative = commutativity {
            return true
        }
        return false
    }

    init(sign: String,
         precedence: Int = 0,
         commutativity: Commutativity,
         perform: @escaping (Int, Int) throws -> Int) {
        self.sign = sign
        self.precedence = precedence
        self.commutativity = commutativity
        self.perform = perform
    }
}

extension Operation: Equatable {
    static func == (lhs: Operation, rhs: Operation) -> Bool {
        lhs.sign == rhs.sign
    }
}

extension Operation: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(sign)
    }
}

// 5 - (1 - 2)    5 + 2 - 1

extension Operation {
    static let addition: Self = .init(sign: "+", commutativity: .commutative, perform: +)
    static let subtraction: Self = .init(sign: "-", commutativity: .operationWhenAppliedTwice(addition)) { lhs, rhs in
        guard lhs > rhs else { throw "Result must be positive" }
        return lhs - rhs
    }
    static let multiplication: Self = .init(sign: "*", precedence: 1, commutativity: .commutative, perform: *)
    static let division: Self = .init(sign: "/", precedence: 1, commutativity: .operationWhenAppliedTwice(multiplication)) { lhs, rhs in
        guard rhs != 0 else { throw "Cannot divide by zero" }
        guard lhs.isMultiple(of: rhs) else { throw "Result must be integer" }
        return Int(lhs / rhs)
    }
}
