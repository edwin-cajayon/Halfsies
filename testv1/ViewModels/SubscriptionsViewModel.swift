//
//  SubscriptionsViewModel.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation
import SwiftUI

@MainActor
class SubscriptionsViewModel: ObservableObject {
    @Published var listings: [SubscriptionListing] = []
    @Published var selectedListing: SubscriptionListing?
    @Published var requests: [SeatRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedService: SubscriptionService?
    
    // Create Listing Form
    @Published var newListingService: SubscriptionService = .netflix
    @Published var newListingPlanName = ""
    @Published var newListingTotalSeats = 4
    @Published var newListingAvailableSeats = 2
    @Published var newListingPricePerSeat = ""
    @Published var newListingDescription = ""
    
    private let subscriptionService: MockSubscriptionService
    
    var filteredListings: [SubscriptionListing] {
        var result = listings
        
        // Filter by service
        if let service = selectedService {
            result = result.filter { $0.service == service }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            result = result.filter {
                $0.service.rawValue.localizedCaseInsensitiveContains(searchText) ||
                $0.ownerName.localizedCaseInsensitiveContains(searchText) ||
                $0.planName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    init(subscriptionService: MockSubscriptionService = .shared) {
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - Fetch Listings
    func fetchListings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            listings = try await subscriptionService.fetchListings()
        } catch {
            errorMessage = "Failed to load listings."
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Single Listing
    func fetchListing(id: String) async {
        isLoading = true
        
        do {
            selectedListing = try await subscriptionService.fetchListing(id: id)
        } catch {
            errorMessage = "Failed to load listing details."
        }
        
        isLoading = false
    }
    
    // MARK: - Create Listing
    func createListing(ownerId: String, ownerName: String) async -> Bool {
        guard validateNewListing() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let listing = SubscriptionListing(
            ownerId: ownerId,
            ownerName: ownerName,
            service: newListingService,
            planName: newListingPlanName,
            totalSeats: newListingTotalSeats,
            availableSeats: newListingAvailableSeats,
            pricePerSeat: Double(newListingPricePerSeat) ?? 0,
            description: newListingDescription
        )
        
        do {
            _ = try await subscriptionService.createListing(listing)
            clearNewListingForm()
            await fetchListings()
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to create listing."
            isLoading = false
            return false
        }
    }
    
    // MARK: - Seat Requests
    func fetchRequests(forListing listingId: String) async {
        do {
            requests = try await subscriptionService.fetchRequests(forListing: listingId)
        } catch {
            errorMessage = "Failed to load requests."
        }
    }
    
    func requestSeat(listing: SubscriptionListing, userId: String, userName: String, message: String) async -> Bool {
        isLoading = true
        
        let request = SeatRequest(
            listingId: listing.id,
            requesterId: userId,
            requesterName: userName,
            message: message
        )
        
        do {
            _ = try await subscriptionService.createRequest(request)
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to send request."
            isLoading = false
            return false
        }
    }
    
    func approveRequest(_ request: SeatRequest) async {
        do {
            try await subscriptionService.updateRequestStatus(requestId: request.id, status: .approved)
            await fetchRequests(forListing: request.listingId)
            await fetchListings()
        } catch {
            errorMessage = "Failed to approve request."
        }
    }
    
    func rejectRequest(_ request: SeatRequest) async {
        do {
            try await subscriptionService.updateRequestStatus(requestId: request.id, status: .rejected)
            await fetchRequests(forListing: request.listingId)
        } catch {
            errorMessage = "Failed to reject request."
        }
    }
    
    // MARK: - Validation
    private func validateNewListing() -> Bool {
        if newListingPlanName.isEmpty {
            errorMessage = "Please enter a plan name."
            return false
        }
        if newListingAvailableSeats < 1 {
            errorMessage = "You need at least 1 available seat."
            return false
        }
        if newListingAvailableSeats > newListingTotalSeats {
            errorMessage = "Available seats can't exceed total seats."
            return false
        }
        guard let price = Double(newListingPricePerSeat), price > 0 else {
            errorMessage = "Please enter a valid price."
            return false
        }
        return true
    }
    
    private func clearNewListingForm() {
        newListingService = .netflix
        newListingPlanName = ""
        newListingTotalSeats = 4
        newListingAvailableSeats = 2
        newListingPricePerSeat = ""
        newListingDescription = ""
    }
}
