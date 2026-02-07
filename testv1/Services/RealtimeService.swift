//
//  RealtimeService.swift
//  Halfisies
//
//  Real-time Firestore listeners for live updates
//

import Foundation
import FirebaseFirestore
import Combine

class RealtimeService: ObservableObject {
    static let shared = RealtimeService()
    
    private let db = Firestore.firestore()
    private var listeners: [String: ListenerRegistration] = [:]
    
    // Published properties for real-time data
    @Published var unreadMessagesCount: Int = 0
    @Published var pendingRequestsCount: Int = 0
    
    private init() {}
    
    // MARK: - Message Listeners
    
    /// Listen for messages in a specific conversation
    func listenToMessages(
        conversationId: String,
        onUpdate: @escaping ([Message]) -> Void
    ) {
        // Remove existing listener if any
        stopListening(for: "messages_\(conversationId)")
        
        // Messages are stored in top-level "messages" collection with conversationId field.
        // Query by conversationId only (no orderBy) to avoid composite index; sort in memory.
        let listener = db.collection("messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("[Halfsies] Error listening to messages: \(error.localizedDescription)")
                    DispatchQueue.main.async { onUpdate([]) }
                    return
                }
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async { onUpdate([]) }
                    return
                }
                
                let messages: [Message] = documents.compactMap { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    guard let convId = data["conversationId"] as? String,
                          let senderId = data["senderId"] as? String,
                          let senderName = data["senderName"] as? String,
                          let content = data["content"] as? String,
                          let timestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return Message(
                        id: id,
                        conversationId: convId,
                        senderId: senderId,
                        senderName: senderName,
                        content: content,
                        createdAt: timestamp.dateValue(),
                        isRead: data["isRead"] as? Bool ?? false
                    )
                }
                .sorted { $0.createdAt < $1.createdAt }
                
