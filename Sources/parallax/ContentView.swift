import SwiftUI
import AppKit

struct ContentView: View {
    @State private var selectedTab: Tab = .chats
    
    enum Tab {
        case chats
        case people
        case knowledgeBase
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Outermost Navigation Bar
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                Button(action: {
                    print("👉 [ContentView] Switched tab to Chats")
                    selectedTab = .chats
                }) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == .chats ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    print("👉 [ContentView] Switched tab to People")
                    selectedTab = .people
                }) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == .people ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    print("👉 [ContentView] Switched tab to Knowledge Base")
                    selectedTab = .knowledgeBase
                }) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == .knowledgeBase ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: {
                    print("👉 [ContentView] Settings button tapped")
                    /* Settings */
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 20)
            }
            .frame(width: 60)
            // A dark, slightly translucent background for the leftmost bar
            .background(Color.black.opacity(0.15)) 
            .ignoresSafeArea()
            
            Divider()
            
            // Content Area based on selection
            Group {
                switch selectedTab {
                case .chats:
                    ChatsView()
                case .people:
                    PeopleOrbitView()
                case .knowledgeBase:
                    KnowledgeBaseView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if event.modifierFlags.contains(.command),
                       event.modifierFlags.contains(.option),
                       event.charactersIgnoringModifiers == "s" {
                        print("📸 DEBUG SCREENSHOT SHORTCUT DETECTED!")
                        captureDebugScreenshot()
                        return nil // Consume event
                    }
                    return event
                }
            }
        }
    }
    
    private func captureDebugScreenshot() {
        guard let window = NSApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? NSApplication.shared.windows.first,
              let view = window.contentView else {
            print("Failed to get window or content view")
            return
        }
        
        guard let bitmapRep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            print("Failed to create bitmap representation")
            return
        }
        
        view.cacheDisplay(in: view.bounds, to: bitmapRep)
        
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            print("Failed to create PNG data")
            return
        }
        
        let path = URL(fileURLWithPath: "/tmp/parallax_debug_render.png")
        do {
            try pngData.write(to: path)
            print("Successfully saved window screenshot to \(path.path)")
        } catch {
            print("Failed to save window screenshot: \(error)")
        }
    }
}


