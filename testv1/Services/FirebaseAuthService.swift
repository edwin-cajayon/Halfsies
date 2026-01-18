//
//  FirebaseAuthService.swift
//  Halfisies
//
//  Real Firebase Authentication Service
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

// MARK: - Firebase Auth Service
class FirebaseAuthService: NSObject, AuthServiceProtocol, ObservableObject {
    static let shared = FirebaseAuthService()
    
    @Published private(set) var currentUser: HalfisiesUser?
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    override init() {
        super.init()
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    // Fetch full user profile from Firestore
                    do {
                        let user = try await FirestoreService.shared.fetchUser(id: firebaseUser.uid)
                        self?.currentUser = user
                    } catch {
                        // User exists in Auth but not Firestore - create profile
                        let newUser = HalfisiesUser(
                            id: firebaseUser.uid,
                            email: firebaseUser.email ?? "",
                            displayName: firebaseUser.displayName ?? "User"
                        )
                        try? await FirestoreService.shared.createUser(newUser)
                        self?.currentUser = newUser
                    }
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    // MARK: - Sign Up with Email
    func signUp(email: String, password: String, displayName: String) async throws -> HalfisiesUser {
        // Validation
        guard email.contains("@") else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.weakPassword }
        
        do {
            // Create Firebase Auth user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            // Create user profile in Firestore
            let user = HalfisiesUser(
                id: result.user.uid,
                email: email,
                displayName: displayName
            )
            
            try await FirestoreService.shared.createUser(user)
            
            await MainActor.run {
                self.currentUser = user
            }
            
            return user
            
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Sign In with Email
    func signIn(email: String, password: String) async throws -> HalfisiesUser {
        guard email.contains("@") else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.invalidPassword }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Fetch user profile from Firestore
            let user = try await FirestoreService.shared.fetchUser(id: result.user.uid)
            
            await MainActor.run {
                self.currentUser = user
            }
            
            return user
            
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Sign In with Apple
    func signInWithApple() async throws -> HalfisiesUser {
        // This method is not directly used - Apple Sign In is handled via handleAppleSignIn
        // The UI triggers ASAuthorizationController which calls handleAppleSignIn
        throw AuthError.unknown
    }
    
    // Set the nonce from the ViewModel (called before Apple Sign In)
    func setCurrentNonce(_ nonce: String?) {
        currentNonce = nonce
    }
    
    // Handle Apple Sign In credential (called from AuthViewModel)
    func handleAppleSignIn(credential: ASAuthorizationAppleIDCredential) async throws -> HalfisiesUser {
        guard let nonce = currentNonce else {
            throw AuthError.unknown
        }
        
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.unknown
        }
        
        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )
        
        do {
            let result = try await Auth.auth().signIn(with: firebaseCredential)
            
            // Check if user exists in Firestore
            do {
                let user = try await FirestoreService.shared.fetchUser(id: result.user.uid)
                await MainActor.run {
                    self.currentUser = user
                }
                return user
            } catch {
                // Create new user profile
                let displayName = [credential.fullName?.givenName, credential.fullName?.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
                
                let user = HalfisiesUser(
                    id: result.user.uid,
                    email: result.user.email ?? credential.email ?? "",
                    displayName: displayName.isEmpty ? "Apple User" : displayName
                )
                
                try await FirestoreService.shared.createUser(user)
                
                await MainActor.run {
                    self.currentUser = user
                }
                
                return user
            }
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            throw AuthError.unknown
        }
    }
    
    // MARK: - Password Reset
    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        // Delete user data from Firestore first
        try await FirestoreService.shared.deleteUser(id: user.uid)
        
        // Then delete auth account
        try await user.delete()
        
        await MainActor.run {
            self.currentUser = nil
        }
    }
    
    // MARK: - Helper Methods
    private func mapFirebaseError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .wrongPassword:
            return .invalidPassword
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .networkError
        default:
            return .unknown
        }
    }
    
    // Generate random nonce for Apple Sign In
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
    
    // SHA256 hash for nonce
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
