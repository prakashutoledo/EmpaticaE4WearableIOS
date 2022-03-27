//
//  SQSService.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/6/22.
//

/*
import AWSCore
import AWSSQS

class AWSCoreUtil {
    static func setConsoleLogger(_ logLevel: AWSDDLogLevel) {
        AWSDDLog.sharedInstance.logLevel = logLevel
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
    }
}

extension AWSCoreUtil {
    public static func setCognitoCredentials(_ cognitoIdentityPoolId: String) -> Void {
        let cognitoCredentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .USEast2,
            identityPoolId: AWSCoreUtil.resolveCognitoIdentityPoolId(cognitoId: cognitoIdentityPoolId)
        )

        let awsServiceConfiguration = AWSServiceConfiguration(
            region: .USEast2,
            credentialsProvider: cognitoCredentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = awsServiceConfiguration
    }
    
    public static func resolveCognitoIdentityPoolId(cognitoId: String) -> String {
        return "\(NasaTLXGlobals.awsRegion):\(cognitoId)"
    }
    
    public static func resolveQueueURL(queueName: String) -> String {
        return "https://sqs.\(NasaTLXGlobals.awsRegion).amazonaws.com/\(NasaTLXGlobals.awsAccount)/\(queueName)"
    }
}

class QueueNotificationService: NSObject {
    private let awssqs: AWSSQS
    
    private init(awssqs: AWSSQS) {
        self.awssqs = awssqs
    }
}

extension QueueNotificationService {
    public static let singleton: QueueNotificationService = QueueNotificationService(awssqs: AWSSQS.default())
}

extension QueueNotificationService {
    public func push<T>(queueName: String, payload: T) where T : Payload {
        let message = Message<T>(
            payload: payload,
            payloadType: payload.payloadType
        )
        
        self.push(
            queueName: queueName,
            message: message.toJson()
        )
    }
    
    private func push(queueName: String, message: String) -> Void {
        let messageRequest: AWSSQSSendMessageRequest! = AWSSQSSendMessageRequest()
        messageRequest.queueUrl = AWSCoreUtil.resolveQueueURL(queueName: queueName)
        messageRequest.messageBody = message
        
        self.awssqs.sendMessage(messageRequest) { (result, error) in
            if let result = result {
                print("Successfully pushed (1) message to \(messageRequest.queueUrl!) with messageId: \(result.messageId ?? "messageId")")
            }
            if let error = error {
                print("Cannot push message to \(messageRequest.queueUrl!) with error \(error)")
            }
        }
    }
}
*/
