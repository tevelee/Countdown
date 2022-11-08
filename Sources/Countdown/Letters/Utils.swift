extension AsyncThrowingStream where Failure == Error {
    static func async(_ block: @escaping (Continuation) async throws -> Void) -> Self {
        .init { continuation in
            let task = Task {
                try await block(continuation)
            }
            continuation.onTermination = { termination in
                if case .cancelled = termination {
                    task.cancel()
                }
            }
        }
    }
}

extension Sequence {
    var async: AsyncLazySequence<Self> {
        AsyncLazySequence(base: self)
    }
}

struct AsyncLazySequence<Base: Sequence>: AsyncSequence {
    typealias Element = Base.Element

    struct Iterator: AsyncIteratorProtocol {
        var iterator: Base.Iterator?

        mutating func next() async -> Base.Element? {
            if !Task.isCancelled, let value = iterator?.next() {
                return value
            } else {
                iterator = nil
                return nil
            }
        }
    }

    let base: Base

    func makeAsyncIterator() -> Iterator {
        Iterator(iterator: base.makeIterator())
    }
}

struct AnyAsyncSequence<Element>: AsyncSequence {
    init<T: AsyncSequence>(_ sequence: T) where T.Element == Element {
        makeAsyncIteratorClosure = { AnyAsyncIterator(sequence.makeAsyncIterator()) }
    }

    struct AnyAsyncIterator: AsyncIteratorProtocol {
        private let nextClosure: () async throws -> Element?

        init<T: AsyncIteratorProtocol>(_ iterator: T) where T.Element == Element {
            var iterator = iterator
            nextClosure = { try await iterator.next() }
        }

        func next() async throws -> Element? {
            try await nextClosure()
        }
    }

    typealias Element = Element
    typealias AsyncIterator = AnyAsyncIterator

    func makeAsyncIterator() -> AsyncIterator {
        AnyAsyncIterator(makeAsyncIteratorClosure())
    }

    private let makeAsyncIteratorClosure: () -> AsyncIterator

}

extension AsyncSequence {
    func eraseToAnyAsyncSequence() -> AnyAsyncSequence<Element> {
        AnyAsyncSequence(self)
    }
}
