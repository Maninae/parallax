import SwiftUI
import IMsgCore

struct MessageThreadView: View {
    let chat: Chat
    @StateObject private var viewModel = MessageThreadViewModel()
    @State private var showInspector: Bool = false
    
    var mainThreadContent: some View {
        VStack(spacing: 0) {
            // Header
            ChatHeaderView(chat: chat, showInspector: $showInspector)
                .frame(height: 60)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
            
            Divider()
            
            // Messages Scrollable Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages, id: \.rowID) { message in
                            MessageBubbleView(message: message)
                                .id(message.rowID)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.rowID, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Compose Area (Read-Only approach for now, pending AppleScript integration)
            ComposeMessageView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            mainThreadContent
            
            if showInspector {
                Divider()
                ContactDetailSidebar(chat: chat) {
                    withAnimation(.spring()) {
                        showInspector = false
                    }
                }
                .transition(.move(edge: .trailing))
            }
        }
        .onAppear {
            viewModel.loadMessages(for: chat.id)
        }
        .onChange(of: chat.id) {
            viewModel.loadMessages(for: chat.id)
        }
    }
}

@MainActor
class MessageThreadViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private let service = MessagesService.shared
    
    func loadMessages(for chatID: Int64) {
        // IMsgCore handles its own internal queue, so we can safely call this from the MainActor
        let fetched = self.service.messages(for: chatID)
        self.messages = fetched
    }
}

struct ChatHeaderView: View {
    let chat: Chat
    @Binding var showInspector: Bool
    @ObservedObject private var contactStore = ContactStore.shared
    
    var displayName: String {
        let defaultName = chat.name
        if !defaultName.isEmpty && defaultName != chat.identifier {
            return defaultName
        }
        if let contact = contactStore.contact(for: chat.identifier) {
            return [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
        }
        return chat.identifier
    }
    
    var body: some View {
        HStack {
            ContactAvatarView(identifier: chat.identifier, size: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.headline)
                
                Text(chat.service)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ButtonActionIcon(icon: "info.circle") {
                withAnimation(.spring()) {
                    showInspector.toggle()
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ButtonActionIcon: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MessageBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromMe { Spacer() }
            
            Text(message.text.isEmpty ? "Attachment" : message.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isFromMe ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isFromMe ? .white : .primary)
                .cornerRadius(18)
                .contextMenu {
                    Button("Copy") {
                        let text = message.text
                        if !text.isEmpty {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(text, forType: .string)
                        }
                    }
                }
            
            if !message.isFromMe { Spacer() }
        }
    }
}

struct ComposeMessageView: View {
    @State private var text: String = ""
    
    var body: some View {
        HStack {
            TextField("iMessage...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 12)
                .padding(.leading, 12)
            
            ButtonActionIcon(icon: "arrow.up.circle.fill") {
                // Send action goes here
            }
            .padding(.trailing, 12)
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}
