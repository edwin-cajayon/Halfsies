//
//  ServiceContainer.swift
//  Halfisies
//
//  Service container for dependency injection
//  Toggle between mock and real Firebase services
//

import Foundation

// MARK: - App Configuration
struct AppConfig {
    /// Set to `true` to use real Firebase services
    /// Set to `false` to use mock services (for development/testing)
    static let useFirebase = false  // Change to `true` when Firebase is configured
    
    /// Set to `true` to enable debug logging
    static let debugMode = true
}

// MARK: - Service Container
class ServiceContainer {
    static let shared = ServiceContainer()
    
    private init() {}
    
    // MARK: - Auth Service
    var authService: AuthServiceProtocol {
        if AppConfig.useFirebase {
            return FirebaseAuthService.shared
        } else {
            return MockAuthService.shared
        }
    }
    
    // MARK: - Subscription Service
    var subscriptionService: SubscriptionServiceProtocol {
        if AppConfig.useFirebase {
            return FirestoreService.shared
        } else {
            return MockSubscriptionService.shared
        }
    }
    
    // MARK: - Debug Helpers
    func logDebug(_ message: String) {
        if AppConfig.debugMode {
            print("[Halfisies] \(message)")
        }
    }
}

// MARK: - Convenience Accessors
extension ServiceContainer {
    static var auth: AuthServiceProtocol {
        shared.authService
    }
    
    static var subscriptions: SubscriptionServiceProtocol {
        shared.subscriptionService
    }
}
