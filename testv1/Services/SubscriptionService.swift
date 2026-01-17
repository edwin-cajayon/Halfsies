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
}
