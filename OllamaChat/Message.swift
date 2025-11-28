import Foundation
import SwiftUI

struct Message: Identifiable, Codable {
    let id: UUID
    var content: String
    let role: MessageRole
    var timestamp: Date
    var images: [Data]?
    var attachments: [Attachment]?
    var isEdited: Bool
    
    init(id: UUID = UUID(), content: String, role: MessageRole, timestamp: Date = Date(), images: [Data]? = nil, attachments: [Attachment]? = nil, isEdited: Bool = false) {
        self.id = id
        self.content = content
        self.role = role
        self.timestamp = timestamp
        self.images = images
        self.attachments = attachments
        self.isEdited = isEdited
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
}

struct Attachment: Identifiable, Codable {
    let id: UUID
    let name: String
    let data: Data
    let mimeType: String
    
    init(id: UUID = UUID(), name: String, data: Data, mimeType: String) {
        self.id = id
        self.name = name
        self.data = data
        self.mimeType = mimeType
    }
}

