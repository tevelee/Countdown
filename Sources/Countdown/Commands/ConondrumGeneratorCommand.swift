import ArgumentParser
import Foundation

struct ConondrumGeneratorCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "conondrums",
                                                    abstract: "Generates conondrums containing given word")

    @Option(name: .long, help: "Show solution")
    var solve: Bool = true

    @Option(name: .long, help: "Filter words that have definition")
    var filterWordsWithDefinitions: Bool = true
    
    @Option(name: .shortAndLong, help: "Dictionary url")
    var dictionary: String = env["DICTIONARY"] ?? "/usr/share/dict/words"

    @Option(name: .long, help: "Length of the conondrum")
    var length: Int = 9

    @Option(name: .long, parsing: .remaining, help: "Phrases to contain")
    var phrases: [String] = []

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
        let sumOfLengths = phrases.map(\.count).reduce(into: 0, +=)
        guard sumOfLengths <= length else {
            throw "Lengths of phrases must be lower than target length"
        }
        let definitionFinder = WordDefinitionFinder()

        outer: for try await word in try url.lines where word.count == length {
            var remainder = word.sorted()
            for phrase in phrases {
                for letter in Array(phrase) {
                    if let index = remainder.firstIndex(of: letter) {
                        remainder.remove(at: index)
                    } else {
                        continue outer
                    }
                }
            }
            let definition = definitionFinder.define(word)
            if filterWordsWithDefinitions, definition == nil {
                continue
            }
            let formattedDefinition = definition.map { ": \($0)" } ?? ""
            do {
                var numberOfSolutions = 0
                let solver = try await ConondrumSolver(target: String(remainder), dictionary: url)
                for try await remaining in solver.findAnagrams() {
                    let subDefinition = definitionFinder.define(remaining)
                    if filterWordsWithDefinitions, subDefinition == nil {
                        continue
                    }
                    let formattedSubDefinition = subDefinition.map { ": \($0)" } ?? ""

                    if solve, numberOfSolutions == 0 {
                        print("")
                        print("\(word)\(formattedDefinition)")
                    }
                    numberOfSolutions += 1

                    let parts = phrases + [remaining]
                    if solve {
                        print("- \(parts.joined(separator: " "))\(formattedSubDefinition)")
                    } else {
                        print("")
                        print("\(parts.joined(separator: " "))\(formattedSubDefinition)")
                        print("swift run Countdown conondrums \(parts.joined())")
                    }
                }
            } catch {}

        }
    }
}
