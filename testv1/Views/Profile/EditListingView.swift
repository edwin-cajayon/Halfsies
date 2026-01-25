//
//  EditListingView.swift
//  Halfisies
//
//  Edit an existing subscription listing
//

import SwiftUI

struct EditListingView: View {
    let listing: SubscriptionListing
    let onSave: (SubscriptionListing) -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Form state
    @State private var service: SubscriptionService
    @State private var planName: String
    @State private var totalSeats: Int
    @State private var availableSeats: Int
    @State private var pricePerSeat: String
    @State private var description: String
    @State private var isActive: Bool
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    init(listing: SubscriptionListing, onSave: @escaping (SubscriptionListing) -> Void) {
        self.listing = listing
        self.onSave = onSave
        
        // Initialize state with existing values
        _service = State(initialValue: listing.service)
        _planName = State(initialValue: listing.planName)
        _totalSeats = State(initialValue: listing.totalSeats)
        _availableSeats = State(initialValue: listing.availableSeats)
        _pricePerSeat = State(initialValue: String(format: "%.2f", listing.pricePerSeat))
        _description = State(initialValue: listing.description)
        _isActive = State(initialValue: listing.isActive)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        serviceSelection
                        planDetails
                        seatsConfiguration
                        pricingSection
                        descriptionSection
                        statusToggle
                        
                        // Error
                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(error)
                            }
                            .font(.system(size: 14))
                            .foregroundColor(HalfisiesTheme.error)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(HalfisiesTheme.error.opacity(0.1))
                            .cornerRadius(HalfisiesTheme.cornerSmall)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
                
