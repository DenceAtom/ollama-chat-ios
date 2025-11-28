import SwiftUI

struct ModelSelectionView: View {
    @EnvironmentObject var ollamaService: OllamaService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
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
                        dismiss()
                    }
                }
            }
            .navigationTitle("Select Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
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

