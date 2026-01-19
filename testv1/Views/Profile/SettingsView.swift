//
//  SettingsView.swift
//  Halfsies
//
//  Settings page with account, notifications, and legal sections
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("emailNotifications") private var emailNotifications = true
    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false
    @State private var showEditProfile = false
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Header
                    header
                        .padding(.top, 8)
                    
                    // Account Section
                    accountSection
                    
                    // Notifications Section
                    notificationsSection
                    
                    // Support Section
                    supportSection
                    
                    // Legal Section
                    legalSection
                    
                    // App Info
                    appInfoSection
                    
                    // Danger Zone
                    dangerZoneSection
                        .padding(.top, 8)
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .alert("Sign Out?", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    if let firebaseAuth = ServiceContainer.auth as? FirebaseAuthService {
                        try? await firebaseAuth.deleteAccount()
                    }
                    authViewModel.signOut()
                    dismiss()
                }
            }
        } message: {
            Text("This will permanently delete your account and all your data. This action cannot be undone.")
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(authViewModel: authViewModel)
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack(alignment: .center) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(HalfisiesTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(HalfisiesTheme.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
            }
            
            Spacer()
            
            Text("Settings")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Spacer()
            
            // Invisible spacer for centering
            Color.clear
                .frame(width: 36, height: 36)
        }
    }
    
    // MARK: - Account Section
    var accountSection: some View {
        SettingsSection(title: "Account") {
            VStack(spacing: 0) {
                // Profile Info
                SettingsRow(
                    icon: "person.fill",
                    iconColor: HalfisiesTheme.primary,
                    title: authViewModel.currentUser?.displayName ?? "User",
                    subtitle: authViewModel.currentUser?.email
                )
                
                SettingsDivider()
                
                // Edit Profile
                SettingsNavigationRow(
                    icon: "pencil",
                    iconColor: HalfisiesTheme.secondary,
                    title: "Edit Profile"
                ) {
                    showEditProfile = true
                }
            }
        }
    }
    
    // MARK: - Notifications Section
    var notificationsSection: some View {
        SettingsSection(title: "Notifications") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "bell.fill",
                    iconColor: HalfisiesTheme.coral,
                    title: "Push Notifications",
                    subtitle: "Get notified about seat requests",
                    isOn: $notificationsEnabled
                )
                
                SettingsDivider()
                
                SettingsToggleRow(
                    icon: "envelope.fill",
                    iconColor: HalfisiesTheme.secondary,
                    title: "Email Notifications",
                    subtitle: "Receive updates via email",
                    isOn: $emailNotifications
                )
            }
        }
    }
    
    // MARK: - Support Section
    var supportSection: some View {
        SettingsSection(title: "Support") {
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    icon: "questionmark.circle.fill",
                    iconColor: HalfisiesTheme.golden,
                    title: "Help Center"
                ) {
                    // Open help center
                }
                
                SettingsDivider()
                
                SettingsNavigationRow(
                    icon: "envelope.fill",
                    iconColor: HalfisiesTheme.primary,
                    title: "Contact Us"
                ) {
                    if let url = URL(string: "mailto:support@halfsies.app") {
                        UIApplication.shared.open(url)
                    }
                }
                
                SettingsDivider()
                
                SettingsNavigationRow(
                    icon: "star.fill",
                    iconColor: HalfisiesTheme.warning,
                    title: "Rate the App"
                ) {
                    // Open App Store review
                }
            }
        }
    }
    
    // MARK: - Legal Section
    var legalSection: some View {
        SettingsSection(title: "Legal") {
            VStack(spacing: 0) {
                SettingsNavigationRow(
                    icon: "doc.text.fill",
                    iconColor: HalfisiesTheme.textMuted,
                    title: "Terms of Service"
                ) {
                    if let url = URL(string: "https://halfsies.app/terms") {
                        UIApplication.shared.open(url)
                    }
                }
                
                SettingsDivider()
                
                SettingsNavigationRow(
                    icon: "hand.raised.fill",
                    iconColor: HalfisiesTheme.textMuted,
                    title: "Privacy Policy"
                ) {
                    if let url = URL(string: "https://halfsies.app/privacy") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
    
    // MARK: - App Info Section
    var appInfoSection: some View {
        SettingsSection(title: "About") {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(HalfisiesTheme.primary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    HalfsiesLogoSimple(size: 26)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Halfsies")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text("Version 1.0.0")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                Text("Made with love")
                    .font(.system(size: 12))
                    .foregroundColor(HalfisiesTheme.textMuted)
            }
        }
    }
    
    // MARK: - Danger Zone Section
    var dangerZoneSection: some View {
        VStack(spacing: 12) {
            // Sign Out Button
            Button(action: { showSignOutConfirmation = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15))
                    Text("Sign Out")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundColor(HalfisiesTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(HalfisiesTheme.primary.opacity(0.1))
                .cornerRadius(HalfisiesTheme.cornerMedium)
            }
            
            // Delete Account Button
            Button(action: { showDeleteConfirmation = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 15))
                    Text("Delete Account")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundColor(HalfisiesTheme.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(HalfisiesTheme.error.opacity(0.08))
                .cornerRadius(HalfisiesTheme.cornerMedium)
            }
        }
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 3)
        }
    }
}

// MARK: - Settings Divider
struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(HalfisiesTheme.divider)
            .frame(height: 1)
            .padding(.leading, 50)
            .padding(.vertical, 2)
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 34, height: 34)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Settings Navigation Row
struct SettingsNavigationRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(HalfisiesTheme.textMuted.opacity(0.6))
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 34, height: 34)
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(HalfisiesTheme.secondary)
                .labelsHidden()
                .scaleEffect(0.9)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    SettingsView(authViewModel: AuthViewModel())
}
