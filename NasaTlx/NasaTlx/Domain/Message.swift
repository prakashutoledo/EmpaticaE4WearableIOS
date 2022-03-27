//
//  Notification.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/7/22.
//
import Foundation

public enum PayloadType: String {
    case e4Band = "E4Band"
    case ntpSync = "NtpSync"
}

public enum PayloadAction: String {
    case sendMessage = "sendMessage"
}

public protocol Payload: Encodable {
    var payloadType: PayloadType { get }
}

public class BaseMessage: Encodable {
    private enum CodingKeys: CodingKey {
        case payloadType, action
    }
    
    let payloadType: PayloadType
    let action: PayloadAction
    
    init(payloadType: PayloadType, action: PayloadAction) {
        self.payloadType = payloadType
        self.action = action
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(payloadType.rawValue, forKey: .payloadType)
        try container.encode(action.rawValue, forKey: .action)
    }
    
    public func toJson() -> String {
        let json = try! JSONEncoder().encode(self)
        return String(data: json, encoding: .utf8)!
    }
}

public class Message<T> : BaseMessage where T: Payload {
    private enum CodingKeys: CodingKey {
        case payload
    }
    
    var payload: T
    
    init(payload: T, payloadType: PayloadType, action: PayloadAction = PayloadAction.sendMessage) {
        self.payload = payload
        super.init(payloadType: payloadType, action: action)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(payload, forKey: .payload)
        try super.encode(to: encoder)
    }
}
