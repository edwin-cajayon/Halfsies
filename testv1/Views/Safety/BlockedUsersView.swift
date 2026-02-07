//
//  BlockedUsersView.swift
//  Halfisies
//
//  Manage blocked users
//

import SwiftUI

struct BlockedUsersView: View {
    let currentUserId: String
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var safetyService = SafetyService.shared
    
    @State private var blockedUsers: [BlockedUser] = []
    @State private var isLoading = true
    @State private var showUnblockConfirm = false
    @State private var userToUnblock: BlockedUser?
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: HalfisiesTheme.primary))
            } else if blockedUsers.isEmpty {
                emptyState
            } else {
                blockedUsersList
            }
        }
        .navigationTitle("Blocked Users")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadBlockedUsers()
        }
        .alert("Unblock User?", isPresented: $showUnblockConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Unblock", role: .destructive) {
                if let user = userToUnblock {
                    unblockUser(user)
                }
            }
        } message: {
            Text("This user will be able to see your listings and contact you again.")
        }
    }
    
    // MARK: - Empty State
    var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.secondary.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 36))
                    .foregroundColor(HalfisiesTheme.secondary)
            }
            
            Text("No Blocked Users")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("You haven't blocked anyone yet.\nBlocked users can't see your listings or message you.")
                .font(.system(size: 15))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Blocked Users List
    var blockedUsersList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(blockedUsers) { blockedUser in
                    blockedUserCard(blockedUser)
                }
            }
            .padding(20)
        }
    }
    
    func blockedUserCard(_ blockedUser: BlockedUser) -> some View {
        HStack(spacing: 14) {
            // Avatar placeholder
            Circle()
                .fill(HalfisiesTheme.error.opacity(0.15))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "nosign")
                        .font(.system(size: 20))
                        .foregroundColor(HalfisiesTheme.error)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("User ID: \(String(blockedUser.id.prefix(8)))...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text("Blocked \(formatDate(blockedUser.blockedAt))")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                if let reason = blockedUser.reason, !reason.isEmpty {
                    Text("Reason: \(reason)")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            
            Spacer()
            
            Button(action: {
                userToUnblock = blockedUser
                showUnblockConfirm = true
            }) {
                Text("Unblock")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(HalfisiesTheme.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(HalfisiesTheme.primary.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(14)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
    }
    
    // MARK: - Functions
    func loadBlockedUsers() async {
        isLoading = true
        blockedUsers = await safetyService.getBlockedUsersList(userId: currentUserId)
        isLoading = false
    }
    
    func unblockUser(_ blockedUser: BlockedUser) {
        Task {
            do {
                try await safetyService.unblockUser(currentUserId: currentUserId, userToUnblock: blockedUser.id)
                await loadBlockedUsers()
            } catch {
                print("Error unblocking user: \(error)")
            }
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        BlockedUsersView(currentUserId: "123")
    }
}
