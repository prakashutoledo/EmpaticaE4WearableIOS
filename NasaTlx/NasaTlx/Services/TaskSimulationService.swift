//
//  TaskSimulationService.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/24/22.
//

import Foundation

class TaskSimulationService: NSObject, ObservableObject {
    @Published
    public var currentTaskCounter: Int = 0
    
    private override init() {
        // private initialization
    }
}

extension TaskSimulationService {
    public static let singleton: TaskSimulationService = TaskSimulationService()
}
