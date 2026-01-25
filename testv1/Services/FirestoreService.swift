//
//  FirestoreService.swift
//  Halfisies
//
//  Real Firestore Database Service
//

import Foundation
import FirebaseFirestore

// MARK: - Firestore Service
class FirestoreService: SubscriptionServiceProtocol, ObservableObject {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    
    // Collection names
    private let usersCollection = "users"
    private let listingsCollection = "listings"
    private let requestsCollection = "requests"
    private let reviewsCollection = "reviews"
    private let conversationsCollection = "conversations"
    private let messagesCollection = "messages"
    
    private init() {}
    
    // MARK: - User Operations
    
    func createUser(_ user: HalfisiesUser) async throws {
        let data = try encodeUser(user)
        try await db.collection(usersCollection).document(user.id).setData(data)
    }
    
    func fetchUser(id: String) async throws -> HalfisiesUser {
        let document = try await db.collection(usersCollection).document(id).getDocument()
        
        guard document.exists, let data = document.data() else {
            throw FirestoreError.documentNotFound
        }
        
        return try decodeUser(data, id: id)
    }
    
    func updateUser(_ user: HalfisiesUser) async throws {
        let data = try encodeUser(user)
        try await db.collection(usersCollection).document(user.id).updateData(data)
    }
    
    func updateUserFCMToken(userId: String, token: String) async throws {
        try await db.collection(usersCollection).document(userId).updateData([
            "fcmToken": token,
            "fcmTokenUpdatedAt": Timestamp(date: Date())
        ])
    }
    
    func getUserFCMToken(userId: String) async throws -> String? {
        let document = try await db.collection(usersCollection).document(userId).getDocument()
        return document.data()?["fcmToken"] as? String
    }
    
    func deleteUser(id: String) async throws {
        // Delete user's listings
        let listings = try await fetchUserListings(userId: id)
        for listing in listings {
            try await deleteListing(id: listing.id)
        }
        
        // Delete user's requests
        let requests = try await fetchMyRequests(userId: id)
        for request in requests {
            try await db.collection(requestsCollection).document(request.id).delete()
        }
        
        // Delete user document
        try await db.collection(usersCollection).document(id).delete()
    }
    
    // MARK: - Listing Operations
    
    func fetchListings() async throws -> [SubscriptionListing] {
        // Fetch ALL listings (no filters) for debugging
        let snapshot = try await db.collection(listingsCollection)
            .getDocuments()
        
        print("[Halfsies] Fetched \(snapshot.documents.count) documents from Firestore")
        
        // Debug: print each document
        for doc in snapshot.documents {
            print("[Halfsies] Document \(doc.documentID): \(doc.data())")
        }
        
        // Decode listings
        let listings = snapshot.documents.compactMap { doc -> SubscriptionListing? in
            do {
                return try decodeListing(doc.data(), id: doc.documentID)
            } catch {
                print("[Halfsies] Failed to decode document \(doc.documentID): \(error)")
                return nil
            }
        }
        
        print("[Halfsies] Successfully decoded \(listings.count) listings")
        
        // Filter for active listings with available seats
        let filtered = listings
            .filter { $0.isActive && $0.availableSeats > 0 }
            .sorted { $0.createdAt > $1.createdAt }
        
        print("[Halfsies] After filtering: \(filtered.count) listings")
        
        return filtered
    }
    
    func fetchListing(id: String) async throws -> SubscriptionListing? {
        let document = try await db.collection(listingsCollection).document(id).getDocument()
        
        guard document.exists, let data = document.data() else {
            return nil
        }
        
        return try decodeListing(data, id: id)
    }
    
