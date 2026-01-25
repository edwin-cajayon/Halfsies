//
//  AuthViewModel.swift
//  Halfsies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var currentUser: HalfisiesUser?
    
    private let authService: AuthServiceProtocol
    private var currentNonce: String?
    
    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? ServiceContainer.auth
        self.currentUser = self.authService.currentUser
        self.isAuthenticated = self.authService.isAuthenticated
    }
    
    // MARK: - Sign Up
    func signUp() async {
        guard validateSignUpInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
            currentUser = user
            isAuthenticated = true
            clearFields()
            
            // Register for notifications and save FCM token
            await registerForNotifications(userId: user.id)
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Sign In
    func signIn() async {
        guard validateSignInInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signIn(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            clearFields()
            
            // Register for notifications and save FCM token
            await registerForNotifications(userId: user.id)
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Sign In with Apple
    func signInWithApple() async {
        // This method is called when using the custom button
        // The actual flow is handled by handleAppleSignInRequest and handleAppleSignInCompletion
        isLoading = true
        errorMessage = nil
    }
    
    // Generate nonce for Apple Sign-In request
    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }
    
    // Get SHA256 hash of nonce for Apple Sign-In
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Handle Apple Sign-In completion
    func handleAppleSignInCompletion(result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                do {
                    var user: HalfisiesUser
                    
                    // Use FirebaseAuthService to handle the credential
                    if let firebaseAuth = authService as? FirebaseAuthService {
                        // Set the nonce in FirebaseAuthService
                        firebaseAuth.setCurrentNonce(currentNonce)
                        user = try await firebaseAuth.handleAppleSignIn(credential: appleIDCredential)
                    } else {
                        // Mock service - just create a mock user
                        user = try await authService.signInWithApple()
                    }
                    
                    currentUser = user
                    isAuthenticated = true
                    
                    // Register for notifications and save FCM token
                    await registerForNotifications(userId: user.id)
                } catch let error as AuthError {
                    errorMessage = error.localizedDescription
                } catch {
                    errorMessage = "Apple Sign In failed. Please try again."
                }
            }
        case .failure(let error):
            // User cancelled or error occurred
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = "Failed to sign out."
        }
    }
    
    // MARK: - Password Reset
    func sendPasswordReset(email: String) async throws {
        try await authService.sendPasswordReset(email: email)
    }
    
    // MARK: - Refresh User
    func refreshUser() async {
        guard let userId = currentUser?.id, AppConfig.useFirebase else { return }
        
        do {
            let user = try await FirestoreService.shared.fetchUser(id: userId)
            currentUser = user
        } catch {
            ServiceContainer.shared.logDebug("Failed to refresh user: \(error)")
        }
    }
    
    // MARK: - Notifications
    private func registerForNotifications(userId: String) async {
        // Request notification permission
        let granted = await NotificationService.shared.requestPermission()
        
        if granted {
            // Save FCM token to Firestore
            await NotificationService.shared.saveTokenToFirestore(userId: userId)
        }
    }
    
    // MARK: - Validation
    private func validateSignInInput() -> Bool {
        if email.isEmpty {
            errorMessage = "Please enter your email."
            return false
        }
        if !email.contains("@") {
            errorMessage = "Please enter a valid email."
            return false
        }
        if password.isEmpty {
            errorMessage = "Please enter your password."
            return false
        }
        return true
    }
    
    private func validateSignUpInput() -> Bool {
        if displayName.isEmpty {
            errorMessage = "Please enter your name."
            return false
        }
        if !validateSignInInput() {
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }
    
    private func clearFields() {
        email = ""
        password = ""
        displayName = ""
    }
    
    // MARK: - Helper Methods
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        return String(nonce)
    }
}
