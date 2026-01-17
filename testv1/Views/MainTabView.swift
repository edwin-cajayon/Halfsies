//
//  MainTabView.swift
//  Halfisies
//
//  Cozy, warm, trust-first design
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
            
            // Custom cozy tab bar
            cozyTabBar
        }
    }
    
    var cozyTabBar: some View {
        HStack(spacing: 0) {
            CozyTabItem(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            CozyTabItem(
                icon: "person.fill",
                title: "Profile",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
        }
        .padding(.horizontal, 32)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            HalfisiesTheme.cardBackground
                .shadow(color: HalfisiesTheme.shadowColor, radius: 12, y: -4)
        )
    }
}

// MARK: - Cozy Tab Item
struct CozyTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Backward compatibility
struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        CozyTabItem(icon: icon, title: title, isSelected: isSelected, action: action)
    }
}

#Preview {
    MainTabView(authViewModel: AuthViewModel())
}
