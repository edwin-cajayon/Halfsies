//
//  HalfisiesApp.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

// MARK: - App Delegate for Push Notifications
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        print("[Halfsies] Firebase configured")
        
        // Setup notifications
        setupNotifications(application)
        
        return true
    }
    
    private func setupNotifications(_ application: UIApplication) {
        // Set delegates
        UNUserNotificationCenter.current().delegate = NotificationService.shared
        Messaging.messaging().delegate = NotificationService.shared
        
        // Setup notification categories
        NotificationService.shared.setupNotificationCategories()
        
        print("[Halfsies] Notifications configured")
    }
    
    // MARK: - Remote Notification Registration
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Pass device token to Firebase
        Messaging.messaging().apnsToken = deviceToken
        
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[Halfsies] APNs Token: \(tokenString)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[Halfsies] Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - Handle Remote Notifications
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("[Halfsies] Received remote notification: \(userInfo)")
        
        // Handle data message from FCM
        if let messageID = userInfo["gcm.message_id"] {
            print("[Halfsies] Message ID: \(messageID)")
        }
        
        completionHandler(.newData)
    }
}

@main
struct testv1App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
