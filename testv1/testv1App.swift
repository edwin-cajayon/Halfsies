//
//  HalfisiesApp.swift
//  Halfisies
//
//  Created by Edwin on 17/01/2026.
//

import SwiftUI
import FirebaseCore

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
        FirebaseApp.configure()
        print("[Halfsies] Firebase configured")
    }
}
