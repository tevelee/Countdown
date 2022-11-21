import Foundation
import ArgumentParser

struct ConondrumsCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "conondrums",
                                                    abstract: "Finds conondrums from the given letters")

    @Option(name: .shortAndLong, help: "Dictionary url")
    var dictionary: String = env["DICTIONARY"] ?? "/usr/share/dict/words"

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
        let solver = try await ConondrumSolver(target: letters, dictionary: url)
        let definitionFinder = WordDefinitionFinder()
        for try await result in solver.findAnagrams() {
            let definition = (definitionFinder.define(result)).map { ": \($0)" } ?? ""
            print("\(result)\(definition)")
        }
    }
}
