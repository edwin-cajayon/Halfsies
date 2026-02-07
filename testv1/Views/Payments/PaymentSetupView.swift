//
//  PaymentSetupView.swift
//  Halfisies
//
//  Setup payment methods when creating a listing
//

import SwiftUI

struct PaymentSetupView: View {
    @Binding var paymentInfo: PaymentInfo
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header Info
                        headerInfo
                        
                        // Payment Methods Selection
                        paymentMethodsSection
                        
                        // Payment Details
                        if !paymentInfo.acceptedMethods.isEmpty {
                            paymentDetailsSection
                        }
                        
                        // Additional Notes
                        notesSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Payment Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(HalfisiesTheme.primary)
                }
            }
        }
    }
    
    // MARK: - Header Info
    var headerInfo: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.secondary.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 26))
                    .foregroundColor(HalfisiesTheme.secondary)
            }
            
            Text("How will co-subscribers pay you?")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Select the payment methods you accept and provide your payment handles so users know where to send money.")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Payment Methods Section
    var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACCEPTED METHODS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            VStack(spacing: 8) {
                ForEach(PaymentMethod.allCases.filter { $0 != .other }) { method in
                    PaymentMethodToggle(
                        method: method,
                        isSelected: paymentInfo.acceptedMethods.contains(method),
                        onToggle: {
                            toggleMethod(method)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Payment Details Section
    var paymentDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PAYMENT DETAILS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            VStack(spacing: 12) {
                if paymentInfo.acceptedMethods.contains(.venmo) {
                    PaymentDetailField(
                        icon: "v.circle.fill",
                        iconColor: Color(hex: "3D95CE"),
                        label: "Venmo Username",
                        placeholder: "@username",
                        text: Binding(
                            get: { paymentInfo.venmoUsername ?? "" },
                            set: { paymentInfo.venmoUsername = $0.isEmpty ? nil : $0 }
                        )
                    )
                }
                
                if paymentInfo.acceptedMethods.contains(.paypal) {
                    PaymentDetailField(
                        icon: "p.circle.fill",
                        iconColor: Color(hex: "003087"),
                        label: "PayPal Email",
                        placeholder: "email@example.com",
                        text: Binding(
                            get: { paymentInfo.paypalEmail ?? "" },
                            set: { paymentInfo.paypalEmail = $0.isEmpty ? nil : $0 }
                        ),
                        keyboardType: .emailAddress
                    )
                }
                
                if paymentInfo.acceptedMethods.contains(.cashApp) {
                    PaymentDetailField(
                        icon: "dollarsign.circle.fill",
                        iconColor: Color(hex: "00D632"),
                        label: "Cash App Tag",
                        placeholder: "$cashtag",
                        text: Binding(
                            get: { paymentInfo.cashAppTag ?? "" },
                            set: { paymentInfo.cashAppTag = $0.isEmpty ? nil : $0 }
                        )
                    )
                }
                
                if paymentInfo.acceptedMethods.contains(.zelle) {
                    PaymentDetailField(
                        icon: "z.circle.fill",
                        iconColor: Color(hex: "6D1ED4"),
                        label: "Zelle Email or Phone",
                        placeholder: "email or phone number",
                        text: Binding(
                            get: { paymentInfo.zelleEmail ?? "" },
                            set: { paymentInfo.zelleEmail = $0.isEmpty ? nil : $0 }
                        )
                    )
                }
                
                if paymentInfo.acceptedMethods.contains(.bankTransfer) {
                    PaymentDetailField(
                        icon: "building.columns.fill",
                        iconColor: Color(hex: "1E3A5F"),
                        label: "Bank Details",
                        placeholder: "Bank name, account info, etc.",
                        text: Binding(
                            get: { paymentInfo.bankDetails ?? "" },
                            set: { paymentInfo.bankDetails = $0.isEmpty ? nil : $0 }
                        ),
                        isMultiline: true
                    )
                }
            }
        }
    }
    
    // MARK: - Notes Section
    var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ADDITIONAL NOTES (OPTIONAL)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            TextEditor(text: Binding(
                get: { paymentInfo.additionalNotes ?? "" },
                set: { paymentInfo.additionalNotes = $0.isEmpty ? nil : $0 }
            ))
            .font(.system(size: 15))
            .foregroundColor(HalfisiesTheme.textPrimary)
            .frame(minHeight: 80)
            .padding(12)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
            
            Text("Any special instructions for payment")
                .font(.system(size: 12))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
    }
    
    // MARK: - Helper
    private func toggleMethod(_ method: PaymentMethod) {
        if paymentInfo.acceptedMethods.contains(method) {
            paymentInfo.acceptedMethods.removeAll { $0 == method }
        } else {
            paymentInfo.acceptedMethods.append(method)
        }
    }
}

// MARK: - Payment Method Toggle
struct PaymentMethodToggle: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: method.color).opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: method.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: method.color))
                }
                
                // Name
                Text(method.rawValue)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Spacer()
                
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isSelected ? HalfisiesTheme.secondary : HalfisiesTheme.border, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(HalfisiesTheme.secondary)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(14)
            .background(isSelected ? HalfisiesTheme.secondary.opacity(0.05) : HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .overlay(
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .stroke(isSelected ? HalfisiesTheme.secondary.opacity(0.3) : HalfisiesTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Payment Detail Field
struct PaymentDetailField: View {
    let icon: String
    let iconColor: Color
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label with icon
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
                
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(HalfisiesTheme.textSecondary)
            }
            
            // Input field
            if isMultiline {
                TextEditor(text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .frame(minHeight: 60)
                    .padding(10)
                    .background(HalfisiesTheme.cardBackground)
                    .cornerRadius(HalfisiesTheme.cornerSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: HalfisiesTheme.cornerSmall)
                            .stroke(HalfisiesTheme.border, lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .padding(12)
                    .background(HalfisiesTheme.cardBackground)
                    .cornerRadius(HalfisiesTheme.cornerSmall)
                    .overlay(
                        RoundedRectangle(cornerRadius: HalfisiesTheme.cornerSmall)
                            .stroke(HalfisiesTheme.border, lineWidth: 1)
                    )
            }
        }
    }
}

#Preview {
    PaymentSetupView(paymentInfo: .constant(PaymentInfo(
        acceptedMethods: [.venmo, .paypal],
        venmoUsername: "@johndoe"
    )))
}
