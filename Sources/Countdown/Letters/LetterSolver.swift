import Foundation

final class LetterSolver {
    private let letters: String
    private let words: AnyAsyncSequence<String>
    private let min: Int
    private let max: Int

    init(letters: String,
         dictionary url: URL,
         min: Int = 4,
         max: Int? = nil) async throws {
        self.letters = letters
        self.words = url.lines.eraseToAnyAsyncSequence()
        self.min = min
        self.max = max ?? letters.count
    }

    init(letters: String,
         words: [String],
         min: Int = 4,
         max: Int? = nil) {
        self.letters = letters
        self.words = words.async.eraseToAnyAsyncSequence()
        self.min = min
        self.max = max ?? letters.count
    }

    func findWords() -> AsyncThrowingStream<String, Error> {
        .async { continuation in
            let targetMap = self.letters.characterMap()
            var solutions: [String] = []
            outer: for try await word in self.words {
                guard let initial = word.first,
                      initial.isLowercase,
                      (self.min ... self.max).contains(word.count),
                      !word.contains("-") else {
                    continue
                }

                let currentMap = word.characterMap()
                for (character, currentCount) in currentMap {
                    if targetMap[character].map({ currentCount > $0 }) ?? true {
                        continue outer
                    }
                }

                solutions.append(word)
                continuation.yield(word)
            }

            if solutions.isEmpty {
                continuation.finish(throwing: "No words found with these letters")
            } else {
                continuation.finish()
            }
        }
    }
}

private extension String {
    func characterMap() -> [Character: Int] {
        Dictionary(grouping: self) { Character($0.lowercased()) }.mapValues(\.count)
    }
}
