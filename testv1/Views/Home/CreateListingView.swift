//
//  CreateListingView.swift
//  Halfisies
//
//  Cozy, warm, trust-first design
//

import SwiftUI

struct CreateListingView: View {
    @ObservedObject var viewModel: SubscriptionsViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool
    
    @State private var paymentInfo = PaymentInfo()
    @State private var showPaymentSetup = false
    
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
                        paymentSection
                        
                        // Error
                        if let error = viewModel.errorMessage {
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
                
                // Create button
                VStack {
                    Spacer()
                    createButton
                }
            }
            .navigationTitle("Share Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(HalfisiesTheme.primary)
                }
            }
        }
    }
    
    // MARK: - Service Selection
    var serviceSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Service")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                ForEach(SubscriptionService.popular, id: \.self) { service in
                    Button(action: { viewModel.newListingService = service }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(service.brandColor.opacity(0.12))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: service.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(service.brandColor)
                            }
                            
                            Text(service.rawValue)
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
                                    viewModel.newListingService == service 
                                        ? HalfisiesTheme.primary 
                                        : HalfisiesTheme.border,
                                    lineWidth: viewModel.newListingService == service ? 2 : 1
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
            
            TextField("e.g. Premium, Family, Bundle", text: $viewModel.newListingPlanName)
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
                            if viewModel.newListingTotalSeats > 2 {
                                viewModel.newListingTotalSeats -= 1
                                if viewModel.newListingAvailableSeats > viewModel.newListingTotalSeats - 1 {
                                    viewModel.newListingAvailableSeats = viewModel.newListingTotalSeats - 1
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
                        
                        Text("\(viewModel.newListingTotalSeats)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.textPrimary)
                            .frame(width: 32)
                        
                        Button(action: {
                            if viewModel.newListingTotalSeats < 10 {
                                viewModel.newListingTotalSeats += 1
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
                    Text("Sharing")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    HStack(spacing: 14) {
                        Button(action: {
                            if viewModel.newListingAvailableSeats > 1 {
                                viewModel.newListingAvailableSeats -= 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(HalfisiesTheme.textMuted)
                                .frame(width: 28, height: 28)
                                .background(HalfisiesTheme.border)
                                .cornerRadius(HalfisiesTheme.cornerSmall)
                        }
                        
                        Text("\(viewModel.newListingAvailableSeats)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.secondary)
                            .frame(width: 32)
                        
                        Button(action: {
                            if viewModel.newListingAvailableSeats < viewModel.newListingTotalSeats - 1 {
                                viewModel.newListingAvailableSeats += 1
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
                
                TextField("0.00", text: $viewModel.newListingPricePerSeat)
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
            if let price = Double(viewModel.newListingPricePerSeat), price > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.secondary)
                    
                    Text("Potential earnings: ")
                        .foregroundColor(HalfisiesTheme.textMuted)
                    +
                    Text("$\(String(format: "%.2f", price * Double(viewModel.newListingAvailableSeats)))/mo")
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
            
            TextEditor(text: $viewModel.newListingDescription)
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
    
    // MARK: - Payment Section
    var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Methods")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Button(action: { showPaymentSetup = true }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(HalfisiesTheme.secondary.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 18))
                            .foregroundColor(HalfisiesTheme.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(paymentInfo.acceptedMethods.isEmpty ? "Set Up Payment Methods" : "Payment Methods Configured")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(HalfisiesTheme.textPrimary)
                        
                        if paymentInfo.acceptedMethods.isEmpty {
                            Text("Tell co-subscribers how to pay you")
                                .font(.system(size: 13))
                                .foregroundColor(HalfisiesTheme.textMuted)
                        } else {
                            Text(paymentInfo.acceptedMethods.map { $0.rawValue }.joined(separator: ", "))
                                .font(.system(size: 13))
                                .foregroundColor(HalfisiesTheme.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: paymentInfo.acceptedMethods.isEmpty ? "chevron.right" : "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(paymentInfo.acceptedMethods.isEmpty ? HalfisiesTheme.textMuted : HalfisiesTheme.secondary)
                }
                .padding(14)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                        .stroke(paymentInfo.acceptedMethods.isEmpty ? HalfisiesTheme.border : HalfisiesTheme.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showPaymentSetup) {
                PaymentSetupView(paymentInfo: $paymentInfo)
            }
            
            Text("Co-subscribers will see your payment info after you approve their request")
                .font(.system(size: 12))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
    }
    
    // MARK: - Create Button
    var createButton: some View {
        VStack(spacing: 0) {
            Divider()
                .background(HalfisiesTheme.divider)
            
            Button(action: {
                Task {
                    guard let user = authViewModel.currentUser else { return }
                    let success = await viewModel.createListing(
                        ownerId: user.id,
                        ownerName: user.displayName,
                        paymentInfo: paymentInfo.acceptedMethods.isEmpty ? nil : paymentInfo
                    )
                    if success {
                        isPresented = false
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Listing")
                    }
                }
            }
            .cozyPrimaryButton()
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.7 : 1)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(HalfisiesTheme.appBackground)
        }
    }
}

#Preview {
    CreateListingView(
        viewModel: SubscriptionsViewModel(),
        authViewModel: AuthViewModel(),
        isPresented: .constant(true)
    )
}
