//
//  HomeView.swift
//  Halfsies
//
//  Vibrant, playful, friendly design
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
                // Background
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
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
                .background(HalfisiesTheme.primaryGradient)
                .cornerRadius(HalfisiesTheme.cornerPill)
                .shadow(color: HalfisiesTheme.primary.opacity(0.3), radius: 6, y: 3)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Welcome Banner
    var welcomeBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.golden.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundColor(HalfisiesTheme.golden)
            }
            
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
        .cozyCard()
        .padding(.horizontal, 20)
    }
    
    // MARK: - Search Bar
    var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(HalfisiesTheme.textMuted)
            
            TextField("Search subscriptions...", text: $viewModel.searchText)
                .foregroundColor(HalfisiesTheme.textPrimary)
                .font(.system(size: 15))
        }
        .padding(14)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Category Pills
    var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All button
                Button(action: { selectedCategory = nil }) {
                    Text("All")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedCategory == nil ? .white : HalfisiesTheme.textSecondary)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(selectedCategory == nil ? HalfisiesTheme.primaryGradient : LinearGradient(colors: [HalfisiesTheme.cardBackground], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(HalfisiesTheme.cornerPill)
                        .shadow(color: selectedCategory == nil ? HalfisiesTheme.primary.opacity(0.3) : Color.clear, radius: 4, y: 2)
                }
                
                ForEach(ServiceCategory.allCases.filter { $0 != .other }, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))
                            Text(category.rawValue)
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(selectedCategory == category ? .white : HalfisiesTheme.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(selectedCategory == category ? HalfisiesTheme.secondary : HalfisiesTheme.cardBackground)
                        .cornerRadius(HalfisiesTheme.cornerPill)
                        .shadow(color: selectedCategory == category ? HalfisiesTheme.secondary.opacity(0.3) : HalfisiesTheme.shadowColor, radius: 4, y: 2)
                    }
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
                        CozySubscriptionCard(listing: listing)
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
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: HalfisiesTheme.primary))
                .scaleEffect(1.2)
            
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
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.secondary.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "tray")
                    .font(.system(size: 32))
                    .foregroundColor(HalfisiesTheme.secondary)
            }
            
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
            .buttonStyle(CozyPillButtonStyle(color: HalfisiesTheme.primary, isSelected: true))
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
        .padding(.horizontal, 20)
    }
}

// MARK: - Cozy Subscription Card
struct CozySubscriptionCard: View {
    let listing: SubscriptionListing
    
    var body: some View {
        HStack(spacing: 14) {
            // Service Icon
            ZStack {
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .fill(listing.service.brandColor.opacity(0.15))
                    .frame(width: 54, height: 54)
                
                Image(systemName: listing.service.icon)
                    .font(.system(size: 24))
                    .foregroundColor(listing.service.brandColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(listing.service.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    // Trust badge
                    if listing.ownerTrustScore >= 80 {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(HalfisiesTheme.secondary)
                    }
                }
                
                Text("\(listing.planName) • \(listing.ownerName)")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                // Seats indicator with colors
                HStack(spacing: 4) {
                    ForEach(0..<min(listing.totalSeats, 5), id: \.self) { index in
                        Circle()
                            .fill(index < listing.occupiedSeats ? HalfisiesTheme.primary : HalfisiesTheme.border)
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
                
                // Savings badge
                if listing.savingsPercent > 0 {
                    Text("-\(listing.savingsPercent)%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(HalfisiesTheme.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(HalfisiesTheme.secondary.opacity(0.15))
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                }
            }
        }
        .cozyCard()
    }
}

// Keep old components for backward compatibility
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
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(isSelected ? .white : HalfisiesTheme.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? color : HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerPill)
        }
    }
}

struct SubscriptionCard: View {
    let listing: SubscriptionListing
    
    var body: some View {
        CozySubscriptionCard(listing: listing)
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
}
