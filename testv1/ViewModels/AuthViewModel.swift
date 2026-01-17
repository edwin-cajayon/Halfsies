//
//  AuthViewModel.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    @Published var currentUser: HalfisiesUser?
    
    private let authService: MockAuthService
    
    init(authService: MockAuthService = .shared) {
        self.authService = authService
        self.currentUser = authService.currentUser
        self.isAuthenticated = authService.isAuthenticated
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
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
        
        isLoading = false
    }
    
    // MARK: - Sign In with Apple
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await authService.signInWithApple()
            currentUser = user
            isAuthenticated = true
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Apple Sign In failed. Please try again."
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
}
