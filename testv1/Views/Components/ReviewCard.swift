//
//  ReviewCard.swift
//  Halfisies
//
//  Displays a single review
//

import SwiftUI

struct ReviewCard: View {
    let review: Review
    var showService: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 10) {
                // Reviewer avatar
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(review.reviewerName.prefix(1).uppercased()))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.primary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.reviewerName)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text(timeAgo(from: review.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                // Rating stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(star <= review.rating ? HalfisiesTheme.warning : HalfisiesTheme.border)
                    }
                }
            }
            
            // Service badge (optional)
            if showService {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 10))
                    Text(review.serviceName)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(HalfisiesTheme.textMuted)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(HalfisiesTheme.appBackground)
                .cornerRadius(HalfisiesTheme.cornerSmall)
            }
            
            // Comment
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textSecondary)
                    .lineSpacing(4)
            }
            
            // Review type badge
            HStack(spacing: 4) {
                Image(systemName: review.reviewType == .asOwner ? "person.badge.key.fill" : "person.fill")
                    .font(.system(size: 10))
                Text(review.reviewType == .asOwner ? "As subscription owner" : "As co-subscriber")
                    .font(.system(size: 11))
            }
            .foregroundColor(HalfisiesTheme.textMuted)
        }
        .padding(14)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
    }
    
    func timeAgo(from date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "Just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        if seconds < 604800 { return "\(seconds / 86400)d ago" }
        if seconds < 2592000 { return "\(seconds / 604800)w ago" }
        return date.formatted(.dateTime.month().year())
    }
}

// MARK: - Reviews Summary Card
struct ReviewsSummaryCard: View {
    let averageRating: Double
    let reviewCount: Int
    let ratingDistribution: [Int: Int] // rating -> count
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Average rating
                VStack(spacing: 4) {
                    Text(String(format: "%.1f", averageRating))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    HStack(spacing: 3) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(averageRating.rounded()) ? "star.fill" : "star")
                                .font(.system(size: 14))
                                .foregroundColor(star <= Int(averageRating.rounded()) ? HalfisiesTheme.warning : HalfisiesTheme.border)
                        }
                    }
                    
                    Text("\(reviewCount) reviews")
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Divider()
                    .frame(height: 80)
                
                // Rating distribution
                VStack(alignment: .leading, spacing: 4) {
                    ForEach((1...5).reversed(), id: \.self) { rating in
                        HStack(spacing: 8) {
                            Text("\(rating)")
                                .font(.system(size: 12))
                                .foregroundColor(HalfisiesTheme.textMuted)
                                .frame(width: 12)
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(HalfisiesTheme.border)
                                        .frame(height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(HalfisiesTheme.warning)
                                        .frame(width: geo.size.width * percentage(for: rating), height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
    }
    
    private func percentage(for rating: Int) -> CGFloat {
        guard reviewCount > 0 else { return 0 }
        let count = ratingDistribution[rating] ?? 0
        return CGFloat(count) / CGFloat(reviewCount)
    }
}

#Preview {
    VStack(spacing: 16) {
        ReviewCard(review: Review.mockReviews[0])
        
        ReviewsSummaryCard(
            averageRating: 4.7,
            reviewCount: 23,
            ratingDistribution: [5: 15, 4: 5, 3: 2, 2: 1, 1: 0]
        )
    }
    .padding()
    .background(HalfisiesTheme.appBackground)
}
