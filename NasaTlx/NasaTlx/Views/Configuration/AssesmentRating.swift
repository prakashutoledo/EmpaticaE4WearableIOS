import Foundation
import SwiftUI

class AssesmentRating: ObservableObject, Encodable {
    private enum CodingKeys: CodingKey {
        case mentalDemand, physicalDemand, temporalDemand, performance, frustationLevel, effortLevel, subjectId, taskName
    }
    
    @Published
    public var mentalDemandValue: Double? = nil
    
    @Published
    public var physicalDemandValue: Double? = nil
    
    @Published
    public var temporalDemandValue: Double? = nil
    
    @Published
    public var performanceValue: Double? = nil
    
    @Published
    public var frustationLevelValue: Double? = nil
    
    @Published
    public var effortLevelValue: Double? = nil
    
    @Published
    public var isFromResult: Bool? = nil
    
    public var subjectId: String? = nil
    public var taskName: String? = nil
    
    public func clear() -> Void {
        self.mentalDemandValue = nil
        self.physicalDemandValue = nil
        self.temporalDemandValue = nil
        self.performanceValue = nil
        self.frustationLevelValue = nil
        self.effortLevelValue = nil
        self.isFromResult = nil
    }
    
    public func isRated() -> Bool {
        return self.mentalDemandValue.isPresent &&
                self.physicalDemandValue.isPresent &&
                self.temporalDemandValue.isPresent &&
                self.performanceValue.isPresent &&
                self.frustationLevelValue.isPresent &&
                self.effortLevelValue.isPresent
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mentalDemandValue, forKey: .mentalDemand)
        try container.encode(physicalDemandValue, forKey: .physicalDemand)
        try container.encode(temporalDemandValue, forKey: .temporalDemand)
        try container.encode(performanceValue, forKey: .performance)
        try container.encode(effortLevelValue, forKey: .effortLevel)
        try container.encode(frustationLevelValue, forKey: .frustationLevel)
        try container.encode(subjectId, forKey: .subjectId)
        try container.encode(taskName, forKey: .taskName)
    }
    
    public func toJson() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}
