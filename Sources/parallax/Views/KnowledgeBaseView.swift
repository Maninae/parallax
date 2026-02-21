import SwiftUI

struct KnowledgeBaseView: View {
    @StateObject private var llmService = LLMService()
    @State private var prompt: String = ""
    @State private var responseText: String = ""
    @State private var isGenerating: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Knowledge Base")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(llmService.isReachable ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(llmService.isReachable ? "Ollama Connected" : "Ollama Disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            ScrollView {
                Text(responseText.isEmpty ? "Ask me anything about your chats..." : responseText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .textSelection(.enabled)
            }
            .padding()
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(12)
            
            HStack {
                TextField("Message local AI...", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isGenerating || !llmService.isReachable)
                
                Button(action: submitPrompt) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(prompt.isEmpty || isGenerating || !llmService.isReachable ? .gray : .blue)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(prompt.isEmpty || isGenerating || !llmService.isReachable)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 400)
    }
    
    private func submitPrompt() {
        guard !prompt.isEmpty else { return }
        
        responseText = ""
        isGenerating = true
        
        let currentPrompt = prompt
        prompt = ""
        
        Task {
            do {
                let stream = llmService.generateResponse(prompt: currentPrompt)
                for try await chunk in stream {
                    await MainActor.run {
                        responseText += chunk
                    }
                }
            } catch {
                await MainActor.run {
                    responseText = "Error generating response: \(error.localizedDescription)"
                }
            }
            
            await MainActor.run {
                isGenerating = false
            }
        }
    }
}
