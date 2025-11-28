import SwiftUI

@main
struct OllamaChatApp: App {
    @StateObject private var ollamaService = OllamaService.shared
    @StateObject private var settings = AppSettings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ollamaService)
                .environmentObject(settings)
        }
    }
}

