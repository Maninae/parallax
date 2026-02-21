import SwiftUI
import IMsgCore

struct ChatsView: View {
    @ObservedObject private var messagesService = MessagesService.shared
    @ObservedObject private var contactStore = ContactStore.shared
    
    @State private var selectedChat: Chat?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar: Chat List
            List(messagesService.recentChats, id: \.id, selection: $selectedChat) { chat in
                ChatRowView(chat: chat)
                    .tag(chat)
            }
            .navigationTitle("Messages")
            .listStyle(.sidebar)
            
            if messagesService.hasFullDiskAccessError {
                FullDiskAccessWarningView()
            }
        } detail: {
            if let selectedChat = selectedChat {
                MessageThreadView(chat: selectedChat)
            } else {
                Text("Select a conversation")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    @ObservedObject private var contactStore = ContactStore.shared
    
    var displayName: String {
        // 1. Try saved group or contact name from SQLite
        if let defaultName = chat.name, !defaultName.isEmpty, defaultName != chat.identifier {
            return defaultName
        }
        
        // 2. Try to resolve via Contacts framework
        if let contact = contactStore.contact(for: chat.identifier) {
            return [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
        }
        
        // 3. Fallback to raw identifier
        return chat.identifier
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ContactAvatarView(identifier: chat.identifier, size: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                // Placeholder for last message snippet
                Text("Last message...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if let date = chat.lastMessageAt {
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ContactAvatarView: View {
    let identifier: String
    let size: CGFloat
    @ObservedObject private var contactStore = ContactStore.shared
    
    var body: some View {
        Group {
            if let contact = contactStore.contact(for: identifier),
               let imageData = contact.thumbnailImageData,
               let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Fallback Avatar
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

// Helper view when Full Disk Access is missing
struct FullDiskAccessWarningView: View {
    @ObservedObject private var messagesService = MessagesService.shared
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Full Disk Access Required")
                .font(.headline)
            
            Text("Parallax needs permission to read your Messages database.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .padding(.horizontal)
            
            Button("Retry") {
                messagesService.retryConnection()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(12)
        .padding()
    }
}
