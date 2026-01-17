//
//  AuthView.swift
//  Halfisies
//
//  Cozy, warm, trust-first design
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var showOnboarding = true
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            if showOnboarding {
                onboardingView
            } else {
                authFormView
            }
        }
    }
    
    // MARK: - Onboarding View
    var onboardingView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Cozy illustration
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.08))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.12))
                    .frame(width: 140, height: 140)
                
                // Friendly people sharing
                HStack(spacing: -12) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i == 1 ? HalfisiesTheme.primary : HalfisiesTheme.secondary)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
                    }
                }
            }
            .padding(.bottom, 40)
            
            // Title & Tagline
            VStack(spacing: 12) {
                Text("Halfisies")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text("Share subscriptions with\npeople you can trust")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.bottom, 36)
            
            // Value Props
            VStack(spacing: 14) {
                ValuePropRow(icon: "heart.fill", text: "Join a friendly community of sharers", color: HalfisiesTheme.primary)
                ValuePropRow(icon: "leaf.fill", text: "Save up to 75% on subscriptions", color: HalfisiesTheme.secondary)
                ValuePropRow(icon: "shield.fill", text: "Verified users & secure payments", color: HalfisiesTheme.primary)
                ValuePropRow(icon: "clock.fill", text: "No commitment, cancel anytime", color: HalfisiesTheme.secondary)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Stats
            HStack(spacing: 0) {
                OnboardingStat(value: "120+", label: "Services")
                OnboardingStat(value: "10K+", label: "Happy Users")
                OnboardingStat(value: "$2M+", label: "Saved")
            }
            .padding(.vertical, 20)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 2)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            // Get Started Button
            Button(action: { withAnimation(.easeInOut) { showOnboarding = false } }) {
                Text("Get Started")
            }
            .cozyPrimaryButton()
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Already have account
            Button(action: { 
                withAnimation(.easeInOut) { 
                    showOnboarding = false
                    isSignUp = false
                }
            }) {
                Text("Already have an account? ")
                    .foregroundColor(HalfisiesTheme.textMuted)
                +
                Text("Sign In")
                    .foregroundColor(HalfisiesTheme.primary)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 15))
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Auth Form View
    var authFormView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                // Back button
                HStack {
                    Button(action: { withAnimation(.easeInOut) { showOnboarding = true } }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(HalfisiesTheme.textSecondary)
                            .padding(10)
                            .background(HalfisiesTheme.cardBackground)
                            .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                
                // Logo & Title
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(HalfisiesTheme.primary)
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                    .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
                    
                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text(isSignUp ? "Start saving on subscriptions" : "Sign in to continue")
                        .font(.system(size: 15))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                // Form Toggle
                HStack(spacing: 0) {
                    Button(action: { withAnimation(.easeInOut) { isSignUp = false } }) {
                        Text("Sign In")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(isSignUp ? HalfisiesTheme.textMuted : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSignUp ? Color.clear : HalfisiesTheme.primary)
                            .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                    
                    Button(action: { withAnimation(.easeInOut) { isSignUp = true } }) {
                        Text("Sign Up")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(isSignUp ? .white : HalfisiesTheme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSignUp ? HalfisiesTheme.primary : Color.clear)
                            .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                }
                .padding(4)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                
                // Form Fields
                VStack(spacing: 14) {
                    if isSignUp {
                        CozyTextField(
                            icon: "person",
                            placeholder: "Your name",
                            text: $viewModel.displayName
                        )
                    }
                    
                    CozyTextField(
                        icon: "envelope",
                        placeholder: "Email address",
                        text: $viewModel.email,
                        keyboardType: .emailAddress
                    )
                    
                    CozyTextField(
                        icon: "lock",
                        placeholder: "Password",
                        text: $viewModel.password,
                        isSecure: true
                    )
                    
                    // Error Message
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
                    
                    // Submit Button
                    Button(action: {
                        Task {
                            if isSignUp {
                                await viewModel.signUp()
                            } else {
                                await viewModel.signIn()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isSignUp ? "Create Account" : "Sign In")
                            }
                        }
                    }
                    .cozyPrimaryButton()
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.7 : 1)
                }
                
                // Divider
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(HalfisiesTheme.divider)
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.system(size: 14))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    Rectangle()
                        .fill(HalfisiesTheme.divider)
                        .frame(height: 1)
                }
                
                // Apple Sign In
                Button(action: {
                    Task { await viewModel.signInWithApple() }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18))
                        Text("Continue with Apple")
                    }
                }
                .cozySecondaryButton()
                .disabled(viewModel.isLoading)
                
                // Legal text
                Text("By continuing, you agree to our Terms of Service\nand Privacy Policy")
                    .font(.system(size: 12))
                    .foregroundColor(HalfisiesTheme.textMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Value Prop Row
struct ValuePropRow: View {
    let icon: String
    let text: String
    var color: Color = HalfisiesTheme.primary
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(HalfisiesTheme.textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Onboarding Stat
struct OnboardingStat: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.primary)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Cozy Text Field
struct CozyTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(HalfisiesTheme.textMuted)
                .frame(width: 22)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(HalfisiesTheme.textPrimary)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
            }
        }
        .padding(16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .overlay(
            RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                .stroke(HalfisiesTheme.border, lineWidth: 1)
        )
    }
}

// Keep AuthTextField for backward compatibility
struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        CozyTextField(icon: icon, placeholder: placeholder, text: $text, keyboardType: keyboardType, isSecure: isSecure)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
