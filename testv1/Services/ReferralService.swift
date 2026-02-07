//
//  ReferralService.swift
//  Halfisies
//
//  Handles referral codes and tracking
//

import Foundation
import FirebaseFirestore

// MARK: - Referral Model
struct Referral: Identifiable, Codable {
    let id: String
    let referrerId: String
    let referredUserId: String
    let referralCode: String
    let status: ReferralStatus
    let createdAt: Date
    let completedAt: Date?
    
    init(
        id: String = UUID().uuidString,
        referrerId: String,
        referredUserId: String,
        referralCode: String,
        status: ReferralStatus = .pending,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.referrerId = referrerId
        self.referredUserId = referredUserId
        self.referralCode = referralCode
        self.status = status
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}

enum ReferralStatus: String, Codable {
    case pending = "pending"           // User signed up but hasn't completed action
    case completed = "completed"       // User completed required action (e.g., first listing)
    case rewarded = "rewarded"         // Rewards have been issued
    case expired = "expired"           // Referral expired
}

// MARK: - Referral Stats
struct ReferralStats {
    var totalReferrals: Int = 0
    var completedReferrals: Int = 0
    var pendingReferrals: Int = 0
    var totalEarnings: Double = 0
}

// MARK: - Referral Service
class ReferralService: ObservableObject {
    static let shared = ReferralService()
    
    private let db = Firestore.firestore()
    
    @Published var myReferralCode: String = ""
    @Published var stats: ReferralStats = ReferralStats()
    @Published var referrals: [Referral] = []
    @Published var pendingReferralCode: String?
    
    private init() {
        // Check for stored pending referral
        if let stored = UserDefaults.standard.string(forKey: "pendingReferralCode") {
            pendingReferralCode = stored
        }
    }
    
    // MARK: - Generate Referral Code
    
    /// Generate a unique referral code for a user
    func generateReferralCode(userId: String, userName: String) -> String {
        // Create a code from user name + random suffix
        let cleanName = userName.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .prefix(6)
        let suffix = String(format: "%04d", Int.random(in: 1000...9999))
        return "\(cleanName)\(suffix)"
    }
    
    /// Get or create referral code for user
    func getOrCreateReferralCode(userId: String, userName: String) async -> String {
        // Check if user already has a code
        do {
            let doc = try await db.collection("users").document(userId).getDocument()
            if let existingCode = doc.data()?["referralCode"] as? String, !existingCode.isEmpty {
                await MainActor.run {
                    self.myReferralCode = existingCode
                }
                return existingCode
            }
        } catch {
            print("[Halfsies] Error fetching referral code: \(error)")
        }
        
        // Generate new code
        let newCode = generateReferralCode(userId: userId, userName: userName)
        
        // Save to Firestore
        do {
            try await db.collection("users").document(userId).updateData([
                "referralCode": newCode
            ])
            
            await MainActor.run {
                self.myReferralCode = newCode
            }
            
            print("[Halfsies] Generated referral code: \(newCode)")
        } catch {
            print("[Halfsies] Error saving referral code: \(error)")
        }
        
        return newCode
    }
    
    // MARK: - Apply Referral Code
    
    /// Store a referral code to apply after signup
    func applyReferralCode(_ code: String) {
        pendingReferralCode = code
        UserDefaults.standard.set(code, forKey: "pendingReferralCode")
        print("[Halfsies] Stored pending referral code: \(code)")
    }
    
