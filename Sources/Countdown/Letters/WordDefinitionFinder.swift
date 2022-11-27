import Foundation
import SwiftSoup

final class WordDefinitionFinder {
    func define(_ input: String, in dictionaryName: String = "Oxford Dictionary of English") -> String? {
        guard let dictionary = DCSDictionary.getDictionary(by: dictionaryName),
              let entry = dictionary.lookUp(text: input)?.first,
              let html = try? SwiftSoup.parse(entry.html) else {
            return nil
        }
        for child in html.nodes(in: "span.sg") {
            let gg = child.text(in: "span.gg")
            let pos = "(\(child.text(in: "span.pos")))"
            let df = child.text(in: "span.df")
            return [gg, pos, df].joined(separator: " ")
        }
        return entry.text
    }
}

private extension Element {
    func text(in selector: String) -> String {
        (try? select(selector).first()?.text(trimAndNormaliseWhitespace: true)) ?? ""
    }

    func nodes(in selector: String) -> [Element] {
        (try? select(selector).first()?.getChildNodes() as? [Element]) ?? []
    }
}

// set DictionaryServicesKey defaults for com.apple.DictionaryServices like here:  https://github.com/shuhjx/dict/blob/2a036e45c0d46ead1b615108c785068e164cfc3f/dict/main.swift
