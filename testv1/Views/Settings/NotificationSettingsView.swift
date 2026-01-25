//
//  NotificationSettingsView.swift
//  Halfisies
//
//  Notification preferences
//

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared
    @State private var pushEnabled = false
    @State private var seatRequestsEnabled = true
    @State private var messagesEnabled = true
    @State private var reviewsEnabled = true
    @State private var remindersEnabled = true
    @State private var showPermissionAlert = false
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Push notification toggle
                    pushNotificationSection
                    
                    if notificationService.hasPermission {
                        // Notification types
                        notificationTypesSection
                    }
                    
                    // Info section
                    infoSection
                }
                .padding(20)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await notificationService.checkPermissionStatus()
            pushEnabled = notificationService.hasPermission
        }
        .alert("Enable Notifications", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("To receive notifications, please enable them in Settings.")
        }
    }
    
    // MARK: - Push Notification Section
    var pushNotificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PUSH NOTIFICATIONS")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Push Notifications")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text(notificationService.hasPermission ? "Enabled" : "Disabled")
                        .font(.system(size: 13))
                        .foregroundColor(notificationService.hasPermission ? HalfisiesTheme.secondary : HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                Toggle("", isOn: $pushEnabled)
                    .labelsHidden()
                    .tint(HalfisiesTheme.secondary)
                    .onChange(of: pushEnabled) { newValue in
                        if newValue && !notificationService.hasPermission {
                            Task {
                                let granted = await notificationService.requestPermission()
                                if !granted {
                                    pushEnabled = false
                                    showPermissionAlert = true
                                }
                            }
                        }
                    }
            }
            .padding(16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        }
    }
    
    // MARK: - Notification Types Section
    var notificationTypesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NOTIFICATION TYPES")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            VStack(spacing: 0) {
                NotificationToggleRow(
                    icon: "hand.raised.fill",
                    iconColor: HalfisiesTheme.primary,
                    title: "Seat Requests",
                    subtitle: "When someone wants to join your subscription",
                    isOn: $seatRequestsEnabled
                )
                
                Divider()
                    .padding(.leading, 52)
                
                NotificationToggleRow(
                    icon: "bubble.left.fill",
                    iconColor: HalfisiesTheme.secondary,
                    title: "Messages",
                    subtitle: "New messages from other users",
                    isOn: $messagesEnabled
                )
                
                Divider()
                    .padding(.leading, 52)
                
                NotificationToggleRow(
                    icon: "star.fill",
                    iconColor: HalfisiesTheme.warning,
                    title: "Reviews",
                    subtitle: "When someone leaves you a review",
                    isOn: $reviewsEnabled
                )
                
                Divider()
                    .padding(.leading, 52)
                
                NotificationToggleRow(
                    icon: "calendar.badge.clock",
                    iconColor: HalfisiesTheme.coral,
                    title: "Reminders",
                    subtitle: "Payment and subscription reminders",
                    isOn: $remindersEnabled
                )
            }
            .padding(.vertical, 6)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        }
    }
    
    // MARK: - Info Section
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.primary)
                
                Text("About Notifications")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            Text("Stay updated with seat requests, messages, and reviews. We'll only send you important notifications to keep you informed about your subscriptions.")
                .font(.system(size: 13))
                .foregroundColor(HalfisiesTheme.textMuted)
                .lineSpacing(4)
        }
        .padding(16)
        .background(HalfisiesTheme.primary.opacity(0.06))
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
}

// MARK: - Notification Toggle Row
struct NotificationToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(HalfisiesTheme.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
