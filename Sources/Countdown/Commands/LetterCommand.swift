import ArgumentParser
import Foundation

struct LettersCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "letters",
                                                    abstract: "Finds words from the given letters")

    @Option(name: .shortAndLong, help: "Dictionary url")
    var dictionary: String = "/usr/share/dict/words"

    @Argument(help: "Letters")
    var letters: String

    private var url: URL {
        get throws {
            if dictionary.hasPrefix("http") {
                guard let validURL = URL(string: dictionary) else {
                    throw "Invalid url \(dictionary)"
                }
                return validURL
            } else {
                return URL(fileURLWithPath: dictionary)
            }
        }
    }

    mutating func run() async throws {
        let solver = try await LetterSolver(letters: letters, dictionary: url)
        var solutions: [Int: [String]] = [:]
        for try await result in solver.findWords() {
            solutions[result.count, default: []].append(result)
        }
        print()
        print("The best solutions are:")

        var displayedSections = 0
        var displayedWords = 0
        for length in solutions.keys.sorted().reversed() {
            defer {
                displayedSections += 1
            }
            if displayedWords >= 3 && displayedSections >= 2 {
                break
            }

            print("\(length) letter words")
            let results = solutions[length] ?? []
            for solution in results {
                print("- \(solution)")
            }
            displayedWords += results.count
        }
    }

}
