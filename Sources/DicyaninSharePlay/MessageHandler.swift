// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import Foundation
import GroupActivities

/// Protocol for message handlers
public protocol MessageHandler {
    associatedtype MessageType: SharePlayMessage
    func handle(_ message: MessageType, from sender: Participant) async
}

/// Type-erased message handler
public struct AnyMessageHandler {
    private let _handle: (any SharePlayMessage, Participant) async -> Void
    
    public init<H: MessageHandler>(_ handler: H) {
        self._handle = { message, sender in
            if let typedMessage = message as? H.MessageType {
                await handler.handle(typedMessage, from: sender)
            }
        }
    }
    
    func handle(_ message: any SharePlayMessage, from sender: Participant) async {
        await _handle(message, sender)
    }
}

/// Registry for message handlers
public class MessageHandlerRegistry {
    public static let shared = MessageHandlerRegistry()
    private var handlers: [String: AnyMessageHandler] = [:]
    
    private init() {}
    
    /// Register a handler for a specific message type
    public func register<H: MessageHandler>(_ handler: H) {
        let typeName = String(describing: H.MessageType.self)
        handlers[typeName] = AnyMessageHandler(handler)
    }
    
    /// Handle a message using registered handlers
    public func handle(_ message: any SharePlayMessage, from sender: Participant) async {
        let typeName = String(describing: type(of: message))
        if let handler = handlers[typeName] {
            await handler.handle(message, from: sender)
        }
    }
}

/// Convenience protocol for creating message handlers
public protocol SharePlayMessageHandler: MessageHandler {
    static var messageType: MessageType.Type { get }
}

/// Default implementation for SharePlayMessageHandler
public extension SharePlayMessageHandler {
    static var messageType: MessageType.Type {
        return MessageType.self
    }
} 