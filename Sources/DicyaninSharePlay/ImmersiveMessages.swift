// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import Foundation
import GroupActivities
import RealityKit

/// Message for syncing 3D entity transformations
public struct EntityTransformMessage: SharePlayMessage {
    public var windowId: String = ""
    public var messageId: String = UUID().uuidString
    
    // Entity identifier
    public let entityId: String
    
    // Transform data
    public let position: SIMD3<Float>
    public let rotation: simd_quatf
    public let scale: SIMD3<Float>
    
    public init(entityId: String, position: SIMD3<Float>, rotation: simd_quatf, scale: SIMD3<Float>) {
        self.entityId = entityId
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }
    
    // Custom Codable conformance
    private enum CodingKeys: String, CodingKey {
        case windowId, messageId, entityId, position, rotation, scale
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        windowId = try container.decode(String.self, forKey: .windowId)
        messageId = try container.decode(String.self, forKey: .messageId)
        entityId = try container.decode(String.self, forKey: .entityId)
        
        // Decode position as [Float] and convert to SIMD3<Float>
        let posArray = try container.decode([Float].self, forKey: .position)
        guard posArray.count == 3 else { throw DecodingError.dataCorruptedError(forKey: .position, in: container, debugDescription: "Expected 3 values for position") }
        position = SIMD3<Float>(posArray[0], posArray[1], posArray[2])
        
        // Decode rotation as [Float] and convert to simd_quatf
        let rotArray = try container.decode([Float].self, forKey: .rotation)
        guard rotArray.count == 4 else { throw DecodingError.dataCorruptedError(forKey: .rotation, in: container, debugDescription: "Expected 4 values for rotation") }
        rotation = simd_quatf(ix: rotArray[0], iy: rotArray[1], iz: rotArray[2], r: rotArray[3])
        
        // Decode scale as [Float] and convert to SIMD3<Float>
        let scaleArray = try container.decode([Float].self, forKey: .scale)
        guard scaleArray.count == 3 else { throw DecodingError.dataCorruptedError(forKey: .scale, in: container, debugDescription: "Expected 3 values for scale") }
        scale = SIMD3<Float>(scaleArray[0], scaleArray[1], scaleArray[2])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(windowId, forKey: .windowId)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(entityId, forKey: .entityId)
        
        // Encode position as [Float]
        try container.encode([position.x, position.y, position.z], forKey: .position)
        
        // Encode rotation as [Float]
        try container.encode([rotation.vector.x, rotation.vector.y, rotation.vector.z, rotation.vector.w], forKey: .rotation)
        
        // Encode scale as [Float]
        try container.encode([scale.x, scale.y, scale.z], forKey: .scale)
    }
}

/// Message for syncing entity creation/deletion
public struct EntityStateMessage: SharePlayMessage {
    public var windowId: String = ""
    public var messageId: String = UUID().uuidString
    
    public let entityId: String
    public let isActive: Bool
    public let modelName: String
    
    public init(entityId: String, isActive: Bool, modelName: String) {
        self.entityId = entityId
        self.isActive = isActive
        self.modelName = modelName
    }
} 