                DispatchQueue.main.async {
                    onUpdate(messages)
                }
            }
        
        listeners["messages_\(conversationId)"] = listener
    }
    
    /// Listen for all conversations for a user
    func listenToConversations(
        userId: String,
        onUpdate: @escaping ([Conversation]) -> Void
    ) {
        stopListening(for: "conversations_\(userId)")
        
        let listener = db.collection("conversations")
            .whereField("participants", arrayContains: userId)
            .order(by: "lastMessageAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("[Halfsies] Error listening to conversations: \(error.localizedDescription)")
                    DispatchQueue.main.async { onUpdate([]) }
                    return
                }
                guard let documents = snapshot?.documents else {
                    DispatchQueue.main.async { onUpdate([]) }
                    return
                }
                
                let conversations: [Conversation] = documents.compactMap { doc in
                    let data = doc.data()
                    let id = doc.documentID
                    guard let participants = data["participants"] as? [String],
                          let participantNames = data["participantNames"] as? [String: String] else {
                        return nil
                    }
                    
                    let lastMessageAt = (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date()
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    
                    return Conversation(
                        id: id,
                        participants: participants,
                        participantNames: participantNames,
                        lastMessage: data["lastMessage"] as? String ?? "",
                        lastMessageAt: lastMessageAt,
                        lastSenderId: data["lastSenderId"] as? String ?? "",
                        listingId: data["listingId"] as? String,
                        serviceName: data["serviceName"] as? String,
                        unreadCount: data["unreadCount"] as? [String: Int] ?? [:],
                        createdAt: createdAt
                    )
                }
                
                DispatchQueue.main.async {
                    onUpdate(conversations)
                    
                    // Update unread count
                    let totalUnread = conversations.reduce(0) { sum, conv in
                        sum + (conv.unreadCount[userId] ?? 0)
                    }
                    self.unreadMessagesCount = totalUnread
                }
            }
        
        listeners["conversations_\(userId)"] = listener
    }
    
    // MARK: - Seat Request Listeners
    
    /// Listen for seat requests for a specific listing owner
    func listenToSeatRequests(
        ownerId: String,
        onUpdate: @escaping ([SeatRequest]) -> Void
    ) {
        stopListening(for: "requests_owner_\(ownerId)")
        
        let listener = db.collection("seatRequests")
            .whereField("ownerId", isEqualTo: ownerId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("[Halfsies] Error listening to seat requests: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let requests: [SeatRequest] = documents.compactMap { doc in
                    try? doc.data(as: SeatRequest.self)
                }
                
                DispatchQueue.main.async {
                    onUpdate(requests)
                    
                    // Update pending count
                    self.pendingRequestsCount = requests.filter { $0.status == .pending }.count
                }
            }
        
        listeners["requests_owner_\(ownerId)"] = listener
    }
    
    /// Listen for seat requests made by a specific user
    func listenToUserRequests(
        userId: String,
        onUpdate: @escaping ([SeatRequest]) -> Void
    ) {
        stopListening(for: "requests_user_\(userId)")
        
        let listener = db.collection("seatRequests")
            .whereField("requesterId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("[Halfsies] Error listening to user requests: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let requests: [SeatRequest] = documents.compactMap { doc in
                    try? doc.data(as: SeatRequest.self)
                }
                
                DispatchQueue.main.async {
                    onUpdate(requests)
                }
            }
        
        listeners["requests_user_\(userId)"] = listener
    }
    
    // MARK: - Listing Listeners
    
    /// Listen for changes to a specific listing
    func listenToListing(
        listingId: String,
        onUpdate: @escaping (SubscriptionListing?) -> Void
    ) {
        stopListening(for: "listing_\(listingId)")
        
        let listener = db.collection("listings")
            .document(listingId)
            .addSnapshotListener { snapshot, error in
                guard let document = snapshot, document.exists else {
                    DispatchQueue.main.async {
                        onUpdate(nil)
                    }
                    return
                }
                
                let listing = try? document.data(as: SubscriptionListing.self)
                
                DispatchQueue.main.async {
                    onUpdate(listing)
                }
            }
        
        listeners["listing_\(listingId)"] = listener
    }
    
    /// Listen for all active listings
    func listenToAllListings(
        onUpdate: @escaping ([SubscriptionListing]) -> Void
    ) {
        stopListening(for: "all_listings")
        
        let listener = db.collection("listings")
            .whereField("isActive", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("[Halfsies] Error listening to listings: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let listings: [SubscriptionListing] = documents.compactMap { doc in
                    try? doc.data(as: SubscriptionListing.self)
                }
                
                DispatchQueue.main.async {
                    onUpdate(listings)
                }
            }
        
        listeners["all_listings"] = listener
    }
    
    // MARK: - Review Listeners
    
    /// Listen for reviews for a specific user
    func listenToReviews(
        userId: String,
        onUpdate: @escaping ([Review]) -> Void
    ) {
        stopListening(for: "reviews_\(userId)")
        
        let listener = db.collection("reviews")
            .whereField("reviewedUserId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("[Halfsies] Error listening to reviews: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let reviews: [Review] = documents.compactMap { doc in
                    try? doc.data(as: Review.self)
                }
                
                DispatchQueue.main.async {
                    onUpdate(reviews)
                }
            }
        
        listeners["reviews_\(userId)"] = listener
    }
    
    // MARK: - Listener Management
    
    /// Stop a specific listener
    func stopListening(for key: String) {
        listeners[key]?.remove()
        listeners.removeValue(forKey: key)
    }
    
    /// Stop all listeners
    func stopAllListeners() {
        listeners.values.forEach { $0.remove() }
        listeners.removeAll()
        print("[Halfsies] All listeners stopped")
    }
    
    /// Stop listeners for a specific user (call on sign out)
    func stopUserListeners(userId: String) {
        let keysToRemove = listeners.keys.filter { $0.contains(userId) }
        keysToRemove.forEach { stopListening(for: $0) }
    }
}
