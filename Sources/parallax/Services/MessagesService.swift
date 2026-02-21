import Foundation
import IMsgCore
import Combine
import OSLog

let msgLogger = Logger(subsystem: "com.parallax.app", category: "MessagesService")

@MainActor
public class MessagesService: ObservableObject {
    public static let shared = MessagesService()
    
    @Published public var recentChats: [Chat] = []
    @Published public var hasFullDiskAccessError: Bool = false
    
    private var store: MessageStore?
    
    private init() {
        setupStore()
    }
    
    private func setupStore() {
        do {
            // IMsgCore defaults to `~/Library/Messages/chat.db`
            self.store = try MessageStore()
            self.hasFullDiskAccessError = false
            loadRecentChats()
        } catch {
            msgLogger.error("Failed to initialize MessageStore: \(error.localizedDescription)")
            self.hasFullDiskAccessError = true
            // If the user hasn't granted Full Disk Access (FDA), this will throw a permissions error.
        }
    }
    
    public func retryConnection() {
        setupStore()
    }
    
    public func loadRecentChats(limit: Int = 100) {
        guard let store = store else { return }
        
        Task.detached {
            do {
                let chats = try store.listChats(limit: limit)
                await MainActor.run {
                    self.recentChats = chats
                }
            } catch {
                msgLogger.error("Failed to load chats: \(error.localizedDescription)")
            }
        }
    }
    
    /// Get detailed participants for a chat via its ROWID
    public func participants(for chatID: Int64) -> [String] {
        guard let store = store else { return [] }
        do {
            return try store.participants(chatID: chatID)
        } catch {
            msgLogger.error("Failed to load participants for \(chatID): \(error.localizedDescription)")
            return []
        }
    }
}
