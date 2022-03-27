//
//  WebSocketService.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/28/22.
//

import Foundation
import WebSocketKit
import NIOPosix

class WebSocketService: NSObject, ObservableObject {
    private var webSocket: WebSocket? = nil
    private var eventLoopGroup: EventLoopGroup? = nil
    private var onMessageCallback: (String) -> ()
    
    private override init() {
        self.onMessageCallback = { _ in }
    }
}

extension WebSocketService {
    public static let singleton: WebSocketService = WebSocketService()
}

extension WebSocketService {
    public func connect(url: String) {
        if eventLoopGroup.isEmpty {
            self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        }

        try! WebSocket.connect(to: URL(string: url)!, on: self.eventLoopGroup!, onUpgrade: self.setWebSocket).wait()
    }
    
    private func setWebSocket(webSocket: WebSocket) {
        self.webSocket = webSocket
        self.webSocket?.onText(self.onMessageReceived)
        self.webSocket?.onPing(self.onPingRecieved)
        self.webSocket?.onPong(self.onPongRecieved)
    }
    
    private func onMessageReceived(webSocket: WebSocket, text: String) {
        self.onMessageCallback(text)
        self.webSocket = webSocket
    }
    
    private func onPingRecieved(websocket: WebSocket) {
        print("Ping is complete")
        self.webSocket = websocket
    }
    
    private func onPongRecieved(websocket: WebSocket) {
        print("Pong is complete")
        self.webSocket = websocket
    }
    
    public func sendMessage<T>(payload: T) where T : Payload {
        let message = Message<T>(
            payload: payload,
            payloadType: payload.payloadType
        )
        
        if let webSocket = self.webSocket {
            if let eventLoopGroup = eventLoopGroup {
                let promise = eventLoopGroup.next().makePromise(of: Void.self)
                webSocket.send(message.toJson(), promise: promise)
                promise.futureResult.whenComplete { result in
                    print("Successfully sent message to the WebSocket server")
                }
            }
        }
    }
    
    public func disconnect(closeEventLoopGroup: Bool = true) {
        if let webSocket = self.webSocket {
            if !webSocket.isClosed {
                try! webSocket.eventLoop.submit {
                    _ = webSocket.close()
                }.wait()
                print("Succesfully closed current WebSocket connection")
                self.webSocket = nil
            }
        }
        
        if closeEventLoopGroup {
            if let eventLoopGroup = self.eventLoopGroup {
                eventLoopGroup.shutdownGracefully { _ in
                    print("EventLoopGroup shutdown complete")
                    self.eventLoopGroup = nil
                }
            }
        }
    }
}
