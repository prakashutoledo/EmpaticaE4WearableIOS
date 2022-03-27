//
//  Extension+DateFormatter.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/5/22.
//

extension DateFormatter {
    public static func optionalEST() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = NasaTLXGlobals.isoDateTimeZoneFormatter
        formatter.timeZone = TimeZone(abbreviation: NasaTLXGlobals.estTimeZone)
        formatter.locale = Locale(identifier: NasaTLXGlobals.enUSPosixLocale)
        return formatter
    }
}
