//
//  SplashScreenView.swift
//  Halfisies
//
//  Animated launch screen with logo
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showTagline = false
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var circleScale: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    HalfisiesTheme.appBackground,
                    Color(hex: "FFF5F8")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated background circles
            GeometryReader { geo in
                // Top left circle
                Circle()
                    .fill(HalfisiesTheme.secondary.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .scaleEffect(circleScale)
                    .offset(x: -100, y: -80)
                
                // Top right circle
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .scaleEffect(circleScale)
                    .offset(x: geo.size.width - 60, y: 80)
                
                // Bottom circle
                Circle()
                    .fill(HalfisiesTheme.golden.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(circleScale)
                    .offset(x: geo.size.width / 2 - 100, y: geo.size.height - 150)
            }
            
            // Main content
            VStack(spacing: 24) {
                // Animated Logo
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    HalfisiesTheme.primary.opacity(0.3),
                                    HalfisiesTheme.primary.opacity(0)
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0.6 : 0.3)
                    
                    // Logo
                    HalfsiesLogoAnimated(size: 120)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
                
                // App name
                VStack(spacing: 8) {
                    Text("Halfsies")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                        .opacity(logoOpacity)
                        .scaleEffect(logoScale)
                    
                    // Tagline
                    if showTagline {
                        Text("Share more, spend less")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(HalfisiesTheme.textSecondary)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeOut(duration: 0.6)) {
                logoOpacity = 1
                logoScale = 1
                circleScale = 1
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                showTagline = true
            }
        }
    }
}

// MARK: - Animated Logo Component
struct HalfsiesLogoAnimated: View {
    let size: CGFloat
    
    @State private var leftOffset: CGFloat = -20
    @State private var rightOffset: CGFloat = 20
    @State private var showLogo = false
    
    var body: some View {
        ZStack {
            // Shadow
            Ellipse()
                .fill(Color.black.opacity(0.1))
                .frame(width: size * 0.8, height: size * 0.15)
                .offset(y: size * 0.55)
                .blur(radius: 8)
                .opacity(showLogo ? 1 : 0)
            
            // Logo halves
            HStack(spacing: 2) {
                // Left half (Pink/Coral)
                HalfCircle()
                    .fill(
                        LinearGradient(
                            colors: [HalfisiesTheme.primary, HalfisiesTheme.coral],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.48, height: size)
                    .offset(x: leftOffset)
                
                // Right half (Teal/Secondary)
                HalfCircle()
                    .fill(
                        LinearGradient(
                            colors: [HalfisiesTheme.secondary, HalfisiesTheme.secondary.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.48, height: size)
                    .rotationEffect(.degrees(180))
                    .offset(x: rightOffset)
            }
            .opacity(showLogo ? 1 : 0)
        }
        .onAppear {
            // Animate logo halves coming together
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showLogo = true
                leftOffset = 0
                rightOffset = 0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
