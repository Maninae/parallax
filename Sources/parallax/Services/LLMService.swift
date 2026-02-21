import Foundation
import Ollama

@MainActor
public class LLMService: ObservableObject {
    public let client = Ollama.Client.default
    
    @Published public var isReachable: Bool = false
    
    public init() {
        Task {
            await checkReachability()
        }
    }
    
    public func checkReachability() async {
        do {
            _ = try await client.version()
            isReachable = true
        } catch {
            isReachable = false
        }
    }
    
    public func generateResponse(prompt: String, model: String = "llama3") -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let stream = client.generateStream(model: Ollama.Model.ID(rawValue: model)!, prompt: prompt)
                    for try await chunk in stream {
                        continuation.yield(chunk.response)
                        if chunk.done {
                            continuation.finish()
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
