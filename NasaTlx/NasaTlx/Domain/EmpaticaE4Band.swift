//
//  SQSMessage.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/6/22.
//

public class EmpaticaE4Band: Payload {
    public var payloadType: PayloadType {
        get {
            return PayloadType.e4Band
        }
    }
    
    private enum CodingKeys: CodingKey {
        case subjectId, fromView, device, payloadType
    }
    
    var subjectId: String?
    var fromView: String?
    var device: Device?
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subjectId, forKey: .subjectId)
        try container.encode(fromView, forKey: .fromView)
        try container.encode(device, forKey: .device)
        try container.encode(payloadType.rawValue, forKey: .payloadType)
    }
}

public class Device: Encodable {
    private enum CodingKeys: CodingKey {
        case serialNumber, connected
    }
    
    var serialNumber: String?
    var connected: Bool = false
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serialNumber, forKey: .serialNumber)
        try container.encode(connected, forKey: .connected)
    }
}
