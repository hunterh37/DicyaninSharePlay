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
        case game_SendHeartMessage
        case entityTransformMessage
        case entityStateMessage
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch base {
        case is Player:
            try container.encode(MessageType.playerMessage, forKey: .type)
        case is PlayerReadyMessage:
            try container.encode(MessageType.playerReadyMessage, forKey: .type)
        case is Game_StartMessage:
            try container.encode(MessageType.game_StartMessage, forKey: .type)
        case is Game_SendHeartMessage:
            try container.encode(MessageType.game_SendHeartMessage, forKey: .type)
        case is EntityTransformMessage:
            try container.encode(MessageType.entityTransformMessage, forKey: .type)
        case is EntityStateMessage:
            try container.encode(MessageType.entityStateMessage, forKey: .type)
        default:
            throw EncodingError.invalidValue(base, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Error encoding AnySharePlayMessage: Invalid type"))
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
        case .game_SendHeartMessage:
            base = try JSONDecoder().decode(Game_SendHeartMessage.self, from: data)
        case .entityTransformMessage:
            base = try JSONDecoder().decode(EntityTransformMessage.self, from: data)
        case .entityStateMessage:
            base = try JSONDecoder().decode(EntityStateMessage.self, from: data)
        }
    }
}

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