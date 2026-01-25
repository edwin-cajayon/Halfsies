//
//  Review.swift
//  Halfisies
//
//  User reviews and ratings
//

import Foundation

// MARK: - Review Type
enum ReviewType: String, Codable {
    case asOwner = "asOwner"         // Review left for an owner by a subscriber
    case asSubscriber = "asSubscriber" // Review left for a subscriber by an owner
}

// MARK: - Review Model
struct Review: Identifiable, Codable {
    let id: String
    let reviewerId: String           // Who wrote the review
    var reviewerName: String
    let targetUserId: String         // Who is being reviewed
    var targetUserName: String
    let listingId: String            // Which listing this was for
    var serviceName: String          // e.g., "Netflix", "Spotify"
    var rating: Int                  // 1-5 stars
    var comment: String
    var reviewType: ReviewType
    var createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        reviewerId: String,
        reviewerName: String,
        targetUserId: String,
        targetUserName: String,
        listingId: String,
        serviceName: String,
        rating: Int,
        comment: String = "",
        reviewType: ReviewType,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.reviewerId = reviewerId
        self.reviewerName = reviewerName
        self.targetUserId = targetUserId
        self.targetUserName = targetUserName
        self.listingId = listingId
        self.serviceName = serviceName
        self.rating = min(5, max(1, rating)) // Clamp between 1-5
        self.comment = comment
        self.reviewType = reviewType
        self.createdAt = createdAt
    }
}

// MARK: - Mock Data
extension Review {
    static let mockReviews: [Review] = [
        Review(
            id: "review-1",
            reviewerId: "sub-1",
            reviewerName: "Jane S.",
            targetUserId: "owner-1",
            targetUserName: "John D.",
            listingId: "1",
            serviceName: "Netflix",
            rating: 5,
            comment: "Great owner! Very responsive and the subscription has been working perfectly for 3 months now.",
            reviewType: .asOwner
        ),
        Review(
            id: "review-2",
            reviewerId: "sub-2",
            reviewerName: "Tom B.",
            targetUserId: "owner-1",
            targetUserName: "John D.",
            listingId: "1",
            serviceName: "Netflix",
            rating: 4,
            comment: "Smooth experience, quick to set everything up.",
            reviewType: .asOwner
        ),
        Review(
            id: "review-3",
            reviewerId: "owner-1",
            reviewerName: "John D.",
            targetUserId: "sub-1",
            targetUserName: "Jane S.",
            listingId: "1",
            serviceName: "Netflix",
            rating: 5,
            comment: "Reliable co-subscriber. Always pays on time!",
            reviewType: .asSubscriber
        ),
        Review(
            id: "review-4",
            reviewerId: "sub-3",
            reviewerName: "Lisa W.",
            targetUserId: "owner-2",
            targetUserName: "Sarah M.",
            listingId: "2",
            serviceName: "Spotify",
            rating: 5,
            comment: "Absolutely love this! Been using it for 6 months with zero issues.",
            reviewType: .asOwner
        )
    ]
}
