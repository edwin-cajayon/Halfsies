//
//  HalfisiesApp.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import SwiftUI
// Uncomment when Firebase SDK is added:
// import Firebase

@main
struct testv1App: App {
    
    init() {
        configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
    
    private func configureFirebase() {
        // Only configure Firebase if enabled and SDK is added
        if AppConfig.useFirebase {
            // Uncomment when Firebase SDK is added:
            // FirebaseApp.configure()
            print("[Halfisies] Firebase configured")
        } else {
            print("[Halfisies] Running with mock services")
        }
    }
}
