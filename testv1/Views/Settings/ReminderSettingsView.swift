//
//  ReminderSettingsView.swift
//  Halfisies
//
//  Manage subscription payment reminders
//

import SwiftUI
import UserNotifications

struct ReminderSettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var remindersEnabled = true
    @State private var reminderDaysBefore = 3
    @State private var reminderTime = Date()
    @State private var scheduledReminders: [ReminderItem] = []
    @State private var isLoading = true
    
    @AppStorage("remindersEnabled") private var savedRemindersEnabled = true
    @AppStorage("reminderDaysBefore") private var savedReminderDaysBefore = 3
    
    private let dayOptions = [1, 2, 3, 5, 7]
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Enable/Disable
                    enableSection
                    
                    if remindersEnabled {
                        // Timing Settings
                        timingSection
                        
                        // Active Reminders
                        activeRemindersSection
                    }
                    
                    // Info
                    infoSection
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
        }
        .navigationTitle("Payment Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            remindersEnabled = savedRemindersEnabled
            reminderDaysBefore = savedReminderDaysBefore
            loadScheduledReminders()
        }
    }
    
    // MARK: - Enable Section
    var enableSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("REMINDERS")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Payment Reminders")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Text("Get notified before payments are due")
                        .font(.system(size: 13))
                        .foregroundColor(HalfisiesTheme.textMuted)
                }
                
                Spacer()
                
                Toggle("", isOn: $remindersEnabled)
                    .tint(HalfisiesTheme.secondary)
                    .labelsHidden()
                    .onChange(of: remindersEnabled) { newValue in
                        savedRemindersEnabled = newValue
                        if !newValue {
                            NotificationService.shared.cancelAllPaymentReminders()
                        }
                    }
            }
            .padding(16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        }
    }
    
    // MARK: - Timing Section
    var timingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("REMINDER TIMING")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
            
            VStack(spacing: 0) {
                // Days before
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundColor(HalfisiesTheme.primary)
                        .frame(width: 24)
                    
                    Text("Remind me")
                        .font(.system(size: 15))
                        .foregroundColor(HalfisiesTheme.textPrimary)
                    
                    Spacer()
                    
                    Picker("Days before", selection: $reminderDaysBefore) {
                        ForEach(dayOptions, id: \.self) { days in
                            Text("\(days) day\(days == 1 ? "" : "s") before")
                                .tag(days)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(HalfisiesTheme.primary)
                    .onChange(of: reminderDaysBefore) { newValue in
                        savedReminderDaysBefore = newValue
                    }
                }
                .padding(16)
            }
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 6, y: 2)
        }
    }
    
    // MARK: - Active Reminders Section
    var activeRemindersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SCHEDULED REMINDERS")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textMuted)
                    .kerning(0.5)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            
            if scheduledReminders.isEmpty && !isLoading {
                HStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 24))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("No Active Reminders")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(HalfisiesTheme.textPrimary)
                        
                        Text("Reminders will appear when you join subscriptions")
                            .font(.system(size: 13))
                            .foregroundColor(HalfisiesTheme.textMuted)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
            } else {
                VStack(spacing: 8) {
                    ForEach(scheduledReminders) { reminder in
                        ReminderRow(reminder: reminder, onDelete: {
                            deleteReminder(reminder)
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Info Section
    var infoSection: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(HalfisiesTheme.secondary)
            
            Text("Reminders help you stay on top of your subscription payments. You'll receive a notification before each payment is due.")
                .font(.system(size: 13))
                .foregroundColor(HalfisiesTheme.textMuted)
                .lineSpacing(4)
        }
        .padding(16)
        .background(HalfisiesTheme.secondary.opacity(0.08))
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    // MARK: - Functions
    func loadScheduledReminders() {
        isLoading = true
        
        NotificationService.shared.getScheduledReminders { requests in
            DispatchQueue.main.async {
                self.scheduledReminders = requests.compactMap { request -> ReminderItem? in
                    guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                          let nextDate = trigger.nextTriggerDate() else {
                        return nil
                    }
                    
                    let subscriptionId = request.content.userInfo["subscriptionId"] as? String ?? ""
                    
                    return ReminderItem(
                        id: request.identifier,
                        title: request.content.title,
                        body: request.content.body,
                        nextDate: nextDate,
                        subscriptionId: subscriptionId,
                        isRecurring: trigger.repeats
                    )
                }
                .sorted { $0.nextDate < $1.nextDate }
                
                self.isLoading = false
            }
        }
    }
    
    func deleteReminder(_ reminder: ReminderItem) {
        NotificationService.shared.cancelPaymentReminder(subscriptionId: reminder.subscriptionId)
        scheduledReminders.removeAll { $0.id == reminder.id }
    }
}

// MARK: - Reminder Item Model
struct ReminderItem: Identifiable {
    let id: String
    let title: String
    let body: String
    let nextDate: Date
    let subscriptionId: String
    let isRecurring: Bool
}

// MARK: - Reminder Row
struct ReminderRow: View {
    let reminder: ReminderItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.primary.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 16))
                    .foregroundColor(HalfisiesTheme.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.body)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(formatDate(reminder.nextDate))
                        .font(.system(size: 12))
                        .foregroundColor(HalfisiesTheme.textMuted)
                    
                    if reminder.isRecurring {
                        Text("• Recurring")
                            .font(.system(size: 12))
                            .foregroundColor(HalfisiesTheme.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.error)
            }
        }
        .padding(14)
        .background(HalfisiesTheme.cardBackground)
        .cornerRadius(HalfisiesTheme.cornerMedium)
        .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ReminderSettingsView(authViewModel: AuthViewModel())
    }
}
