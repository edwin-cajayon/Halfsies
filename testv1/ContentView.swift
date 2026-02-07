//
//  ContentView.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var deepLinkService: DeepLinkService
    @State private var showSplash = true
    @State private var showDeepLinkedListing = false
    
    var body: some View {
        ZStack {
            // Main content
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView(authViewModel: authViewModel)
                } else {
                    AuthView()
                        .environmentObject(authViewModel)
                }
            }
            .animation(.easeInOut, value: authViewModel.isAuthenticated)
            
            // Splash screen overlay
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .environmentObject(themeManager)
        .onAppear {
            // Show splash for 2 seconds, then fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
        .onReceive(deepLinkService.$showDeepLinkedListing) { listing in
            if listing != nil {
                showDeepLinkedListing = true
            }
        }
        .sheet(isPresented: $showDeepLinkedListing, onDismiss: {
            deepLinkService.clearPendingDestination()
        }) {
            if let listing = deepLinkService.showDeepLinkedListing {
                NavigationStack {
                    ListingDetailView(listing: listing, authViewModel: authViewModel)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    showDeepLinkedListing = false
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
