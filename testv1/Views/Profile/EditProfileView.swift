//
//  EditProfileView.swift
//  Halfsies
//
//  Edit profile page for name and photo
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        ZStack {
            HalfisiesTheme.appBackground
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header
                    header
                        .padding(.top, 8)
                    
                    // Profile Photo
                    profilePhotoSection
                    
                    // Name Field
                    nameSection
                    
                    // Save Button
                    saveButton
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .onAppear {
            displayName = authViewModel.currentUser?.displayName ?? ""
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your profile has been updated!")
        }
    }
    
    // MARK: - Header
    var header: some View {
        HStack(alignment: .center) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(HalfisiesTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(HalfisiesTheme.cardBackground)
                    .cornerRadius(18)
                    .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
            }
            
            Spacer()
            
            Text("Edit Profile")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textPrimary)
            
            Spacer()
            
            // Invisible spacer for centering
            Color.clear
                .frame(width: 36, height: 36)
        }
    }
    
    // MARK: - Profile Photo Section
    var profilePhotoSection: some View {
        VStack(spacing: 16) {
            // Photo Display
            ZStack {
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(HalfisiesTheme.primary.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(String(displayName.prefix(1).uppercased()))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(HalfisiesTheme.primary)
                        )
                }
                
                // Camera badge
                Circle()
                    .fill(HalfisiesTheme.primary)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    )
                    .offset(x: 42, y: 42)
                    .shadow(color: HalfisiesTheme.shadowColor, radius: 4, y: 2)
            }
            
            // Photo Picker
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Change Photo")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(HalfisiesTheme.primary)
            }
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
            
            Text("Tap to upload a new photo")
                .font(.system(size: 13))
                .foregroundColor(HalfisiesTheme.textMuted)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Name Section
    var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DISPLAY NAME")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
                .padding(.leading, 4)
            
            HStack(spacing: 14) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(HalfisiesTheme.primary)
                    .frame(width: 24)
                
                TextField("Your name", text: $displayName)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textPrimary)
                
                if !displayName.isEmpty {
                    Button(action: { displayName = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(HalfisiesTheme.textMuted.opacity(0.5))
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(HalfisiesTheme.cardBackground)
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: HalfisiesTheme.shadowColor, radius: 8, y: 3)
            
            Text("This is how other users will see you")
                .font(.system(size: 12))
                .foregroundColor(HalfisiesTheme.textMuted)
                .padding(.leading, 4)
        }
    }
    
    // MARK: - Email Section (Read Only)
    var emailSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EMAIL")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(HalfisiesTheme.textMuted)
                .kerning(0.5)
                .padding(.leading, 4)
            
            HStack(spacing: 14) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundColor(HalfisiesTheme.secondary)
                    .frame(width: 24)
                
                Text(authViewModel.currentUser?.email ?? "")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(HalfisiesTheme.textMuted)
                
                Spacer()
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(HalfisiesTheme.textMuted.opacity(0.5))
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(HalfisiesTheme.cardBackground.opacity(0.6))
            .cornerRadius(HalfisiesTheme.cornerMedium)
            
            Text("Email cannot be changed")
                .font(.system(size: 12))
                .foregroundColor(HalfisiesTheme.textMuted)
                .padding(.leading, 4)
        }
    }
    
    // MARK: - Save Button
    var saveButton: some View {
        Button(action: saveProfile) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                    Text("Save Changes")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                canSave
                    ? HalfisiesTheme.primary
                    : HalfisiesTheme.textMuted.opacity(0.3)
            )
            .cornerRadius(HalfisiesTheme.cornerMedium)
            .shadow(color: canSave ? HalfisiesTheme.primary.opacity(0.3) : Color.clear, radius: 8, y: 4)
        }
        .disabled(!canSave || isLoading)
    }
    
    // MARK: - Helpers
    var canSave: Bool {
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty &&
        displayName != authViewModel.currentUser?.displayName
    }
    
    func saveProfile() {
        guard canSave else { return }
        
        isLoading = true
        
        Task {
            do {
                // Update user in Firestore
                guard var updatedUser = authViewModel.currentUser else {
                    throw NSError(domain: "EditProfile", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
                
                updatedUser.displayName = displayName.trimmingCharacters(in: .whitespaces)
                
                // Save to Firestore
                try await FirestoreService.shared.updateUser(updatedUser)
                
                // Update local state
                await MainActor.run {
                    authViewModel.currentUser = updatedUser
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to save profile. Please try again."
                    showError = true
                }
            }
        }
    }
}

#Preview {
    EditProfileView(authViewModel: AuthViewModel())
}
