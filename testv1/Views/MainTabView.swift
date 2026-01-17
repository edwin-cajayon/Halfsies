//
//  MainTabView.swift
//  Halfisies
//
//  Liquid Glass design
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(authViewModel: authViewModel)
                    .tag(0)
                
                ProfileView(authViewModel: authViewModel)
                    .tag(1)
            }
            
            // Liquid Glass Tab Bar
            liquidGlassTabBar
        }
    }
    
    var liquidGlassTabBar: some View {
        HStack(spacing: 0) {
            LiquidGlassTabItem(
                icon: "house",
                title: "Home",
                isSelected: selectedTab == 0,
                action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 0 } }
            )
            
            LiquidGlassTabItem(
                icon: "person",
                title: "Profile",
                isSelected: selectedTab == 1,
                action: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedTab = 1 } }
            )
        }
        .padding(.horizontal, 40)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            ZStack {
                // Blur material
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                // Glass gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Top highlight line
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    
                    Spacer()
                }
            }
            .shadow(color: HalfisiesTheme.glassShadow, radius: 16, y: -8)
            .shadow(color: HalfisiesTheme.primary.opacity(0.05), radius: 20, y: -10)
        )
    }
}

// MARK: - Liquid Glass Tab Item
struct LiquidGlassTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    // Glass background for selected state
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        HalfisiesTheme.primary.opacity(0.15),
                                        HalfisiesTheme.primary.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(HalfisiesTheme.primary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    Image(systemName: isSelected ? "\(icon).fill" : icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 44)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Backward compatibility
struct CozyTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        LiquidGlassTabItem(icon: icon.replacingOccurrences(of: ".fill", with: ""), title: title, isSelected: isSelected, action: action)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        LiquidGlassTabItem(icon: icon.replacingOccurrences(of: ".fill", with: ""), title: title, isSelected: isSelected, action: action)
    }
}

#Preview {
    MainTabView(authViewModel: AuthViewModel())
}
