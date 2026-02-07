//
//  MessagesViewModel.swift
//  Halfisies
//
//  ViewModel for messaging functionality
//

import Foundation

@MainActor
class MessagesViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let subscriptionService: SubscriptionServiceProtocol
    private let realtimeService = RealtimeService.shared
    
    var totalUnreadCount: Int {
        guard let userId = currentUserId else { return 0 }
        return conversations.reduce(0) { $0 + $1.unreadCountFor(userId: userId) }
    }
    
    private var currentUserId: String?
    private var isListeningToConversations = false
    
    init(subscriptionService: SubscriptionServiceProtocol? = nil) {
        self.subscriptionService = subscriptionService ?? ServiceContainer.subscriptions
    }
    
    func setCurrentUser(id: String) {
        self.currentUserId = id
    }
    
    // MARK: - Conversations
    
    /// Start listening to conversations in real-time
    func startListeningToConversations() {
        guard let userId = currentUserId, !isListeningToConversations else { return }
        
        isLoading = true
        isListeningToConversations = true
        
        realtimeService.listenToConversations(userId: userId) { [weak self] conversations in
            self?.conversations = conversations
            self?.isLoading = false
            print("[Halfsies] Real-time: \(conversations.count) conversations")
        }
    }
    
    /// Stop listening to conversations
    func stopListeningToConversations() {
        guard let userId = currentUserId else { return }
        realtimeService.stopListening(for: "conversations_\(userId)")
        isListeningToConversations = false
    }
    
    func fetchConversations() async {
        guard let userId = currentUserId else { return }
        
        isLoading = true
        
        do {
            conversations = try await subscriptionService.fetchConversations(userId: userId)
            print("[Halfsies] Fetched \(conversations.count) conversations")
        } catch {
            errorMessage = "Failed to load conversations."
            print("[Halfsies] Error fetching conversations: \(error)")
        }
        
        isLoading = false
    }
    
    func startConversation(
        with otherUserId: String,
        otherUserName: String,
        currentUser: HalfisiesUser,
        listingId: String? = nil,
        serviceName: String? = nil
    ) async -> Conversation? {
        let participants = [currentUser.id, otherUserId].sorted()
        
        // Check if conversation already exists
        do {
            if let existing = try await subscriptionService.findConversation(
                participants: participants,
                listingId: listingId
            ) {
                print("[Halfsies] Found existing conversation: \(existing.id)")
                return existing
            }
        } catch {
            print("[Halfsies] Error finding conversation: \(error)")
        }
        
        // Create new conversation
        let conversation = Conversation(
            participants: participants,
            participantNames: [
                currentUser.id: currentUser.displayName,
                otherUserId: otherUserName
            ],
            listingId: listingId,
            serviceName: serviceName
        )
        
        do {
            let created = try await subscriptionService.createConversation(conversation)
            await fetchConversations()
            print("[Halfsies] Created new conversation: \(created.id)")
            return created
        } catch {
            errorMessage = "Failed to start conversation."
            print("[Halfsies] Error creating conversation: \(error)")
            return nil
        }
    }
    
    // MARK: - Messages
    
    /// Start listening to messages in a conversation in real-time
    func startListeningToMessages(conversationId: String) {
        isLoading = true
        
        realtimeService.listenToMessages(conversationId: conversationId) { [weak self] messages in
            self?.messages = messages
            self?.isLoading = false
            print("[Halfsies] Real-time: \(messages.count) messages")
        }
        
        // Mark as read
        if let userId = currentUserId {
            Task {
                try? await subscriptionService.markMessagesAsRead(conversationId: conversationId, userId: userId)
            }
        }
    }
    
    /// Stop listening to messages
    func stopListeningToMessages(conversationId: String) {
        realtimeService.stopListening(for: "messages_\(conversationId)")
    }
    
    func fetchMessages(conversationId: String) async {
        isLoading = true
        
        do {
            messages = try await subscriptionService.fetchMessages(conversationId: conversationId)
            print("[Halfsies] Fetched \(messages.count) messages")
            
            // Mark as read
            if let userId = currentUserId {
                try await subscriptionService.markMessagesAsRead(conversationId: conversationId, userId: userId)
                await fetchConversations() // Refresh to update unread counts
            }
        } catch {
            errorMessage = "Failed to load messages."
            print("[Halfsies] Error fetching messages: \(error)")
        }
        
        isLoading = false
    }
    
    func sendMessage(content: String, in conversation: Conversation, from user: HalfisiesUser) async {
        let message = Message(
            conversationId: conversation.id,
            senderId: user.id,
            senderName: user.displayName,
            content: content
        )
        
        do {
            let sent = try await subscriptionService.sendMessage(message)
            // Don't manually append - the real-time listener will handle it
            // This prevents duplicate messages
            print("[Halfsies] Sent message: \(sent.id)")
        } catch {
            errorMessage = "Failed to send message."
            print("[Halfsies] Error sending message: \(error)")
        }
    }
}