    func fetchUserListings(userId: String) async throws -> [SubscriptionListing] {
        // Simplified query to avoid composite index requirement
        let snapshot = try await db.collection(listingsCollection)
            .whereField("ownerId", isEqualTo: userId)
            .getDocuments()
        
        // Sort in memory
        return snapshot.documents.compactMap { doc in
            try? decodeListing(doc.data(), id: doc.documentID)
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func createListing(_ listing: SubscriptionListing) async throws -> SubscriptionListing {
        let data = encodeListing(listing)
        print("[Halfsies] Creating listing with ID: \(listing.id)")
        print("[Halfsies] Listing data: \(data)")
        
        let docRef = db.collection(listingsCollection).document(listing.id)
        try await docRef.setData(data)
        print("[Halfsies] Listing created successfully in Firestore")
        
        // Update user's isOwner flag
        do {
            try await db.collection(usersCollection).document(listing.ownerId).updateData([
                "isOwner": true
            ])
            print("[Halfsies] Updated user isOwner flag")
        } catch {
            print("[Halfsies] Failed to update user isOwner: \(error)")
            // Don't fail the whole operation for this
        }
        
        return listing
    }
    
    func updateListing(_ listing: SubscriptionListing) async throws {
        let data = encodeListing(listing)
        try await db.collection(listingsCollection).document(listing.id).updateData(data)
    }
    
    func deleteListing(id: String) async throws {
        // Delete all requests for this listing
        let requests = try await fetchRequests(forListing: id)
        for request in requests {
            try await db.collection(requestsCollection).document(request.id).delete()
        }
        
        // Delete the listing
        try await db.collection(listingsCollection).document(id).delete()
    }
    
    // MARK: - Request Operations
    
    func fetchRequests(forListing listingId: String) async throws -> [SeatRequest] {
        // Simplified query to avoid composite index requirement
        let snapshot = try await db.collection(requestsCollection)
            .whereField("listingId", isEqualTo: listingId)
            .getDocuments()
        
        // Sort in memory
        return snapshot.documents.compactMap { doc in
            try? decodeRequest(doc.data(), id: doc.documentID)
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchMyRequests(userId: String) async throws -> [SeatRequest] {
        // Simplified query to avoid composite index requirement
        let snapshot = try await db.collection(requestsCollection)
            .whereField("requesterId", isEqualTo: userId)
            .getDocuments()
        
        // Sort in memory
        return snapshot.documents.compactMap { doc in
            try? decodeRequest(doc.data(), id: doc.documentID)
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchIncomingRequests(ownerId: String) async throws -> [SeatRequest] {
        print("[Halfsies] fetchIncomingRequests for owner: \(ownerId)")
        
        // First, get all listings owned by this user
        let listings = try await fetchUserListings(userId: ownerId)
        let listingIds = listings.map { $0.id }
        
        print("[Halfsies] Owner has \(listings.count) listings with IDs: \(listingIds)")
        
        guard !listingIds.isEmpty else { 
            print("[Halfsies] No listings found, returning empty")
            return [] 
        }
        
        // Fetch requests for these listings
        var allRequests: [SeatRequest] = []
        
        // Firestore 'in' query limited to 10 items, so batch if needed
        let batches = stride(from: 0, to: listingIds.count, by: 10).map {
            Array(listingIds[$0..<min($0 + 10, listingIds.count)])
        }
        
        for batch in batches {
            let snapshot = try await db.collection(requestsCollection)
                .whereField("listingId", in: batch)
                .getDocuments()
            
            print("[Halfsies] Found \(snapshot.documents.count) requests for batch")
            
            let requests = snapshot.documents.compactMap { doc -> SeatRequest? in
                let request = try? decodeRequest(doc.data(), id: doc.documentID)
                if let r = request {
                    print("[Halfsies] Request: \(r.requesterName), status: \(r.status.rawValue)")
                }
                return request
            }
            allRequests.append(contentsOf: requests)
        }
        
        // Filter for pending and sort in memory
        let pendingRequests = allRequests
            .filter { $0.status == .pending }
            .sorted { $0.createdAt > $1.createdAt }
        
        print("[Halfsies] Returning \(pendingRequests.count) pending requests")
        return pendingRequests
    }
    
    func createRequest(_ request: SeatRequest) async throws -> SeatRequest {
        let data = encodeRequest(request)
        try await db.collection(requestsCollection).document(request.id).setData(data)
        return request
    }
    
    func updateRequestStatus(requestId: String, status: SeatRequestStatus) async throws {
        var updateData: [String: Any] = [
            "status": status.rawValue,
            "respondedAt": Timestamp(date: Date())
        ]
        
        try await db.collection(requestsCollection).document(requestId).updateData(updateData)
        
        // If approved, decrease available seats
        if status == .approved {
            let requestDoc = try await db.collection(requestsCollection).document(requestId).getDocument()
            if let data = requestDoc.data(), let listingId = data["listingId"] as? String {
                try await db.collection(listingsCollection).document(listingId).updateData([
                    "availableSeats": FieldValue.increment(Int64(-1)),
                    "joinedCount": FieldValue.increment(Int64(1))
                ])
            }
        }
    }
    
    func leaveSubscription(requestId: String, listingId: String) async throws {
        print("[Halfsies] Leaving subscription - requestId: \(requestId), listingId: \(listingId)")
        
        // Update request status to cancelled
        try await db.collection(requestsCollection).document(requestId).updateData([
            "status": SeatRequestStatus.cancelled.rawValue,
            "respondedAt": Timestamp(date: Date())
        ])
        
        // Increase available seats and decrease joined count on the listing
        try await db.collection(listingsCollection).document(listingId).updateData([
            "availableSeats": FieldValue.increment(Int64(1)),
            "joinedCount": FieldValue.increment(Int64(-1))
        ])
        
        print("[Halfsies] Successfully left subscription")
    }
    
    // MARK: - Review Operations
    
    func createReview(_ review: Review) async throws -> Review {
        let data = encodeReview(review)
        print("[Halfsies] Creating review with ID: \(review.id)")
        
        try await db.collection(reviewsCollection).document(review.id).setData(data)
        
        // Update target user's rating
        try await updateUserRating(userId: review.targetUserId)
        
        print("[Halfsies] Review created successfully")
        return review
    }
    
    func fetchReviewsForUser(userId: String) async throws -> [Review] {
        let snapshot = try await db.collection(reviewsCollection)
            .whereField("targetUserId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeReview(doc.data(), id: doc.documentID)
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchReviewsForListing(listingId: String) async throws -> [Review] {
        let snapshot = try await db.collection(reviewsCollection)
            .whereField("listingId", isEqualTo: listingId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeReview(doc.data(), id: doc.documentID)
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func hasReviewed(reviewerId: String, targetUserId: String, listingId: String) async throws -> Bool {
        let snapshot = try await db.collection(reviewsCollection)
            .whereField("reviewerId", isEqualTo: reviewerId)
            .whereField("targetUserId", isEqualTo: targetUserId)
            .whereField("listingId", isEqualTo: listingId)
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }
    
    /// Recalculates and updates a user's average rating based on all reviews
    private func updateUserRating(userId: String) async throws {
        let reviews = try await fetchReviewsForUser(userId: userId)
        
        guard !reviews.isEmpty else { return }
        
        let totalRating = reviews.reduce(0) { $0 + $1.rating }
        let averageRating = Double(totalRating) / Double(reviews.count)
        
        try await db.collection(usersCollection).document(userId).updateData([
            "rating": averageRating,
            "reviewCount": reviews.count
        ])
        
        print("[Halfsies] Updated user \(userId) rating to \(averageRating) with \(reviews.count) reviews")
    }
    
    // MARK: - Messaging Operations
    
    func createConversation(_ conversation: Conversation) async throws -> Conversation {
        let data = encodeConversation(conversation)
        print("[Halfsies] Creating conversation with ID: \(conversation.id)")
        
        try await db.collection(conversationsCollection).document(conversation.id).setData(data)
        
        print("[Halfsies] Conversation created successfully")
        return conversation
    }
    
    func fetchConversations(userId: String) async throws -> [Conversation] {
        let snapshot = try await db.collection(conversationsCollection)
            .whereField("participants", arrayContains: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeConversation(doc.data(), id: doc.documentID)
        }.sorted { $0.lastMessageAt > $1.lastMessageAt }
    }
    
    func fetchConversation(id: String) async throws -> Conversation? {
        let document = try await db.collection(conversationsCollection).document(id).getDocument()
        
        guard document.exists, let data = document.data() else {
            return nil
        }
        
        return try decodeConversation(data, id: id)
    }
    
    func findConversation(participants: [String], listingId: String?) async throws -> Conversation? {
        // Fetch all conversations for the first participant
        let snapshot = try await db.collection(conversationsCollection)
            .whereField("participants", arrayContains: participants[0])
            .getDocuments()
        
        let conversations = snapshot.documents.compactMap { doc in
            try? decodeConversation(doc.data(), id: doc.documentID)
        }
        
        // Find matching conversation
        return conversations.first { conv in
            let sameParticipants = Set(conv.participants) == Set(participants)
            if let listingId = listingId {
                return sameParticipants && conv.listingId == listingId
            }
            return sameParticipants
        }
    }
    
    func sendMessage(_ message: Message) async throws -> Message {
        let data = encodeMessage(message)
        print("[Halfsies] Sending message in conversation: \(message.conversationId)")
        
        try await db.collection(messagesCollection).document(message.id).setData(data)
        
        // Update conversation's last message
        try await db.collection(conversationsCollection).document(message.conversationId).updateData([
            "lastMessage": message.content,
            "lastMessageAt": Timestamp(date: message.createdAt),
            "lastSenderId": message.senderId
        ])
        
        // Increment unread count for other participants
        let conversation = try await fetchConversation(id: message.conversationId)
        if let conv = conversation {
            for participant in conv.participants where participant != message.senderId {
                try await db.collection(conversationsCollection).document(message.conversationId).updateData([
                    "unreadCount.\(participant)": FieldValue.increment(Int64(1))
                ])
            }
        }
        
        print("[Halfsies] Message sent successfully")
        return message
    }
    
    func fetchMessages(conversationId: String) async throws -> [Message] {
        let snapshot = try await db.collection(messagesCollection)
            .whereField("conversationId", isEqualTo: conversationId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeMessage(doc.data(), id: doc.documentID)
        }.sorted { $0.createdAt < $1.createdAt }
    }
    
    func markMessagesAsRead(conversationId: String, userId: String) async throws {
        // Reset unread count for this user
        try await db.collection(conversationsCollection).document(conversationId).updateData([
            "unreadCount.\(userId)": 0
        ])
        
        print("[Halfsies] Marked messages as read for user: \(userId)")
    }
    
    // MARK: - Real-time Listeners
    
    func listenToListings(completion: @escaping ([SubscriptionListing]) -> Void) -> ListenerRegistration {
        return db.collection(listingsCollection)
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let listings = documents.compactMap { doc in
                    try? self.decodeListing(doc.data(), id: doc.documentID)
                }
                    .filter { $0.availableSeats > 0 }
                    .sorted { $0.createdAt > $1.createdAt }
                
                completion(listings)
            }
    }
    
    func listenToUserRequests(userId: String, completion: @escaping ([SeatRequest]) -> Void) -> ListenerRegistration {
        return db.collection(requestsCollection)
            .whereField("requesterId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let requests = documents.compactMap { doc in
                    try? self.decodeRequest(doc.data(), id: doc.documentID)
                }
                completion(requests)
            }
    }
    
    // MARK: - Encoding/Decoding Helpers
    
    private func encodeUser(_ user: HalfisiesUser) throws -> [String: Any] {
        return [
            "email": user.email,
            "displayName": user.displayName,
            "avatarURL": user.avatarURL as Any,
            "rating": user.rating,
            "reviewCount": user.reviewCount,
            "trustScore": user.trustScore,
            "verifiedEmail": user.verifiedEmail,
            "verifiedPhone": user.verifiedPhone,
            "verifiedID": user.verifiedID,
            "totalSavings": user.totalSavings,
            "memberSince": Timestamp(date: user.memberSince),
            "isOwner": user.isOwner
        ]
    }
    
    private func decodeUser(_ data: [String: Any], id: String) throws -> HalfisiesUser {
        guard let email = data["email"] as? String,
              let displayName = data["displayName"] as? String else {
            throw FirestoreError.decodingError
        }
        
        return HalfisiesUser(
            id: id,
            email: email,
            displayName: displayName,
            avatarURL: data["avatarURL"] as? String,
            rating: data["rating"] as? Double ?? 5.0,
            reviewCount: data["reviewCount"] as? Int ?? 0,
            trustScore: data["trustScore"] as? Int ?? 50,
            verifiedEmail: data["verifiedEmail"] as? Bool ?? false,
            verifiedPhone: data["verifiedPhone"] as? Bool ?? false,
            verifiedID: data["verifiedID"] as? Bool ?? false,
            totalSavings: data["totalSavings"] as? Double ?? 0,
            memberSince: (data["memberSince"] as? Timestamp)?.dateValue() ?? Date(),
            isOwner: data["isOwner"] as? Bool ?? false
        )
    }
    
    private func encodeListing(_ listing: SubscriptionListing) -> [String: Any] {
        return [
            "ownerId": listing.ownerId,
            "ownerName": listing.ownerName,
            "ownerRating": listing.ownerRating,
            "ownerTrustScore": listing.ownerTrustScore,
            "service": listing.service.rawValue,
            "planName": listing.planName,
            "totalSeats": listing.totalSeats,
            "availableSeats": listing.availableSeats,
            "pricePerSeat": listing.pricePerSeat,
            "description": listing.description,
            "createdAt": Timestamp(date: listing.createdAt),
            "isActive": listing.isActive,
            "joinedCount": listing.joinedCount
        ]
    }
    
    private func decodeListing(_ data: [String: Any], id: String) throws -> SubscriptionListing {
        guard let ownerId = data["ownerId"] as? String,
              let ownerName = data["ownerName"] as? String,
              let serviceRaw = data["service"] as? String,
              let service = SubscriptionService(rawValue: serviceRaw),
              let planName = data["planName"] as? String,
              let totalSeats = data["totalSeats"] as? Int,
              let availableSeats = data["availableSeats"] as? Int,
              let pricePerSeat = data["pricePerSeat"] as? Double else {
            throw FirestoreError.decodingError
        }
        
        return SubscriptionListing(
            id: id,
            ownerId: ownerId,
            ownerName: ownerName,
            ownerRating: data["ownerRating"] as? Double ?? 5.0,
            ownerTrustScore: data["ownerTrustScore"] as? Int ?? 50,
            service: service,
            planName: planName,
            totalSeats: totalSeats,
            availableSeats: availableSeats,
            pricePerSeat: pricePerSeat,
            description: data["description"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            isActive: data["isActive"] as? Bool ?? true,
            joinedCount: data["joinedCount"] as? Int ?? 0
        )
    }
    
    private func encodeRequest(_ request: SeatRequest) -> [String: Any] {
        var data: [String: Any] = [
            "listingId": request.listingId,
            "requesterId": request.requesterId,
            "requesterName": request.requesterName,
            "requesterRating": request.requesterRating,
            "status": request.status.rawValue,
            "message": request.message,
            "createdAt": Timestamp(date: request.createdAt)
        ]
        
        if let respondedAt = request.respondedAt {
            data["respondedAt"] = Timestamp(date: respondedAt)
        }
        
        return data
    }
    
    private func decodeRequest(_ data: [String: Any], id: String) throws -> SeatRequest {
        guard let listingId = data["listingId"] as? String,
              let requesterId = data["requesterId"] as? String,
              let requesterName = data["requesterName"] as? String,
              let statusRaw = data["status"] as? String,
              let status = SeatRequestStatus(rawValue: statusRaw) else {
            throw FirestoreError.decodingError
        }
        
        return SeatRequest(
            id: id,
            listingId: listingId,
            requesterId: requesterId,
            requesterName: requesterName,
            requesterRating: data["requesterRating"] as? Double ?? 5.0,
            status: status,
            message: data["message"] as? String ?? "",
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            respondedAt: (data["respondedAt"] as? Timestamp)?.dateValue()
        )
    }
    
    private func encodeReview(_ review: Review) -> [String: Any] {
        return [
            "reviewerId": review.reviewerId,
            "reviewerName": review.reviewerName,
            "targetUserId": review.targetUserId,
            "targetUserName": review.targetUserName,
            "listingId": review.listingId,
            "serviceName": review.serviceName,
            "rating": review.rating,
            "comment": review.comment,
            "reviewType": review.reviewType.rawValue,
            "createdAt": Timestamp(date: review.createdAt)
        ]
    }
    
    private func decodeReview(_ data: [String: Any], id: String) throws -> Review {
        guard let reviewerId = data["reviewerId"] as? String,
              let reviewerName = data["reviewerName"] as? String,
              let targetUserId = data["targetUserId"] as? String,
              let targetUserName = data["targetUserName"] as? String,
              let listingId = data["listingId"] as? String,
              let serviceName = data["serviceName"] as? String,
              let rating = data["rating"] as? Int,
              let reviewTypeRaw = data["reviewType"] as? String,
              let reviewType = ReviewType(rawValue: reviewTypeRaw) else {
            throw FirestoreError.decodingError
        }
        
        return Review(
            id: id,
            reviewerId: reviewerId,
            reviewerName: reviewerName,
            targetUserId: targetUserId,
            targetUserName: targetUserName,
            listingId: listingId,
            serviceName: serviceName,
            rating: rating,
            comment: data["comment"] as? String ?? "",
            reviewType: reviewType,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    private func encodeConversation(_ conversation: Conversation) -> [String: Any] {
        return [
            "participants": conversation.participants,
            "participantNames": conversation.participantNames,
            "lastMessage": conversation.lastMessage,
            "lastMessageAt": Timestamp(date: conversation.lastMessageAt),
            "lastSenderId": conversation.lastSenderId,
            "listingId": conversation.listingId as Any,
            "serviceName": conversation.serviceName as Any,
            "unreadCount": conversation.unreadCount,
            "createdAt": Timestamp(date: conversation.createdAt)
        ]
    }
    
    private func decodeConversation(_ data: [String: Any], id: String) throws -> Conversation {
        guard let participants = data["participants"] as? [String],
              let participantNames = data["participantNames"] as? [String: String] else {
            throw FirestoreError.decodingError
        }
        
        return Conversation(
            id: id,
            participants: participants,
            participantNames: participantNames,
            lastMessage: data["lastMessage"] as? String ?? "",
            lastMessageAt: (data["lastMessageAt"] as? Timestamp)?.dateValue() ?? Date(),
            lastSenderId: data["lastSenderId"] as? String ?? "",
            listingId: data["listingId"] as? String,
            serviceName: data["serviceName"] as? String,
            unreadCount: data["unreadCount"] as? [String: Int] ?? [:],
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    private func encodeMessage(_ message: Message) -> [String: Any] {
        return [
            "conversationId": message.conversationId,
            "senderId": message.senderId,
            "senderName": message.senderName,
            "content": message.content,
            "createdAt": Timestamp(date: message.createdAt),
            "isRead": message.isRead
        ]
    }
    
    private func decodeMessage(_ data: [String: Any], id: String) throws -> Message {
        guard let conversationId = data["conversationId"] as? String,
              let senderId = data["senderId"] as? String,
              let senderName = data["senderName"] as? String,
              let content = data["content"] as? String else {
            throw FirestoreError.decodingError
        }
        
        return Message(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            senderName: senderName,
            content: content,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
            isRead: data["isRead"] as? Bool ?? false
        )
    }
}

// MARK: - Firestore Errors
enum FirestoreError: LocalizedError {
    case documentNotFound
    case decodingError
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .decodingError:
            return "Failed to decode document"
        case .encodingError:
            return "Failed to encode document"
        }
    }
}
