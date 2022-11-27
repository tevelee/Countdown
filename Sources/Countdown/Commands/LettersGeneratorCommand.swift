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
            try await LettersSolverPrinter(solver: LetterSolver(letters: result, dictionary: url),
                                           definitionFinder: WordDefinitionFinder(),
                                           filterWordsWithDefinitions: filterWordsWithDefinitions).printSolution()
        } else {
            print("")
            print("Solve this by running:")
            print("swift run Countdown letters \(result)")
        }
    }
}
