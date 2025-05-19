// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import Foundation
import GroupActivities
import RealityKit

/// Handler for entity transform messages
public class EntityTransformHandler: SharePlayMessageHandler {
    public typealias MessageType = EntityTransformMessage
    
    // Callback for when transform is received
    private let onTransformReceived: (EntityTransformMessage) -> Void
    
    public init(onTransformReceived: @escaping (EntityTransformMessage) -> Void) {
        self.onTransformReceived = onTransformReceived
    }
    
    public func handle(_ message: EntityTransformMessage, from sender: Participant) async {
        onTransformReceived(message)
    }
}

/// Handler for entity state messages
public class EntityStateHandler: SharePlayMessageHandler {
    public typealias MessageType = EntityStateMessage
    
    // Callback for when entity state changes
    private let onStateChanged: (EntityStateMessage) -> Void
    
    public init(onStateChanged: @escaping (EntityStateMessage) -> Void) {
        self.onStateChanged = onStateChanged
    }
    
    public func handle(_ message: EntityStateMessage, from sender: Participant) async {
        onStateChanged(message)
    }
} 