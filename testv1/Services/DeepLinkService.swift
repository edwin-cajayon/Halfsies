//
//  DeepLinkService.swift
//  Halfisies
//
//  Handles deep linking for sharing listings and referrals
//

import Foundation
import SwiftUI

// MARK: - Deep Link Types
enum DeepLinkDestination: Equatable {
    case listing(id: String)
    case profile(id: String)
    case referral(code: String)
    case conversation(id: String)
    case home
    
    var path: String {
        switch self {
        case .listing(let id): return "/listing/\(id)"
        case .profile(let id): return "/profile/\(id)"
        case .referral(let code): return "/referral/\(code)"
        case .conversation(let id): return "/chat/\(id)"
        case .home: return "/"
        }
    }
}

// MARK: - Deep Link Service
class DeepLinkService: ObservableObject {
    static let shared = DeepLinkService()
    
    // App's URL scheme - update this to match your app
    static let scheme = "halfsies"
    static let host = "app.halfsies.io"
    
    @Published var pendingDestination: DeepLinkDestination?
    @Published var showDeepLinkedListing: SubscriptionListing?
    
    private init() {}
    
    // MARK: - URL Generation
    
    /// Generate a shareable URL for a listing
    func generateListingURL(listingId: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.host
        components.path = "/listing/\(listingId)"
        return components.url
    }
    
    /// Generate a shareable URL for a referral code
    func generateReferralURL(code: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Self.host
        components.path = "/referral/\(code)"
        return components.url
    }
    
    /// Generate an app-scheme URL (for local testing)
    func generateAppSchemeURL(destination: DeepLinkDestination) -> URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = "open"
        components.path = destination.path
        return components.url
    }
    
    // MARK: - URL Parsing
    
    /// Parse an incoming URL and determine the destination
    func parseURL(_ url: URL) -> DeepLinkDestination? {
        // Handle app scheme URLs (halfsies://open/listing/123)
        if url.scheme == Self.scheme {
            return parseAppSchemeURL(url)
        }
        
        // Handle universal links (https://app.halfsies.io/listing/123)
        if url.host == Self.host || url.host == "www.\(Self.host)" {
            return parseUniversalLink(url)
        }
        
        return nil
    }
    
    private func parseAppSchemeURL(_ url: URL) -> DeepLinkDestination? {
        let path = url.path
        return parsePath(path)
    }
    
    private func parseUniversalLink(_ url: URL) -> DeepLinkDestination? {
        let path = url.path
        return parsePath(path)
    }
    
    private func parsePath(_ path: String) -> DeepLinkDestination? {
        let components = path.split(separator: "/").map(String.init)
        
        guard components.count >= 2 else { return .home }
        
        switch components[0] {
        case "listing":
            return .listing(id: components[1])
        case "profile":
            return .profile(id: components[1])
        case "referral":
            return .referral(code: components[1])
        case "chat":
            return .conversation(id: components[1])
        default:
            return .home
        }
    }
    
    // MARK: - Handle Deep Link
    
    /// Process a deep link destination
    @MainActor
    func handleDeepLink(_ destination: DeepLinkDestination) {
        pendingDestination = destination
        
        // Additional handling can be added here
        switch destination {
        case .listing(let id):
            print("[Halfsies] Deep link to listing: \(id)")
            fetchAndShowListing(id: id)
        case .referral(let code):
            print("[Halfsies] Deep link with referral: \(code)")
            ReferralService.shared.applyReferralCode(code)
        case .profile(let id):
            print("[Halfsies] Deep link to profile: \(id)")
        case .conversation(let id):
            print("[Halfsies] Deep link to conversation: \(id)")
        case .home:
            print("[Halfsies] Deep link to home")
        }
    }
    
    /// Clear pending destination after navigation
    func clearPendingDestination() {
        pendingDestination = nil
        showDeepLinkedListing = nil
    }
    
    // MARK: - Fetch Listing
    
    @MainActor
    private func fetchAndShowListing(id: String) {
        Task {
            do {
                if let listing = try await FirestoreService.shared.fetchListing(id: id) {
                    showDeepLinkedListing = listing
                }
            } catch {
                print("[Halfsies] Error fetching deep-linked listing: \(error)")
            }
        }
    }
}

// MARK: - Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Share Button for Listings
struct ShareListingButton: View {
    let listing: SubscriptionListing
    @State private var showShareSheet = false
    
    var body: some View {
        Button(action: { showShareSheet = true }) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18))
                .foregroundColor(HalfisiesTheme.textSecondary)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = DeepLinkService.shared.generateListingURL(listingId: listing.id) {
                ShareSheet(items: [
                    "Check out this \(listing.service.rawValue) subscription on Halfsies! Save money by sharing. 💰",
                    url
                ])
            }
        }
    }
}

// MARK: - Compact Share Button
struct CompactShareButton: View {
    let listing: SubscriptionListing
    @State private var showShareSheet = false
    
    var body: some View {
        Button(action: { showShareSheet = true }) {
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.cardBackground)
                    .frame(width: 32, height: 32)
                    .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
                
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textSecondary)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = DeepLinkService.shared.generateListingURL(listingId: listing.id) {
                ShareSheet(items: [
                    "Check out this \(listing.service.rawValue) subscription on Halfsies! 💰",
                    url
                ])
            }
        }
    }
}
