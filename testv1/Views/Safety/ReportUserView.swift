//
//  ReportUserView.swift
//  Halfisies
//
//  Report a user interface
//

import SwiftUI

struct ReportUserView: View {
    let reportedUserId: String
    let reportedUserName: String
    let currentUser: HalfisiesUser
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedReason: ReportReason?
    @State private var details: String = ""
    @State private var shouldBlock: Bool = true
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header info
                        headerSection
                        
                        // Reason selection
                        reasonSection
                        
                        // Details
                        detailsSection
                        
                        // Block option
                        blockOptionSection
                        
                        // Submit button
                        submitButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Report User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            .alert("Report Submitted", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(shouldBlock 
                    ? "Thank you for your report. This user has been blocked and you won't see their content anymore."
                    : "Thank you for your report. We'll review it shortly.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header Section
    var headerSection: some View {
        VStack(spacing: 12) {
            // Warning icon
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.error.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(HalfisiesTheme.error)
            }
            
            Text("Report \(reportedUserName)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Help us keep Halfsies safe by reporting users who violate our community guidelines.")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Reason Section
    var reasonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why are you reporting this user?")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(ReportReason.allCases, id: \.self) { reason in
                    Button(action: { selectedReason = reason }) {
                        HStack(spacing: 14) {
                            Image(systemName: reason.icon)
                                .font(.system(size: 18))
                                .foregroundColor(selectedReason == reason ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                                .frame(width: 24)
                            
                            Text(reason.displayName)
                                .font(.system(size: 15))
                                .foregroundColor(HalfisiesTheme.textPrimary)
                            
                            Spacer()
                            
                            if selectedReason == reason {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(HalfisiesTheme.primary)
                            } else {
                                Circle()
                                    .stroke(HalfisiesTheme.border, lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                            }
                        }
                        .padding(14)
                        .background(HalfisiesTheme.cardBackground)
                        .cornerRadius(HalfisiesTheme.cornerMedium)
                        .overlay(
                            RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                                .stroke(selectedReason == reason ? HalfisiesTheme.primary : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Details Section
    var detailsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Additional details (optional)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            TextEditor(text: $details)
                .font(.system(size: 15))
                .foregroundColor(HalfisiesTheme.textPrimary)
                .frame(minHeight: 100)
                .padding(12)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                        .stroke(HalfisiesTheme.border, lineWidth: 1)
                )
                .overlay(
                    Group {
                        if details.isEmpty {
                            Text("Please provide any additional context...")
                                .font(.system(size: 15))
                                .foregroundColor(HalfisiesTheme.textMuted.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 20)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
    
    // MARK: - Block Option Section
    var blockOptionSection: some View {
        Button(action: { shouldBlock.toggle() }) {
            HStack(spacing: 14) {
                Image(systemName: shouldBlock ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundColor(shouldBlock ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Block this user")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text("They won't be able to contact you or see your listings")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
            }
            .padding(14)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Submit Button
    var submitButton: some View {
        Button(action: submitReport) {
            HStack(spacing: 8) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 15))
                    Text("Submit Report")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(selectedReason != nil ? HalfisiesTheme.error : HalfisiesTheme.textMuted.opacity(0.3))
            .cornerRadius(HalfisiesTheme.cornerMedium)
        }
        .disabled(selectedReason == nil || isSubmitting)
    }
    
    // MARK: - Submit
    func submitReport() {
        guard let reason = selectedReason else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await SafetyService.shared.reportAndBlockUser(
                    currentUser: currentUser,
                    reportedUserId: reportedUserId,
                    reportedUserName: reportedUserName,
                    reason: reason,
                    details: details,
                    shouldBlock: shouldBlock
                )
                
                await MainActor.run {
                    isSubmitting = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    ReportUserView(
        reportedUserId: "123",
        reportedUserName: "John Doe",
        currentUser: HalfisiesUser.mockOwner
    )
}
