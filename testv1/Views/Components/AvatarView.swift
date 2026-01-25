//
//  AvatarView.swift
//  Halfisies
//
//  Reusable avatar component with loading from URL
//

import SwiftUI

struct AvatarView: View {
    let user: HalfisiesUser?
    var size: CGFloat = 50
    var showBadge: Bool = false
    
    var body: some View {
        ZStack {
            if let avatarURL = user?.avatarURL, let url = URL(string: avatarURL) {
                // Load from URL
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure:
                        initialsAvatar
                    case .empty:
                        loadingAvatar
                    @unknown default:
                        initialsAvatar
                    }
                }
            } else {
                // Fallback to initials
                initialsAvatar
            }
            
            // Trust badge
            if showBadge, let user = user, user.trustScore >= 70 {
                Circle()
                    .fill(HalfisiesTheme.secondary)
                    .frame(width: size * 0.3, height: size * 0.3)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: size * 0.15, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .offset(x: size * 0.35, y: size * 0.35)
            }
        }
    }
    
    var initialsAvatar: some View {
        Circle()
            .fill(HalfisiesTheme.primary.opacity(0.15))
            .frame(width: size, height: size)
            .overlay(
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.primary)
            )
    }
    
    var loadingAvatar: some View {
        Circle()
            .fill(HalfisiesTheme.border)
            .frame(width: size, height: size)
            .overlay(
                ProgressView()
                    .scaleEffect(size / 80)
            )
    }
    
    var initials: String {
        guard let name = user?.displayName, !name.isEmpty else {
            return "?"
        }
        return String(name.prefix(1).uppercased())
    }
}

// MARK: - Simple Avatar (Name-based)
struct SimpleAvatar: View {
    let name: String
    var size: CGFloat = 40
    var color: Color = HalfisiesTheme.primary
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.15))
            .frame(width: size, height: size)
            .overlay(
                Text(String(name.prefix(1).uppercased()))
                    .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        AvatarView(user: .mockOwner, size: 80, showBadge: true)
        AvatarView(user: nil, size: 60)
        SimpleAvatar(name: "John", size: 50)
    }
}
