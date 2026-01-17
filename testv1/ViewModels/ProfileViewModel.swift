//
//  ProfileViewModel.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: HalfisiesUser?
    @Published var myListings: [SubscriptionListing] = []
    @Published var myRequests: [SeatRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let subscriptionService: MockSubscriptionService
    
    var pendingRequestsCount: Int {
        myRequests.filter { $0.status == .pending }.count
    }
    
    var approvedRequestsCount: Int {
        myRequests.filter { $0.status == .approved }.count
    }
    
    var totalMonthlySavings: Double {
        // Calculate from joined subscriptions (approved requests)
        // For now, estimate based on approved count
        Double(approvedRequestsCount) * 8.50
    }
    
    var totalMonthlyEarnings: Double {
        myListings.reduce(0) { $0 + $1.monthlyRevenue }
    }
    
    var lifetimeSavings: Double {
        user?.totalSavings ?? 0
    }
    
    var trustScore: Int {
        user?.trustScore ?? 50
    }
    
    init(subscriptionService: MockSubscriptionService = .shared) {
        self.subscriptionService = subscriptionService
    }
    
    func setUser(_ user: HalfisiesUser?) {
        self.user = user
    }
    
    func fetchMyListings() async {
        guard let userId = user?.id else { return }
        
        isLoading = true
        
        do {
            let allListings = try await subscriptionService.fetchListings()
            myListings = allListings.filter { $0.ownerId == userId }
        } catch {
            errorMessage = "Failed to load your listings."
        }
        
        isLoading = false
    }
    
    func fetchMyRequests() async {
        guard let userId = user?.id else { return }
        
        do {
            myRequests = try await subscriptionService.fetchMyRequests(userId: userId)
        } catch {
            errorMessage = "Failed to load your requests."
        }
    }
    
    func loadAllData() async {
        await fetchMyListings()
        await fetchMyRequests()
    }
}
