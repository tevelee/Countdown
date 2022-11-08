import ArgumentParser

struct NumbersCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "numbers",
                                                    abstract: "Tries to achieve the target number combining the given numbers with basic operations")

    @Argument(help: "Numbers separated by whitespaces")
    var numbers: [Int]

    @Option(name: .shortAndLong, help: "Target")
    var target: Int

    @Option(name: .shortAndLong, help: "Operators to use, comma separated", transform: {
        $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    })
    var operators: [String] = ["+", "-", "*", "/"]

    mutating func run() async throws {
        let solver = try NumberSolver(target: target, numbers: numbers, operations: operators.map(Self.operation(from:)))

        var shortestSolution: Node?
        print("Finding solutions...")
        for try await (reason, solution) in solver.solutions() {
            let steps = solution.steps().joined(separator: ", ")
            print("\(reason): \(steps)")
            await Task.yield()
            if shortestSolution.map(solution.isLessComplex) ?? true {
                shortestSolution = solution
            }
        }
        if let solution = shortestSolution {
            print()
            print("The easiest solution was \(solution.description)")
            print()
            print(solution.tree())
            print()
            print(solution.steps().joined(separator: "\n"))
        }
    }

    private static func operation(from sign: String) throws -> Operation {
        switch sign {
        case "+": return .addition
        case "-": return .subtraction
        case "*": return .multiplication
        case "/": return .division
        default: throw "Unsupported operator \(sign)"
        }
    }
}
