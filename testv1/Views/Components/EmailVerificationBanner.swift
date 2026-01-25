//
//  EmailVerificationBanner.swift
//  Halfisies
//
//  Banner prompting users to verify their email
//

import SwiftUI

struct EmailVerificationBanner: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isResending = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        if shouldShowBanner {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(HalfisiesTheme.warning.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "envelope.badge")
                        .font(.system(size: 16))
                        .foregroundColor(HalfisiesTheme.warning)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text("Verify your email")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text("Check your inbox for a verification link")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                // Resend Button
                Button(action: resendVerification) {
                    if isResending {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if showSuccess {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(HalfisiesTheme.secondary)
                    } else {
                        Text("Resend")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(HalfisiesTheme.primary)
                    }
                }
                .disabled(isResending || showSuccess)
            }
            .padding(14)
            .background(HalfisiesTheme.warning.opacity(0.08))
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .overlay(
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .stroke(HalfisiesTheme.warning.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var shouldShowBanner: Bool {
        guard let user = authViewModel.currentUser else { return false }
        // Show if email is not verified (based on Firestore user data)
        return !user.verifiedEmail
    }
    
    private func resendVerification() {
        isResending = true
        
        Task {
            do {
                if let firebaseAuth = ServiceContainer.auth as? FirebaseAuthService {
                    try await firebaseAuth.sendVerificationEmail()
                }
                
                await MainActor.run {
                    isResending = false
                    showSuccess = true
                    
                    // Reset success state after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showSuccess = false
                    }
                }
            } catch {
                await MainActor.run {
                    isResending = false
                    errorMessage = "Failed to send verification email. Please try again."
                    showError = true
                }
            }
        }
    }
}

// MARK: - Compact Version for Profile
struct EmailVerificationCard: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var isResending = false
    @State private var showSuccess = false
    
    var body: some View {
        if !isVerified {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(HalfisiesTheme.warning)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Email not verified")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.textPrimary)
                        
                        Text("Verify to unlock all features")
                            .font(.system(size: 13))
                            .foregroundColor(HalfisiesTheme.textMuted)
                    }
                    
                    Spacer()
                }
                
                Button(action: resendVerification) {
                    HStack(spacing: 6) {
                        if isResending {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else if showSuccess {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                            Text("Sent!")
                        } else {
                            Image(systemName: "envelope")
                                .font(.system(size: 13))
                            Text("Resend Verification Email")
                        }
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(showSuccess ? HalfisiesTheme.secondary : HalfisiesTheme.warning)
                    .cornerRadius(HalfisiesTheme.cornerSmall)
                }
                .disabled(isResending || showSuccess)
            }
            .padding(16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 3)
        }
    }
    
    private var isVerified: Bool {
        authViewModel.currentUser?.verifiedEmail ?? false
    }
    
    private func resendVerification() {
        isResending = true
        
        Task {
            do {
                if let firebaseAuth = ServiceContainer.auth as? FirebaseAuthService {
                    try await firebaseAuth.sendVerificationEmail()
                }
                
                await MainActor.run {
                    isResending = false
                    showSuccess = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showSuccess = false
                    }
                }
            } catch {
                await MainActor.run {
                    isResending = false
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        EmailVerificationBanner(authViewModel: AuthViewModel())
        EmailVerificationCard(authViewModel: AuthViewModel())
    }
    .padding()
    .background(HalfisiesTheme.appBackground)
}
