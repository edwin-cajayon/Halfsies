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
        let snapshot = try await db.collection(listingsCollection)
            .whereField("isActive", isEqualTo: true)
            .whereField("availableSeats", isGreaterThan: 0)
            .order(by: "availableSeats", descending: false)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeListing(doc.data(), id: doc.documentID)
        }
    }
    
    func fetchListing(id: String) async throws -> SubscriptionListing? {
        let document = try await db.collection(listingsCollection).document(id).getDocument()
        
        guard document.exists, let data = document.data() else {
            return nil
        }
        
        return try decodeListing(data, id: id)
    }
    
    func fetchUserListings(userId: String) async throws -> [SubscriptionListing] {
        let snapshot = try await db.collection(listingsCollection)
            .whereField("ownerId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeListing(doc.data(), id: doc.documentID)
        }
    }
    
    func createListing(_ listing: SubscriptionListing) async throws -> SubscriptionListing {
        let data = encodeListing(listing)
        let docRef = db.collection(listingsCollection).document(listing.id)
        try await docRef.setData(data)
        
        // Update user's isOwner flag
        try await db.collection(usersCollection).document(listing.ownerId).updateData([
            "isOwner": true
        ])
        
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
        let snapshot = try await db.collection(requestsCollection)
            .whereField("listingId", isEqualTo: listingId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeRequest(doc.data(), id: doc.documentID)
        }
    }
    
    func fetchMyRequests(userId: String) async throws -> [SeatRequest] {
        let snapshot = try await db.collection(requestsCollection)
            .whereField("requesterId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? decodeRequest(doc.data(), id: doc.documentID)
        }
    }
    
    func fetchIncomingRequests(ownerId: String) async throws -> [SeatRequest] {
        // First, get all listings owned by this user
        let listings = try await fetchUserListings(userId: ownerId)
        let listingIds = listings.map { $0.id }
        
        guard !listingIds.isEmpty else { return [] }
        
        // Fetch requests for these listings
        var allRequests: [SeatRequest] = []
        
        // Firestore 'in' query limited to 10 items, so batch if needed
        let batches = stride(from: 0, to: listingIds.count, by: 10).map {
            Array(listingIds[$0..<min($0 + 10, listingIds.count)])
        }
        
        for batch in batches {
            let snapshot = try await db.collection(requestsCollection)
                .whereField("listingId", in: batch)
                .whereField("status", isEqualTo: "pending")
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let requests = snapshot.documents.compactMap { doc in
                try? decodeRequest(doc.data(), id: doc.documentID)
            }
            allRequests.append(contentsOf: requests)
        }
        
        return allRequests
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
    
    // MARK: - Real-time Listeners
    
    func listenToListings(completion: @escaping ([SubscriptionListing]) -> Void) -> ListenerRegistration {
        return db.collection(listingsCollection)
            .whereField("isActive", isEqualTo: true)
            .whereField("availableSeats", isGreaterThan: 0)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let listings = documents.compactMap { doc in
                    try? self.decodeListing(doc.data(), id: doc.documentID)
                }
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
