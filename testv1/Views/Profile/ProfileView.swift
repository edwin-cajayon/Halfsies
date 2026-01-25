//
//  ProfileView.swift
//  Halfisies
//
//  Cozy, warm, trust-first design
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var messagesViewModel = MessagesViewModel()
    @State private var selectedTab = 0
    @State private var showSettings = false
    @State private var listingToEdit: SubscriptionListing?
    @State private var listingToReview: SubscriptionListing?
    @State private var reviewedListings: Set<String> = []
    @State private var conversationToOpen: Conversation?
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    profileHeader
                    trustScoreCard
                    savingsCard
                    statsSection
                    tabSelector
                    
                    if selectedTab == 0 {
                        myListingsSection
                    } else if selectedTab == 1 {
                        activeSubscriptionsSection
                    } else if selectedTab == 2 {
                        incomingRequestsSection
                    } else if selectedTab == 3 {
                        myRequestsSection
                    } else {
                        reviewsSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
        .task {
            viewModel.setUser(authViewModel.currentUser)
            await viewModel.loadAllData()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(authViewModel: authViewModel)
        }
    }
    
    // MARK: - Profile Header
    var profileHeader: some View {
        VStack(spacing: 14) {
            // Settings button
            HStack {
                Spacer()
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(HalfisiesTheme.textMuted)
                        .padding(10)
                        .background(HalfisiesTheme.cardBackground)
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                        .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
                }
            }
            .padding(.bottom, 4)
            
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(String(authViewModel.currentUser?.displayName.prefix(1) ?? "?"))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.primary)
                    )
                
                if viewModel.trustScore >= 70 {
                    Circle()
                        .fill(HalfisiesTheme.cardBackground)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: viewModel.trustScore >= 90 ? "star.fill" : "checkmark.seal.fill")
                                .font(.system(size: 14))
                                .foregroundColor(viewModel.trustScore >= 90 ? HalfisiesTheme.warning : HalfisiesTheme.secondary)
                        )
                        .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
                        .offset(x: 4, y: 4)
                }
            }
            
            VStack(spacing: 4) {
                Text(authViewModel.currentUser?.displayName ?? "User")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text(authViewModel.currentUser?.email ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            // Member since
            if let memberSince = authViewModel.currentUser?.memberSince {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text("Member since \(memberSince.formatted(.dateTime.month().year()))")
                        .font(.system(size: 13))
                }
                .foregroundColor(HalfisiesTheme.textMuted)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Trust Score Card
    var trustScoreCard: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(HalfisiesTheme.secondary)
                
                Text("Trust Score")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.trustScore)%")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.secondary)
                
                Text(trustLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(HalfisiesTheme.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(HalfisiesTheme.secondary.opacity(0.12))
                    .cornerRadius(HalfisiesTheme.cornerSmall)
            }
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(HalfisiesTheme.border)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(HalfisiesTheme.secondary)
                        .frame(width: geo.size.width * CGFloat(viewModel.trustScore) / 100, height: 8)
                }
            }
            .frame(height: 8)
            
            // Verification items
            VStack(spacing: 10) {
                VerificationRow(
                    icon: "envelope.fill",
                    text: "Email verified",
                    isVerified: authViewModel.currentUser?.verifiedEmail ?? false
                )
                VerificationRow(
                    icon: "phone.fill",
                    text: "Phone verified",
                    isVerified: authViewModel.currentUser?.verifiedPhone ?? false
                )
                VerificationRow(
                    icon: "person.text.rectangle",
                    text: "ID verified",
                    isVerified: authViewModel.currentUser?.verifiedID ?? false
                )
            }
        }
        .cozyCard()
        .padding(.horizontal, 20)
    }
    
    var trustLabel: String {
        switch viewModel.trustScore {
        case 0..<50: return "New"
        case 50..<70: return "Verified"
        case 70..<90: return "Trusted"
        default: return "Super Trusted"
        }
    }
    
    // MARK: - Savings Card
    var savingsCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text("Total Saved")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Text("$\(String(format: "%.0f", viewModel.lifetimeSavings))")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Monthly")
                    .font(.system(size: 11))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                Text("$\(String(format: "%.2f", viewModel.totalMonthlySavings))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
            }
        }
        .padding(16)
        .background(HalfisiesTheme.secondary.opacity(0.08))
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .overlay(
            RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                .stroke(HalfisiesTheme.secondary.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Stats Section
    var statsSection: some View {
        HStack(spacing: 12) {
            CozyStatCard(
                title: "Listings",
                value: "\(viewModel.myListings.count)",
                icon: "rectangle.stack.fill",
                color: HalfisiesTheme.primary
            )
            
            CozyStatCard(
                title: "Active",
                value: "\(viewModel.approvedRequestsCount)",
                icon: "checkmark.circle.fill",
                color: HalfisiesTheme.secondary
            )
            
            CozyStatCard(
                title: "Pending",
                value: "\(viewModel.pendingRequestsCount)",
                icon: "clock.fill",
                color: HalfisiesTheme.warning
            )
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tab Selector
    var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                // My Listings
                TabButton(title: "Listings", isSelected: selectedTab == 0) {
                    withAnimation(.easeInOut) { selectedTab = 0 }
                }
                
                // Active Subscriptions (joined)
                TabButton(title: "Active", badge: viewModel.approvedRequestsCount, isSelected: selectedTab == 1, badgeColor: HalfisiesTheme.secondary) {
                    withAnimation(.easeInOut) { selectedTab = 1 }
                }
                
                // Incoming Requests
                TabButton(title: "Incoming", badge: viewModel.pendingIncomingCount, isSelected: selectedTab == 2, badgeColor: HalfisiesTheme.coral) {
                    withAnimation(.easeInOut) { selectedTab = 2 }
                }
                
                // My Requests
                TabButton(title: "Requests", isSelected: selectedTab == 3) {
                    withAnimation(.easeInOut) { selectedTab = 3 }
                }
                
                // Reviews
                TabButton(title: "Reviews", badge: viewModel.myReviews.count, isSelected: selectedTab == 4, badgeColor: HalfisiesTheme.warning) {
                    withAnimation(.easeInOut) { selectedTab = 4 }
                }
            }
            .padding(4)
        }
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .padding(.horizontal, 20)
    }
    
    // MARK: - My Listings Section
    var myListingsSection: some View {
        VStack(spacing: 12) {
            if viewModel.myListings.isEmpty {
                emptyListings
            } else {
                ForEach(viewModel.myListings) { listing in
                    MyListingCard(
                        listing: listing,
                        onEdit: {
                            listingToEdit = listing
                        },
                        onDelete: {
                            Task {
                                await viewModel.deleteListing(listing)
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .sheet(item: $listingToEdit) { listing in
            EditListingView(listing: listing) { updatedListing in
                Task {
                    await viewModel.updateListing(updatedListing)
                }
            }
        }
    }
    
    var emptyListings: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.rectangle.on.rectangle")
                .font(.system(size: 32))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Text("No listings yet")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Share a subscription and start earning!")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    // MARK: - Active Subscriptions Section
    var activeSubscriptionsSection: some View {
        VStack(spacing: 12) {
            if viewModel.joinedSubscriptions.isEmpty {
                emptyActive
            } else {
                ForEach(viewModel.joinedSubscriptions) { listing in
                    ActiveSubscriptionCard(
                        listing: listing,
                        currentUser: authViewModel.currentUser,
                        hasReviewed: reviewedListings.contains(listing.id),
                        onLeave: {
                            Task {
                                await viewModel.leaveSubscription(listingId: listing.id)
                            }
                        },
                        onReview: {
                            listingToReview = listing
                        },
                        onMessage: {
                            startConversation(with: listing)
                        }
                    )
                    .task {
                        // Check if user has already reviewed this owner for this listing
                        let hasReviewed = await viewModel.hasReviewed(
                            targetUserId: listing.ownerId,
                            listingId: listing.id
                        )
                        if hasReviewed {
                            reviewedListings.insert(listing.id)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .sheet(item: $listingToReview) { listing in
            if let currentUser = authViewModel.currentUser {
                WriteReviewView(
                    listing: listing,
                    targetUserId: listing.ownerId,
                    targetUserName: listing.ownerName,
                    reviewType: .asOwner,
                    currentUser: currentUser
                ) { review in
                    Task {
                        await viewModel.submitReview(review)
                        reviewedListings.insert(listing.id)
                    }
                }
            }
        }
        .background(
            NavigationLink(
                destination: conversationToOpen.map { conv in
                    ChatView(conversation: conv, authViewModel: authViewModel)
                },
                isActive: Binding(
                    get: { conversationToOpen != nil },
                    set: { if !$0 { conversationToOpen = nil } }
                )
            ) { EmptyView() }
        )
    }
    
    private func startConversation(with listing: SubscriptionListing) {
        guard let currentUser = authViewModel.currentUser else { return }
        
        messagesViewModel.setCurrentUser(id: currentUser.id)
        
        Task {
            if let conversation = await messagesViewModel.startConversation(
                with: listing.ownerId,
                otherUserName: listing.ownerName,
                currentUser: currentUser,
                listingId: listing.id,
                serviceName: listing.service.rawValue
            ) {
                conversationToOpen = conversation
            }
        }
    }
    
    var emptyActive: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Text("No active subscriptions")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Join a subscription to start saving!")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    // MARK: - My Requests Section
    var myRequestsSection: some View {
        VStack(spacing: 12) {
            if viewModel.myRequests.isEmpty {
                emptyRequests
            } else {
                ForEach(viewModel.myRequests) { request in
                    RequestCard(request: request)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    var emptyRequests: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised")
                .font(.system(size: 32))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Text("No requests yet")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Browse subscriptions and request a seat!")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    // MARK: - Incoming Requests Section
    var incomingRequestsSection: some View {
        VStack(spacing: 12) {
            if viewModel.incomingRequests.isEmpty {
                emptyIncoming
            } else {
                ForEach(viewModel.incomingRequests) { request in
                    IncomingRequestCard(
                        request: request,
                        onApprove: {
                            Task { await viewModel.approveRequest(request) }
                        },
                        onReject: {
                            Task { await viewModel.rejectRequest(request) }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    var emptyIncoming: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Text("No incoming requests")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("When someone wants to join your subscription, you'll see it here")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    // MARK: - Reviews Section
    var reviewsSection: some View {
        VStack(spacing: 16) {
            if viewModel.myReviews.isEmpty {
                emptyReviews
            } else {
                // Reviews summary
                ReviewsSummaryCard(
                    averageRating: viewModel.averageRating,
                    reviewCount: viewModel.myReviews.count,
                    ratingDistribution: viewModel.ratingDistribution
                )
                
                // All reviews
                ForEach(viewModel.myReviews) { review in
                    ReviewCard(review: review)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    var emptyReviews: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.bubble")
                .font(.system(size: 32))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Text("No reviews yet")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Reviews from other users will appear here")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
}

// MARK: - Tab Button Helper
struct TabButton: View {
    let title: String
    var badge: Int = 0
    let isSelected: Bool
    var badgeColor: Color = HalfisiesTheme.primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : badgeColor)
                        .cornerRadius(6)
                }
            }
            .foregroundColor(isSelected ? .white : HalfisiesTheme.textMuted)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? HalfisiesTheme.primary : Color.clear)
            .cornerRadius(HalfisiesTheme.cornerSmall)
        }
    }
}

// MARK: - Verification Row
struct VerificationRow: View {
    let icon: String
    let text: String
    let isVerified: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(HalfisiesTheme.textMuted)
                .frame(width: 18)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textSecondary)
            
            Spacer()
            
            Image(systemName: isVerified ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(isVerified ? HalfisiesTheme.secondary : HalfisiesTheme.border)
        }
    }
}

// MARK: - Cozy Stat Card
struct CozyStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
    }
}

// Backward compatibility
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        CozyStatCard(title: title, value: value, icon: icon, color: color)
    }
}

// MARK: - My Listing Card
struct MyListingCard: View {
    let listing: SubscriptionListing
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(listing.service.brandColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: listing.service.icon)
                        .font(.system(size: 18))
                        .foregroundColor(listing.service.brandColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(listing.service.rawValue)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.textPrimary)
                        
                        if !listing.isActive {
                            Text("Paused")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(HalfisiesTheme.warning)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(HalfisiesTheme.warning.opacity(0.12))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text("\(listing.availableSeats)/\(listing.totalSeats) seats available")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(String(format: "%.2f", listing.monthlyRevenue))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text("/month")
                        .font(.system(size: 10))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            .padding(14)
            
            // Action buttons
            HStack(spacing: 0) {
                // Edit button
                Button(action: onEdit) {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text("Edit")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(HalfisiesTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(HalfisiesTheme.primary.opacity(0.08))
                }
                
                // Delete button
                Button(action: { showDeleteConfirmation = true }) {
                    HStack(spacing: 5) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        Text("Delete")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(HalfisiesTheme.error.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(HalfisiesTheme.error.opacity(0.08))
                }
            }
        }
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        .alert("Delete Listing?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will permanently delete this listing and all associated seat requests. This action cannot be undone.")
        }
    }
}

// MARK: - Request Card
struct RequestCard: View {
    let request: SeatRequest
    
    var statusColor: Color {
        switch request.status {
        case .pending: return HalfisiesTheme.warning
        case .approved: return HalfisiesTheme.secondary
        case .rejected: return HalfisiesTheme.error
        case .cancelled: return HalfisiesTheme.textMuted
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: request.status == .approved ? "checkmark" : 
                          request.status == .pending ? "clock" : "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(statusColor)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Seat Request")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text(request.message.isEmpty ? "No message" : request.message)
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(request.status.rawValue.capitalized)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(statusColor.opacity(0.12))
                .cornerRadius(HalfisiesTheme.cornerSmall)
        }
        .cozyCard(padding: 14)
    }
}

// MARK: - Active Subscription Card
struct ActiveSubscriptionCard: View {
    let listing: SubscriptionListing
    let currentUser: HalfisiesUser?
    let hasReviewed: Bool
    let onLeave: () -> Void
    let onReview: () -> Void
    let onMessage: () -> Void
    
    @State private var showLeaveConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(listing.service.brandColor.opacity(0.12))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: listing.service.icon)
                        .font(.system(size: 20))
                        .foregroundColor(listing.service.brandColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(listing.service.rawValue)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.textPrimary)
                        
                        Text("Active")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(HalfisiesTheme.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(HalfisiesTheme.secondary.opacity(0.12))
                            .cornerRadius(4)
                    }
                    
                    Text(listing.planName)
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                        Text("Shared by \(listing.ownerName)")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(String(format: "%.2f", listing.pricePerSeat))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text("/month")
                        .font(.system(size: 10))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            .padding(14)
            
            // Action buttons
            HStack(spacing: 0) {
                // Message button
                Button(action: onMessage) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 11))
                        Text("Message")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(HalfisiesTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(HalfisiesTheme.primary.opacity(0.08))
                }
                
                // Review button
                Button(action: onReview) {
                    HStack(spacing: 4) {
                        Image(systemName: hasReviewed ? "checkmark.circle.fill" : "star.fill")
                            .font(.system(size: 11))
                        Text(hasReviewed ? "Reviewed" : "Review")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(hasReviewed ? HalfisiesTheme.textMuted : HalfisiesTheme.warning)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(hasReviewed ? HalfisiesTheme.border.opacity(0.3) : HalfisiesTheme.warning.opacity(0.08))
                }
                .disabled(hasReviewed)
                
                // Leave button
                Button(action: { showLeaveConfirmation = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 11))
                        Text("Leave")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(HalfisiesTheme.error.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(HalfisiesTheme.error.opacity(0.08))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                .fill(HalfisiesTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                        .stroke(HalfisiesTheme.secondary.opacity(0.2), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium))
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        .alert("Leave Subscription?", isPresented: $showLeaveConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Leave", role: .destructive) {
                onLeave()
            }
        } message: {
            Text("You will lose access to this subscription. You can request to join again later if seats are available.")
        }
    }
}

// MARK: - Incoming Request Card (with approve/reject)
struct IncomingRequestCard: View {
    let request: SeatRequest
    let onApprove: () -> Void
    let onReject: () -> Void
    
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 14) {
            // Request info
            HStack(spacing: 12) {
                // Requester avatar
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(request.requesterName.prefix(1).uppercased()))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.primary)
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(request.requesterName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text("wants to join your subscription")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                // Time ago
                Text(timeAgo(from: request.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            // Message if any
            if !request.message.isEmpty {
                HStack {
                    Text("\"\(request.message)\"")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textSecondary)
                        .italic()
                        .lineLimit(2)
                    Spacer()
                }
                .padding(12)
                .background(HalfisiesTheme.appBackground)
                .cornerRadius(HalfisiesTheme.cornerSmall)
            }
            
            // Action buttons
            if request.status == .pending {
                HStack(spacing: 12) {
                    // Reject button
                    Button(action: {
                        isProcessing = true
                        onReject()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Decline")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(HalfisiesTheme.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(HalfisiesTheme.error.opacity(0.1))
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                    .disabled(isProcessing)
                    
                    // Approve button
                    Button(action: {
                        isProcessing = true
                        onApprove()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Approve")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(HalfisiesTheme.secondary)
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                    .disabled(isProcessing)
                }
            } else {
                // Already processed
                HStack {
                    Image(systemName: request.status == .approved ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(request.status == .approved ? HalfisiesTheme.secondary : HalfisiesTheme.error)
                    Text(request.status == .approved ? "Approved" : "Declined")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(request.status == .approved ? HalfisiesTheme.secondary : HalfisiesTheme.error)
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 3)
    }
    
    func timeAgo(from date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}

#Preview {
    ProfileView(authViewModel: AuthViewModel())
}
