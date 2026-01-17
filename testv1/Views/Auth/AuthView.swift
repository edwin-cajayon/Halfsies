//
//  AuthView.swift
//  Halfsies
//
//  Vibrant, playful, friendly design with Liquid Glass effects
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var showOnboarding = true
    
    var body: some View {
        ZStack {
            // Liquid Glass Background
            LiquidGlassBackground()
            
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
            
            // Glass illustration with colorful circles
            ZStack {
                // Glass background
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 180, height: 180)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: HalfisiesTheme.glassShadow, radius: 20)
                
                // People sharing with glass effect
                HStack(spacing: -16) {
                    GlassAvatar(icon: "person.fill", color: HalfisiesTheme.secondary, size: 56)
                    GlassAvatar(icon: "heart.fill", color: HalfisiesTheme.primary, size: 64)
                        .zIndex(1)
                    GlassAvatar(icon: "person.fill", color: HalfisiesTheme.coral, size: 56)
                }
            }
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
            
            // Value Props with glass icons
            VStack(spacing: 14) {
                GlassValuePropRow(icon: "sparkles", text: "Join a fun community of sharers", color: HalfisiesTheme.golden)
                GlassValuePropRow(icon: "heart.circle.fill", text: "Save up to 75% together", color: HalfisiesTheme.primary)
                GlassValuePropRow(icon: "shield.fill", text: "Verified users you can trust", color: HalfisiesTheme.secondary)
                GlassValuePropRow(icon: "bolt.fill", text: "No commitment, cancel anytime", color: HalfisiesTheme.coral)
            }
            .padding(.horizontal, 36)
            
            Spacer()
            
            // Liquid Glass Stats Card
            HStack(spacing: 0) {
                GlassOnboardingStat(value: "120+", label: "Services", color: HalfisiesTheme.secondary)
                GlassOnboardingStat(value: "10K+", label: "Happy Users", color: HalfisiesTheme.primary)
                GlassOnboardingStat(value: "$2M+", label: "Saved", color: HalfisiesTheme.golden)
            }
            .padding(.vertical, 20)
            .liquidGlassCard(padding: 0, cornerRadius: HalfisiesTheme.cornerXLarge)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            // Glass Get Started Button
            Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showOnboarding = false } }) {
                HStack {
                    Text("Get Started")
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .liquidGlassPrimaryButton()
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            
            // Already have account
            Button(action: { 
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { 
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
                // Glass back button
                HStack {
                    Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showOnboarding = true } }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(HalfisiesTheme.textSecondary)
                            .padding(12)
                            .background(
                                ZStack {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                    
                                    Circle()
                                        .fill(Color.white.opacity(0.7))
                                    
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                }
                            )
                            .shadow(color: HalfisiesTheme.glassShadow, radius: 6, y: 2)
                    }
                    Spacer()
                }
                .padding(.top, 12)
                
                // Glass Logo & Title
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(HalfisiesTheme.primaryGradient)
                            .frame(width: 72, height: 72)
                        
                        // Glass shine
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
                    .shadow(color: HalfisiesTheme.primary.opacity(0.4), radius: 12, y: 4)
                    
                    Text(isSignUp ? "Join the fun" : "Welcome back")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text(isSignUp ? "Create your free account" : "Sign in to continue saving")
                        .font(.system(size: 15))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                // Glass Form Toggle
                HStack(spacing: 0) {
                    Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isSignUp = false } }) {
                        Text("Sign In")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(isSignUp ? HalfisiesTheme.textMuted : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    if !isSignUp {
                                        Capsule()
                                            .fill(HalfisiesTheme.primary)
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                                                    startPoint: .top,
                                                    endPoint: .center
                                                )
                                            )
                                    }
                                }
                            )
                    }
                    
                    Button(action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isSignUp = true } }) {
                        Text("Sign Up")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(isSignUp ? .white : HalfisiesTheme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                ZStack {
                                    if isSignUp {
                                        Capsule()
                                            .fill(HalfisiesTheme.primary)
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                                                    startPoint: .top,
                                                    endPoint: .center
                                                )
                                            )
                                    }
                                }
                            )
                    }
                }
                .padding(4)
                .background(
                    ZStack {
                        Capsule()
                            .fill(.ultraThinMaterial)
                        Capsule()
                            .fill(Color.white.opacity(0.6))
                        Capsule()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    }
                )
                .shadow(color: HalfisiesTheme.glassShadow, radius: 8, y: 2)
                
                // Glass Form Fields
                VStack(spacing: 14) {
                    if isSignUp {
                        GlassTextField(
                            icon: "person",
                            placeholder: "Your name",
                            text: $viewModel.displayName,
                            iconColor: HalfisiesTheme.coral
                        )
                    }
                    
                    GlassTextField(
                        icon: "envelope",
                        placeholder: "Email address",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        iconColor: HalfisiesTheme.secondary
                    )
                    
                    GlassTextField(
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
                        .background(
                            RoundedRectangle(cornerRadius: HalfisiesTheme.cornerSmall)
                                .fill(HalfisiesTheme.coral.opacity(0.1))
                        )
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
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                    }
                    .liquidGlassPrimaryButton()
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
                
                // Glass Apple Sign In
                Button(action: {
                    Task { await viewModel.signInWithApple() }
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18))
                        Text("Continue with Apple")
                    }
                }
                .liquidGlassSecondaryButton()
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

// MARK: - Glass Avatar
struct GlassAvatar: View {
    let icon: String
    var color: Color = HalfisiesTheme.primary
    var size: CGFloat = 56
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
            
            // Glass shine
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            
            // Inner highlight
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .padding(1)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .shadow(color: color.opacity(0.4), radius: 8, y: 4)
    }
}

// MARK: - Glass Value Prop Row
struct GlassValuePropRow: View {
    let icon: String
    let text: String
    var color: Color = HalfisiesTheme.primary
    
    var body: some View {
        HStack(spacing: 14) {
            GlassIconBadge(icon: icon, color: color, size: 36)
            
            Text(text)
                .font(.system(size: 15, design: .rounded))
                .foregroundColor(HalfisiesTheme.textSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Glass Onboarding Stat
struct GlassOnboardingStat: View {
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

// MARK: - Glass Text Field
struct GlassTextField: View {
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
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .fill(Color.white.opacity(0.7))
                
                RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .shadow(color: HalfisiesTheme.glassShadow, radius: 6, y: 2)
    }
}

// Legacy compatibility
struct ValuePropRow: View {
    let icon: String
    let text: String
    var color: Color = HalfisiesTheme.primary
    
    var body: some View {
        GlassValuePropRow(icon: icon, text: text, color: color)
    }
}

struct OnboardingStat: View {
    let value: String
    let label: String
    var color: Color = HalfisiesTheme.primary
    
    var body: some View {
        GlassOnboardingStat(value: value, label: label, color: color)
    }
}

struct CozyTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var iconColor: Color = HalfisiesTheme.primary
    
    var body: some View {
        GlassTextField(icon: icon, placeholder: placeholder, text: $text, keyboardType: keyboardType, isSecure: isSecure, iconColor: iconColor)
    }
}

struct AuthTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    
    var body: some View {
        GlassTextField(icon: icon, placeholder: placeholder, text: $text, keyboardType: keyboardType, isSecure: isSecure)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
