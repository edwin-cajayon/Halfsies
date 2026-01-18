//
//  AuthView.swift
//  Halfsies
//
//  Vibrant, playful, friendly design with Liquid Glass buttons
//

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var showOnboarding = true
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    HalfisiesTheme.appBackground,
                    Color(hex: "FFF5F8")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(HalfisiesTheme.secondary.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .offset(x: -80, y: -50)
                
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.1))
                    .frame(width: 150, height: 150)
                    .offset(x: geo.size.width - 60, y: 100)
                
                Circle()
                    .fill(HalfisiesTheme.golden.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .offset(x: geo.size.width - 120, y: geo.size.height - 200)
            }
            
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
            
            // App Logo
            HalfsiesLogoSimple(size: 120)
                .padding(.bottom, 36)
            
            // Title & Tagline
            VStack(spacing: 12) {
                Text("Halfsies")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text("Share subscriptions,\nsave together")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.bottom, 32)
            
            // Value Props with colorful icons
            VStack(spacing: 14) {
                ValuePropRow(icon: "sparkles", text: "Join a fun community of sharers", color: HalfisiesTheme.golden)
                ValuePropRow(icon: "heart.circle.fill", text: "Save up to 75% together", color: HalfisiesTheme.primary)
                ValuePropRow(icon: "shield.fill", text: "Verified users you can trust", color: HalfisiesTheme.secondary)
                ValuePropRow(icon: "bolt.fill", text: "No commitment, cancel anytime", color: HalfisiesTheme.coral)
            }
            .padding(.horizontal, 36)
            
            Spacer()
            
            // Colorful Stats
            HStack(spacing: 0) {
                OnboardingStat(value: "120+", label: "Services", color: HalfisiesTheme.secondary)
                OnboardingStat(value: "10K+", label: "Happy Users", color: HalfisiesTheme.primary)
                OnboardingStat(value: "$2M+", label: "Saved", color: HalfisiesTheme.golden)
            }
            .padding(.vertical, 20)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerLarge)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 16, y: 4)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            // Get Started Button (Liquid Glass)
            Button(action: { withAnimation(.spring()) { showOnboarding = false } }) {
                HStack {
                    Text("Get Started")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .cozyPrimaryButton()
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Already have account
            Button(action: { 
                withAnimation(.spring()) { 
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
                    Button(action: { withAnimation(.spring()) { showOnboarding = true } }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(HalfisiesTheme.textSecondary)
                            .padding(12)
                            .background(HalfisiesTheme.cardBackground)
                            .cornerRadius(HalfisiesTheme.cornerSmall)
                            .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                
                // Logo & Title
                VStack(spacing: 14) {
                    HalfsiesLogoSimple(size: 72)
                    
                    Text(isSignUp ? "Join the fun" : "Welcome back")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text(isSignUp ? "Create your free account" : "Sign in to continue saving")
                        .font(.system(size: 15))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                // Form Toggle
                HStack(spacing: 0) {
                    Button(action: { withAnimation(.spring()) { isSignUp = false } }) {
                        Text("Sign In")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(isSignUp ? HalfisiesTheme.textMuted : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(isSignUp ? Color.clear : HalfisiesTheme.primary)
                            .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                    
                    Button(action: { withAnimation(.spring()) { isSignUp = true } }) {
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
                .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 2)
                
                // Form Fields
                VStack(spacing: 14) {
                    if isSignUp {
                        CozyTextField(
                            icon: "person",
                            placeholder: "Your name",
                            text: $viewModel.displayName,
                            iconColor: HalfisiesTheme.coral
                        )
                    }
                    
                    CozyTextField(
                        icon: "envelope",
                        placeholder: "Email address",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        iconColor: HalfisiesTheme.secondary
                    )
                    
                    CozyTextField(
                        icon: "lock",
                        placeholder: "Password",
                        text: $viewModel.password,
                        isSecure: true,
                        iconColor: HalfisiesTheme.primary
                    )
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(error)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(HalfisiesTheme.coral)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(HalfisiesTheme.coral.opacity(0.1))
                        .cornerRadius(HalfisiesTheme.cornerSmall)
                    }
                    
                    // Submit Button (Liquid Glass)
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
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
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
                
                // Apple Sign In (Native Button)
                SignInWithAppleButton(.signIn) { request in
                    let nonce = viewModel.generateNonce()
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewModel.sha256(nonce)
                } onCompletion: { result in
                    Task {
                        await viewModel.handleAppleSignInCompletion(result: result)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(HalfisiesTheme.cornerMedium)
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
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
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
    var color: Color = HalfisiesTheme.primary
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
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
    var iconColor: Color = HalfisiesTheme.primary
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
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
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
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
