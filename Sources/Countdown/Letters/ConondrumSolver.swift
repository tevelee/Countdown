import Foundation

final class ConondrumSolver {
    private let target: String
    private let words: AnyAsyncSequence<String>

    init(target: String, dictionary url: URL) async throws {
        self.target = target
        self.words = url.lines.eraseToAnyAsyncSequence()
    }

    init(target: String,
         words: [String]) {
        self.target = target
        self.words = words.async.eraseToAnyAsyncSequence()
    }

    func findAnagrams() -> AsyncThrowingStream<String, Error> {
        .async { continuation in
            var solutions: [String] = []
            let target = self.target

            let matches = self.words
                .filter { $0.count == target.count && $0 != target }
                .filter { $0.first!.isLowercase }
                .filter { !$0.contains("-") }
                .filter { $0.sorted() == target.sorted() }

            for try await match in matches {
                solutions.append(match)
                continuation.yield(match)
            }

            if solutions.isEmpty {
                continuation.finish(throwing: "No conondrum found")
            } else {
                continuation.finish()
            }
        }
    }
}
