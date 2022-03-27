//
//  E4Events.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/12/21.
//

public final class ElasticsearchEvent: Encodable {
    var jsonEvent: String = ""
    var indexName = ""
}

public class BaseEvent: Encodable {
    private enum CodingKeys: CodingKey {
        case acquiredTime, actualTime, bandType, subjectId, fromView
    }
    
    var acquiredTime: Date?
    var actualTime: Date?
    var bandType: String = NasaTLXGlobals.empaticaE4BandName
    var subjectId: String = ""
    var fromView: String = ""
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(acquiredTime?.currentDate(), forKey: .acquiredTime)
        try container.encode(actualTime?.currentDate(), forKey: .actualTime)
        try container.encode(bandType, forKey: .bandType)
        try container.encode(subjectId, forKey: .subjectId)
        try container.encode(fromView, forKey: .fromView)
    }
    
    public func toJson() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}

public final class IBIEvent : BaseEvent {
    private enum CodingKeys: CodingKey {
        case ibi
    }
    
    var ibi: Float = 0
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ibi, forKey: .ibi)
        try super.encode(to: encoder)
    }
}

public final class BVPEvent : BaseEvent {
    private enum CodingKeys: CodingKey {
        case bvp
    }
    
    var bvp: Float = 0
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bvp, forKey: .bvp)
        try super.encode(to: encoder)
    }
}

public final class GSREvent: BaseEvent {
    private enum CodingKeys: CodingKey {
        case gsr
    }
    
    var gsr: Float = 0
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gsr, forKey: .gsr)
        try super.encode(to: encoder)
    }
}

public final class TemperatureEvent: BaseEvent {
    private enum CodingKeys: CodingKey {
        case temperature
    }
    
    var temperature: Float = 0
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(temperature, forKey: .temperature)
        try super.encode(to: encoder)
    }
}

public final class AccelerationEvent : BaseEvent {
    private enum CodingKeys: CodingKey {
        case accelerationX, accelerationY, accelerationZ
    }
    
    var accelerationX: Int = 0
    var accelerationY: Int = 0
    var accelerationZ: Int = 0
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accelerationX, forKey: .accelerationX)
        try container.encode(accelerationY, forKey: .accelerationY)
        try container.encode(accelerationZ, forKey: .accelerationZ)
        try super.encode(to: encoder)
    }
}


