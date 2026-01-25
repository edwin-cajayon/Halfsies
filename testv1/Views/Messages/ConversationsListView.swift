//
//  ConversationsListView.swift
//  Halfisies
//
//  List of all conversations
//

import SwiftUI

struct ConversationsListView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = MessagesViewModel()
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.conversations.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: HalfisiesTheme.primary))
            } else if viewModel.conversations.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.conversations) { conversation in
                            NavigationLink(destination: ChatView(
                                conversation: conversation,
                                authViewModel: authViewModel
                            )) {
                                ConversationRow(
                                    conversation: conversation,
                                    currentUserId: authViewModel.currentUser?.id ?? ""
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.large)
        .task {
            if let userId = authViewModel.currentUser?.id {
                viewModel.setCurrentUser(id: userId)
                await viewModel.fetchConversations()
            }
        }
        .refreshable {
            await viewModel.fetchConversations()
        }
    }
    
    var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 48))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Text("No messages yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("Start a conversation by messaging\na subscription owner or co-subscriber")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// MARK: - Conversation Row
struct ConversationRow: View {
    let conversation: Conversation
    let currentUserId: String
    
    var otherName: String {
        conversation.otherParticipantName(currentUserId: currentUserId)
    }
    
    var unreadCount: Int {
        conversation.unreadCountFor(userId: currentUserId)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Text(String(otherName.prefix(1).uppercased()))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(HalfisiesTheme.primary)
                    )
                
                // Service badge if available
                if let serviceName = conversation.serviceName {
                    Circle()
                        .fill(HalfisiesTheme.cardBackground)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: serviceIcon(for: serviceName))
                                .font(.system(size: 10))
                                .foregroundColor(HalfisiesTheme.secondary)
                        )
                        .offset(x: 4, y: 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherName)
                        .font(.system(size: 15, weight: unreadCount > 0 ? .bold : .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    if let serviceName = conversation.serviceName {
                        Text("• \(serviceName)")
                            .font(.system(size: 12))
                            .foregroundColor(HalfisiesTheme.textMuted)
                    }
                    
                    Spacer()
                    
                    Text(timeAgo(from: conversation.lastMessageAt))
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                HStack {
                    Text(conversation.lastMessage.isEmpty ? "No messages yet" : conversation.lastMessage)
                        .font(.system(size: 14, weight: unreadCount > 0 ? .medium : .regular))
                        .foregroundColor(unreadCount > 0 ? HalfisiesTheme.textPrimary : HalfisiesTheme.textMuted)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(HalfisiesTheme.primary)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(14)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
    }
    
    func serviceIcon(for serviceName: String) -> String {
        // Map service name to icon
        switch serviceName.lowercased() {
        case "netflix": return "play.rectangle.fill"
        case "spotify": return "waveform"
        case "disney+": return "sparkles"
        case "youtube premium": return "play.circle.fill"
        default: return "app.fill"
        }
    }
    
    func timeAgo(from date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "Now" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86400 { return "\(seconds / 3600)h" }
        if seconds < 604800 { return "\(seconds / 86400)d" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}

#Preview {
    NavigationStack {
        ConversationsListView(authViewModel: AuthViewModel())
    }
}
