//
//  ClockService.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/7/22.
//

import Kronos
import Combine
import SwiftUI

class NTPSyncService: NSObject, ObservableObject {
    @Published
    public var offset: TimeInterval? = nil
    
    @Published
    public var isTimeSynced = false
    
    private override init() {
        // private initialization
    }
}

extension NTPSyncService {
    public static let singleton: NTPSyncService = NTPSyncService()
}

extension NTPSyncService {
    public func syncTimestamp(ntpPool: String = "pool.ntp.org") -> Void {
        print(ntpPool)
        Clock.sync(from: ntpPool, first: self.firstSync, completion: self.completeSync)
    }
    
    private func firstSync(date: Date, offset: TimeInterval) -> Void {
        self.offset = offset
        self.isTimeSynced = true
        print("First sync complete")
    }
    
    private func completeSync(date: Date?, offset: TimeInterval?) -> Void {
        self.isTimeSynced = true
        self.offset = offset
        print("All sync complete")
    }
}
