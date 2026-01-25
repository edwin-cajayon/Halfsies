//
//  ChatView.swift
//  Halfisies
//
//  Individual chat conversation
//

import SwiftUI

struct ChatView: View {
    let conversation: Conversation
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = MessagesViewModel()
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var currentUserId: String {
        authViewModel.currentUser?.id ?? ""
    }
    
    var otherName: String {
        conversation.otherParticipantName(currentUserId: currentUserId)
    }
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Context header if there's a listing
                if let serviceName = conversation.serviceName {
                    contextHeader(serviceName: serviceName)
                }
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(
                                    message: message,
                                    isCurrentUser: message.senderId == currentUserId
                                )
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input bar
                inputBar
            }
        }
        .navigationTitle(otherName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let userId = authViewModel.currentUser?.id {
                viewModel.setCurrentUser(id: userId)
                await viewModel.fetchMessages(conversationId: conversation.id)
            }
        }
    }
    
    // MARK: - Context Header
    func contextHeader(serviceName: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "tag.fill")
                .font(.system(size: 12))
                .foregroundColor(HalfisiesTheme.secondary)
            
            Text("Conversation about \(serviceName)")
                .font(.system(size: 13))
                .foregroundColor(HalfisiesTheme.textMuted)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(HalfisiesTheme.secondary.opacity(0.08))
    }
    
    // MARK: - Input Bar
    var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(HalfisiesTheme.divider)
            
            HStack(spacing: 12) {
                // Text field
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(HalfisiesTheme.cardBackground)
                    .cornerRadius(20)
                    .lineLimit(1...4)
                    .focused($isTextFieldFocused)
                
                // Send button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                            ? HalfisiesTheme.border 
                            : HalfisiesTheme.primary)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(HalfisiesTheme.appBackground)
        }
    }
    
    // MARK: - Send Message
    private func sendMessage() {
        let content = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty, let user = authViewModel.currentUser else { return }
        
        messageText = ""
        
        Task {
            await viewModel.sendMessage(content: content, in: conversation, from: user)
        }
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: 60) }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(isCurrentUser ? .white : HalfisiesTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isCurrentUser 
                            ? HalfisiesTheme.primary 
                            : HalfisiesTheme.cardBackground
                    )
                    .cornerRadius(18)
                    .cornerRadius(isCurrentUser ? 4 : 18, corners: isCurrentUser ? [.bottomRight] : [.bottomLeft])
                
                // Timestamp
                Text(formatTime(message.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            if !isCurrentUser { Spacer(minLength: 60) }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d, h:mm a"
        }
        
        return formatter.string(from: date)
    }
}

// Corner radius extension for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationStack {
        ChatView(
            conversation: Conversation.mockConversations[0],
            authViewModel: AuthViewModel()
        )
    }
}
