// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import Foundation
import GroupActivities

// MARK: - Messages

public protocol SharePlayMessage: Codable, Equatable, Decodable {
    var windowId: String { get }
    var messageId: String { get }
}

/// Generic SharePlayMessage type with custom decoding & encoding.
public struct AnySharePlayMessage: Codable {
    public let base: any SharePlayMessage

    public init<T: SharePlayMessage>(_ base: T) {
        self.base = base
    }

    private enum CodingKeys: String, CodingKey {
        case base
        case type
    }

    private enum MessageType: String, Codable {
        case playerMessage
        case playerReadyMessage
        case game_StartMessage
        case entityTransformMessage
        case entityStateMessage
        case customMessage
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // First try built-in types
        switch base {
        case is Player:
            try container.encode(MessageType.playerMessage, forKey: .type)
        case is PlayerReadyMessage:
            try container.encode(MessageType.playerReadyMessage, forKey: .type)
        case is Game_StartMessage:
            try container.encode(MessageType.game_StartMessage, forKey: .type)
        case is EntityTransformMessage:
            try container.encode(MessageType.entityTransformMessage, forKey: .type)
        case is EntityStateMessage:
            try container.encode(MessageType.entityStateMessage, forKey: .type)
        default:
            // If not a built-in type, try to get from registry
            if let typeIdentifier = MessageRegistry.shared.typeIdentifier(for: base) {
                try container.encode(MessageType.customMessage, forKey: .type)
                try container.encode(typeIdentifier, forKey: .customType)
            } else {
                throw EncodingError.invalidValue(base, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Error encoding AnySharePlayMessage: Unregistered type"))
            }
        }
        
        let data = try JSONEncoder().encode(base)
        try container.encode(data, forKey: .base)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        let data = try container.decode(Data.self, forKey: .base)

        switch type {
        case .playerMessage:
            base = try JSONDecoder().decode(Player.self, from: data)
        case .playerReadyMessage:
            base = try JSONDecoder().decode(PlayerReadyMessage.self, from: data)
        case .game_StartMessage:
            base = try JSONDecoder().decode(Game_StartMessage.self, from: data)
        case .entityTransformMessage:
            base = try JSONDecoder().decode(EntityTransformMessage.self, from: data)
        case .entityStateMessage:
            base = try JSONDecoder().decode(EntityStateMessage.self, from: data)
        case .customMessage:
            // For custom messages, we need the type identifier
            let typeIdentifier = try container.decode(String.self, forKey: .customType)
            guard let messageType = MessageRegistry.shared.type(for: typeIdentifier) else {
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown custom message type: \(typeIdentifier)")
            }
            base = try JSONDecoder().decode(messageType, from: data)
        }
    }
}

// MARK: - Message Registry

public class MessageRegistry {
    public static let shared = MessageRegistry()
    
    private var typeMap: [String: any SharePlayMessage.Type] = [:]
    
    private init() {
        // Register built-in message types
        register(Player.self, typeIdentifier: "playerMessage")
        register(PlayerReadyMessage.self, typeIdentifier: "playerReadyMessage")
        register(Game_StartMessage.self, typeIdentifier: "game_StartMessage")
        register(EntityTransformMessage.self, typeIdentifier: "entityTransformMessage")
        register(EntityStateMessage.self, typeIdentifier: "entityStateMessage")
    }
    
    public func register<T: SharePlayMessage>(_ type: T.Type, typeIdentifier: String) {
        print("📱 [SharePlay] Registering message type: \(typeIdentifier)")
        typeMap[typeIdentifier] = type
    }
    
    public func typeIdentifier(for message: any SharePlayMessage) -> String? {
        typeMap.first { $0.value == Swift.type(of: message) }?.key
    }
    
    public func type(for typeIdentifier: String) -> (any SharePlayMessage.Type)? {
        typeMap[typeIdentifier]
    }
}

// MARK: - Built-in Messages

public struct Game_StartMessage: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    public var windowId: String = ""
    public var messageId: String = UUID().uuidString
    public let id: UUID
    public let gameMode: String
    
    public static func == (lhs: Game_StartMessage, rhs: Game_StartMessage) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(windowId: String, messageId: String, id: UUID, gameMode: String) {
        self.windowId = windowId
        self.messageId = messageId
        self.id = id
        self.gameMode = gameMode
    }
}

public struct PlayerReadyMessage: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    public var windowId: String = ""
    public var messageId: String = UUID().uuidString
    public let id: UUID
    
    public static func == (lhs: PlayerReadyMessage, rhs: PlayerReadyMessage) -> Bool {
        lhs.id == rhs.id
    }
} 