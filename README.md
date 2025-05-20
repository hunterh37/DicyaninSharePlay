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

### 1. Configure Your Project

**IMPORTANT**: You must add the SharePlay entitlement to your Xcode project:
1. Select your project in Xcode
2. Select your target
3. Go to "Signing & Capabilities"
4. Click "+" and add "SharePlay"
5. Ensure your provisioning profile includes SharePlay entitlement

### 2. Initialize SharePlay

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

### 3. Configure Your ImmersiveView

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

### 4. Add SharePlay Status and Player Management

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            // SharePlay status and controls
            DicyaninSharePlayStatusView()
                .frame(maxWidth: 300)
            
            // Player name editor
            PlayerNameEditor()
                .frame(maxWidth: 300)
            
            // Active players list
            PlayerListView()
                .frame(maxWidth: 300)
        }
    }
}
```

## Components

### DicyaninSharePlayStatusView
A view that displays the current SharePlay session status and provides controls to start/stop the session.
- Shows active/inactive status with appropriate icons
- Provides prominent "Start SharePlay" button when inactive
- Shows destructive "Leave SharePlay" button when active
- Automatically updates when session state changes

### PlayerNameEditor
A view that allows users to set and edit their player name.
- Shows current player name or "Set your name" prompt
- Provides inline editing with validation
- Automatically syncs name changes across SharePlay session

### PlayerListView
A view that displays all active players in the SharePlay session.
- Shows player names with ready status
- Indicates local player with "(You)" label
- Updates automatically when players join/leave
- Uses modern translucent design

## Message Types

### Player
Represents a player in the SharePlay session with properties:
- `name`: Player's display name
- `id`: Unique identifier
- `score`: Current score
- `isActive`: Whether player is active
- `isReady`: Player's ready status
- `isVisionDevice`: Whether player is on visionOS
- `playerSeat`: Assigned seat number

### EntityTransformMessage
For syncing 3D entity transformations:
- `entityId`: Target entity identifier
- `position`: SIMD3<Float> position
- `rotation`: simd_quatf rotation
- `scale`: SIMD3<Float> scale

### EntityStateMessage
For syncing entity creation/deletion:
- `entityId`: Target entity identifier
- `isActive`: Whether entity should be active
- `modelName`: Name of the model to load

## Best Practices

1. **Session Management**
   - Always check session state before sending messages
   - Handle session cleanup properly when leaving
   - Use appropriate error handling for session operations

2. **Player Management**
   - Update player state through PlayerManager
   - Handle player disconnections gracefully
   - Validate player data before sending

3. **Message Handling**
   - Use appropriate message types for different data
   - Handle message delivery failures
   - Consider message ordering for critical updates

4. **UI Updates**
   - Use ObservableObject for state management
   - Update UI on the main thread
   - Handle edge cases (no players, disconnected, etc.)

## License

Copyright © 2025 Dicyanin Labs. All rights reserved.

## Author

Hunter Harris 

## Usage

### Basic Setup

1. Add the SharePlay entitlement to your app's target
2. Import the package in your app
3. Use the provided views and managers

### SharePlay Status View

```swift
import DicyaninSharePlay

struct ContentView: View {
    var body: some View {
        DicyaninSharePlayStatusView()
    }
}
```

### Player List View

```swift
import DicyaninSharePlay

struct ContentView: View {
    var body: some View {
        PlayerListView()
    }
}
```

### Custom Message Types

You can create and register your own SharePlay message types. Here's how:

1. Create a message type that conforms to `SharePlayMessage`:

```swift
struct CustomGameMessage: Codable, Sendable, Identifiable, Equatable, SharePlayMessage {
    public var windowId: String = ""
    public var messageId: String = UUID().uuidString
    public let id: UUID
    public let customData: String
    
    public static func == (lhs: CustomGameMessage, rhs: CustomGameMessage) -> Bool {
        lhs.id == rhs.id
    }
}
```

2. Register your message type in your app's initialization:

```swift
// In your app's initialization code (e.g., App.swift)
@main
struct YourApp: App {
    init() {
        // Register custom message types
        MessageRegistry.shared.register(CustomGameMessage.self, typeIdentifier: "customGameMessage")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

3. Use your custom message type:

```swift
// Sending a custom message
let message = CustomGameMessage(
    windowId: "main",
    messageId: UUID().uuidString,
    id: UUID(),
    customData: "Hello SharePlay!"
)
SharePlayManager.sendMessage(message: message)
```

### Built-in Message Types

The package includes several built-in message types:
- `Player`: Player information
- `PlayerReadyMessage`: Player ready status
- `Game_StartMessage`: Game start notification
- `Game_SendHeartMessage`: Heart synchronization
- `EntityTransformMessage`: Entity transform updates
- `EntityStateMessage`: Entity state updates 