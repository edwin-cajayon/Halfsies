//
//  HomeView.swift
//  Halfsies
//
//  Vibrant, playful, friendly design with Liquid Glass effects
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SubscriptionsViewModel()
    @State private var showCreateListing = false
    @State private var selectedCategory: ServiceCategory?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Liquid Glass Background with gradient blobs
                LiquidGlassBackground()
                
                VStack(spacing: 0) {
                    headerView
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            welcomeBanner
                            searchBar
                            categoryPills
                            
                            if viewModel.isLoading {
                                loadingState
                            } else if viewModel.filteredListings.isEmpty {
                                emptyState
                            } else {
                                listingsSection
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .sheet(isPresented: $showCreateListing) {
                CreateListingView(
                    viewModel: viewModel,
                    authViewModel: authViewModel,
                    isPresented: $showCreateListing
                )
            }
        }
        .task {
            await viewModel.fetchListings()
        }
    }
    
    // MARK: - Header
    var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Hey there,")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                Text(authViewModel.currentUser?.displayName ?? "Friend")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
            }
            
            Spacer()
            
            // Glass share button
            Button(action: { showCreateListing = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Share")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        Capsule()
                            .fill(HalfisiesTheme.primaryGradient)
                        
                        // Glass shine
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                )
                .shadow(color: HalfisiesTheme.primary.opacity(0.4), radius: 8, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Welcome Banner (Liquid Glass)
    var welcomeBanner: some View {
        HStack(spacing: 14) {
            GlassIconBadge(icon: "sparkles", color: HalfisiesTheme.golden, size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Save up to 75% together!")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text("Join trusted sharers • No commitment")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            Spacer()
        }
        .liquidGlassCard()
        .padding(.horizontal, 20)
    }
    
    // MARK: - Search Bar (Liquid Glass)
    var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(HalfisiesTheme.textMuted)
            
            TextField("Search subscriptions...", text: $viewModel.searchText)
                .foregroundColor(HalfisiesTheme.textPrimary)
                .font(.system(size: 15))
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .fill(Color.white.opacity(0.7))
                
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: HalfisiesTheme.glassShadow, radius: 8, y: 4)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Category Pills (Liquid Glass)
    var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All button
                Button(action: { selectedCategory = nil }) {
                    Text("All")
                }
                .buttonStyle(LiquidGlassButtonStyle(color: HalfisiesTheme.primary, isSelected: selectedCategory == nil))
                
                ForEach(ServiceCategory.allCases.filter { $0 != .other }, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))
                            Text(category.rawValue)
                        }
                    }
                    .buttonStyle(LiquidGlassButtonStyle(color: HalfisiesTheme.secondary, isSelected: selectedCategory == category))
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Listings Section
    var listingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Available Now")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Spacer()
                
                Text("\(filteredByCategory.count) listings")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            .padding(.horizontal, 20)
            
            LazyVStack(spacing: 12) {
                ForEach(filteredByCategory) { listing in
                    NavigationLink(destination: ListingDetailView(listing: listing, authViewModel: authViewModel)) {
                        LiquidGlassSubscriptionCard(listing: listing)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    var filteredByCategory: [SubscriptionListing] {
        var result = viewModel.filteredListings
        if let category = selectedCategory {
            result = result.filter { $0.service.category == category }
        }
        return result
    }
    
    // MARK: - Loading State
    var loadingState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: HalfisiesTheme.primary))
                    .scaleEffect(1.2)
            }
            
            Text("Finding great deals...")
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Empty State
    var emptyState: some View {
        VStack(spacing: 16) {
            GlassIconBadge(icon: "tray", color: HalfisiesTheme.secondary, size: 80)
            
            Text("No subscriptions found")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Try adjusting your filters or\nbe the first to share!")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
            
            Button(action: { showCreateListing = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Share a Subscription")
                }
            }
            .buttonStyle(LiquidGlassButtonStyle(color: HalfisiesTheme.primary, isSelected: true))
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
    }
}

// MARK: - Liquid Glass Subscription Card
struct LiquidGlassSubscriptionCard: View {
    let listing: SubscriptionListing
    
    var body: some View {
        HStack(spacing: 14) {
            // Service Icon with glass effect
            GlassIconBadge(icon: listing.service.icon, color: listing.service.brandColor, size: 54)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(listing.service.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    // Glass trust badge
                    if listing.ownerTrustScore >= 80 {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(HalfisiesTheme.secondary)
                            .shadow(color: HalfisiesTheme.secondary.opacity(0.3), radius: 2)
                    }
                }
                
                Text("\(listing.planName) • \(listing.ownerName)")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                // Glass seats indicator
                HStack(spacing: 4) {
                    ForEach(0..<min(listing.totalSeats, 5), id: \.self) { index in
                        Circle()
                            .fill(
                                index < listing.occupiedSeats 
                                    ? HalfisiesTheme.primary 
                                    : Color.white.opacity(0.5)
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        index < listing.occupiedSeats 
                                            ? HalfisiesTheme.primary.opacity(0.5)
                                            : Color.white.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                            .frame(width: 8, height: 8)
                    }
                    
                    Text("\(listing.availableSeats) left")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(listing.availableSeats == 1 ? HalfisiesTheme.coral : HalfisiesTheme.textMuted)
                        .padding(.leading, 4)
                }
            }
            
            Spacer()
            
            // Price & Savings
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", listing.pricePerSeat))")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.primary)
                
                Text("/month")
                    .font(.system(size: 11))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                // Glass savings badge
                if listing.savingsPercent > 0 {
                    GlassDiscountBadge(percent: listing.savingsPercent)
                }
            }
        }
        .liquidGlassCard()
    }
}

// Legacy compatibility
struct CozySubscriptionCard: View {
    let listing: SubscriptionListing
    
    var body: some View {
        LiquidGlassSubscriptionCard(listing: listing)
    }
}

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    var color: Color = HalfisiesTheme.primary
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
            }
        }
        .buttonStyle(LiquidGlassButtonStyle(color: color, isSelected: isSelected))
    }
}

struct SubscriptionCard: View {
    let listing: SubscriptionListing
    
    var body: some View {
        LiquidGlassSubscriptionCard(listing: listing)
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
}
