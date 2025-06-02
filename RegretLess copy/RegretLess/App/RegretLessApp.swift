//
//  RegretLessApp.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/12/25.
//

import Firebase
import FirebaseFirestore
import FirebaseCore
import FirebaseAppCheck
import SwiftUI
import Foundation

@main
struct RegretLessApp: App {
    // State objects for app-wide data
    @StateObject private var habitStore = HabitTrackingStore()
    @StateObject private var userStore = UserStore()
    @StateObject private var storyStore = PeerStoryStore()
    @StateObject private var authManager = AuthenticationManager()
    @StateObject private var profileManager = UserProfileManager()
    @State private var showLogin = false
    
    // For login state
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    // Add this new state for intro tutorial
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false

    
    // Initialize Firebase
    init() {
        hasSeenIntro = false
        print("Beginning Firebase configuration")
        
        // Configure App Check for simulator
        #if targetEnvironment(simulator)
            print("🔍 Setting up App Check Debug Provider for simulator")
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        // Configure Firebase with default configuration
        FirebaseApp.configure()
        print("✅ Firebase core configured")
        
        // Set up a custom FirebaseOptions to point to the specific database
        guard let options = FirebaseOptions.defaultOptions() else {
            print("❌ Failed to get default Firebase options")
            return
        }
        
        // Create a custom Firebase app with our specific database ID
        let databaseURL = "https://regretlessappofficialdatabase.firebaseio.com"
        options.databaseURL = databaseURL
        
        // Check if the app already exists
        if FirebaseApp.app(name: "regretlessCustomApp") == nil {
            // No throwing functions here, so no try needed
            FirebaseApp.configure(name: "regretlessCustomApp", options: options)
            print("✅ Custom Firebase app created for specific database")
        } else {
            print("✅ Custom Firebase app already exists")
        }
        
        guard let customApp = FirebaseApp.app(name: "regretlessCustomApp") else {
            print("❌ Failed to access custom Firebase app")
            return
        }
        
        // Initialize Firestore with our custom app
        let db = Firestore.firestore(app: customApp, database: "regretlessappofficialdatabase")
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
        print("✅ Firestore configured with custom database settings")
        
        // Assign this database as the shared instance for your managers to use
        UserDefaults.standard.set("regretlessCustomApp", forKey: "firebaseAppName")
        
        // Test connection
        print("⭐️ Testing Firestore connection to custom database...")
        db.collection("testCollection").document("testDoc").setData([
            "timestamp": FieldValue.serverTimestamp(),
            "testField": "Test write to custom database",
            "database": "regretlessappofficialdatabase"
        ]) { error in
            if let error = error {
                print("❌ FIREBASE ERROR: \(error.localizedDescription)")
                print("❌ Please check your Firebase console and security rules")
            } else {
                print("✅ Firestore write test to custom database successful!")
            }
        }
    }
    
    // Test Firestore connection - moved outside init
    func testFirestore() {
        guard let customApp = FirebaseApp.app(name: "regretlessCustomApp") else {
            print("❌ Custom Firebase app not found")
            return
        }
        
        let db = Firestore.firestore(app: customApp, database: "regretlessappofficialdatabase")
        let testDoc = db.collection("test").document()
        
        print("⭐️ Testing Firestore write...")
        testDoc.setData(["test": "value", "timestamp": FieldValue.serverTimestamp()]) { error in
            if let error = error {
                print("❌ Firestore write error: \(error.localizedDescription)")
            } else {
                print("✅ Firestore write successful!")
                
                // Now try reading it back
                print("⭐️ Testing Firestore read...")
                testDoc.getDocument { document, error in
                    if let error = error {
                        print("❌ Firestore read error: \(error.localizedDescription)")
                    } else if let document = document, document.exists {
                        print("✅ Firestore read successful: \(document.data() ?? [:])")
                    } else {
                        print("❌ Firestore document doesn't exist")
                    }
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if !hasSeenIntro {
                // Show intro tutorial first
                IntroTutorialView(showLogin: $showLogin)
                    .onAppear {
                        print("Showing intro tutorial")
                    }
                    .onChange(of: showLogin) { oldValue, newValue in
                        print("showLogin changed to: \(newValue)")
                        if newValue {
                            // User finished the intro, mark it as seen
                            hasSeenIntro = true
                            print("hasSeenIntro set to true")
                        }
                    }
            } else if authManager.isAuthenticated {
                // Main app content for authenticated users
                MainTabView()
                    .environmentObject(habitStore)
                    .environmentObject(userStore)
                    .environmentObject(storyStore)
                    .environmentObject(authManager)
                    .environmentObject(profileManager)
                    .preferredColorScheme(.light)
                    .accentColor(Color.theme.accent)
                    .overlay(
                        ZStack {
                            if userStore.showPointAnimation {
                                PointAwardView(points: userStore.pointsToShow)
                                    .transition(.scale)
                                    .zIndex(100)
                            }

                            if userStore.showMilestoneAnimation, let milestone = userStore.achievedMilestone {
                                MilestoneAchievementView(milestone: milestone)
                                    .transition(.opacity)
                                    .zIndex(101)
                            }
                        }
                    )
            } else {
                // Login/registration screen for unauthenticated users
                LoginView()
                    .environmentObject(authManager)
                    .preferredColorScheme(.light)
                    .accentColor(Color.theme.accent)
            }
        }
    }
}
