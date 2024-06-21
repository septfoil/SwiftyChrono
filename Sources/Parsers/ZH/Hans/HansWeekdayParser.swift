//
//  File.swift
//  
//
//  Created by yefei on 2024/6/21.
//

import Foundation

private let PATTERN =
"(上|今|本|下|这)" +
"(?:個|个)?" +
"(?:周|星期|礼拜)" +
"(\(ZH_WEEKDAY_OFFSET_PATTERN))?" +
//"(?:[\\s|,|，]*)?" +
"(?:(上(?:午)|早(?:上)|下(?:午)|晚(?:上)|夜(?:晚)?|中(?:午)|凌(?:晨)))?｜" +
"(?:周|星期|礼拜)" +
"(\(ZH_WEEKDAY_OFFSET_PATTERN))"

private let prefixGroup = 1
private let weekdayGroup1 = 2
private let timeGroup1 = 3
private let weekdayGroup2 = 4

public class HansWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chinese }
    
    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        var offset = 0
        if match.isNotEmpty(atRangeIndex: weekdayGroup1) {
            offset = ZH_WEEKDAY_OFFSET[match.string(from: text, atRangeIndex: weekdayGroup1)] ?? 1
            if match.isNotEmpty(atRangeIndex: timeGroup1) {
                setTime(text: text, match: match, index: timeGroup1, opt: opt, result: &result)
            }
        } else if match.isNotEmpty(atRangeIndex: weekdayGroup2) {
            offset = ZH_WEEKDAY_OFFSET[match.string(from: text, atRangeIndex: weekdayGroup2)] ?? 1
        }
        
        var modifier = ""
        let prefix = match.isNotEmpty(atRangeIndex: prefixGroup) ? match.string(from: text, atRangeIndex: prefixGroup) : ""
        
        if prefix == "上" {
            modifier = "last"
        } else if prefix == "下" {
            modifier = "next"
        } else if prefix == "今" || prefix == "这"  || prefix == "本" {
            modifier = "this"
        }
        
        result = updateParsedComponent(result: result, ref: ref, offset: offset, modifier: modifier)
        result.tags[.zhHantWeekdayParser] = true
        return result
    }
    
    func setTime(text: String, match: NSTextCheckingResult, index: Int, opt: [OptionType: Int], result: inout ParsedResult) {
        if match.isNotEmpty(atRangeIndex: index) {
            let timeString2 = match.string(from: text, atRangeIndex: index)
            let time2 = timeString2.firstString ?? ""
            
            if (time2 == "早" || time2 == "上") {
                result.start.assign(.hour, value: opt[.morning] ?? 9)
            } else if (time2 == "下") {
                result.start.assign(.hour, value: opt[.afternoon] ?? 15)
                result.start.assign(.meridiem, value: 1)
            } else if (time2 == "中") {
                result.start.assign(.hour, value: 12)
                result.start.assign(.meridiem, value: 1)
            } else if (time2 == "夜" || time2 == "晚") {
                result.start.assign(.hour, value: opt[.evening] ?? 21)
                result.start.assign(.meridiem, value: 1)
            } else if (time2 == "凌") {
                result.start.assign(.hour, value: 0)
            }
        }
    }
}
