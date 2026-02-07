//
//  PaymentTrackingView.swift
//  Halfisies
//
//  View for co-subscribers to track their payments
//

import SwiftUI

struct PaymentTrackingView: View {
    let payment: PaymentRecord
    let paymentInfo: PaymentInfo?
    let onMarkAsPaid: (PaymentMethod) -> Void
    
    @State private var selectedMethod: PaymentMethod?
    @State private var showPaymentMethods = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Payment Header
            paymentHeader
            
            // Status Badge
            statusBadge
            
            // Payment Details
            paymentDetails
            
            // Action Button
            if payment.status == .pending || payment.status == .overdue {
                actionButton
            }
        }
        .padding(16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 3)
        .sheet(isPresented: $showPaymentMethods) {
            PaymentMethodsSheet(
                paymentInfo: paymentInfo,
                amount: payment.amount,
                recipientName: payment.recipientName,
                onSelect: { method in
                    selectedMethod = method
                    showPaymentMethods = false
                    onMarkAsPaid(method)
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Payment Header
    var paymentHeader: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 20))
                    .foregroundColor(HalfisiesTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Payment Due")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text("To \(payment.recipientName)")
                    .font(.system(size: 13))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            Spacer()
            
            // Amount
            Text(payment.formattedAmount)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.primary)
        }
    }
    
    // MARK: - Status Badge
    var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(hex: payment.status.color))
                .frame(width: 8, height: 8)
            
            Text(payment.status.displayName)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: payment.status.color))
            
            Spacer()
            
            if payment.status == .pending || payment.status == .overdue {
                Text("Due \(payment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(size: 12))
                    .foregroundColor(payment.isOverdue ? HalfisiesTheme.coral : HalfisiesTheme.textMuted)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: payment.status.color).opacity(0.1))
        .cornerRadius(HalfisiesTheme.cornerSmall)
    }
    
    // MARK: - Payment Details
    var paymentDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let methods = paymentInfo?.acceptedMethods, !methods.isEmpty {
                Text("Accepted Payment Methods")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                HStack(spacing: 8) {
                    ForEach(methods) { method in
                        HStack(spacing: 4) {
                            Image(systemName: method.icon)
                                .font(.system(size: 12))
                            Text(method.rawValue)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: method.color))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: method.color).opacity(0.1))
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                }
            }
        }
    }
    
    // MARK: - Action Button
    var actionButton: some View {
        Button(action: { showPaymentMethods = true }) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                Text("Mark as Paid")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(HalfisiesTheme.secondary)
            .cornerRadius(HalfisiesTheme.cornerMedium)
        }
    }
}

// MARK: - Payment Methods Sheet
struct PaymentMethodsSheet: View {
    let paymentInfo: PaymentInfo?
    let amount: Double
    let recipientName: String
    let onSelect: (PaymentMethod) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Pay \(String(format: "$%.2f", amount))")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(HalfisiesTheme.textPrimary)
                            
                            Text("to \(recipientName)")
                                .font(.system(size: 16))
                                .foregroundColor(HalfisiesTheme.textMuted)
                        }
                        .padding(.top, 20)
                        
                        // Instructions
                        instructionCard
                        
                        // Payment Methods
                        if let methods = paymentInfo?.acceptedMethods, !methods.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("SELECT PAYMENT METHOD")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(HalfisiesTheme.textMuted)
                                    .kerning(0.5)
                                
                                ForEach(methods) { method in
                                    PaymentMethodRow(
                                        method: method,
                                        handle: paymentInfo?.getPaymentHandle(for: method),
                                        onSelect: { onSelect(method) }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Complete Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
        }
    }
    
    var instructionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(HalfisiesTheme.secondary)
                
                Text("How it works")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InstructionStep(number: 1, text: "Choose a payment method below")
                InstructionStep(number: 2, text: "Complete the payment externally")
                InstructionStep(number: 3, text: "Come back and confirm")
            }
        }
        .padding(16)
        .background(HalfisiesTheme.secondary.opacity(0.08))
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .padding(.horizontal, 20)
    }
}

// MARK: - Instruction Step
struct InstructionStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.secondary.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(HalfisiesTheme.secondary)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textSecondary)
        }
    }
}

// MARK: - Payment Method Row
struct PaymentMethodRow: View {
    let method: PaymentMethod
    let handle: String?
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: method.color).opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: method.icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: method.color))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    if let handle = handle, !handle.isEmpty {
                        Text(handle)
                            .font(.system(size: 13))
                            .foregroundColor(HalfisiesTheme.textMuted)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            .padding(14)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaymentTrackingView(
        payment: .mockPending,
        paymentInfo: PaymentInfo(
            acceptedMethods: [.venmo, .paypal, .cashApp],
            venmoUsername: "@john-doe",
            paypalEmail: "john@email.com",
            cashAppTag: "$johndoe"
        ),
        onMarkAsPaid: { _ in }
    )
    .padding()
    .background(HalfisiesTheme.appBackground)
}
