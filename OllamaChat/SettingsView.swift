import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var ollamaURL: String {
        didSet {
            UserDefaults.standard.set(ollamaURL, forKey: "ollamaURL")
        }
    }
    
    @Published var systemPrompt: String {
        didSet {
            UserDefaults.standard.set(systemPrompt, forKey: "systemPrompt")
        }
    }
    
    private init() {
        self.ollamaURL = UserDefaults.standard.string(forKey: "ollamaURL") ?? "http://192.168.1.100:11434"
        self.systemPrompt = UserDefaults.standard.string(forKey: "systemPrompt") ?? "You are a helpful assistant."
    }
}

struct SettingsView: View {
    @EnvironmentObject var ollamaService: OllamaService
    @EnvironmentObject var settings: AppSettings
    @State private var showingModelSelection = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Connection")) {
                    HStack {
                        Text("Ollama URL")
                        Spacer()
                        TextField("http://192.168.1.100:11434", text: $settings.ollamaURL)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Button(action: {
                        Task {
                            await ollamaService.loadModels()
                        }
                    }) {
                        HStack {
                            Text("Test Connection")
                            Spacer()
                            if ollamaService.isConnected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Section(header: Text("Model")) {
                    Button(action: {
                        showingModelSelection = true
                    }) {
                        HStack {
                            Text("Selected Model")
                            Spacer()
                            Text(ollamaService.selectedModel.isEmpty ? "None" : ollamaService.selectedModel)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await ollamaService.loadModels()
                        }
                    }) {
                        HStack {
                            Text("Refresh Models")
                            Spacer()
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Models Available")) {
                    if ollamaService.models.isEmpty {
                        Text("No models found. Make sure Ollama is running and connected.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(ollamaService.models, id: \.name) { model in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(model.name)
                                        .font(.headline)
                                    Text(formatBytes(model.size))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if model.name == ollamaService.selectedModel {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                ollamaService.selectedModel = model.name
                            }
                        }
                    }
                }
                
                Section(header: Text("System Prompt")) {
                    TextEditor(text: $settings.systemPrompt)
                        .frame(height: 100)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingModelSelection) {
                ModelSelectionView()
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

