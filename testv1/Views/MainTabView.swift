//
//  MainTabView.swift
//  Halfisies
//
//  Sleek, minimal tab bar
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var messagesViewModel = MessagesViewModel()
    @ObservedObject private var onboardingManager = OnboardingManager.shared
    @State private var selectedTab = 0
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(authViewModel: authViewModel)
                    .tag(0)
                
                NavigationStack {
                    ConversationsListView(authViewModel: authViewModel)
                }
                .tag(1)
                
                ProfileView(authViewModel: authViewModel)
                    .tag(2)
            }
            
            // Sleek tab bar
            sleekTabBar
        }
        .task {
            if let userId = authViewModel.currentUser?.id {
                messagesViewModel.setCurrentUser(id: userId)
                await messagesViewModel.fetchConversations()
            }
        }
        .onAppear {
            // Show onboarding on first launch
            if !onboardingManager.hasCompletedOnboarding {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingTutorialView {
                showOnboarding = false
            }
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
            
            SleekTabItemWithBadge(
                icon: "bubble.left.and.bubble.right",
                title: "Messages",
                isSelected: selectedTab == 1,
                badgeCount: messagesViewModel.totalUnreadCount,
                action: { selectedTab = 1 }
            )
            
            SleekTabItem(
                icon: "person",
                title: "Profile",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
        }
        .padding(.horizontal, 40)
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

// MARK: - Sleek Tab Item with Badge
struct SleekTabItemWithBadge: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var badgeCount: Int = 0
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isSelected ? "\(icon).fill" : icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                    
                    if badgeCount > 0 {
                        Text(badgeCount > 99 ? "99+" : "\(badgeCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(HalfisiesTheme.coral)
                            .cornerRadius(8)
                            .offset(x: 10, y: -6)
                    }
                }
                
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
