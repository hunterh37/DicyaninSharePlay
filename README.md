# DicyaninSharePlay

A SharePlay package for visionOS that enables real-time synchronization of 3D content and game state across multiple devices.

## Features

- Real-time 3D entity synchronization
- Player management and seat assignment
- Type-safe message handling system
- Support for custom message types
- Built specifically for visionOS

## Requirements

- visionOS 1.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/DicyaninSharePlay.git", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File > Add Packages...
2. Enter the repository URL
3. Select the version rule
4. Click Add Package

## Getting Started

### 1. Initialize SharePlay

```swift
import DicyaninSharePlay
import RealityKit

struct ContentView: View {
    var body: some View {
        Button("Start SharePlay") {
            SharePlayManager.shared.startSharePlay()
        }
    }
}
```

### 2. Configure Your ImmersiveView

```swift
struct ImmersiveView: View {
    @State private var content: Entity?
    
    var body: some View {
        RealityView { content in
            // Your 3D content setup
            self.content = content
            registerMessageHandlers()
        } update: { content in
            // Update your 3D content
        }
    }
    
    private func registerMessageHandlers() {
        // Register transform handler
        let transformHandler = EntityTransformHandler { message in
            guard let entity = content?.entities.first(where: { $0.id.description == message.entityId }) else { return }
            entity.position = message.position
            entity.orientation = message.rotation
            entity.scale = message.scale
        }
        MessageHandlerRegistry.shared.register(transformHandler)
        
        // Register state handler
        let stateHandler = EntityStateHandler { message in
            if message.isActive {
                Task {
                    if let newEntity = try? await Entity(named: message.modelName, in: realityKitContentBundle) {
                        content?.add(newEntity)
                    }
                }
            } else {
                if let entity = content?.entities.first(where: { $0.id.description == message.entityId }) {
                    content?.remove(entity)
                }
            }
        }
        MessageHandlerRegistry.shared.register(stateHandler)
    }
}
```

### 3. Send Messages

```swift
// Send entity transform updates
let message = EntityTransformMessage(
    entityId: entity.id.description,
    position: entity.position,
    rotation: entity.orientation,
    scale: entity.scale
)
SharePlayManager.sendMessage(message: message)

// Send entity state changes
let message = EntityStateMessage(
    entityId: entity.id.description,
    isActive: true, // or false for deletion
    modelName: "YourModelName"
)
SharePlayManager.sendMessage(message: message)
```

## Custom Message Types

To create a custom message type:

1. Create a new struct conforming to `SharePlayMessage`:

```swift
struct CustomMessage: SharePlayMessage {
    var windowId: String = ""
    var messageId: String = UUID().uuidString
    
    // Add your custom properties
    let customData: String
}
```

2. Add the message type to `AnySharePlayMessage`:

```swift
private enum MessageType: String, Codable {
    // ... existing cases ...
    case customMessage
}

// In encode method:
case is CustomMessage:
    try container.encode(MessageType.customMessage, forKey: .type)

// In init(from:) method:
case .customMessage:
    base = try JSONDecoder().decode(CustomMessage.self, from: data)
```

3. Create a handler:

```swift
class CustomMessageHandler: SharePlayMessageHandler {
    typealias MessageType = CustomMessage
    
    private let onMessageReceived: (CustomMessage) -> Void
    
    init(onMessageReceived: @escaping (CustomMessage) -> Void) {
        self.onMessageReceived = onMessageReceived
    }
    
    func handle(_ message: CustomMessage, from sender: Participant) async {
        onMessageReceived(message)
    }
}
```

## License

Copyright © 2025 Dicyanin Labs. All rights reserved.

## Author

Hunter Harris 