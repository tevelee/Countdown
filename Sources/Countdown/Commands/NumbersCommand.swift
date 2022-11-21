import ArgumentParser

struct NumbersCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "numbers",
                                                    abstract: "Tries to achieve the target number combining the given numbers with basic operations")

    @Argument(help: "Numbers separated by whitespaces")
    var numbers: [Int]

    @Option(name: .shortAndLong, help: "Target")
    var target: Int

    @Option(name: .shortAndLong, help: "Broaden target if fails to solve")
    var broadenTarget: Bool = true

    @Option(name: .shortAndLong, help: "Operators to use, comma separated", transform: {
        $0.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    })
    var operators: [String] = ["+", "-", "*", "/"]

    mutating func run() async throws {
        try await solve(target: target, tryToBroadenTarget: broadenTarget)
    }

    @discardableResult
    private func solve(target: Int, tryToBroadenTarget: Bool) async throws -> Bool {
        let solver = try NumberSolver(target: target, numbers: numbers, operations: operators.map(Self.operation(from:)))

        var shortestSolution: Node?
        print("Finding solutions...")
        do {
            for try await (reason, solution) in solver.solutions() {
                let steps = solution.steps().joined(separator: ", ")
                print("\(reason): \(steps)")
                await Task.yield()
                if shortestSolution.map(solution.isLessComplex) ?? true {
                    shortestSolution = solution
                }
            }
        } catch {}
        if let solution = shortestSolution {
            print()
            print("The easiest solution was \(solution.description)")
            print()
            print(solution.tree())
            print()
            print(solution.steps().joined(separator: "\n"))
            return true
        } else if tryToBroadenTarget {
            print("Found no solution")
            for broader in 1...10 {
                print("")
                print("Trying \(broader) lower \(target - broader)")
                do {
                    if try await solve(target: target - broader, tryToBroadenTarget: false) {
                        return true
                    }
                } catch {}
                print("")
                print("Trying \(broader) larger \(target + broader)")
                do {
                    if try await solve(target: target + broader, tryToBroadenTarget: false) {
                        return true
                    }
                } catch {}
            }
        }
        throw "Cannot be solved"
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
