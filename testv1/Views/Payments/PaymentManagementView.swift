//
//  PaymentManagementView.swift
//  Halfisies
//
//  View for principals to manage incoming payments
//

import SwiftUI

struct PaymentManagementView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var payments: [PaymentRecord] = []
    @State private var isLoading = false
    @State private var selectedFilter: PaymentFilter = .all
    
    enum PaymentFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case awaiting = "Awaiting"
        case confirmed = "Confirmed"
    }
    
    var filteredPayments: [PaymentRecord] {
        switch selectedFilter {
        case .all: return payments
        case .pending: return payments.filter { $0.status == .pending || $0.status == .overdue }
        case .awaiting: return payments.filter { $0.status == .awaitingConfirmation }
        case .confirmed: return payments.filter { $0.status == .confirmed }
        }
    }
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Summary Card
                summaryCard
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                // Filter Tabs
                filterTabs
                    .padding(.vertical, 16)
                
                // Payments List
                if isLoading {
                    loadingState
                } else if filteredPayments.isEmpty {
                    emptyState
                } else {
                    paymentsList
                }
            }
        }
        .navigationTitle("Payments")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Summary Card
    var summaryCard: some View {
        HStack(spacing: 0) {
            // Pending
            SummaryItem(
                title: "Pending",
                value: "\(payments.filter { $0.status == .pending }.count)",
                color: HalfisiesTheme.warning
            )
            
            Divider()
                .frame(height: 40)
            
            // Awaiting
            SummaryItem(
                title: "Awaiting",
                value: "\(payments.filter { $0.status == .awaitingConfirmation }.count)",
                color: HalfisiesTheme.secondary
            )
            
            Divider()
                .frame(height: 40)
            
            // Confirmed
            SummaryItem(
                title: "Confirmed",
                value: "\(payments.filter { $0.status == .confirmed }.count)",
                color: Color(hex: "4ECDC4")
            )
        }
        .padding(.vertical, 16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 3)
    }
    
    // MARK: - Filter Tabs
    var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PaymentFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedFilter == filter ? .white : HalfisiesTheme.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedFilter == filter ? HalfisiesTheme.primary : HalfisiesTheme.cardBackground)
                            .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Payments List
    var paymentsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(filteredPayments) { payment in
                    IncomingPaymentCard(
                        payment: payment,
                        onConfirm: { confirmPayment(payment) },
                        onDispute: { disputePayment(payment) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Loading State
    var loadingState: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading payments...")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
            Spacer()
        }
    }
    
    // MARK: - Empty State
    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "creditcard")
                    .font(.system(size: 32))
                    .foregroundColor(HalfisiesTheme.primary)
            }
            
            Text("No payments yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Payments from co-subscribers will appear here")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - Actions
    private func confirmPayment(_ payment: PaymentRecord) {
        // Update payment status to confirmed
        if let index = payments.firstIndex(where: { $0.id == payment.id }) {
            payments[index].status = .confirmed
            payments[index].confirmedDate = Date()
        }
    }
    
    private func disputePayment(_ payment: PaymentRecord) {
        // Update payment status to disputed
        if let index = payments.firstIndex(where: { $0.id == payment.id }) {
            payments[index].status = .disputed
        }
    }
}

// MARK: - Summary Item
struct SummaryItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Incoming Payment Card
struct IncomingPaymentCard: View {
    let payment: PaymentRecord
    let onConfirm: () -> Void
    let onDispute: () -> Void
    
    @State private var showConfirmAlert = false
    
    var body: some View {
        VStack(spacing: 14) {
            // Header
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(HalfisiesTheme.secondary.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(String(payment.payerName.prefix(1)))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.secondary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(payment.payerName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: payment.status.color))
                            .frame(width: 6, height: 6)
                        
                        Text(payment.status.displayName)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: payment.status.color))
                    }
                }
                
                Spacer()
                
                Text(payment.formattedAmount)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.primary)
            }
            
            // Payment method if available
            if let method = payment.paymentMethod {
                HStack(spacing: 6) {
                    Image(systemName: method.icon)
                        .font(.system(size: 12))
                    Text("Paid via \(method.rawValue)")
                        .font(.system(size: 13))
                }
                .foregroundColor(HalfisiesTheme.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Date info
            HStack {
                if let paidDate = payment.paidDate {
                    Text("Marked paid \(paidDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                } else {
                    Text("Due \(payment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 12))
                        .foregroundColor(payment.isOverdue ? HalfisiesTheme.coral : HalfisiesTheme.textMuted)
                }
                
                Spacer()
            }
            
            // Action buttons (for awaiting confirmation)
            if payment.status == .awaitingConfirmation {
                HStack(spacing: 12) {
                    // Dispute button
                    Button(action: onDispute) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 13))
                            Text("Dispute")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(HalfisiesTheme.coral)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(HalfisiesTheme.coral.opacity(0.1))
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                    
                    // Confirm button
                    Button(action: { showConfirmAlert = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 13))
                            Text("Confirm Received")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hex: "4ECDC4"))
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                }
            }
        }
        .padding(16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        .alert("Confirm Payment?", isPresented: $showConfirmAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm") { onConfirm() }
        } message: {
            Text("Confirm that you received \(payment.formattedAmount) from \(payment.payerName)?")
        }
    }
}

#Preview {
    NavigationStack {
        PaymentManagementView(authViewModel: AuthViewModel())
    }
}
