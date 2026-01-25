//
//  SubscriptionService.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation
import Combine

// MARK: - Subscription Service Protocol
protocol SubscriptionServiceProtocol {
    func fetchListings() async throws -> [SubscriptionListing]
    func fetchListing(id: String) async throws -> SubscriptionListing?
    func createListing(_ listing: SubscriptionListing) async throws -> SubscriptionListing
    func updateListing(_ listing: SubscriptionListing) async throws
    func deleteListing(id: String) async throws
    
    func fetchRequests(forListing listingId: String) async throws -> [SeatRequest]
    func fetchMyRequests(userId: String) async throws -> [SeatRequest]
    func createRequest(_ request: SeatRequest) async throws -> SeatRequest
    func updateRequestStatus(requestId: String, status: SeatRequestStatus) async throws
    func leaveSubscription(requestId: String, listingId: String) async throws
    
    // Reviews
    func createReview(_ review: Review) async throws -> Review
    func fetchReviewsForUser(userId: String) async throws -> [Review]
    func fetchReviewsForListing(listingId: String) async throws -> [Review]
    func hasReviewed(reviewerId: String, targetUserId: String, listingId: String) async throws -> Bool
    
    // Messaging
    func createConversation(_ conversation: Conversation) async throws -> Conversation
    func fetchConversations(userId: String) async throws -> [Conversation]
    func fetchConversation(id: String) async throws -> Conversation?
    func findConversation(participants: [String], listingId: String?) async throws -> Conversation?
    func sendMessage(_ message: Message) async throws -> Message
    func fetchMessages(conversationId: String) async throws -> [Message]
    func markMessagesAsRead(conversationId: String, userId: String) async throws
}

// MARK: - Mock Subscription Service
/// Mocked Firestore service for MVP development
class MockSubscriptionService: SubscriptionServiceProtocol, ObservableObject {
    static let shared = MockSubscriptionService()
    
    @Published private(set) var listings: [SubscriptionListing] = SubscriptionListing.mockListings
    @Published private(set) var requests: [SeatRequest] = SeatRequest.mockRequests
    
    private init() {}
    
    // MARK: - Listings
    
    func fetchListings() async throws -> [SubscriptionListing] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return listings.filter { $0.isActive && $0.availableSeats > 0 }
    }
    
    func fetchListing(id: String) async throws -> SubscriptionListing? {
        try await Task.sleep(nanoseconds: 300_000_000)
        return listings.first { $0.id == id }
    }
    
    func createListing(_ listing: SubscriptionListing) async throws -> SubscriptionListing {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        await MainActor.run {
            self.listings.insert(listing, at: 0)
        }
        
        return listing
    }
    
    func updateListing(_ listing: SubscriptionListing) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            if let index = self.listings.firstIndex(where: { $0.id == listing.id }) {
                self.listings[index] = listing
            }
        }
    }
    
    func deleteListing(id: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            self.listings.removeAll { $0.id == id }
        }
    }
    
    // MARK: - Seat Requests
    
    func fetchRequests(forListing listingId: String) async throws -> [SeatRequest] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return requests.filter { $0.listingId == listingId }
    }
    
    func fetchMyRequests(userId: String) async throws -> [SeatRequest] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return requests.filter { $0.requesterId == userId }
    }
    
    func createRequest(_ request: SeatRequest) async throws -> SeatRequest {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        await MainActor.run {
            self.requests.append(request)
        }
        
        return request
    }
    
    func updateRequestStatus(requestId: String, status: SeatRequestStatus) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            if let index = self.requests.firstIndex(where: { $0.id == requestId }) {
                self.requests[index].status = status
                self.requests[index].respondedAt = Date()
                
                // If approved, decrease available seats
                if status == .approved {
                    let listingId = self.requests[index].listingId
                    if let listingIndex = self.listings.firstIndex(where: { $0.id == listingId }) {
                        self.listings[listingIndex].availableSeats -= 1
                    }
                }
            }
        }
    }
    
    func leaveSubscription(requestId: String, listingId: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            // Update request status to cancelled
            if let index = self.requests.firstIndex(where: { $0.id == requestId }) {
                self.requests[index].status = .cancelled
                self.requests[index].respondedAt = Date()
            }
            
            // Increase available seats on the listing
            if let listingIndex = self.listings.firstIndex(where: { $0.id == listingId }) {
                self.listings[listingIndex].availableSeats += 1
            }
        }
    }
    
    // MARK: - Reviews
    
    @Published private(set) var reviews: [Review] = Review.mockReviews
    
    func createReview(_ review: Review) async throws -> Review {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        await MainActor.run {
            self.reviews.append(review)
        }
        
        return review
    }
    
    func fetchReviewsForUser(userId: String) async throws -> [Review] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return reviews.filter { $0.targetUserId == userId }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func fetchReviewsForListing(listingId: String) async throws -> [Review] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return reviews.filter { $0.listingId == listingId }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func hasReviewed(reviewerId: String, targetUserId: String, listingId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 200_000_000)
        return reviews.contains { 
            $0.reviewerId == reviewerId && 
            $0.targetUserId == targetUserId && 
            $0.listingId == listingId 
        }
    }
    
    // MARK: - Messaging
    
    @Published private(set) var conversations: [Conversation] = Conversation.mockConversations
    @Published private(set) var messages: [Message] = Message.mockMessages
    
    func createConversation(_ conversation: Conversation) async throws -> Conversation {
        try await Task.sleep(nanoseconds: 300_000_000)
        
        await MainActor.run {
            self.conversations.insert(conversation, at: 0)
        }
        
        return conversation
    }
    
    func fetchConversations(userId: String) async throws -> [Conversation] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return conversations
            .filter { $0.participants.contains(userId) }
            .sorted { $0.lastMessageAt > $1.lastMessageAt }
    }
    
    func fetchConversation(id: String) async throws -> Conversation? {
        try await Task.sleep(nanoseconds: 200_000_000)
        return conversations.first { $0.id == id }
    }
    
    func findConversation(participants: [String], listingId: String?) async throws -> Conversation? {
        try await Task.sleep(nanoseconds: 200_000_000)
        return conversations.first { conv in
            let sameParticipants = Set(conv.participants) == Set(participants)
            if let listingId = listingId {
                return sameParticipants && conv.listingId == listingId
            }
            return sameParticipants
        }
    }
    
    func sendMessage(_ message: Message) async throws -> Message {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        await MainActor.run {
            self.messages.append(message)
            
            // Update conversation's last message
            if let index = self.conversations.firstIndex(where: { $0.id == message.conversationId }) {
                self.conversations[index].lastMessage = message.content
                self.conversations[index].lastMessageAt = message.createdAt
                self.conversations[index].lastSenderId = message.senderId
                
                // Increment unread count for other participants
                for participant in self.conversations[index].participants where participant != message.senderId {
                    self.conversations[index].unreadCount[participant, default: 0] += 1
                }
            }
        }
        
        return message
    }
    
    func fetchMessages(conversationId: String) async throws -> [Message] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return messages
            .filter { $0.conversationId == conversationId }
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    func markMessagesAsRead(conversationId: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        
        await MainActor.run {
            // Mark messages as read
            for i in self.messages.indices {
                if self.messages[i].conversationId == conversationId && 
                   self.messages[i].senderId != userId {
                    self.messages[i].isRead = true
                }
            }
            
            // Reset unread count
            if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
                self.conversations[index].unreadCount[userId] = 0
            }
        }
    }
}
