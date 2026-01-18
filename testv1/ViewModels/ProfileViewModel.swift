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
    @Published var incomingRequests: [SeatRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let subscriptionService: SubscriptionServiceProtocol
    
    var pendingRequestsCount: Int {
        myRequests.filter { $0.status == .pending }.count
    }
    
    var approvedRequestsCount: Int {
        myRequests.filter { $0.status == .approved }.count
    }
    
    var pendingIncomingCount: Int {
        incomingRequests.filter { $0.status == .pending }.count
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
    
    init(subscriptionService: SubscriptionServiceProtocol? = nil) {
        self.subscriptionService = subscriptionService ?? ServiceContainer.subscriptions
    }
    
    func setUser(_ user: HalfisiesUser?) {
        self.user = user
    }
    
    func fetchMyListings() async {
        guard let userId = user?.id else { return }
        
        isLoading = true
        
        do {
            // Use dedicated method if using Firestore
            if AppConfig.useFirebase {
                myListings = try await (subscriptionService as? FirestoreService)?.fetchUserListings(userId: userId) ?? []
            } else {
                let allListings = try await subscriptionService.fetchListings()
                myListings = allListings.filter { $0.ownerId == userId }
            }
            ServiceContainer.shared.logDebug("Fetched \(myListings.count) user listings")
        } catch {
            errorMessage = "Failed to load your listings."
        }
        
        isLoading = false
    }
    
    func fetchMyRequests() async {
        guard let userId = user?.id else { return }
        
        do {
            myRequests = try await subscriptionService.fetchMyRequests(userId: userId)
            ServiceContainer.shared.logDebug("Fetched \(myRequests.count) user requests")
        } catch {
            errorMessage = "Failed to load your requests."
        }
    }
    
    func fetchIncomingRequests() async {
        guard let userId = user?.id else { return }
        
        do {
            if AppConfig.useFirebase {
                incomingRequests = try await (subscriptionService as? FirestoreService)?.fetchIncomingRequests(ownerId: userId) ?? []
            } else {
                // For mock service, filter from all requests
                var allIncoming: [SeatRequest] = []
                for listing in myListings {
                    let requests = try await subscriptionService.fetchRequests(forListing: listing.id)
                    allIncoming.append(contentsOf: requests.filter { $0.status == .pending })
                }
                incomingRequests = allIncoming
            }
            ServiceContainer.shared.logDebug("Fetched \(incomingRequests.count) incoming requests")
        } catch {
            errorMessage = "Failed to load incoming requests."
        }
    }
    
    func approveRequest(_ request: SeatRequest) async {
        do {
            try await subscriptionService.updateRequestStatus(requestId: request.id, status: .approved)
            await fetchIncomingRequests()
            await fetchMyListings()
            ServiceContainer.shared.logDebug("Approved request: \(request.id)")
        } catch {
            errorMessage = "Failed to approve request."
        }
    }
    
    func rejectRequest(_ request: SeatRequest) async {
        do {
            try await subscriptionService.updateRequestStatus(requestId: request.id, status: .rejected)
            await fetchIncomingRequests()
            ServiceContainer.shared.logDebug("Rejected request: \(request.id)")
        } catch {
            errorMessage = "Failed to reject request."
        }
    }
    
    func loadAllData() async {
        await fetchMyListings()
        await fetchMyRequests()
        await fetchIncomingRequests()
    }
}
