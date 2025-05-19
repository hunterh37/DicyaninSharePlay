// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import SwiftUI
import GroupActivities

public struct DicyaninSharePlayStatusView: View {
    @StateObject private var sharePlayManager = SharePlayManager.shared
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            if sharePlayManager.sessionInfo.session != nil {
                // Active session
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.green)
                    Text("SharePlay Active")
                        .foregroundStyle(.green)
                }
                
                Button(role: .destructive) {
                    sharePlayManager.cleanup()
                } label: {
                    Label("Leave SharePlay", systemImage: "person.2.slash")
                }
                .buttonStyle(.bordered)
            } else {
                // No active session
                HStack {
                    Image(systemName: "person.2.slash")
                        .foregroundStyle(.secondary)
                    Text("SharePlay Inactive")
                        .foregroundStyle(.secondary)
                }
                
                Button {
                    sharePlayManager.startSharePlay()
                } label: {
                    Label("Start SharePlay", systemImage: "person.2.fill")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    DicyaninSharePlayStatusView()
} 