import SwiftUI
import IMsgCore

struct PeopleOrbitView: View {
    @StateObject private var viewModel = PeopleOrbitViewModel()
    
    // Interactive Zoom and Pan state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Sleek dark mode background
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Mapping Your Orbit...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.participants.isEmpty {
                 Text("No contacts found to orbit.")
                    .foregroundColor(.secondary)
            } else {
                // Interactive organic canvas
                GeometryReader { geometry in
                    ZStack {
                        // We wrap the layout in a massive frame so we can pan freely in any direction
                        BubbleLayout(itemSize: 80, spacing: 16) {
                            ForEach(viewModel.participants, id: \.self) { identifier in
                                ContactBubble(identifier: identifier)
                                    .onTapGesture {
                                        // Placeholder for launching into person-specific orbit view
                                        print("👉 [PeopleOrbitView] Tapped on contact bubble for: \(identifier)")
                                    }
                            }
                        }
                        .frame(width: 4000, height: 4000)
                        
                        // Apply the interactive transformations
                        .scaleEffect(scale)
                        .offset(offset)
                        // Add pan/drag support
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        // Add zoom/magnification support
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 0.2), 3.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .animation(.interactiveSpring(), value: offset)
                        .animation(.interactiveSpring(), value: scale)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped() // Prevent overflow rendering beyond the view bounds
                }
            }
        }
        .onAppear {
            viewModel.loadParticipants()
        }
    }
}

struct ContactBubble: View {
    let identifier: String
    @ObservedObject private var contactStore = ContactStore.shared
    
    var displayName: String {
        if let contact = contactStore.contact(for: identifier) {
            let first = contact.givenName
            return first.isEmpty ? contact.familyName : first
        }
        // Truncate raw numbers to avoid massive labels
        return identifier.count > 10 ? String(identifier.prefix(10)) + "..." : identifier
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ContactAvatarView(identifier: identifier, size: 70)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 5)
                .overlay(
                    Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(width: 80)
        }
    }
}

@MainActor
class PeopleOrbitViewModel: ObservableObject {
    @Published var participants: [String] = []
    @Published var isLoading: Bool = true
    
    private let messagesService = MessagesService.shared
    
    func loadParticipants() {
        isLoading = true
        
        Task.detached {
            let service = await MessagesService.shared
            let chats = await service.recentChats
            
            var extracted = Set<String>()
            // Extract the participants from the 100 most recent loaded chats
            for chat in chats {
                let parts = await service.participants(for: chat.id)
                for p in parts {
                    // Do not add empty handles
                    if !p.isEmpty {
                        extracted.insert(p)
                    }
                }
            }
            
            // Limit to top 150 unique contacts to keep performance optimal
            let limited = Array(extracted.prefix(150))
            
            await MainActor.run {
                self.participants = limited
                self.isLoading = false
            }
        }
    }
}
