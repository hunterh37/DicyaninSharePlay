// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import SwiftUI

public struct PlayerNameEditor: View {
    @StateObject private var playerManager = PlayerManager.shared
    @State private var playerName: String = ""
    @State private var isEditing = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            if isEditing {
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        submitName()
                    }
                
                Button("Save") {
                    submitName()
                }
                .buttonStyle(.borderedProminent)
            } else {
                HStack {
                    if let player = playerManager.localPlayer {
                        Text(player.name)
                            .font(.headline)
                    } else {
                        Text("Set your name")
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        playerName = playerManager.localPlayer?.name ?? ""
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func submitName() {
        guard !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        playerManager.updateLocalPlayer(name: playerName)
        isEditing = false
    }
}

#Preview {
    PlayerNameEditor()
} 