import ArgumentParser
import Foundation

struct LettersSolverCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "letters",
                                                    abstract: "Finds words from the given letters")

    @Option(name: .shortAndLong, help: "Dictionary url")
    var dictionary: String = env["DICTIONARY"] ?? "/usr/share/dict/words"

    @Option(name: .long, help: "Minimum length")
    var min: Int = 4

    @Option(name: .long, help: "Maximum length")
    var max: Int?

    @Option(name: .long, help: "Filter words that have definition")
    var filterWordsWithDefinitions: Bool = true

    @Argument(help: "Letters")
    var letters: String

    private static let env = ProcessInfo.processInfo.environment

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
        let solver = try await LetterSolver(letters: letters, dictionary: url, min: min, max: max)
        var solutions: [Int: [String]] = [:]
        for try await result in solver.findWords() {
            solutions[result.count, default: []].append(result)
        }
        print()
        print("The best solutions are:")

        let definitionFinder = WordDefinitionFinder()

        var displayedSections = 0
        var displayedWords = 0
        for length in solutions.keys.sorted().reversed() {
            defer {
                displayedSections += 1
            }
            if displayedWords >= 3 && displayedSections >= 2 {
                break
            }

            var numberOfSolutions = 0
            let results = solutions[length] ?? []
            for solution in results {
                let definition = definitionFinder.define(solution)
                if filterWordsWithDefinitions, definition == nil {
                    continue
                }

                if numberOfSolutions == 0 {
                    print("\(length) letter words")
                }
                numberOfSolutions += 1

                let formattedDefinition = definition.map { ": \($0)" } ?? ""
                print("- \(solution)\(formattedDefinition)")
            }
            displayedWords += results.count
        }
    }

}
