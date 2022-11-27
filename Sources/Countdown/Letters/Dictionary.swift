import Foundation
import CoreServices
import Dictionary

class DictionaryRecord {
    private let record: CFTypeRef
    
    init(_ record: CFTypeRef) {
        self.record = record
    }

    var text: String {
        DCSRecordCopyData(record, Int(DCSRecordVersion.text.rawValue))!.takeUnretainedValue() as String
    }

    var html: String {
        DCSRecordCopyData(record, Int(DCSRecordVersion.HTML.rawValue))!.takeUnretainedValue() as String
    }
}

extension DCSDictionary {
    static let availableDictionaries: [String: DCSDictionary] = getAvailableDictionaries()
    
    private static func getAvailableDictionaries() -> [String: DCSDictionary] {
        var dictionaries = [String: DCSDictionary]()
        
        let availableDictionaries: NSArray = DCSCopyAvailableDictionaries().takeUnretainedValue()
        for dictionary in availableDictionaries {
            let dict = dictionary as! DCSDictionary
            let name = dict.name
            
            dictionaries[name] = dict
        }
        return dictionaries
    }
    
    static func getDictionary(by name: String, ignoreCase: Bool = true) -> DCSDictionary? {
        if !ignoreCase {
            return availableDictionaries[name]
        }
        
        for (dictName, dict) in availableDictionaries {
            if (dictName.caseInsensitiveCompare(name) == .orderedSame) {
                return dict
            }
        }
        return nil
    }
    
    var name: String {
        DCSDictionaryGetName(self).takeUnretainedValue() as String
    }
    
    var shortName: String {
        DCSDictionaryGetShortName(self).takeUnretainedValue() as String
    }
    func lookUp(text: String) -> [DictionaryRecord]? {
        var result = [DictionaryRecord]()

        let range = DCSGetTermRangeInString(self, text as CFString, 0)
        if range.location == kCFNotFound {
            return nil
        }

        let begin = text.index(text.startIndex, offsetBy: range.location)
        let end = text.index(begin, offsetBy: range.length)
        let term = text[begin..<end]

        let records = DCSCopyRecordsForSearchString(self, term as CFString, nil, nil).takeUnretainedValue() as Array

        for record in records {
            result.append(DictionaryRecord(record))
        }

        return result
    }
}
