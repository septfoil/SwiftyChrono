//
//  Options.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/18/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

public struct ModeOptio {
    var parsers: [Parser]
    var refiners: [Refiner]
    
    init(parsers: [Parser], refiners: [Refiner]) {
        self.parsers = parsers
        self.refiners = refiners
    }
}

private func baseOption(strictMode: Bool) -> ModeOptio {
    return ModeOptio(parsers: [
        // EN
        ENISOFormatParser(strictMode: strictMode),
        ENDeadlineFormatParser(strictMode: strictMode),
        ENMonthNameLittleEndianParser(strictMode: strictMode),
        ENMonthNameMiddleEndianParser(strictMode: strictMode),
        ENMonthNameParser(strictMode: strictMode),
        ENSlashDateFormatParser(strictMode: strictMode),
        ENSlashDateFormatStartWithYearParser(strictMode: strictMode),
        ENSlashMonthFormatParser(strictMode: strictMode),
        ENTimeAgoFormatParser(strictMode: strictMode),
        ENTimeLaterFormatParser(strictMode: strictMode),
        ENTimeExpressionParser(strictMode: strictMode),
        
        // JP
        JPStandardParser(strictMode: strictMode),
        
        // ES
        ESTimeAgoFormatParser(strictMode: strictMode),
        ESDeadlineFormatParser(strictMode: strictMode),
        ESTimeExpressionParser(strictMode: strictMode),
        ESMonthNameLittleEndianParser(strictMode: strictMode),
        ESSlashDateFormatParser(strictMode: strictMode),
        
        // FR
        FRDeadlineFormatParser(strictMode: strictMode),
        FRMonthNameLittleEndianParser(strictMode: strictMode),
        FRSlashDateFormatParser(strictMode: strictMode),
        FRTimeAgoFormatParser(strictMode: strictMode),
        FRTimeExpressionParser(strictMode: strictMode),
        
        // DE
        DEDeadlineFormatParser(strictMode: strictMode),
        DEMonthNameLittleEndianParser(strictMode: strictMode),
        DESlashDateFormatParser(strictMode: strictMode),
        DETimeAgoFormatParser(strictMode: strictMode),
        DETimeExpressionParser(strictMode: strictMode),
        
        // ZH-Hans
        HansCasualDateParser(strictMode: strictMode),
        HansDateParser(strictMode: strictMode),
        HansDeadlineFormatParser(strictMode: strictMode),
        HansTimeExpressionParser(strictMode: strictMode),
        HansWeekdayParser(strictMode: strictMode),
        
        // RU
        RUDeadlineFormatParser(strictMode: strictMode),
        RUMonthNameLittleEndianParser(strictMode: strictMode),
        RUMonthNameParser(strictMode: strictMode),
        RUSlashDateFormatParser(strictMode: strictMode),
        RUTimeAgoFormatParser(strictMode: strictMode),
        RUTimeExpressionParser(strictMode: strictMode),
        
    ], refiners: [
        // Removing overlaping first
        OverlapRemovalRefiner(),
        ForwardDateRefiner(),
        
        // ETC
        ENMergeDateTimeRefiner(),
        ENMergeDateRangeRefiner(),
        ENPrioritizeSpecificDateRefiner(),
        FRMergeDateRangeRefiner(),
        FRMergeDateTimeRefiner(),
        JPMergeDateRangeRefiner(),
        DEMergeDateTimeRefiner(),
        DEMergeDateRangeRefiner(),
        RUMergeDateTimeRefiner(),
        RUMergeDateRangeRefiner(),
        
        // Extract additional info later
        ExtractTimezoneOffsetRefiner(),
        ExtractTimezoneAbbrRefiner(),
        
        UnlikelyFormatFilter(),
    ])
}

func strictModeOption() -> ModeOptio {
    return baseOption(strictMode: true)
}

public func casualModeOption() -> ModeOptio {
    var options = baseOption(strictMode: false)
    
    options.parsers.insert(contentsOf: [
        // ZH-Hans
        HansWeekdayParser(strictMode: false),
//        HansCasualDateParser(strictMode: false),
        HansDateParser(strictMode: false),
        HansDeadlineFormatParser(strictMode: false),
        HansTimeExpressionParser(strictMode: false),
        
        // EN
        ENISOFormatParser(strictMode: false),
        ENSlashDateFormatParser(strictMode: false),
        ENSlashDateFormatStartWithYearParser(strictMode: false),
        ENTimeAgoFormatParser(strictMode: false),
        ENTimeExpressionParser(strictMode: false),
        ENTimeLaterFormatParser(strictMode: false),
        ENWeekdayParser(strictMode: false),
        ENCasualTimeParser(strictMode: false),
        ENCasualDateParser(strictMode: false),
        ENWeekdayParser(strictMode: false),
        ENRelativeDateFormatParser(strictMode: false),
        ENMonthNameParser(strictMode: false),
        ENDeadlineFormatParser(strictMode: false),
        
        
        // JP
        JPCasualDateParser(strictMode: false),
        
        // ES
        ESCasualDateParser(strictMode: false),
        ESWeekdayParser(strictMode: false),
        
        // FR
        FRCasualDateParser(strictMode: false),
        FRWeekdayParser(strictMode: false),
        
        // DE
        DECasualTimeParser(strictMode: false),
        DECasualDateParser(strictMode: false),
        DEWeekdayParser(strictMode: false),
        DEMorgenTimeParser(strictMode: false),
        
        // RU
        RUCasualTimeParser(strictMode: false),
        RUCasualDateParser(strictMode: false),
        RUWeekdayParser(strictMode: false),
        
        
    ], at: 0)
    
    return options
}

public enum Language {
    case english, spanish, french, japanese, german, chinese, russian
}
