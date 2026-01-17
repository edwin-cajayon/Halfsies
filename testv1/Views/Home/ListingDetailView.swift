//
//  ListingDetailView.swift
//  Halfisies
//
//  Cozy, warm, trust-first design
//

import SwiftUI

struct ListingDetailView: View {
    let listing: SubscriptionListing
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SubscriptionsViewModel()
    @State private var requestMessage = ""
    @State private var showRequestSheet = false
    @State private var requestSent = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroCard
                    savingsBanner
                    ownerSection
                    
                    if !listing.description.isEmpty {
                        descriptionSection
                    }
                    
                    seatSection
                    priceSection
                    trustSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 12)
            }
            
            // Sticky request button
            VStack {
                Spacer()
                requestButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRequestSheet) {
            requestSheet
        }
    }
    
    // MARK: - Hero Card
    var heroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(listing.service.brandColor.opacity(0.12))
                    .frame(width: 88, height: 88)
                
                Image(systemName: listing.service.icon)
                    .font(.system(size: 38))
                    .foregroundColor(listing.service.brandColor)
            }
            
            VStack(spacing: 6) {
                Text(listing.service.rawValue)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text(listing.planName + " Plan")
                    .font(.system(size: 15))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            // Social proof
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 12))
                Text("\(listing.joinedCount) people have joined")
                    .font(.system(size: 13))
            }
            .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerLarge)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 2)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Savings Banner
    var savingsBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("You save")
                    .font(.system(size: 12))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$\(String(format: "%.2f", listing.monthlySavings))")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text("/month")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("-\(listing.savingsPercent)%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.secondary)
                
                Text("vs solo price")
                    .font(.system(size: 11))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
        }
        .padding(16)
        .background(HalfisiesTheme.secondary.opacity(0.1))
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .overlay(
            RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                .stroke(HalfisiesTheme.secondary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Owner Section
    var ownerSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                // Avatar
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(HalfisiesTheme.primary.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(String(listing.ownerName.prefix(1)))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(HalfisiesTheme.primary)
                        )
                    
                    if listing.ownerTrustScore >= 80 {
                        Circle()
                            .fill(HalfisiesTheme.cardBackground)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(HalfisiesTheme.secondary)
                            )
                            .offset(x: 4, y: 4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Shared by")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    Text(listing.ownerName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                }
                
                Spacer()
                
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.warning)
                    
                    Text(String(format: "%.1f", listing.ownerRating))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(HalfisiesTheme.warning.opacity(0.12))
                .cornerRadius(HalfisiesTheme.cornerSmall)
            }
            
            // Trust bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text("Trust Score")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    Spacer()
                    
                    Text("\(listing.ownerTrustScore)%")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text(trustLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(HalfisiesTheme.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(HalfisiesTheme.secondary.opacity(0.12))
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(HalfisiesTheme.border)
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(HalfisiesTheme.secondary)
                            .frame(width: geo.size.width * CGFloat(listing.ownerTrustScore) / 100, height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .cozyCard()
        .padding(.horizontal, 20)
    }
    
    var trustLabel: String {
        switch listing.ownerTrustScore {
        case 0..<50: return "New"
        case 50..<70: return "Verified"
        case 70..<90: return "Trusted"
        default: return "Super Trusted"
        }
    }
    
    // MARK: - Description Section
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About this listing")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Text(listing.description)
                .font(.system(size: 15))
                .foregroundColor(HalfisiesTheme.textSecondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cozyCard()
        .padding(.horizontal, 20)
    }
    
    // MARK: - Seat Section
    var seatSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Seat Availability")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            HStack(spacing: 10) {
                ForEach(0..<listing.totalSeats, id: \.self) { index in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(index < listing.occupiedSeats 
                                    ? HalfisiesTheme.secondary 
                                    : HalfisiesTheme.border)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: index < listing.occupiedSeats ? "person.fill" : "plus")
                                .font(.system(size: 16))
                                .foregroundColor(index < listing.occupiedSeats ? .white : HalfisiesTheme.textMuted)
                        }
                        
                        Text(index < listing.occupiedSeats ? "Filled" : "Open")
                            .font(.system(size: 10))
                            .foregroundColor(HalfisiesTheme.textMuted)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            // No commitment
            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.secondary)
                
                Text("No commitment • Cancel anytime")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
        }
        .cozyCard()
        .padding(.horizontal, 20)
    }
    
    // MARK: - Price Section
    var priceSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Price per seat")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", listing.pricePerSeat))/mo")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(HalfisiesTheme.textPrimary)
            }
            
            Divider()
                .background(HalfisiesTheme.divider)
            
            HStack {
                Text("Solo subscription")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", listing.service.soloPrice))/mo")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted)
                    .strikethrough()
            }
            
            Divider()
                .background(HalfisiesTheme.divider)
            
            HStack {
                Text("Your yearly savings")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                Spacer()
                
                Text("$\(String(format: "%.0f", listing.yearlySavings))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(HalfisiesTheme.secondary)
            }
        }
        .cozyCard()
        .padding(.horizontal, 20)
    }
    
    // MARK: - Trust Section
    var trustSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 22))
                    .foregroundColor(HalfisiesTheme.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Safe & Secure")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text("Payments protected, verified users only")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                TrustBadge(icon: "creditcard.fill", text: "Secure Pay")
                TrustBadge(icon: "checkmark.seal.fill", text: "Verified")
                TrustBadge(icon: "arrow.uturn.backward", text: "Refunds")
            }
        }
        .cozyCard()
        .padding(.horizontal, 20)
    }
    
    // MARK: - Request Button
    var requestButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(HalfisiesTheme.divider)
            
            Button(action: { showRequestSheet = true }) {
                HStack(spacing: 8) {
                    Image(systemName: requestSent ? "checkmark.circle.fill" : "hand.raised.fill")
                    Text(requestSent ? "Request Sent!" : "Request a Seat")
                }
            }
            .buttonStyle(CozyPrimaryButtonStyle())
            .disabled(requestSent || listing.availableSeats == 0)
            .opacity(requestSent ? 0.8 : 1)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(HalfisiesTheme.appBackground)
        }
    }
    
    // MARK: - Request Sheet
    var requestSheet: some View {
        NavigationStack {
            ZStack {
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Service card
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(listing.service.brandColor.opacity(0.12))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: listing.service.icon)
                                .font(.system(size: 20))
                                .foregroundColor(listing.service.brandColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(listing.service.rawValue)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(HalfisiesTheme.textPrimary)
                            
                            Text("$\(String(format: "%.2f", listing.pricePerSeat))/month • Save \(listing.savingsPercent)%")
                                .font(.system(size: 13))
                                .foregroundColor(HalfisiesTheme.secondary)
                        }
                        
                        Spacer()
                    }
                    .cozyCard()
                    
                    // Message field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message to owner (optional)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(HalfisiesTheme.textMuted)
                        
                        TextEditor(text: $requestMessage)
                            .foregroundColor(HalfisiesTheme.textPrimary)
                            .font(.system(size: 15))
                            .scrollContentBackground(.hidden)
                            .frame(height: 100)
                            .padding(12)
                            .background(HalfisiesTheme.cardBackground)
                            .cornerRadius(HalfisiesTheme.cornerMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                                    .stroke(HalfisiesTheme.border, lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                    
                    // Submit
                    Button(action: {
                        Task {
                            guard let user = authViewModel.currentUser else { return }
                            let success = await viewModel.requestSeat(
                                listing: listing,
                                userId: user.id,
                                userName: user.displayName,
                                message: requestMessage
                            )
                            if success {
                                requestSent = true
                                showRequestSheet = false
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send Request")
                            }
                        }
                    }
                    .cozyPrimaryButton()
                    .disabled(viewModel.isLoading)
                }
                .padding(20)
            }
            .navigationTitle("Request Seat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showRequestSheet = false
                    }
                    .foregroundColor(HalfisiesTheme.primary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Trust Badge
struct TrustBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(HalfisiesTheme.secondary)
            
            Text(text)
                .font(.system(size: 11))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// Backward compatibility
struct SecurityBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        TrustBadge(icon: icon, text: text)
    }
}

#Preview {
    NavigationStack {
        ListingDetailView(
            listing: SubscriptionListing.mockListings[0],
            authViewModel: AuthViewModel()
        )
    }
}
