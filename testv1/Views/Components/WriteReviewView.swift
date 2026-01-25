//
//  WriteReviewView.swift
//  Halfisies
//
//  Sheet for writing a review
//

import SwiftUI

struct WriteReviewView: View {
    let listing: SubscriptionListing
    let targetUserId: String
    let targetUserName: String
    let reviewType: ReviewType
    let currentUser: HalfisiesUser
    let onSubmit: (Review) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var rating: Int = 5
    @State private var comment: String = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // User being reviewed
                        userCard
                        
                        // Rating selector
                        ratingSection
                        
                        // Comment section
                        commentSection
                        
                        // Submit button
                        submitButton
                        
                        Spacer()
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Write Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(HalfisiesTheme.primary)
                }
            }
        }
    }
    
    // MARK: - User Card
    var userCard: some View {
        HStack(spacing: 14) {
            // Avatar
            Circle()
                .fill(HalfisiesTheme.primary.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(
                    Text(String(targetUserName.prefix(1).uppercased()))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Reviewing")
                    .font(.system(size: 12))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                Text(targetUserName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(listing.service.brandColor.opacity(0.12))
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: listing.service.icon)
                            .font(.system(size: 10))
                            .foregroundColor(listing.service.brandColor)
                    }
                    
                    Text(listing.service.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
    }
    
    // MARK: - Rating Section
    var ratingSection: some View {
        VStack(spacing: 16) {
            Text("How was your experience?")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            rating = star 
                        }
                    }) {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundColor(star <= rating ? HalfisiesTheme.warning : HalfisiesTheme.border)
                            .scaleEffect(star <= rating ? 1.1 : 1.0)
                    }
                }
            }
            
            Text(ratingLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ratingColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ratingColor.opacity(0.12))
                .cornerRadius(HalfisiesTheme.cornerSmall)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
    }
    
    var ratingLabel: String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Great"
        case 5: return "Excellent"
        default: return ""
        }
    }
    
    var ratingColor: Color {
        switch rating {
        case 1: return HalfisiesTheme.error
        case 2: return HalfisiesTheme.coral
        case 3: return HalfisiesTheme.warning
        case 4: return HalfisiesTheme.secondary
        case 5: return HalfisiesTheme.secondary
        default: return HalfisiesTheme.textMuted
        }
    }
    
    // MARK: - Comment Section
    var commentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Share your experience (optional)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            TextEditor(text: $comment)
                .foregroundColor(HalfisiesTheme.textPrimary)
                .font(.system(size: 15))
                .scrollContentBackground(.hidden)
                .frame(height: 120)
                .padding(12)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                        .stroke(HalfisiesTheme.border, lineWidth: 1)
                )
            
            Text("\(comment.count)/500 characters")
                .font(.system(size: 11))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
    }
    
    // MARK: - Submit Button
    var submitButton: some View {
        Button(action: submitReview) {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "paperplane.fill")
                    Text("Submit Review")
                }
            }
        }
        .cozyPrimaryButton()
        .disabled(isSubmitting)
        .opacity(isSubmitting ? 0.7 : 1)
    }
    
    // MARK: - Submit Logic
    private func submitReview() {
        isSubmitting = true
        
        let review = Review(
            reviewerId: currentUser.id,
            reviewerName: currentUser.displayName,
            targetUserId: targetUserId,
            targetUserName: targetUserName,
            listingId: listing.id,
            serviceName: listing.service.rawValue,
            rating: rating,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines),
            reviewType: reviewType
        )
        
        onSubmit(review)
        dismiss()
    }
}

#Preview {
    WriteReviewView(
        listing: SubscriptionListing.mockListings[0],
        targetUserId: "owner-1",
        targetUserName: "John D.",
        reviewType: .asOwner,
        currentUser: HalfisiesUser.mockCoSubscriber,
        onSubmit: { _ in }
    )
}
