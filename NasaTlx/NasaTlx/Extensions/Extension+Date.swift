//
//  Extension+Date.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/11/21.
//

import Foundation

extension Date {
    public func currentDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    /**
     * Finds the minute and second interval starting from the given date till current date
     * 
     * @param sinceDate a start date to calculate minute and second interval
     *
     * @return a formatted minute and second interval from sinceDate to current date
     */
    public func minuteSecondInterval(sinceDate: Date) -> String? {
        let durationInterval : TimeInterval = self.timeIntervalSince(sinceDate)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [ .minute, .second ]
        formatter.zeroFormattingBehavior = [ .pad ]
        return formatter.string(from: durationInterval)
    }
    
    public func currentDate() -> String {
        return DateFormatter.optionalEST().string(from: self)
    }
}
