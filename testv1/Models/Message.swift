//
//  Message.swift
//  Halfisies
//
//  Chat and messaging models
//

import Foundation

// MARK: - Conversation
struct Conversation: Identifiable, Codable {
    let id: String
    let participants: [String]           // User IDs
    var participantNames: [String: String] // userId -> displayName mapping
    var lastMessage: String
    var lastMessageAt: Date
    var lastSenderId: String
    var listingId: String?               // Optional: which listing this conversation is about
    var serviceName: String?             // Optional: service name for context
    var unreadCount: [String: Int]       // userId -> unread count
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        participants: [String],
        participantNames: [String: String],
        lastMessage: String = "",
        lastMessageAt: Date = Date(),
        lastSenderId: String = "",
        listingId: String? = nil,
        serviceName: String? = nil,
        unreadCount: [String: Int] = [:],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.participants = participants
        self.participantNames = participantNames
        self.lastMessage = lastMessage
        self.lastMessageAt = lastMessageAt
        self.lastSenderId = lastSenderId
        self.listingId = listingId
        self.serviceName = serviceName
        self.unreadCount = unreadCount
        self.createdAt = createdAt
    }
    
    /// Get the other participant's ID (for 1-on-1 conversations)
    func otherParticipantId(currentUserId: String) -> String? {
        participants.first { $0 != currentUserId }
    }
    
    /// Get the other participant's name
    func otherParticipantName(currentUserId: String) -> String {
        guard let otherId = otherParticipantId(currentUserId: currentUserId) else {
            return "Unknown"
        }
        return participantNames[otherId] ?? "Unknown"
    }
    
    /// Get unread count for a user
    func unreadCountFor(userId: String) -> Int {
        unreadCount[userId] ?? 0
    }
}

// MARK: - Message
struct Message: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderId: String
    var senderName: String
    var content: String
    var createdAt: Date
    var isRead: Bool
    
    init(
        id: String = UUID().uuidString,
        conversationId: String,
        senderId: String,
        senderName: String,
        content: String,
        createdAt: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.createdAt = createdAt
        self.isRead = isRead
    }
}

// MARK: - Mock Data
extension Conversation {
    static let mockConversations: [Conversation] = [
        Conversation(
            id: "conv-1",
            participants: ["owner-1", "sub-1"],
            participantNames: ["owner-1": "John D.", "sub-1": "Jane S."],
            lastMessage: "Sure, I'll send you the details!",
            lastMessageAt: Date().addingTimeInterval(-3600),
            lastSenderId: "owner-1",
            listingId: "1",
            serviceName: "Netflix",
            unreadCount: ["sub-1": 1]
        ),
        Conversation(
            id: "conv-2",
            participants: ["owner-2", "sub-1"],
            participantNames: ["owner-2": "Sarah M.", "sub-1": "Jane S."],
            lastMessage: "Thanks for joining!",
            lastMessageAt: Date().addingTimeInterval(-86400),
            lastSenderId: "owner-2",
            listingId: "2",
            serviceName: "Spotify"
        )
    ]
}

extension Message {
    static let mockMessages: [Message] = [
        Message(
            id: "msg-1",
            conversationId: "conv-1",
            senderId: "sub-1",
            senderName: "Jane S.",
            content: "Hi! I'm interested in joining your Netflix subscription.",
            createdAt: Date().addingTimeInterval(-7200)
        ),
        Message(
            id: "msg-2",
            conversationId: "conv-1",
            senderId: "owner-1",
            senderName: "John D.",
            content: "Hey Jane! Great, I have 2 spots available. Would you like me to add you?",
            createdAt: Date().addingTimeInterval(-5400)
        ),
        Message(
            id: "msg-3",
            conversationId: "conv-1",
            senderId: "sub-1",
            senderName: "Jane S.",
            content: "Yes please! How does the payment work?",
            createdAt: Date().addingTimeInterval(-3700)
        ),
        Message(
            id: "msg-4",
            conversationId: "conv-1",
            senderId: "owner-1",
            senderName: "John D.",
            content: "Sure, I'll send you the details!",
            createdAt: Date().addingTimeInterval(-3600)
        )
    ]
}
