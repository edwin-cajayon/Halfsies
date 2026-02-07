//
//  ReferralView.swift
//  Halfisies
//
//  Invite friends and track referrals
//

import SwiftUI

struct ReferralView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject private var referralService = ReferralService.shared
    @State private var showShareSheet = false
    @State private var codeCopied = false
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero Section
                    heroSection
                    
                    // Your Code Section
                    codeSection
                    
                    // Stats Section
                    statsSection
                    
                    // How It Works
                    howItWorksSection
                    
                    // Referrals List
                    if !referralService.referrals.isEmpty {
                        referralsListSection
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
        }
        .navigationTitle("Invite Friends")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadReferralData()
        }
        .sheet(isPresented: $showShareSheet) {
            shareSheet
        }
    }
    
    // MARK: - Hero Section
    var heroSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [HalfisiesTheme.primary, HalfisiesTheme.coral],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            Text("Invite Friends, Get Rewards")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Share your referral code with friends. When they join and create their first listing, you both get rewarded!")
                .font(.system(size: 15))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Code Section
    var codeSection: some View {
        VStack(spacing: 16) {
            Text("YOUR REFERRAL CODE")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            // Code Display
            HStack(spacing: 12) {
                Text(referralService.myReferralCode.isEmpty ? "Loading..." : referralService.myReferralCode.uppercased())
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(HalfisiesTheme.primary)
                    .kerning(2)
                
                Button(action: copyCode) {
                    Image(systemName: codeCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .font(.system(size: 20))
                        .foregroundColor(codeCopied ? HalfisiesTheme.secondary : HalfisiesTheme.textMuted)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .fill(HalfisiesTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [HalfisiesTheme.primary.opacity(0.3), HalfisiesTheme.secondary.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 4)
            
            // Share Button
            Button(action: { showShareSheet = true }) {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Share Invite Link")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [HalfisiesTheme.primary, HalfisiesTheme.coral],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .shadow(color: HalfisiesTheme.primary.opacity(0.3), radius: 8, y: 4)
            }
        }
    }
    
    // MARK: - Stats Section
    var statsSection: some View {
        HStack(spacing: 12) {
            ReferralStatCard(
                value: "\(referralService.stats.totalReferrals)",
                label: "Total Invited",
                icon: "person.2.fill",
                color: HalfisiesTheme.primary
            )
            
            ReferralStatCard(
                value: "\(referralService.stats.completedReferrals)",
                label: "Completed",
                icon: "checkmark.circle.fill",
                color: HalfisiesTheme.secondary
            )
            
            ReferralStatCard(
                value: "$\(String(format: "%.0f", referralService.stats.totalEarnings))",
                label: "Earned",
                icon: "dollarsign.circle.fill",
                color: HalfisiesTheme.golden
            )
        }
    }
    
    // MARK: - How It Works
    var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("HOW IT WORKS")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            VStack(spacing: 0) {
                HowItWorksRow(
                    step: 1,
                    icon: "square.and.arrow.up",
                    title: "Share Your Code",
                    description: "Send your referral code to friends"
                )
                
                HowItWorksRow(
                    step: 2,
                    icon: "person.badge.plus",
                    title: "Friend Signs Up",
                    description: "They create an account using your code"
                )
                
                HowItWorksRow(
                    step: 3,
                    icon: "list.bullet.rectangle",
                    title: "First Listing",
                    description: "They create their first subscription listing",
                    isLast: true
                )
            }
            .padding(16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        }
    }
    
    // MARK: - Referrals List
    var referralsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR REFERRALS")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            VStack(spacing: 8) {
                ForEach(referralService.referrals) { referral in
                    ReferralRow(referral: referral)
                }
            }
        }
    }
    
    // MARK: - Share Sheet
    var shareSheet: some View {
        Group {
            if let url = DeepLinkService.shared.generateReferralURL(code: referralService.myReferralCode) {
                ShareSheet(items: [
                    "Join me on Halfsies and save money on subscriptions! Use my referral code: \(referralService.myReferralCode.uppercased()) 🎉",
                    url
                ])
            }
        }
    }
    
    // MARK: - Functions
    func loadReferralData() async {
        guard let user = authViewModel.currentUser else { return }
        
        isLoading = true
        
        // Get or create referral code
        _ = await referralService.getOrCreateReferralCode(userId: user.id, userName: user.displayName)
        
        // Fetch referrals
        await referralService.fetchMyReferrals(userId: user.id)
        
        isLoading = false
    }
    
    func copyCode() {
        UIPasteboard.general.string = referralService.myReferralCode.uppercased()
        codeCopied = true
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            codeCopied = false
        }
    }
}

// MARK: - Referral Stat Card
struct ReferralStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
    }
}

// MARK: - How It Works Row
struct HowItWorksRow: View {
    let step: Int
    let icon: String
    let title: String
    let description: String
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Step indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(HalfisiesTheme.primary.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Text("\(step)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.primary)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(HalfisiesTheme.border)
                        .frame(width: 2, height: 30)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            .padding(.bottom, isLast ? 0 : 16)
            
            Spacer()
        }
    }
}

// MARK: - Referral Row
struct ReferralRow: View {
    let referral: Referral
    
    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: statusIcon)
                        .font(.system(size: 18))
                        .foregroundColor(statusColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Friend #\(String(referral.referredUserId.prefix(6)))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text(formatDate(referral.createdAt))
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            Spacer()
            
            Text(referral.status.rawValue.capitalized)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.12))
                .cornerRadius(6)
        }
        .padding(14)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    var statusColor: Color {
        switch referral.status {
        case .pending: return HalfisiesTheme.golden
        case .completed, .rewarded: return HalfisiesTheme.secondary
        case .expired: return HalfisiesTheme.textMuted
        }
    }
    
    var statusIcon: String {
        switch referral.status {
        case .pending: return "clock.fill"
        case .completed, .rewarded: return "checkmark.circle.fill"
        case .expired: return "xmark.circle.fill"
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
        ReferralView(authViewModel: AuthViewModel())
    }
}
