import SwiftUI
import IMsgCore

struct ContactDetailSidebar: View {
    let chat: Chat
    let onClose: () -> Void
    
    @ObservedObject private var messagesService = MessagesService.shared
    @ObservedObject private var contactStore = ContactStore.shared
    @State private var participants: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Details")
                    .font(.headline)
                Spacer()
                Button(action: {
                    print("👉 [ContactDetailSidebar] Close button tapped.")
                    onClose()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Large group/contact photo
                    ContactAvatarView(identifier: chat.identifier, size: 80)
                        .padding(.top, 24)
                    
                    Text(chat.name.isEmpty ? chat.identifier : chat.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Participants Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PARTICIPANTS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(participants, id: \.self) { participant in
                            let contactName = resolveName(for: participant)
                            
                            HStack(spacing: 12) {
                                ContactAvatarView(identifier: participant, size: 30)
                                VStack(alignment: .leading) {
                                    Text(contactName)
                                        .font(.subheadline)
                                    if contactName != participant {
                                        Text(participant)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .frame(width: 280)
        .background(VisualEffectView(material: .sidebar, blendingMode: .withinWindow))
        .onAppear {
            participants = messagesService.participants(for: chat.id)
        }
        .onChange(of: chat.id) { _ in
            participants = messagesService.participants(for: chat.id)
        }
    }
    
    private func resolveName(for id: String) -> String {
        if let contact = contactStore.contact(for: id) {
            return [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
        }
        return id
    }
}
