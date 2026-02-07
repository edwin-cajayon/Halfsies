//
//  Report.swift
//  Halfisies
//
//  Model for user reports and blocking
//

import Foundation

// MARK: - Report Reason
enum ReportReason: String, Codable, CaseIterable {
    case spam = "spam"
    case harassment = "harassment"
    case scam = "scam"
    case inappropriateContent = "inappropriate_content"
    case fakeProfile = "fake_profile"
    case paymentIssue = "payment_issue"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .spam: return "Spam"
        case .harassment: return "Harassment or Bullying"
        case .scam: return "Scam or Fraud"
        case .inappropriateContent: return "Inappropriate Content"
        case .fakeProfile: return "Fake Profile"
        case .paymentIssue: return "Payment Issue"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .spam: return "envelope.badge.fill"
        case .harassment: return "exclamationmark.bubble.fill"
        case .scam: return "exclamationmark.triangle.fill"
        case .inappropriateContent: return "eye.slash.fill"
        case .fakeProfile: return "person.crop.circle.badge.xmark"
        case .paymentIssue: return "creditcard.trianglebadge.exclamationmark"
        case .other: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Report Type
enum ReportType: String, Codable {
    case user = "user"
    case listing = "listing"
    case message = "message"
    case review = "review"
}

// MARK: - Report Status
enum ReportStatus: String, Codable {
    case pending = "pending"
    case reviewing = "reviewing"
    case resolved = "resolved"
    case dismissed = "dismissed"
}

// MARK: - Report Model
struct Report: Identifiable, Codable {
    let id: String
    let reporterId: String
    let reporterName: String
    let reportedUserId: String
    let reportedUserName: String
    let reportType: ReportType
    let reason: ReportReason
    let details: String
    let relatedContentId: String? // listing ID, message ID, etc.
    let status: ReportStatus
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        reporterId: String,
        reporterName: String,
        reportedUserId: String,
        reportedUserName: String,
        reportType: ReportType,
        reason: ReportReason,
        details: String,
        relatedContentId: String? = nil,
        status: ReportStatus = .pending,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.reporterId = reporterId
        self.reporterName = reporterName
        self.reportedUserId = reportedUserId
        self.reportedUserName = reportedUserName
        self.reportType = reportType
        self.reason = reason
        self.details = details
        self.relatedContentId = relatedContentId
        self.status = status
        self.createdAt = createdAt
    }
}

// MARK: - Blocked User
struct BlockedUser: Identifiable, Codable {
    let id: String // The blocked user's ID
    let blockedAt: Date
    let reason: String?
    
    init(id: String, blockedAt: Date = Date(), reason: String? = nil) {
        self.id = id
        self.blockedAt = blockedAt
        self.reason = reason
    }
}
