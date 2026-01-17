//
//  SeatRequest.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation

// MARK: - Seat Request Status
enum SeatRequestStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case cancelled = "cancelled"
}

// MARK: - Seat Request
struct SeatRequest: Identifiable, Codable {
    let id: String
    let listingId: String
    let requesterId: String
    var requesterName: String
    var requesterRating: Double
    var status: SeatRequestStatus
    var message: String
    var createdAt: Date
    var respondedAt: Date?
    
    init(
        id: String = UUID().uuidString,
        listingId: String,
        requesterId: String,
        requesterName: String,
        requesterRating: Double = 5.0,
        status: SeatRequestStatus = .pending,
        message: String = "",
        createdAt: Date = Date(),
        respondedAt: Date? = nil
    ) {
        self.id = id
        self.listingId = listingId
        self.requesterId = requesterId
        self.requesterName = requesterName
        self.requesterRating = requesterRating
        self.status = status
        self.message = message
        self.createdAt = createdAt
        self.respondedAt = respondedAt
    }
}

// MARK: - Mock Data
extension SeatRequest {
    static let mockRequests: [SeatRequest] = [
        SeatRequest(
            id: "req-1",
            listingId: "1",
            requesterId: "sub-1",
            requesterName: "Jane S.",
            requesterRating: 4.9,
            status: .pending,
            message: "Hey! I'd love to join your Netflix plan. I'm reliable and always pay on time!"
        ),
        SeatRequest(
            id: "req-2",
            listingId: "1",
            requesterId: "sub-2",
            requesterName: "Tom B.",
            requesterRating: 4.5,
            status: .pending,
            message: "Looking for a Netflix spot. Happy to pay for 6 months upfront!"
        ),
        SeatRequest(
            id: "req-3",
            listingId: "2",
            requesterId: "sub-3",
            requesterName: "Lisa W.",
            requesterRating: 5.0,
            status: .approved,
            message: "Would love a Spotify slot!",
            respondedAt: Date().addingTimeInterval(-86400)
        )
    ]
}
