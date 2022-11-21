import ArgumentParser
import Foundation

struct LettersGeneratorCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "letters",
                                                    abstract: "Generates letters round")

    @Option(name: .long, help: "The number of vowels to choose")
    var vowels: Int = 4

    @Option(name: .long, help: "The number of consonants to choose")
    var consonants: Int = 5

    @Option(name: .long, help: "Use the countdown rules (min 3 vowels and min 4 consonants)")
    var countdownRules: Bool = true

    @Option(name: .long, help: "Show solution")
    var solve: Bool = false

    @Option(name: .long, help: "Filter words that have definition")
    var filterWordsWithDefinitions: Bool = true

    @Option(name: .shortAndLong, help: "Dictionary url")
    var dictionary: String = env["DICTIONARY"] ?? "/usr/share/dict/words"

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
        if countdownRules, (vowels < 3 || consonants < 4) {
            throw "In Countdown, the you must choose at least 3 vowels and at least 4 consonants"
        }

        let allVowels = Set(Array("aeiou"))
        let allConsonants = Set(Array("bcdfghjklmnpqrstvwxyz"))

        let selection = (1 ... vowels).compactMap { _ in allVowels.randomElement() }
        + (1 ... consonants).compactMap { _ in allConsonants.randomElement() }

        print("With \(vowels) vowels and \(consonants) consonants the letters are:")
        let result = selection.shuffled().map(String.init).joined()
        print(result)

        if solve {
            let solver = try await LetterSolver(letters: result, dictionary: url)
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
        } else {
            print("")
            print("Solve this by running:")
            print("swift run Countdown letters \(result)")
        }
    }
}
