//
//  OnboardingTutorialView.swift
//  Halfisies
//
//  First-time user tutorial walkthrough
//

import SwiftUI

// MARK: - Onboarding Manager
class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}

// MARK: - Onboarding Tutorial View
struct OnboardingTutorialView: View {
    @ObservedObject var onboardingManager = OnboardingManager.shared
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "person.2.fill",
            iconColor: Color(hex: "FF70A6"),
            title: "Share Subscriptions",
            description: "Find others to share subscription costs with. Split Netflix, Spotify, and more with verified users.",
            illustration: "share"
        ),
        OnboardingPage(
            icon: "dollarsign.circle.fill",
            iconColor: Color(hex: "70D6FF"),
            title: "Save Up to 75%",
            description: "Family plans are cheaper per person. By sharing, everyone saves money without compromising access.",
            illustration: "save"
        ),
        OnboardingPage(
            icon: "shield.fill",
            iconColor: Color(hex: "FFD670"),
            title: "Safe & Verified",
            description: "All users are verified. Our trust system helps you find reliable sharing partners.",
            illustration: "trust"
        ),
        OnboardingPage(
            icon: "bolt.fill",
            iconColor: Color(hex: "FF9770"),
            title: "Get Started",
            description: "Browse available subscriptions or list your own. Start saving today!",
            illustration: "start"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    if currentPage < pages.count - 1 {
                        Button(action: complete) {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(HalfisiesTheme.textMuted)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom section
                VStack(spacing: 24) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? HalfisiesTheme.primary : HalfisiesTheme.border)
                                .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    // Buttons
                    if currentPage < pages.count - 1 {
                        Button(action: nextPage) {
                            HStack(spacing: 8) {
                                Text("Next")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .cozyPrimaryButton()
                        .padding(.horizontal, 24)
                    } else {
                        Button(action: complete) {
                            HStack(spacing: 8) {
                                Text("Let's Go!")
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                        .cozyPrimaryButton()
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private func nextPage() {
        withAnimation(.spring()) {
            currentPage += 1
        }
    }
    
    private func complete() {
        onboardingManager.completeOnboarding()
        onComplete()
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let illustration: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Illustration
            illustrationView
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16))
                    .foregroundColor(HalfisiesTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    var illustrationView: some View {
        ZStack {
            // Background circles
            Circle()
                .fill(page.iconColor.opacity(0.1))
                .frame(width: 200, height: 200)
            
            Circle()
                .fill(page.iconColor.opacity(0.15))
                .frame(width: 150, height: 150)
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.iconColor)
                    .frame(width: 100, height: 100)
                    .shadow(color: page.iconColor.opacity(0.4), radius: 20, y: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Onboarding Feature Row
struct OnboardingFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingTutorialView(onComplete: {})
}
