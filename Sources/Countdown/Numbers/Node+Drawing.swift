extension Node {
    func tree(spacing: Int = 3) -> String {
        var lines: [String]
        switch self {
        case let .number(value):
            lines = [String(value)]
        case let .operation(operation, lhs, rhs, _):
            let lWidth = lhs.width(spacing: spacing)
            let rWidth = rhs.width(spacing: spacing)
            lines = [
                String(spaces: lWidth) + "[" + operation.sign + "]",
                String(spaces: lWidth - 1) + "/" + String(spaces: spacing) + "\\"
            ]
            let numberOfLines = max(lhs.height(), rhs.height())
            let lLines = lhs.tree(spacing: spacing).components(separatedBy: "\n").padded(to: numberOfLines, content: String(spaces: lWidth))
            let rLines = rhs.tree(spacing: spacing).components(separatedBy: "\n").padded(to: numberOfLines, content: String(spaces: rWidth))
            let mergedLines = zip(lLines, rLines).map { lLine, rLine in
                lLine + String(spaces: spacing) + rLine
            }
            lines.append(contentsOf: mergedLines)
        }
        return lines.map { line in
            line.padded(to: width(spacing: spacing))
        }.joined(separator: "\n")
    }

    private func width(spacing: Int) -> Int {
        switch self {
        case let .number(value):
            return String(value).count
        case let .operation(_, lhs, rhs, _):
            return lhs.width(spacing: spacing) + spacing + rhs.width(spacing: spacing)
        }
    }

    private func height() -> Int {
        switch self {
        case .number:
            return 1
        case let .operation(_, lhs, rhs, _):
            return 2 + max(lhs.height(), rhs.height())
        }
    }
}

private extension String {
    init(spaces: Int) {
        self = Array(repeating: " ", count: spaces).joined()
    }

    func padded(to length: Int) -> String {
        padding(toLength: length, withPad: " ", startingAt: 0)
    }
}

private extension Array {
    func padded(to length: Int, content: Element) -> Self {
        let extra = length - count
        guard extra > 0 else {
            return self
        }
        return self + Array(repeating: content, count: extra)
    }
}
