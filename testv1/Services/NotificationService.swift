//
//  NotificationService.swift
//  Halfisies
//
//  Handles push notifications and local notifications
//

import Foundation
import UserNotifications
import UIKit
import FirebaseMessaging

// MARK: - Notification Types
enum HalfisiesNotificationType: String {
    case seatRequest = "seat_request"           // Someone requested a seat
    case seatApproved = "seat_approved"         // Your request was approved
    case seatRejected = "seat_rejected"         // Your request was rejected
    case newMessage = "new_message"             // New chat message
    case newReview = "new_review"               // Someone left you a review
    case subscriptionReminder = "subscription_reminder"  // Payment reminder
    
    var title: String {
        switch self {
        case .seatRequest: return "New Seat Request"
        case .seatApproved: return "Request Approved"
        case .seatRejected: return "Request Declined"
        case .newMessage: return "New Message"
        case .newReview: return "New Review"
        case .subscriptionReminder: return "Payment Reminder"
        }
    }
    
    var icon: String {
        switch self {
        case .seatRequest: return "hand.raised.fill"
        case .seatApproved: return "checkmark.circle.fill"
        case .seatRejected: return "xmark.circle.fill"
        case .newMessage: return "bubble.left.fill"
        case .newReview: return "star.fill"
        case .subscriptionReminder: return "calendar.badge.clock"
        }
    }
}

// MARK: - Notification Service
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var hasPermission = false
    @Published var fcmToken: String?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Permission Handling
    
    /// Request notification permissions from the user
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            
            await MainActor.run {
                self.hasPermission = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
                print("[Halfsies] Notification permission granted")
            } else {
                print("[Halfsies] Notification permission denied")
            }
            
            return granted
        } catch {
            print("[Halfsies] Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Check current notification permission status
    func checkPermissionStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        await MainActor.run {
            self.hasPermission = settings.authorizationStatus == .authorized
        }
    }
    
    /// Register for remote notifications
    @MainActor
    private func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
        
        // Get FCM token
        Messaging.messaging().delegate = self
        
        do {
            let token = try await Messaging.messaging().token()
            self.fcmToken = token
            print("[Halfsies] FCM Token: \(token)")
        } catch {
            print("[Halfsies] Error getting FCM token: \(error)")
        }
    }
    
    // MARK: - Token Management
    
    /// Save FCM token to user's Firestore document
    func saveTokenToFirestore(userId: String) async {
        guard let token = fcmToken else { return }
        
        do {
            try await FirestoreService.shared.updateUserFCMToken(userId: userId, token: token)
            print("[Halfsies] Saved FCM token for user: \(userId)")
        } catch {
            print("[Halfsies] Error saving FCM token: \(error)")
        }
    }
    
    // MARK: - Local Notifications
    
    /// Schedule a local notification (for immediate feedback)
    func sendLocalNotification(
        type: HalfisiesNotificationType,
        body: String,
        data: [String: String] = [:]
    ) {
        let content = UNMutableNotificationContent()
        content.title = type.title
        content.body = body
        content.sound = .default
        content.userInfo = data
        
        // Add category for actions
        content.categoryIdentifier = type.rawValue
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Halfsies] Error sending local notification: \(error)")
            } else {
                print("[Halfsies] Local notification scheduled: \(type.title)")
            }
        }
    }
    
    /// Send notification for seat request
    func notifySeatRequest(requesterName: String, serviceName: String) {
        sendLocalNotification(
            type: .seatRequest,
            body: "\(requesterName) wants to join your \(serviceName) subscription"
        )
    }
    
    /// Send notification for approved request
    func notifySeatApproved(ownerName: String, serviceName: String) {
        sendLocalNotification(
            type: .seatApproved,
            body: "\(ownerName) approved your request to join \(serviceName)"
        )
    }
    
    /// Send notification for rejected request
    func notifySeatRejected(ownerName: String, serviceName: String) {
        sendLocalNotification(
            type: .seatRejected,
            body: "\(ownerName) declined your request to join \(serviceName)"
        )
    }
    
    /// Send notification for new message
    func notifyNewMessage(senderName: String, preview: String) {
        let truncated = preview.count > 50 ? String(preview.prefix(50)) + "..." : preview
        sendLocalNotification(
            type: .newMessage,
            body: "\(senderName): \(truncated)"
        )
    }
    
    /// Send notification for new review
    func notifyNewReview(reviewerName: String, rating: Int) {
        let stars = String(repeating: "★", count: rating)
        sendLocalNotification(
            type: .newReview,
            body: "\(reviewerName) left you a \(stars) review"
        )
    }
    
    // MARK: - Badge Management
    
    /// Update app badge count
    @MainActor
    func updateBadgeCount(_ count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    /// Clear app badge
    @MainActor
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - Notification Categories (for actions)
    
    /// Setup notification categories with actions
    func setupNotificationCategories() {
        // Seat Request actions
        let approveAction = UNNotificationAction(
            identifier: "approve_seat",
            title: "Approve",
            options: [.foreground]
        )
        let declineAction = UNNotificationAction(
            identifier: "decline_seat",
            title: "Decline",
            options: [.destructive]
        )
        let seatRequestCategory = UNNotificationCategory(
            identifier: HalfisiesNotificationType.seatRequest.rawValue,
            actions: [approveAction, declineAction],
            intentIdentifiers: []
        )
        
        // Message actions
        let replyAction = UNNotificationAction(
            identifier: "reply_message",
            title: "Reply",
            options: [.foreground]
        )
        let messageCategory = UNNotificationCategory(
            identifier: HalfisiesNotificationType.newMessage.rawValue,
            actions: [replyAction],
            intentIdentifiers: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            seatRequestCategory,
            messageCategory
        ])
        
        print("[Halfsies] Notification categories configured")
    }
}

// MARK: - Firebase Messaging Delegate
extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        DispatchQueue.main.async {
            self.fcmToken = token
        }
        
        print("[Halfsies] FCM Token refreshed: \(token)")
        
        // Note: You would save this to Firestore when the user is logged in
        // This is handled by saveTokenToFirestore()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        print("[Halfsies] Notification tapped: \(actionIdentifier)")
        print("[Halfsies] User info: \(userInfo)")
        
        // Handle notification actions
        switch actionIdentifier {
        case "approve_seat":
            // Handle approve action
            print("[Halfsies] User tapped Approve")
        case "decline_seat":
            // Handle decline action
            print("[Halfsies] User tapped Decline")
        case "reply_message":
            // Handle reply action
            print("[Halfsies] User tapped Reply")
        default:
            // Default tap - open app
            break
        }
        
        completionHandler()
    }
}
