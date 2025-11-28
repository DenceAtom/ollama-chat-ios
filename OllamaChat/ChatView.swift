import SwiftUI
import PhotosUI

struct ChatView: View {
    @EnvironmentObject var ollamaService: OllamaService
    @StateObject private var webSearchService = WebSearchService()
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingFilePicker = false
    @State private var editingMessage: Message?
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message, onEdit: {
                                    editingMessage = message
                                    inputText = message.content
                                })
                                .id(message.id)
                            }
                            
                            if ollamaService.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding()
                                    Text("Thinking...")
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input area
                VStack(spacing: 8) {
                    // Selected images preview
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button(action: {
                                            selectedImages.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 70)
                    }
                    
                    HStack(spacing: 12) {
                        // Image picker button
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Image(systemName: "photo")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        
                        // File picker button
                        Button(action: {
                            showingFilePicker = true
                        }) {
                            Image(systemName: "doc")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                        }
                        
                        // Text input
                        TextField("Type a message...", text: $inputText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...5)
                        
                        // Web search toggle
                        Button(action: {
                            isSearching.toggle()
                        }) {
                            Image(systemName: isSearching ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                                .font(.system(size: 20))
                                .foregroundColor(isSearching ? .blue : .gray)
                        }
                        
                        // Send button
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(inputText.isEmpty && selectedImages.isEmpty ? .gray : .blue)
                        }
                        .disabled(inputText.isEmpty && selectedImages.isEmpty || ollamaService.isLoading)
                    }
                    .padding()
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("Ollama Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        messages.removeAll()
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImages: $selectedImages)
            }
            .sheet(isPresented: $showingFilePicker) {
                FilePicker { url in
                    if let url = url {
                        handleFileSelection(url: url)
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty || !selectedImages.isEmpty else { return }
        
        let messageContent = inputText.isEmpty ? "[Image]" : inputText
        let imageData = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // If editing, update existing message
        if let editingMessage = editingMessage {
            if let index = messages.firstIndex(where: { $0.id == editingMessage.id }) {
                messages[index].content = messageContent
                messages[index].isEdited = true
                messages[index].images = imageData.isEmpty ? nil : imageData
            }
            self.editingMessage = nil
            inputText = ""
            selectedImages = []
            return
        }
        
        // Add user message
        let userMessage = Message(
            content: messageContent,
            role: .user,
            images: imageData.isEmpty ? nil : imageData
        )
        messages.append(userMessage)
        
        inputText = ""
        selectedImages = []
        
        // Get response
        Task {
            do {
                var responseText = ""
                
                if isSearching && !messageContent.isEmpty {
                    // Perform web search first
                    let searchResults = await webSearchService.search(query: messageContent)
                    let searchContext = searchResults.prefix(3).map { "\($0.title): \($0.snippet)" }.joined(separator: "\n\n")
                    responseText = try await ollamaService.sendMessage(
                        "Based on the following search results, answer the question: \(messageContent)\n\nSearch results:\n\(searchContext)",
                        conversationHistory: messages
                    )
                } else {
                    responseText = try await ollamaService.sendMessage(
                        messageContent,
                        conversationHistory: messages,
                        images: imageData.isEmpty ? nil : imageData
                    )
                }
                
                await MainActor.run {
                    let assistantMessage = Message(
                        content: responseText,
                        role: .assistant
                    )
                    messages.append(assistantMessage)
                }
            } catch {
                await MainActor.run {
                    let errorMessage = Message(
                        content: "Error: \(error.localizedDescription)",
                        role: .assistant
                    )
                    messages.append(errorMessage)
                }
            }
        }
    }
    
    private func handleFileSelection(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            
            // Try to create image from data
            if let image = UIImage(data: data) {
                selectedImages.append(image)
            } else {
                // It's a file attachment
                let attachment = Attachment(
                    name: fileName,
                    data: data,
                    mimeType: url.mimeType ?? "application/octet-stream"
                )
                
                // Add as a message with attachment
                let message = Message(
                    content: "📎 \(fileName)",
                    role: .user,
                    attachments: [attachment]
                )
                messages.append(message)
            }
        } catch {
            print("Error handling file: \(error)")
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .padding(12)
                    .background(message.role == .user ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .cornerRadius(16)
                
                // Images
                if let images = message.images {
                    ForEach(Array(images.enumerated()), id: \.offset) { _, imageData in
                        if let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 200)
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Attachments
                if let attachments = message.attachments {
                    ForEach(attachments) { attachment in
                        HStack {
                            Image(systemName: "doc.fill")
                            Text(attachment.name)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                // Timestamp and edit indicator
                HStack(spacing: 4) {
                    if message.isEdited {
                        Text("Edited")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .user {
                // Edit button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            } else {
                Spacer()
            }
        }
    }
}

import UniformTypeIdentifiers

extension URL {
    var mimeType: String? {
        guard let uti = UTType(filenameExtension: self.pathExtension) else {
            return nil
        }
        return uti.preferredMIMEType
    }
}

