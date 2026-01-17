//
//  MainTabView.swift
//  Halfisies
//
//  Sleek, minimal tab bar
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
            
            // Sleek tab bar
            sleekTabBar
        }
    }
    
    var sleekTabBar: some View {
        HStack(spacing: 0) {
            SleekTabItem(
                icon: "house",
                title: "Home",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            SleekTabItem(
                icon: "person",
                title: "Profile",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
        }
        .padding(.horizontal, 60)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            HalfisiesTheme.cardBackground
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: -2)
        )
    }
}

// MARK: - Sleek Tab Item
struct SleekTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
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
        SleekTabItem(icon: icon.replacingOccurrences(of: ".fill", with: ""), title: title, isSelected: isSelected, action: action)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        SleekTabItem(icon: icon.replacingOccurrences(of: ".fill", with: ""), title: title, isSelected: isSelected, action: action)
    }
}

#Preview {
    MainTabView(authViewModel: AuthViewModel())
}
