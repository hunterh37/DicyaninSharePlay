// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import SwiftUI
import GroupActivities

/// A view that displays the list of active players in the SharePlay session
public struct PlayerListView: View {
    @StateObject private var playerManager = PlayerManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Players")
                .font(.headline)
                .padding(.bottom, 4)
            
            if playerManager.players.isEmpty {
                Text("No active players")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(playerManager.players.enumerated()), id: \.element.id) { _, player in
                            HStack {
                                Circle()
                                    .frame(width: 12, height: 12)
                                
                                Text(player.name)
                                    .font(.subheadline)
                                
                                if player.isReady {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                                
                                if player.id == playerManager.localPlayer?.id {
                                    Text("(You)")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PlayerListView()
} 
