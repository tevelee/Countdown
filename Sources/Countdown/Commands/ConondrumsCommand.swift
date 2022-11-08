import Foundation
import ArgumentParser

struct ConondrumsCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(commandName: "conondrums",
                                                    abstract: "Finds conondrums from the given letters")

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
        let solver = try await ConondrumSolver(target: letters, dictionary: url)
        for try await result in solver.findAnagrams() {
            print(result)
        }
    }
}
