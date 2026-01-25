//
//  ForgotPasswordView.swift
//  Halfisies
//
//  Password reset flow
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        // Icon
                        iconSection
                        
                        // Title & Description
                        titleSection
                        
                        // Email Input
                        emailField
                        
                        // Reset Button
                        resetButton
                        
                        // Back to Sign In
                        backToSignIn
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                }
            }
        }
        .alert("Check Your Email", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("We've sent password reset instructions to \(email). Please check your inbox.")
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(HalfisiesTheme.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
    
    // MARK: - Icon Section
    var iconSection: some View {
        ZStack {
            Circle()
                .fill(HalfisiesTheme.primary.opacity(0.1))
                .frame(width: 100, height: 100)
            
            Image(systemName: "key.fill")
                .font(.system(size: 40))
                .foregroundColor(HalfisiesTheme.primary)
        }
    }
    
    // MARK: - Title Section
    var titleSection: some View {
        VStack(spacing: 12) {
            Text("Forgot Password?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("No worries! Enter your email address and we'll send you instructions to reset your password.")
                .font(.system(size: 15))
                .foregroundColor(HalfisiesTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Email Field
    var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email Address")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(HalfisiesTheme.textSecondary)
            
            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                TextField("Enter your email", text: $email)
                    .font(.system(size: 16, design: .rounded))
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .padding(16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .overlay(
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .stroke(errorMessage != nil ? HalfisiesTheme.error : HalfisiesTheme.border, lineWidth: 1)
            )
            .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
            
            // Error message
            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(error)
                        .font(.system(size: 12))
                }
                .foregroundColor(HalfisiesTheme.error)
            }
        }
    }
    
    // MARK: - Reset Button
    var resetButton: some View {
        Button(action: sendResetEmail) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 15))
                    Text("Send Reset Link")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [HalfisiesTheme.primary, HalfisiesTheme.primary.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.primary.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isLoading || email.isEmpty)
        .opacity(email.isEmpty ? 0.6 : 1)
    }
    
    // MARK: - Back to Sign In
    var backToSignIn: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 13))
                Text("Back to Sign In")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
            }
            .foregroundColor(HalfisiesTheme.textSecondary)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Actions
    private func sendResetEmail() {
        errorMessage = nil
        
        // Validate email
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        
        guard email.contains("@") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        
        isLoading = true
        
        Task {
            do {
                try await authViewModel.sendPasswordReset(email: email)
                await MainActor.run {
                    isLoading = false
                    showSuccess = true
                }
            } catch let error as AuthError {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Something went wrong. Please try again."
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView(authViewModel: AuthViewModel())
}
