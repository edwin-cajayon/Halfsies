//
//  FavoritesManager.swift
//  Halfisies
//
//  Manages user's favorite/bookmarked listings
//

import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteIds: Set<String> = []
    
    private let favoritesKey = "halfsies_favorites"
    
    private init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    func isFavorite(_ listingId: String) -> Bool {
        favoriteIds.contains(listingId)
    }
    
    func toggleFavorite(_ listingId: String) {
        if favoriteIds.contains(listingId) {
            favoriteIds.remove(listingId)
        } else {
            favoriteIds.insert(listingId)
        }
        saveFavorites()
    }
    
    func addFavorite(_ listingId: String) {
        favoriteIds.insert(listingId)
        saveFavorites()
    }
    
    func removeFavorite(_ listingId: String) {
        favoriteIds.remove(listingId)
        saveFavorites()
    }
    
    func clearAllFavorites() {
        favoriteIds.removeAll()
        saveFavorites()
    }
    
    // MARK: - Persistence
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteIds = ids
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteIds) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}

// MARK: - Favorite Button Component
struct FavoriteButton: View {
    let listingId: String
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    var size: CGFloat = 20
    var showBackground: Bool = true
    
    var isFavorite: Bool {
        favoritesManager.isFavorite(listingId)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesManager.toggleFavorite(listingId)
            }
        }) {
            ZStack {
                if showBackground {
                    Circle()
                        .fill(HalfisiesTheme.cardBackground)
                        .frame(width: size + 16, height: size + 16)
                        .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
                }
                
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: size, weight: .medium))
                    .foregroundColor(isFavorite ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                    .scaleEffect(isFavorite ? 1.1 : 1.0)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Favorite Button (for cards)
struct CompactFavoriteButton: View {
    let listingId: String
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    
    var isFavorite: Bool {
        favoritesManager.isFavorite(listingId)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesManager.toggleFavorite(listingId)
            }
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFavorite ? HalfisiesTheme.primary : HalfisiesTheme.textMuted)
                .padding(8)
                .background(
                    Circle()
                        .fill(HalfisiesTheme.cardBackground.opacity(0.9))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}
