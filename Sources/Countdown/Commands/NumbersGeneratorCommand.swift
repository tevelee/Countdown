import ArgumentParser
import Foundation

struct NumbersGeneratorCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "numbers",
                                                    abstract: "Generates numbers round")

    @Option(name: .long, help: "The number of big numbers to choose")
    var big: Int = 2

    @Option(name: .long, help: "Total numbers to choose")
    var total: Int = 6

    @Option(name: .long, help: "All the big numbers")
    var bigNumbers: [Int] = [25, 50, 75, 100]

    @Option(name: .long, help: "All the small numbers")
    var smallNumbers: [Int] = Array(1...10)

    @Option(name: .long, help: "Show solution")
    var solve: Bool = false

    mutating func run() async throws {
        guard total >= big else {
            throw "Total must not exceed number of big ones chosen"
        }
        guard total > 0 else {
            throw "Total must be greater than zero"
        }
        print("With \(big) big ones and \(total - big) little ones the numbers are:")
        let numbers = choose(count: big, from: bigNumbers) + choose(count: total - big, from: smallNumbers)
        let formatted = ListFormatter().string(from: numbers) ?? numbers.map(\.description).joined(separator: ", ")
        print(formatted)
        let target = Int.random(in: 100 ... 1000)
        print("And the target is \(target)")
        if solve {
            try await NumberSolverPrinter(target: target, numbers: numbers).printSolution()
        } else {
            print("")
            print("Solve this by running:")
            print("swift run Countdown numbers \(numbers.map(\.description).joined(separator: " ")) --target \(target)")
        }
    }

    private func choose<T>(count: Int, from original: [T]) -> [T] {
        var pool = original
        var result: [T] = []
        while result.count < count {
            if let index = pool.indices.randomElement() {
                result.append(pool.remove(at: index))
            } else {
                pool = original
            }
        }
        return result
    }
}
