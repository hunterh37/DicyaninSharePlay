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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Get the type identifier from the registry
        guard let typeIdentifier = MessageRegistry.shared.typeIdentifier(for: base) else {
            throw EncodingError.invalidValue(base, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Error encoding AnySharePlayMessage: Unregistered type"))
        }
        
        try container.encode(typeIdentifier, forKey: .type)
        let data = try JSONEncoder().encode(base)
        try container.encode(data, forKey: .base)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeIdentifier = try container.decode(String.self, forKey: .type)
        let data = try container.decode(Data.self, forKey: .base)

        // Get the type from the registry
        guard let type = MessageRegistry.shared.type(for: typeIdentifier) else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown message type: \(typeIdentifier)")
        }
        
        base = try JSONDecoder().decode(type, from: data)
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
        register(Game_SendHeartMessage.self, typeIdentifier: "game_SendHeartMessage")
        register(EntityTransformMessage.self, typeIdentifier: "entityTransformMessage")
        register(EntityStateMessage.self, typeIdentifier: "entityStateMessage")
    }
    
    public func register<T: SharePlayMessage>(_ type: T.Type, typeIdentifier: String) {
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

public struct Game_SendHeartMessage: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    public let id: UUID
    public let seatNumber: Int
    public let heartHeight: Float
    public var windowId: String = ""
    public var messageId: String = UUID().uuidString
    
    public init(windowId: String, messageId: String, id: UUID, seatNumber: Int, heartHeight: Float) {
        self.windowId = windowId
        self.messageId = messageId
        self.id = id
        self.seatNumber = seatNumber
        self.heartHeight = heartHeight
    }
    
    public static func == (lhs: Game_SendHeartMessage, rhs: Game_SendHeartMessage) -> Bool {
        lhs.id == rhs.id
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