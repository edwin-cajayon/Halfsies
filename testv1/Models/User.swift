//
//  User.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation

struct HalfisiesUser: Identifiable, Codable {
    let id: String
    var email: String
    var displayName: String
    var avatarURL: String?
    var rating: Double
    var reviewCount: Int
    var trustScore: Int // 0-100 trust score like Spliiit
    var verifiedEmail: Bool
    var verifiedPhone: Bool
    var verifiedID: Bool
    var totalSavings: Double // Lifetime savings
    var memberSince: Date
    var isOwner: Bool // Has created listings
    
    init(
        id: String = UUID().uuidString,
        email: String,
        displayName: String,
        avatarURL: String? = nil,
        rating: Double = 5.0,
        reviewCount: Int = 0,
        trustScore: Int = 50,
        verifiedEmail: Bool = true,
        verifiedPhone: Bool = false,
        verifiedID: Bool = false,
        totalSavings: Double = 0,
        memberSince: Date = Date(),
        isOwner: Bool = false
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.rating = rating
        self.reviewCount = reviewCount
        self.trustScore = trustScore
        self.verifiedEmail = verifiedEmail
        self.verifiedPhone = verifiedPhone
        self.verifiedID = verifiedID
        self.totalSavings = totalSavings
        self.memberSince = memberSince
        self.isOwner = isOwner
    }
    
    // Trust score calculation based on verifications
    var calculatedTrustScore: Int {
        var score = 30 // Base score
        if verifiedEmail { score += 20 }
        if verifiedPhone { score += 25 }
        if verifiedID { score += 25 }
        return min(score, 100)
    }
    
    var trustLevel: TrustLevel {
        switch trustScore {
        case 0..<40: return .new
        case 40..<70: return .verified
        case 70..<90: return .trusted
        default: return .superTrusted
        }
    }
}

enum TrustLevel: String {
    case new = "New"
    case verified = "Verified"
    case trusted = "Trusted"
    case superTrusted = "Super Trusted"
    
    var color: String {
        switch self {
        case .new: return "888899"
        case .verified: return "4ECDC4"
        case .trusted: return "6C5CE7"
        case .superTrusted: return "FFD93D"
        }
    }
    
    var icon: String {
        switch self {
        case .new: return "person.circle"
        case .verified: return "checkmark.shield"
        case .trusted: return "shield.fill"
        case .superTrusted: return "star.shield.fill"
        }
    }
}

// MARK: - Mock Data
extension HalfisiesUser {
    static let mockOwner = HalfisiesUser(
        id: "owner-1",
        email: "john@example.com",
        displayName: "John D.",
        rating: 4.8,
        reviewCount: 23,
        trustScore: 85,
        verifiedEmail: true,
        verifiedPhone: true,
        verifiedID: true,
        totalSavings: 245.50,
        isOwner: true
    )
    
    static let mockCoSubscriber = HalfisiesUser(
        id: "sub-1",
        email: "jane@example.com",
        displayName: "Jane S.",
        rating: 4.9,
        reviewCount: 12,
        trustScore: 72,
        verifiedEmail: true,
        verifiedPhone: true,
        verifiedID: false,
        totalSavings: 156.00,
        isOwner: false
    )
}
