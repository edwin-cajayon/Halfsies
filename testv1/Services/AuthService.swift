//
//  AuthService.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation
import Combine

// MARK: - Auth Error
enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case tooManyRequests
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please enter a valid email address."
        case .invalidPassword: return "Password must be at least 6 characters."
        case .userNotFound: return "No account found with this email."
        case .emailAlreadyInUse: return "An account already exists with this email."
        case .weakPassword: return "Password is too weak. Use at least 6 characters."
        case .networkError: return "Network error. Please check your connection."
        case .tooManyRequests: return "Please wait a moment before trying again."
        case .unknown: return "Something went wrong. Please try again."
        }
    }
}

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    var currentUser: HalfisiesUser? { get }
    var isAuthenticated: Bool { get }
    var isEmailVerified: Bool { get }

    func signUp(email: String, password: String, displayName: String) async throws -> HalfisiesUser
    func signIn(email: String, password: String) async throws -> HalfisiesUser
    func signInWithApple() async throws -> HalfisiesUser
    func signOut() throws
    func sendPasswordReset(email: String) async throws
    func sendVerificationEmail() async throws
    func checkEmailVerification() async throws -> Bool
}

// MARK: - Default Implementations
extension AuthServiceProtocol {
    var isEmailVerified: Bool { true }
    func sendVerificationEmail() async throws {}
    func checkEmailVerification() async throws -> Bool { true }
}

// MARK: - Mock Auth Service
/// Mocked Firebase Auth service for MVP development
class MockAuthService: AuthServiceProtocol, ObservableObject {
    static let shared = MockAuthService()

    @Published private(set) var currentUser: HalfisiesUser?
    private var _isEmailVerified = false
    private var lastVerificationSent: Date?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    var isEmailVerified: Bool {
        _isEmailVerified
    }

    private init() {}
    
    func signUp(email: String, password: String, displayName: String) async throws -> HalfisiesUser {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Validation
        guard email.contains("@") else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        
        let user = HalfisiesUser(
            email: email,
            displayName: displayName
        )
        
        await MainActor.run {
            self.currentUser = user
        }
        
        return user
    }
    
    func signIn(email: String, password: String) async throws -> HalfisiesUser {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Validation
        guard email.contains("@") else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.invalidPassword }
        
        // Mock successful login
        let user = HalfisiesUser(
            email: email,
            displayName: email.components(separatedBy: "@").first?.capitalized ?? "User"
        )
        
        await MainActor.run {
            self.currentUser = user
        }
        
        return user
    }
    
    func signInWithApple() async throws -> HalfisiesUser {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock Apple Sign In
        let user = HalfisiesUser(
            email: "apple.user@privaterelay.appleid.com",
            displayName: "Apple User"
        )
        
        await MainActor.run {
            self.currentUser = user
        }
        
        return user
    }
    
    func signOut() throws {
        currentUser = nil
    }
    
    func sendPasswordReset(email: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Validation
        guard email.contains("@") else { throw AuthError.invalidEmail }

        // Mock successful password reset email sent
        print("[Mock] Password reset email sent to: \(email)")
    }

    func sendVerificationEmail() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000)

        guard currentUser != nil else {
            throw AuthError.userNotFound
        }

        // Rate limiting check
        if let lastSent = lastVerificationSent {
            let timeSinceLast = Date().timeIntervalSince(lastSent)
            if timeSinceLast < 60 {
                throw AuthError.tooManyRequests
            }
        }

        lastVerificationSent = Date()
        print("[Mock] Verification email sent")
    }

    func checkEmailVerification() async throws -> Bool {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        guard currentUser != nil else {
            throw AuthError.userNotFound
        }

        // In mock mode, simulate verification after 3 "checks"
        // In real app, this would check Firebase Auth
        return _isEmailVerified
    }

    // Helper for testing - simulate verification
    func simulateEmailVerified() {
        _isEmailVerified = true
        if var user = currentUser {
            user.verifiedEmail = true
            currentUser = user
        }
    }
}
