//
//  SafetyService.swift
//  Halfisies
//
//  Handles reporting and blocking functionality
//

import Foundation
import FirebaseFirestore

class SafetyService: ObservableObject {
    static let shared = SafetyService()
    
    private let db = Firestore.firestore()
    
    @Published var blockedUserIds: Set<String> = []
    @Published var isLoading = false
    
    private init() {}
    
    // MARK: - Blocking
    
    /// Load blocked users for current user
    func loadBlockedUsers(userId: String) async {
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("blockedUsers")
                .getDocuments()
            
            let ids = Set(snapshot.documents.map { $0.documentID })
            
            await MainActor.run {
                self.blockedUserIds = ids
            }
            
            print("[Halfsies] Loaded \(ids.count) blocked users")
        } catch {
            print("[Halfsies] Error loading blocked users: \(error)")
        }
    }
    
    /// Block a user
    func blockUser(currentUserId: String, userToBlock: String, reason: String? = nil) async throws {
        let blockedUser = BlockedUser(id: userToBlock, reason: reason)
        
        try await db.collection("users")
            .document(currentUserId)
            .collection("blockedUsers")
            .document(userToBlock)
            .setData([
                "blockedAt": Timestamp(date: blockedUser.blockedAt),
                "reason": reason ?? ""
            ])
        
        await MainActor.run {
            self.blockedUserIds.insert(userToBlock)
        }
        
        print("[Halfsies] Blocked user: \(userToBlock)")
    }
    
    /// Unblock a user
    func unblockUser(currentUserId: String, userToUnblock: String) async throws {
        try await db.collection("users")
            .document(currentUserId)
            .collection("blockedUsers")
            .document(userToUnblock)
            .delete()
        
        await MainActor.run {
            self.blockedUserIds.remove(userToUnblock)
        }
        
        print("[Halfsies] Unblocked user: \(userToUnblock)")
    }
    
    /// Check if a user is blocked
    func isBlocked(_ userId: String) -> Bool {
        return blockedUserIds.contains(userId)
    }
    
    // MARK: - Reporting
    
    /// Submit a report
    func submitReport(_ report: Report) async throws {
        let data: [String: Any] = [
            "id": report.id,
            "reporterId": report.reporterId,
            "reporterName": report.reporterName,
            "reportedUserId": report.reportedUserId,
            "reportedUserName": report.reportedUserName,
            "reportType": report.reportType.rawValue,
            "reason": report.reason.rawValue,
            "details": report.details,
            "relatedContentId": report.relatedContentId ?? "",
            "status": report.status.rawValue,
            "createdAt": Timestamp(date: report.createdAt)
        ]
        
        try await db.collection("reports")
            .document(report.id)
            .setData(data)
        
        print("[Halfsies] Report submitted: \(report.id)")
    }
    
    /// Report and optionally block a user
    func reportAndBlockUser(
        currentUser: HalfisiesUser,
        reportedUserId: String,
        reportedUserName: String,
        reason: ReportReason,
        details: String,
        shouldBlock: Bool
    ) async throws {
        // Create report
        let report = Report(
            reporterId: currentUser.id,
            reporterName: currentUser.displayName,
            reportedUserId: reportedUserId,
            reportedUserName: reportedUserName,
            reportType: .user,
            reason: reason,
            details: details
        )
        
        try await submitReport(report)
        
        // Block if requested
        if shouldBlock {
            try await blockUser(currentUserId: currentUser.id, userToBlock: reportedUserId, reason: reason.displayName)
        }
    }
    
    // MARK: - Get Blocked Users List
    
    func getBlockedUsersList(userId: String) async -> [BlockedUser] {
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("blockedUsers")
                .order(by: "blockedAt", descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap { doc -> BlockedUser? in
                let data = doc.data()
                let timestamp = data["blockedAt"] as? Timestamp ?? Timestamp()
                let reason = data["reason"] as? String
                return BlockedUser(id: doc.documentID, blockedAt: timestamp.dateValue(), reason: reason)
            }
        } catch {
            print("[Halfsies] Error fetching blocked users list: \(error)")
            return []
        }
    }
}
