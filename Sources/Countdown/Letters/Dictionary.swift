//
//  macdict.swift
//  macdict
//
//  Created by 钟建峰 on 2020/2/12.
//  Copyright © 2020 钟建峰. All rights reserved.
//

import Foundation
import CoreServices
import Dictionary

/**
 词条记录
 */
class DictionaryRecord {
    /// 原始记录
    private let record: CFTypeRef
    
    /**
     使用原始这条记录初始化`DictionaryRecord`
     - Parameter record: 原始词条记录
     */
    fileprivate init(_ record: CFTypeRef) {
        self.record = record
    }
    
    /// 词目
    var headword: String {
        
        return DCSRecordGetHeadword(record).takeUnretainedValue() as String
    }
    
    /// 纯文本解释
    var text: String {
        return DCSRecordCopyData(record, Int(DCSRecordVersion.text.rawValue))!.takeUnretainedValue() as String
    }

    var title: String {
        DCSRecordGetTitle(record).takeUnretainedValue() as String
    }

    var anchor: String {
        DCSRecordGetAnchor(record).takeUnretainedValue() as String
    }

    var string: String {
        DCSRecordGetString(record).takeUnretainedValue() as String
    }

    var rawHeadword: String {
        DCSRecordGetRawHeadword(record).takeUnretainedValue() as String
    }

    var associatedObj: String {
        DCSRecordGetAssociatedObj(record).takeUnretainedValue() as String
    }

    var subDictionary: DCSDictionary {
        DCSRecordGetSubDictionary(record).takeUnretainedValue() as DCSDictionary
    }
    
    /// HTML格式的解释
    var html: String {
        return DCSRecordCopyData(record, Int(DCSRecordVersion.HTML.rawValue))!.takeUnretainedValue() as String
    }
    
    /// 带APP CSS样式的HTML格式解释
    var htmlWithAppCSS: String {
        return DCSRecordCopyData(record, Int(DCSRecordVersion.htmlWithAppCSS.rawValue))!.takeUnretainedValue() as String
    }
    
    /// 带Popover CSS样式的HTML格式的解释
    var htmlWithPopoverCSS: String {
        return DCSRecordCopyData(record, Int(DCSRecordVersion.htmlWithPopoverCSS.rawValue))!.takeUnretainedValue() as String
    }
}


extension DCSDictionary {
    
    // MARK: - Class Properties
    
    /// 获取所有可用的字典，其中`key`为字典名，`value`为对应的字典
    static let availableDictionaries: [String: DCSDictionary] = getAvailableDictionaries()
    
    // MARK: - Class Methods
    
    /// 获取所有可用字典
    /// - Returns: 返回所有可用字典的集合，其中`key`为字典名，`value`为相应的字典对象
    static func getAvailableDictionaries() -> [String: DCSDictionary] {
        var dictionaries = [String: DCSDictionary]()
        
        let availableDictionaries: NSArray = DCSCopyAvailableDictionaries().takeUnretainedValue()
        for dictionary in availableDictionaries {
            let dict = dictionary as! DCSDictionary
            let name = dict.name
            
            dictionaries[name] = dict
        }
        return dictionaries
    }
    
    /**
     获取指定名称的字典
     - Parameters:
        - name: 字典名称
        - ignoreCase: 是否忽略名称的大小写
     - Returns: 如果找到返回找到的字典，否则返回 nil
     */
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
    
    /**
     在指定字典中查找`text`的解释
     - Parameters:
        - dictionary: 指定字典
        - text: 要查找的文本
     - Returns: 返回所有解释词条记录
     */
    static func lookUp(dictionary: DCSDictionary, text: String) -> [DictionaryRecord]? {
        var result = [DictionaryRecord]()
        
        let range = DCSGetTermRangeInString(dictionary, text as CFString, 0)
        if range.location == kCFNotFound {
            return nil
        }
        
        let begin = text.index(text.startIndex, offsetBy: range.location)
        let end = text.index(begin, offsetBy: range.length)
        let term = text[begin..<end]
        
        let records = DCSCopyRecordsForSearchString(dictionary, term as CFString, nil, nil).takeUnretainedValue() as Array
        
        for record in records {
            result.append(DictionaryRecord(record))
        }
        
        return result
    }
    
    /**
     使用默认字典查找指定文本
     - Parameter text: 要查找的文本
     - Returns: 返回找到的解释项的无格式文本
     */
    static func lookUp(text: String) -> String? {
        let range = DCSGetTermRangeInString(nil, text as CFString, 0)
        if range.location == kCFNotFound {
            return nil
        }
        
        return DCSCopyTextDefinition(nil, text as CFString, range)?.takeUnretainedValue() as String?
    }
    
    // MARK: - Member Properties
    
    /// 字典名
    var name: String {
        return DCSDictionaryGetName(self).takeUnretainedValue() as String
    }
    
    /// 字典短名
    var shortName: String {
        return DCSDictionaryGetShortName(self).takeUnretainedValue() as String
    }
    
    // MARK: - Member Methods
    
    /**
     在字典中查找指定文本
     - Parameter text: 要查找的文本
     - Returns: 返回找到的所有词条记录
     */
    func lookUp(text: String) -> [DictionaryRecord]? {
        return DCSDictionary.lookUp(dictionary: self, text: text)
    }
}
