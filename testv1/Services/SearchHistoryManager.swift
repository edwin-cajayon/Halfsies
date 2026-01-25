//
//  SearchHistoryManager.swift
//  Halfisies
//
//  Manages search history for quick access to recent searches
//

import Foundation
import SwiftUI

class SearchHistoryManager: ObservableObject {
    static let shared = SearchHistoryManager()
    
    @Published var recentSearches: [String] = []
    
    private let searchHistoryKey = "halfsies_search_history"
    private let maxHistoryCount = 10
    
    private init() {
        loadHistory()
    }
    
    // MARK: - Public Methods
    
    func addSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Remove if already exists (to move to top)
        recentSearches.removeAll { $0.lowercased() == trimmed.lowercased() }
        
        // Add to beginning
        recentSearches.insert(trimmed, at: 0)
        
        // Keep only max count
        if recentSearches.count > maxHistoryCount {
            recentSearches = Array(recentSearches.prefix(maxHistoryCount))
        }
        
        saveHistory()
    }
    
    func removeSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        saveHistory()
    }
    
    func clearHistory() {
        recentSearches.removeAll()
        saveHistory()
    }
    
    // MARK: - Persistence
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: searchHistoryKey),
           let searches = try? JSONDecoder().decode([String].self, from: data) {
            recentSearches = searches
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: searchHistoryKey)
        }
    }
}

// MARK: - Search History View Component
struct SearchHistoryView: View {
    @ObservedObject var historyManager = SearchHistoryManager.shared
    let onSelect: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Recent Searches")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textSecondary)
                
                Spacer()
                
                if !historyManager.recentSearches.isEmpty {
                    Button(action: {
                        withAnimation {
                            historyManager.clearHistory()
                        }
                    }) {
                        Text("Clear All")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(HalfisiesTheme.primary)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            if historyManager.recentSearches.isEmpty {
                // Empty state
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 24))
                            .foregroundColor(HalfisiesTheme.textMuted)
                        Text("No recent searches")
                            .font(.system(size: 13))
                            .foregroundColor(HalfisiesTheme.textMuted)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                // Search items
                VStack(spacing: 0) {
                    ForEach(historyManager.recentSearches, id: \.self) { search in
                        SearchHistoryRow(
                            query: search,
                            onSelect: {
                                onSelect(search)
                            },
                            onRemove: {
                                withAnimation {
                                    historyManager.removeSearch(search)
                                }
                            }
                        )
                        
                        if search != historyManager.recentSearches.last {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
            }
        }
    }
}

// MARK: - Search History Row
struct SearchHistoryRow: View {
    let query: String
    let onSelect: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .frame(width: 24)
            
            Button(action: onSelect) {
                Text(query)
                    .font(.system(size: 15))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .lineLimit(1)
                
                Spacer()
            }
            .buttonStyle(.plain)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(HalfisiesTheme.textMuted)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
