//
//  SQSService.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/6/22.
//

import AWSSQS

class QueueNotificationService: NSObject, ObservableObject {
    private static var instance: QueueNotificationService? = QueueNotificationService()
    
    static func singleton() -> QueueNotificationService {
        return instance ?? QueueNotificationService()
    }
}


extension QueueNotificationService {
    static func authenticate() -> Void {
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType:.USEast2,
           identityPoolId:"us-east-2:9012c140-923b-4422-887f-9860cdcb4a27"
        )

        let configuration = AWSServiceConfiguration(
            region:.USEast2,
            credentialsProvider:credentialsProvider
        )
        
        AWSSQS.register(with: configuration!, forKey: "USEAST2SQS")
        print("Succesfully register with given cognito information")
    }
}

extension QueueNotificationService {
    public func sendMessage(message: SQSMessage) {
        let jsonMessage = try! JSONEncoder().encode(message)
        self.sendMessage(message: String(data: jsonMessage, encoding: .utf8)!)
    }
    
    public func sendMessage(message: String) -> Void {
        let sqs =  AWSSQS(forKey: "USEAST2SQS")
        let messageRequest = AWSSQSSendMessageRequest()
        messageRequest?.queueUrl = NasaTlxGlobals.QUEUE_URL
        messageRequest?.messageBody = message
        
        sqs.sendMessage(messageRequest!) { (result, error) in
            if let result = result {
                print("Successfully sent (1) message. SQS messageId: \(result.messageId ?? "messageId")")
            }
            if let error = error {
                print("SQS sendMessage error: \(error)")
            }
        }
    }
}
