// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import Foundation
import SwiftUI
import GroupActivities

@MainActor
public final class PlayerManager: ObservableObject {
    public static let shared = PlayerManager()
    
    @Published public var players: [Player] = []
    @Published public private(set) var localPlayer: Player?
    
    private init() {
        setupMessageHandling()
    }
    
    private func setupMessageHandling() {
        let handler = PlayerMessageHandler { [weak self] player in
            self?.handlePlayerMessage(player)
        }
        MessageHandlerRegistry.shared.register(handler)
    }
    
    private func handlePlayerMessage(_ player: Player) {
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index] = player
        } else {
            players.append(player)
        }
        
        // Update local player if this is our player
        if player.id == localPlayer?.id {
            localPlayer = player
        }
    }
    
    public func updateLocalPlayer(name: String) {
        guard var player = localPlayer else {
            // Create new player if none exists
            let newPlayer = Player(
                name: name,
                id: UUID(),
                score: 0,
                isActive: false,
                isReady: true,
                isVisionDevice: true,
                playerSeat: 0
            )
            localPlayer = newPlayer
            Task {
                await SharePlayManager.sendMessage(message: newPlayer, handleLocally: true)
            }
            return
        }
        
        // Update existing player
        player.name = name
        localPlayer = player
        Task {
            await SharePlayManager.sendMessage(message: player, handleLocally: true)
        }
    }
    
    public func setLocalPlayerReady(_ isReady: Bool) {
        guard var player = localPlayer else { return }
        player.isReady = isReady
        localPlayer = player
        Task {
            await SharePlayManager.sendMessage(message: player, handleLocally: true)
        }
    }
}

private class PlayerMessageHandler: SharePlayMessageHandler {
    typealias MessageType = Player
    
    private let onPlayerReceived: (Player) -> Void
    
    init(onPlayerReceived: @escaping (Player) -> Void) {
        self.onPlayerReceived = onPlayerReceived
    }
    
    func handle(_ message: Player, from sender: Participant) async {
        onPlayerReceived(message)
    }
} 