                // Save button
                VStack {
                    Spacer()
                    saveButton
                }
            }
            .navigationTitle("Edit Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(HalfisiesTheme.primary)
                }
            }
            .alert("Listing Updated", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your listing has been updated successfully.")
            }
        }
    }
    
    // MARK: - Service Selection
    var serviceSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                ForEach(SubscriptionService.popular, id: \.self) { svc in
                    Button(action: { service = svc }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(svc.brandColor.opacity(0.12))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: svc.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(svc.brandColor)
                            }
                            
                            Text(svc.rawValue)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(HalfisiesTheme.textPrimary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(HalfisiesTheme.cardBackground)
                        .cornerRadius(HalfisiesTheme.cornerMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                                .stroke(
                                    service == svc
                                        ? HalfisiesTheme.primary
                                        : HalfisiesTheme.border,
                                    lineWidth: service == svc ? 2 : 1
                                )
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Plan Details
    var planDetails: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Plan Name")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            TextField("e.g. Premium, Family, Bundle", text: $planName)
                .foregroundColor(HalfisiesTheme.textPrimary)
                .padding(16)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                        .stroke(HalfisiesTheme.border, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Seats Configuration
    var seatsConfiguration: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seats")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            HStack(spacing: 12) {
                // Total Seats
                VStack(spacing: 8) {
                    Text("Total")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    HStack(spacing: 14) {
                        Button(action: {
                            if totalSeats > 2 {
                                totalSeats -= 1
                                if availableSeats > totalSeats - 1 {
                                    availableSeats = totalSeats - 1
                                }
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(HalfisiesTheme.textMuted)
                                .frame(width: 28, height: 28)
                                .background(HalfisiesTheme.border)
                                .cornerRadius(HalfisiesTheme.cornerSmall)
                        }
                        
                        Text("\(totalSeats)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.textPrimary)
                            .frame(width: 32)
                        
                        Button(action: {
                            if totalSeats < 10 {
                                totalSeats += 1
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(HalfisiesTheme.primary)
                                .cornerRadius(HalfisiesTheme.cornerSmall)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                
                // Available Seats
                VStack(spacing: 8) {
                    Text("Available")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    HStack(spacing: 14) {
                        Button(action: {
                            if availableSeats > 0 {
                                availableSeats -= 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(HalfisiesTheme.textMuted)
                                .frame(width: 28, height: 28)
                                .background(HalfisiesTheme.border)
                                .cornerRadius(HalfisiesTheme.cornerSmall)
                        }
                        
                        Text("\(availableSeats)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.secondary)
                            .frame(width: 32)
                        
                        Button(action: {
                            if availableSeats < totalSeats - 1 {
                                availableSeats += 1
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(HalfisiesTheme.secondary)
                                .cornerRadius(HalfisiesTheme.cornerSmall)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
            }
            
            // Note about occupied seats
            let occupiedSeats = listing.totalSeats - listing.availableSeats
            if occupiedSeats > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.primary)
                    
                    Text("\(occupiedSeats) seat\(occupiedSeats == 1 ? " is" : "s are") currently occupied by members.")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
        }
    }
    
    // MARK: - Pricing Section
    var pricingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price per Seat (Monthly)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            HStack {
                Text("$")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(HalfisiesTheme.primary)
                
                TextField("0.00", text: $pricePerSeat)
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .font(.system(size: 18, weight: .semibold))
                    .keyboardType(.decimalPad)
            }
            .padding(16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .overlay(
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .stroke(HalfisiesTheme.border, lineWidth: 1)
            )
            
            // Earnings preview
            if let price = Double(pricePerSeat), price > 0 {
                let occupiedSeats = totalSeats - availableSeats
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text("Current earnings: ")
                        .foregroundColor(HalfisiesTheme.textMuted)
                    +
                    Text("$\(String(format: "%.2f", price * Double(occupiedSeats)))/mo")
                        .foregroundColor(HalfisiesTheme.secondary)
                        .fontWeight(.semibold)
                }
                .font(.system(size: 13))
            }
        }
    }
    
    // MARK: - Description Section
    var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description (Optional)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            TextEditor(text: $description)
                .foregroundColor(HalfisiesTheme.textPrimary)
                .font(.system(size: 15))
                .scrollContentBackground(.hidden)
                .frame(height: 80)
                .padding(12)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                        .stroke(HalfisiesTheme.border, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Status Toggle
    var statusToggle: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Listing Status")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isActive ? "Active" : "Paused")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text(isActive ? "Your listing is visible to others" : "Your listing is hidden from search")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                Toggle("", isOn: $isActive)
                    .labelsHidden()
                    .tint(HalfisiesTheme.secondary)
            }
            .padding(16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
        }
    }
    
    // MARK: - Save Button
    var saveButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(HalfisiesTheme.divider)
            
            Button(action: saveListing) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Changes")
                    }
                }
            }
            .cozyPrimaryButton()
            .disabled(isLoading)
            .opacity(isLoading ? 0.7 : 1)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(HalfisiesTheme.appBackground)
        }
    }
    
    // MARK: - Save Logic
    private func saveListing() {
        // Validate
        guard !planName.isEmpty else {
            errorMessage = "Please enter a plan name."
            return
        }
        
        guard let price = Double(pricePerSeat), price > 0 else {
            errorMessage = "Please enter a valid price."
            return
        }
        
        // Create updated listing
        let updatedListing = SubscriptionListing(
            id: listing.id,
            ownerId: listing.ownerId,
            ownerName: listing.ownerName,
            ownerRating: listing.ownerRating,
            ownerTrustScore: listing.ownerTrustScore,
            service: service,
            planName: planName,
            totalSeats: totalSeats,
            availableSeats: availableSeats,
            pricePerSeat: price,
            description: description,
            createdAt: listing.createdAt,
            isActive: isActive,
            joinedCount: listing.joinedCount
        )
        
        isLoading = true
        errorMessage = nil
        
        onSave(updatedListing)
        showSuccessAlert = true
        isLoading = false
    }
}

#Preview {
    EditListingView(
        listing: SubscriptionListing.mockListings[0],
        onSave: { _ in }
    )
}
