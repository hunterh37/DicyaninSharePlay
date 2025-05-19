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