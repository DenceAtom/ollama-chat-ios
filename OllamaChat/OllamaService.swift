import Foundation
import Combine

class OllamaService: ObservableObject {
    static let shared = OllamaService()
    
    @Published var models: [OllamaModel] = []
    @Published var selectedModel: String = ""
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false
    
    private var baseURL: String {
        AppSettings.shared.ollamaURL
    }
    
    private init() {
        Task {
            await loadModels()
        }
    }
    
    func loadModels() async {
        guard let url = URL(string: "\(baseURL)/api/tags") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OllamaModelsResponse.self, from: data)
            
            await MainActor.run {
                self.models = response.models
                if self.selectedModel.isEmpty && !self.models.isEmpty {
                    self.selectedModel = self.models[0].name
                }
                self.isConnected = true
            }
        } catch {
            await MainActor.run {
                self.isConnected = false
                print("Error loading models: \(error)")
            }
        }
    }
    
    func sendMessage(_ message: String, conversationHistory: [Message], images: [Data]? = nil) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            throw OllamaError.invalidURL
        }
        
        var messages: [[String: Any]] = []
        
        // Add conversation history
        for msg in conversationHistory {
            var messageDict: [String: Any] = [
                "role": msg.role.rawValue,
                "content": msg.content
            ]
            
            // Add images if available
            if let images = msg.images, !images.isEmpty {
                var imagesArray: [String] = []
                for imageData in images {
                    let base64 = imageData.base64EncodedString()
                    imagesArray.append("data:image/jpeg;base64,\(base64)")
                }
                messageDict["images"] = imagesArray
            }
            
            messages.append(messageDict)
        }
        
        // Add current message
        var currentMessage: [String: Any] = [
            "role": "user",
            "content": message
        ]
        
        if let images = images, !images.isEmpty {
            var imagesArray: [String] = []
            for imageData in images {
                let base64 = imageData.base64EncodedString()
                imagesArray.append("data:image/jpeg;base64,\(base64)")
            }
            currentMessage["images"] = imagesArray
        }
        
        messages.append(currentMessage)
        
        let requestBody: [String: Any] = [
            "model": selectedModel.isEmpty ? (models.first?.name ?? "llama2") : selectedModel,
            "messages": messages,
            "stream": false
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.requestFailed
        }
        
        let chatResponse = try JSONDecoder().decode(OllamaChatResponse.self, from: data)
        return chatResponse.message.content
    }
    
    func generateResponse(prompt: String, systemPrompt: String? = nil) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            throw OllamaError.invalidURL
        }
        
        var requestBody: [String: Any] = [
            "model": selectedModel.isEmpty ? (models.first?.name ?? "llama2") : selectedModel,
            "prompt": prompt,
            "stream": false
        ]
        
        if let systemPrompt = systemPrompt {
            requestBody["system"] = systemPrompt
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.requestFailed
        }
        
        let generateResponse = try JSONDecoder().decode(OllamaGenerateResponse.self, from: data)
        return generateResponse.response
    }
}

// MARK: - Models

struct OllamaModel: Codable {
    let name: String
    let modifiedAt: String
    let size: Int64
    
    enum CodingKeys: String, CodingKey {
        case name
        case modifiedAt = "modified_at"
        case size
    }
}

struct OllamaModelsResponse: Codable {
    let models: [OllamaModel]
}

struct OllamaChatResponse: Codable {
    let message: OllamaMessage
    let done: Bool
}

struct OllamaMessage: Codable {
    let role: String
    let content: String
}

struct OllamaGenerateResponse: Codable {
    let response: String
}

enum OllamaError: LocalizedError {
    case invalidURL
    case requestFailed
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Ollama URL"
        case .requestFailed:
            return "Request to Ollama failed"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