    /// Process pending referral after user signs up
    func processPendingReferral(newUserId: String) async {
        guard let code = pendingReferralCode else { return }
        
        do {
            // Find referrer by code
            let snapshot = try await db.collection("users")
                .whereField("referralCode", isEqualTo: code)
                .limit(to: 1)
                .getDocuments()
            
            guard let referrerDoc = snapshot.documents.first else {
                print("[Halfsies] No user found with referral code: \(code)")
                clearPendingReferral()
                return
            }
            
            let referrerId = referrerDoc.documentID
            
            // Don't allow self-referral
            guard referrerId != newUserId else {
                print("[Halfsies] Cannot self-refer")
                clearPendingReferral()
                return
            }
            
            // Create referral record
            let referral = Referral(
                referrerId: referrerId,
                referredUserId: newUserId,
                referralCode: code
            )
            
            try await saveReferral(referral)
            
            // Mark user as referred
            try await db.collection("users").document(newUserId).updateData([
                "referredBy": referrerId,
                "referralCodeUsed": code
            ])
            
            print("[Halfsies] Referral processed: \(code)")
            clearPendingReferral()
            
        } catch {
            print("[Halfsies] Error processing referral: \(error)")
        }
    }
    
    private func clearPendingReferral() {
        pendingReferralCode = nil
        UserDefaults.standard.removeObject(forKey: "pendingReferralCode")
    }
    
    // MARK: - Track Referrals
    
    /// Save a referral to Firestore
    private func saveReferral(_ referral: Referral) async throws {
        let data: [String: Any] = [
            "id": referral.id,
            "referrerId": referral.referrerId,
            "referredUserId": referral.referredUserId,
            "referralCode": referral.referralCode,
            "status": referral.status.rawValue,
            "createdAt": Timestamp(date: referral.createdAt),
            "completedAt": referral.completedAt != nil ? Timestamp(date: referral.completedAt!) : NSNull()
        ]
        
        try await db.collection("referrals").document(referral.id).setData(data)
    }
    
    /// Fetch referrals for a user (as referrer)
    func fetchMyReferrals(userId: String) async {
        do {
            let snapshot = try await db.collection("referrals")
                .whereField("referrerId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let fetched: [Referral] = snapshot.documents.compactMap { doc in
                let data = doc.data()
                guard let id = data["id"] as? String,
                      let referrerId = data["referrerId"] as? String,
                      let referredUserId = data["referredUserId"] as? String,
                      let referralCode = data["referralCode"] as? String,
                      let statusRaw = data["status"] as? String,
                      let status = ReferralStatus(rawValue: statusRaw),
                      let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() else {
                    return nil
                }
                
                let completedAt = (data["completedAt"] as? Timestamp)?.dateValue()
                
                return Referral(
                    id: id,
                    referrerId: referrerId,
                    referredUserId: referredUserId,
                    referralCode: referralCode,
                    status: status,
                    createdAt: createdAt,
                    completedAt: completedAt
                )
            }
            
            await MainActor.run {
                self.referrals = fetched
                self.updateStats()
            }
            
        } catch {
            print("[Halfsies] Error fetching referrals: \(error)")
        }
    }
    
    /// Mark a referral as completed (e.g., when referred user creates first listing)
    func completeReferral(referredUserId: String) async {
        do {
            let snapshot = try await db.collection("referrals")
                .whereField("referredUserId", isEqualTo: referredUserId)
                .whereField("status", isEqualTo: ReferralStatus.pending.rawValue)
                .limit(to: 1)
                .getDocuments()
            
            guard let doc = snapshot.documents.first else { return }
            
            try await doc.reference.updateData([
                "status": ReferralStatus.completed.rawValue,
                "completedAt": Timestamp(date: Date())
            ])
            
            print("[Halfsies] Referral completed for user: \(referredUserId)")
            
        } catch {
            print("[Halfsies] Error completing referral: \(error)")
        }
    }
    
    // MARK: - Stats
    
    private func updateStats() {
        stats.totalReferrals = referrals.count
        stats.completedReferrals = referrals.filter { $0.status == .completed || $0.status == .rewarded }.count
        stats.pendingReferrals = referrals.filter { $0.status == .pending }.count
        // Note: Earnings would be calculated based on your reward structure
        stats.totalEarnings = Double(stats.completedReferrals) * 5.0 // Example: $5 per referral
    }
}
