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
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please enter a valid email address."
        case .invalidPassword: return "Password must be at least 6 characters."
        case .userNotFound: return "No account found with this email."
        case .emailAlreadyInUse: return "An account already exists with this email."
        case .weakPassword: return "Password is too weak. Use at least 6 characters."
        case .networkError: return "Network error. Please check your connection."
        case .unknown: return "Something went wrong. Please try again."
        }
    }
}

// MARK: - Auth Service Protocol
protocol AuthServiceProtocol {
    var currentUser: HalfisiesUser? { get }
    var isAuthenticated: Bool { get }
    
    func signUp(email: String, password: String, displayName: String) async throws -> HalfisiesUser
    func signIn(email: String, password: String) async throws -> HalfisiesUser
    func signInWithApple() async throws -> HalfisiesUser
    func signOut() throws
}

// MARK: - Mock Auth Service
/// Mocked Firebase Auth service for MVP development
class MockAuthService: AuthServiceProtocol, ObservableObject {
    static let shared = MockAuthService()
    
    @Published private(set) var currentUser: HalfisiesUser?
    
    var isAuthenticated: Bool {
        currentUser != nil
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
}
