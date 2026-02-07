//
//  DeleteAccountView.swift
//  Halfisies
//
//  Delete account confirmation view
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct DeleteAccountView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var confirmText = ""
    @State private var isDeleting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let confirmationWord = "DELETE"
    
    var canDelete: Bool {
        confirmText.uppercased() == confirmationWord
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                HalfisiesTheme.appBackground
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Warning icon
                        warningHeader
                        
                        // Warning info
                        warningInfo
                        
                        // What gets deleted
                        deletionInfo
                        
                        // Confirmation input
                        confirmationSection
                        
                        // Delete button
                        deleteButton
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(HalfisiesTheme.textMuted)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Warning Header
    var warningHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(HalfisiesTheme.error.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(HalfisiesTheme.error)
            }
            
            Text("Delete Your Account?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("This action cannot be undone")
                .font(.system(size: 15))
                .foregroundColor(HalfisiesTheme.error)
        }
    }
    
    // MARK: - Warning Info
    var warningInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Before you go...")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Text("We're sorry to see you leave. If you're having issues with the app, please contact support first - we'd love to help!")
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textMuted)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HalfisiesTheme.secondary.opacity(0.1))
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    // MARK: - Deletion Info
    var deletionInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The following will be permanently deleted:")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            VStack(spacing: 10) {
                deletionRow(icon: "person.fill", text: "Your profile and account information")
                deletionRow(icon: "list.bullet", text: "All your subscription listings")
                deletionRow(icon: "message.fill", text: "All your conversations and messages")
                deletionRow(icon: "star.fill", text: "Reviews you've written")
                deletionRow(icon: "photo.fill", text: "Your profile photo")
                deletionRow(icon: "heart.fill", text: "Your favorites and saved items")
            }
        }
        .padding(16)
        .background(HalfisiesTheme.error.opacity(0.08))
        .cornerRadius(HalfisiesTheme.cornerMedium)
    }
    
    func deletionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.error)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Spacer()
        }
    }
    
    // MARK: - Confirmation Section
    var confirmationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Type \"\(confirmationWord)\" to confirm")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            TextField("Type \(confirmationWord)", text: $confirmText)
                .font(.system(size: 16))
                .foregroundColor(HalfisiesTheme.textPrimary)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(14)
                .background(HalfisiesTheme.cardBackground)
                .cornerRadius(HalfisiesTheme.cornerMedium)
                .overlay(
                    RoundedRectangle(cornerRadius: HalfisiesTheme.cornerMedium)
                        .stroke(canDelete ? HalfisiesTheme.error : HalfisiesTheme.border, lineWidth: 1)
                )
        }
    }
    
    // MARK: - Delete Button
    var deleteButton: some View {
        Button(action: deleteAccount) {
            HStack(spacing: 8) {
                if isDeleting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 15))
                    Text("Delete My Account")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canDelete ? HalfisiesTheme.error : HalfisiesTheme.textMuted.opacity(0.3))
            .cornerRadius(HalfisiesTheme.cornerMedium)
        }
        .disabled(!canDelete || isDeleting)
    }
    
    // MARK: - Delete Account
    func deleteAccount() {
        guard canDelete else { return }
        guard let user = authViewModel.currentUser else { return }
        
        isDeleting = true
        
        Task {
            do {
                let db = Firestore.firestore()
                let storage = Storage.storage()
                
                // 1. Delete user's listings
                let listingsSnapshot = try await db.collection("listings")
                    .whereField("ownerId", isEqualTo: user.id)
                    .getDocuments()
                
                for doc in listingsSnapshot.documents {
                    try await doc.reference.delete()
                }
                
                // 2. Delete user's seat requests
                let requestsSnapshot = try await db.collection("seatRequests")
                    .whereField("requesterId", isEqualTo: user.id)
                    .getDocuments()
                
                for doc in requestsSnapshot.documents {
                    try await doc.reference.delete()
                }
                
                // 3. Delete user's reviews
                let reviewsSnapshot = try await db.collection("reviews")
                    .whereField("reviewerId", isEqualTo: user.id)
                    .getDocuments()
                
                for doc in reviewsSnapshot.documents {
                    try await doc.reference.delete()
                }
                
                // 4. Delete user's avatar from storage
                let avatarRef = storage.reference().child("avatars/\(user.id)/profile.jpg")
                try? await avatarRef.delete()
                
                // 5. Delete user document
                try await db.collection("users").document(user.id).delete()
                
                // 6. Delete Firebase Auth account
                try await Auth.auth().currentUser?.delete()
                
                // 7. Sign out locally
                await MainActor.run {
                    authViewModel.signOut()
                    dismiss()
                }
                
            } catch {
                await MainActor.run {
                    isDeleting = false
                    
                    // Check if re-authentication is needed
                    if let authError = error as NSError?,
                       authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        errorMessage = "For security reasons, please sign out and sign in again before deleting your account."
                    } else {
                        errorMessage = error.localizedDescription
                    }
                    showError = true
                }
            }
        }
    }
}

#Preview {
    DeleteAccountView(authViewModel: AuthViewModel())
}
