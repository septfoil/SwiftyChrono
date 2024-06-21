//
//  ENCasualTimeParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "(\\W|^)((this)?\\s*(morning|afternoon|evening|night|midnight|midday|noon))"
private let timeMatch = 4

public class ENCasualTimeParser: Parser {
    override var pattern: String { return PATTERN }
    
    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        let (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        
        if match.isNotEmpty(atRangeIndex: timeMatch) {
            let time = match.string(from: text, atRangeIndex: timeMatch)
            switch time {
            case "afternoon":
                result.start.assign(.hour, value: opt[.afternoon] ?? 15)
            case "evening", "night":
                result.start.assign(.hour, value: opt[.evening] ?? 21)
            case "morning":
                result.start.assign(.hour, value: opt[.morning] ?? 9)
            case "noon", "midday":
                result.start.assign(.hour, value: opt[.noon] ?? 12)
            default: break
            }
        }
        
        result.tags[.enCasualTimeParser] = true
        return result
    }
}
