import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .chats
    
    enum Tab {
        case chats
        case people
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Outermost Navigation Bar
            VStack(spacing: 24) {
                Spacer().frame(height: 20)
                
                Button(action: { selectedTab = .chats }) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == .chats ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { selectedTab = .people }) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == .people ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: { /* Settings */ }) {
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// Stub view for the orbit until Phase 5
struct PeopleOrbitView: View {
    var body: some View {
        Text("People Orbit 'Bubble-Sea' Goes Here")
            .font(.largeTitle)
            .foregroundColor(.secondary)
    }
}

