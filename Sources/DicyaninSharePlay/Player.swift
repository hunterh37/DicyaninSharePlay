// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import Foundation
import GroupActivities

public struct Player: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    public var windowId: String = ""
    public var messageId: String = UUID().uuidString
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.name == rhs.name && lhs.id == rhs.id
    }
    
    public var name: String
    public let id: UUID
    public var score: Int
    public var isActive: Bool
    public var isReady: Bool
    public var playerSeat: Int
    public var isVisionDevice: Bool
    
    public init(name: String, id: UUID, score: Int, isActive: Bool, isReady: Bool, isVisionDevice: Bool, playerSeat: Int) {
        self.name = name
        self.score = score
        self.id = id
        self.isActive = isActive
        self.isReady = isReady
        self.playerSeat = playerSeat
        self.isVisionDevice = isVisionDevice
    }
    
    /// The local player, "me".
    public static var local: Player? = nil
} 