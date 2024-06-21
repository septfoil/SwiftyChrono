//
//  File.swift
//  
//
//  Created by yefei on 2024/6/21.
//

import Foundation

private let PATTERN = "((?:上|今|本|下|这)周|(?:周|星期|礼拜)(?:\(ZH_WEEKDAY_OFFSET_PATTERN)))"

private let prefixGroup = 1
private let weekdayGroup = 2

public class HansWeekdayParser: Parser {
    override var pattern: String { return PATTERN }
    override var language: Language { return .chinese }
    
    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndexForCHHant(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        let dayOfWeek = match.string(from: text, atRangeIndex: weekdayGroup)
        let offset = ZH_WEEKDAY_OFFSET[dayOfWeek] ?? 1
        
        var modifier = ""
        let prefix = match.isNotEmpty(atRangeIndex: prefixGroup) ? match.string(from: text, atRangeIndex: prefixGroup) : ""
        
        if prefix == "上" {
            modifier = "last"
        } else if prefix == "下" {
            modifier = "next"
        } else if prefix == "今" || prefix == "这" || prefix == "本" {
            modifier = "this"
        }
        
        result = updateParsedComponent(result: result, ref: ref, offset: offset, modifier: modifier)
        result.tags[.zhHantWeekdayParser] = true
        return result
    }
}
