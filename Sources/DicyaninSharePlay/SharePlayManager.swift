// Copyright © 2025 Dicyanin Labs
// Author: Hunter Harris

import Foundation
import GroupActivities
import Combine
import UIKit

@available(visionOS 1.0, *)
public class SharePlayManager: ObservableObject {
    public static let shared = SharePlayManager()
    
    @Published public var sessionInfo: DemoSessionInfo = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    public func startSharePlay() {
        print("📱 [SharePlay] Starting SharePlay")
        Task {
            do {
                let activity = MyGroupActivity()
                print("📱 [SharePlay] Activating activity")
                let _ = try await activity.activate()
                print("📱 [SharePlay] Activity activated successfully")
            } catch {
                print("📱 [SharePlay] Failed to start SharePlay: \(error.localizedDescription)")
            }
        }
    }
    
    public func configureSession(_ session: GroupSession<MyGroupActivity>) {
        print("📱 [SharePlay] Configuring session")
        self.cleanup()
        
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 1000000000)
            await joinSession(session: session)
        }
        
        session.$state.sink { [weak self] state in
            print("📱 [SharePlay] Session state changed: \(state)")
            switch state {
            case .invalidated: self?.cleanup()
            default:
                break
            }
        }.store(in: &cancellables)
    }
    
    public func joinSession(session: GroupSession<MyGroupActivity>) async {
        print("📱 [SharePlay] Joining session")
        await MainActor.run {
            let newSessionInfo = DemoSessionInfo(newSession: session)
            self.sessionInfo = newSessionInfo
            print("📱 [SharePlay] Session joined successfully")
            
            SharePlayManager.subscribeToSessionUpdates()
            SharePlayManager.subscribeToPlayerUpdates()
            
            session.join()
        }
    }
    
    public static func subscribeToSessionUpdates() {
        guard let messenger = SharePlayManager.shared.sessionInfo.messenger else { return }
        
        Task { @MainActor in
            for await (anyMessage, sender) in messenger.messages(of: AnySharePlayMessage.self) {
                await MessageHandlerRegistry.shared.handle(anyMessage.base, from: sender.source)
            }
        }
    }
    
    public static func subscribeToPlayerUpdates() {
        guard let newSession = SharePlayManager.shared.sessionInfo.session else {
            print("📱 [SharePlay] Failed to get session")
            return
        }
        
        newSession.$activeParticipants.sink { activeParticipants in
            let localId = newSession.localParticipant.id
            var totalParticipants = activeParticipants.count
            if totalParticipants == 1 {
                totalParticipants += 1
            }
            let isVisionDevice = true // Always true for visionOS
            let localPlayerSeat = isVisionDevice ? 1 : totalParticipants
            Player.local = .init(name: "Player\(localPlayerSeat)",
                               id: localId,   
                               score: 0,
                               isActive: true,
                               isReady: false,
                               isVisionDevice: isVisionDevice,
                               playerSeat: localPlayerSeat)
            
            for participant in activeParticipants {
                let participantIndex = Array(activeParticipants).firstIndex(of: participant) ?? 1
                let seatNumber = participantIndex + 2  // Start at 2 since Vision Pro is 1
                
                let potentialNewPlayer = Player(
                    name: "Player \(seatNumber)",
                    id: participant.id,
                    score: 0,
                    isActive: true,
                    isReady: false,
                    isVisionDevice: false,
                    playerSeat: seatNumber
                )
            }
        }
        .store(in: &SharePlayManager.shared.cancellables)
    }
    
    public static func getColorForSeat(seat: Int) -> UIColor {
        switch seat {
        case 1: return .red
        case 2: return .blue
        case 3: return .purple
        case 4: return .yellow
        default: return .black
        }
    }
    
    @MainActor
    public static func handleMessage(_ message: AnySharePlayMessage,
                              sender: Participant,
                              forceHandling: Bool = false) async {
        await MessageHandlerRegistry.shared.handle(message.base, from: sender)
    }
    
    public static func sendMessage(message: any SharePlayMessage,
                            participants: Set<Participant>? = nil,
                            handleLocally: Bool = false)
    {
        if handleLocally {
            Task {
                if let localParticipant = SharePlayManager.shared.sessionInfo.session?.localParticipant {
                    await SharePlayManager.handleMessage(AnySharePlayMessage(message), sender: localParticipant, forceHandling: handleLocally)
                }
            }
        }
    
        if let session = SharePlayManager.shared.sessionInfo.session,
            let messenger = SharePlayManager.shared.sessionInfo.messenger
        {
            let everyoneElse = session.activeParticipants.subtracting([session.localParticipant])
            let newMessage = AnySharePlayMessage(message)
            messenger.send(newMessage, to: .only(participants ?? everyoneElse)) { error in
                if let error = error { print("📱 [SharePlay] Error sending \(message.self) Message: \(error)") }
            }
        }
    }
    
    public func cleanup() {
        print("📱 [SharePlay] Cleaning up session")
        Task { @MainActor in
            SharePlayManager.shared.sessionInfo.session?.leave()
            SharePlayManager.shared.sessionInfo.session = nil
            sessionInfo.session = nil
            sessionInfo.messenger = nil
            sessionInfo = .init()
            cancellables.removeAll()
            print("📱 [SharePlay] Cleanup complete")
        }
    }
}

extension SharePlayManager {
    public static func sendStartGameMessage() {
        let startGameMsg: Game_StartMessage = .init(windowId: "", messageId: "", id: UUID(), gameMode: "default")
        sendMessage(message: startGameMsg, handleLocally: false)
    }
}

@available(visionOS 1.0, *)
public struct MyGroupActivity: GroupActivity {
    public var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "My SharePlay Activity"
        metadata.type = .generic
        return metadata
    }
    public static var activityIdentifier = "dicyaninlabs.org.shareplay-activity2"
}

public class DemoSessionInfo: ObservableObject {
    @Published public var session: GroupSession<MyGroupActivity>?
    @Published public var messenger: GroupSessionMessenger?
    public var reliableMessenger: GroupSessionMessenger?
    public var journal: GroupSessionJournal?
    
    public init() { }
    public init(newSession: GroupSession<MyGroupActivity>) {
        self.session = newSession
        self.messenger = GroupSessionMessenger(session: newSession, deliveryMode: .reliable)
        self.reliableMessenger = GroupSessionMessenger(session: newSession, deliveryMode: .unreliable)
    }
} 