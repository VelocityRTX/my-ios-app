//
//  AuthenticationManager.swift
//  RegretLess
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics
import SwiftUI
import FirebaseStorage

class AuthenticationManager: ObservableObject {
    @Published var firebaseUser: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isProcessing = false
    @Published var isEmailVerified = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    // Use the custom Firebase app
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    private let storage = Storage.storage()
    
    init() {
        // Listen for authentication state changes using the custom Auth instance
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            self?.firebaseUser = user
            self?.isAuthenticated = user != nil
            self?.isEmailVerified = user?.isEmailVerified ?? false
        }
    }
    
    deinit {
        // Remove the listener when the manager is deallocated
        if let handle = authStateHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
    // Register a new user
    func registerUser(email: String, password: String, username: String, completion: @escaping (Bool) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        print("⭐️ Starting user registration for \(username)")
        
        // Check if username is already taken
        checkUsernameAvailability(username) { [weak self] isAvailable in
            guard let self = self else { return }
            
            print("⭐️ Username availability check: \(isAvailable)")
            
            if !isAvailable {
                self.errorMessage = "Username is already taken"
                self.isProcessing = false
                completion(false)
                return
            }
            
            // Create user with email and password
            self.auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Firebase Auth Error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                    completion(false)
                    return
                }
                
                print("✅ User created successfully in Firebase Auth")
                
                guard let user = authResult?.user else {
                    print("❌ Auth result contains no user")
                    self.errorMessage = "Unknown error occurred"
                    self.isProcessing = false
                    completion(false)
                    return
                }
                
                // Set the user's display name to their username
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = username
                
                changeRequest.commitChanges { [weak self] error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("❌ Failed to set display name: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                        self.isProcessing = false
                        completion(false)
                        return
                    }
                    
                    print("✅ Display name set successfully")
                    
                    // Store additional user info in Firestore
                    let userData: [String: Any] = [
                        "username": username,
                        "email": email,
                        "joinDate": Timestamp(date: Date()),
                        "streakDays": 0,
                        "totalPointsEarned": 0,
                        "milestones": [],
                        "unlockedRewards": []
                    ]
                    
                    print("⭐️ Attempting to create user document in Firestore")
                    
                    // After the user creation is successful and the user document is created
                    self.db.collection("users").document(user.uid).setData(userData) { error in
                        self.isProcessing = false
                        
                        if let error = error {
                            print("❌ Firestore Error creating user document: \(error.localizedDescription)")
                            self.errorMessage = error.localizedDescription
                            completion(false)
                            return
                        }
                        
                        print("✅ User document created successfully in Firestore")
                        
                        // Transfer onboarding data to the new user
                        print("⭐️ Attempting to transfer onboarding data")
                        self.transferOnboardingDataToUser(userId: user.uid) { success in
                            if success {
                                print("✅ Onboarding data transferred successfully")
                            } else {
                                print("⚠️ Failed to transfer some onboarding data")
                            }
                            
                            // Log analytics event
                            Analytics.logEvent("user_registered", parameters: ["method": "email"])
                            
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    // Log in an existing user
    func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        self.auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isProcessing = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            // Log analytics event
            Analytics.logEvent("user_login", parameters: ["method": "email"])
            
            completion(true)
        }
    }
    
    // Log out the current user
    func logoutUser(completion: @escaping (Bool) -> Void) {
        do {
            try self.auth.signOut()
            
            // Log analytics event
            Analytics.logEvent("user_logout", parameters: nil)
            
            completion(true)
        } catch {
            errorMessage = error.localizedDescription
            completion(false)
        }
    }
    
    // Reset password
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isProcessing = true
        errorMessage = nil
        
        self.auth.sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            self.isProcessing = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    // Resend verification email
    func resendVerificationEmail(completion: @escaping (Bool) -> Void) {
        guard let user = self.auth.currentUser else {
            errorMessage = "No user logged in"
            completion(false)
            return
        }
        
        user.sendEmailVerification { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    // Check if a username is available
    private func checkUsernameAvailability(_ username: String, completion: @escaping (Bool) -> Void) {
        self.db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking username: \(error.localizedDescription)")
                    // If there's an error, let them try to register anyway
                    completion(true)
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(true)
                    return
                }
                
                // Username is available if no documents are found
                completion(snapshot.documents.isEmpty)
            }
    }
    
    func transferOnboardingDataToUser(userId: String, completion: @escaping (Bool) -> Void) {
        print("⭐️ Starting transfer of onboarding data to user: \(userId)")
        let defaults = UserDefaults.standard
        let db = self.db
        
        // Create cessation plan based on onboarding data
        var cessationPlanData: [String: Any] = [:]
        
        // Start date is now
        cessationPlanData["startDate"] = Timestamp(date: Date())
        print("✅ Added startDate to cessation plan")
        
        // Target quit date
        if let targetDateTimeInterval = defaults.object(forKey: "intro_target_date") as? TimeInterval {
            let targetDate = Date(timeIntervalSince1970: targetDateTimeInterval)
            cessationPlanData["targetQuitDate"] = Timestamp(date: targetDate)
            print("✅ Added targetQuitDate to cessation plan: \(targetDate)")
        } else {
            print("⚠️ No target date found in UserDefaults")
        }
        
        // Selected approach
        if let approach = defaults.string(forKey: "intro_approach") {
            cessationPlanData["approach"] = approach
            print("✅ Added approach to cessation plan: \(approach)")
        } else {
            print("⚠️ No approach found in UserDefaults")
        }
        
        // Daily goals will be calculated based on vaping frequency and approach
        cessationPlanData["dailyGoals"] = [] // To be populated
        
        // Create strategies based on symptoms and triggers
        cessationPlanData["strategies"] = [] // To be populated
        
        // Create user profile data
        var userData: [String: Any] = [:]
        
        // Vaping habits
        userData["vapingFrequency"] = defaults.integer(forKey: "intro_vaping_frequency")
        userData["daysPerWeekVaping"] = defaults.integer(forKey: "intro_days_per_week")
        userData["vapesDaily"] = defaults.bool(forKey: "intro_vapes_daily")
        userData["vapeFromBoredom"] = defaults.bool(forKey: "intro_vape_from_boredom")
        
        // After saving the user path
        if let userPath = defaults.string(forKey: "intro_user_path") {
            // Only save valid paths, not "undecided"
            if userPath == "quitting" || userPath == "learning" {
                userData["userPath"] = userPath
                print("✅ Added userPath: \(userPath)")
            }
            
            // Add learning-specific data if applicable
            if userPath == "learning" {
                // Save learning reasons
                if let learningReasons = defaults.stringArray(forKey: "intro_learning_reasons") {
                    userData["learningReasons"] = learningReasons
                    print("✅ Added learningReasons: \(learningReasons)")
                }
                
                // Save other learning reason
                if let otherReason = defaults.string(forKey: "intro_other_learning_reason"), !otherReason.isEmpty {
                    userData["otherLearningReason"] = otherReason
                    print("✅ Added otherLearningReason")
                }
                
                // Save selected topics
                if let selectedTopics = defaults.stringArray(forKey: "intro_selected_topics") {
                    userData["selectedTopics"] = selectedTopics
                    print("✅ Added selectedTopics: \(selectedTopics)")
                }
            }
        }
        
        print("✅ Added basic vaping habits to user data")
        
        if let mainReason = defaults.string(forKey: "intro_main_reason") {
            userData["mainVapingReason"] = mainReason
            print("✅ Added mainVapingReason: \(mainReason)")
        }
        
        if let vapeType = defaults.string(forKey: "intro_vape_type") {
            userData["vapeType"] = vapeType
            print("✅ Added vapeType: \(vapeType)")
        }
        
        if let nicotineType = defaults.string(forKey: "intro_nicotine_type") {
            userData["nicotineType"] = nicotineType
            print("✅ Added nicotineType: \(nicotineType)")
        }
        
        userData["nicotineStrength"] = defaults.integer(forKey: "intro_nicotine_strength")
        userData["weeklySpending"] = defaults.double(forKey: "intro_weekly_spending")
        
        // Quit reasons
        if let quitReasons = defaults.stringArray(forKey: "intro_quit_reasons") {
            userData["quitReasons"] = quitReasons
            print("✅ Added quitReasons: \(quitReasons)")
        } else {
            print("⚠️ No quit reasons found in UserDefaults")
        }
        
        if let personalReason = defaults.string(forKey: "intro_personal_reason") {
            userData["personalQuitReason"] = personalReason
            print("✅ Added personalQuitReason")
        }
        
        // Symptoms
        if let physicalSymptoms = defaults.stringArray(forKey: "intro_physical_symptoms") {
            userData["physicalSymptoms"] = physicalSymptoms
            print("✅ Added physicalSymptoms: \(physicalSymptoms)")
        }
        
        if let mentalSymptoms = defaults.stringArray(forKey: "intro_mental_symptoms") {
            userData["mentalSymptoms"] = mentalSymptoms
            print("✅ Added mentalSymptoms: \(mentalSymptoms)")
        }
        
        // Confidence info
        userData["confidenceLevel"] = defaults.integer(forKey: "intro_confidence_level")
        
        if let lowConfidenceReason = defaults.string(forKey: "intro_low_confidence_reason") {
            userData["lackOfConfidenceReason"] = lowConfidenceReason
            print("✅ Added lackOfConfidenceReason")
        }
        
        if let neutralConfidenceReason = defaults.string(forKey: "intro_neutral_confidence_reason") {
            userData["neutralConfidenceReason"] = neutralConfidenceReason
            print("✅ Added neutralConfidenceReason")
        }
        
        if let highConfidenceReason = defaults.string(forKey: "intro_high_confidence_reason") {
            userData["highConfidenceReason"] = highConfidenceReason
            print("✅ Added highConfidenceReason")
        }
        
        // Add cessation plan to user data
        userData["cessationPlan"] = cessationPlanData
        print("✅ Added cessation plan to user data")
        
        print("⭐️ Attempting to write user data to Firestore")
        
        // Save data to Firestore
        self.db.collection("users").document(userId).updateData(userData) { error in
            if let error = error {
                print("❌ Error transferring onboarding data: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            print("✅ Successfully wrote user data to Firestore")
            
            // Upload profile image if exists
            if let imageData = defaults.data(forKey: "intro_profile_image") {
                print("⭐️ Found profile image data (\(imageData.count) bytes), uploading...")
                self.uploadProfileImage(imageData: imageData, userId: userId) { success in
                    if success {
                        print("✅ Profile image uploaded successfully")
                    } else {
                        print("❌ Failed to upload profile image")
                    }
                    completion(success)
                }
            } else {
                print("ℹ️ No profile image found to upload")
                completion(true)
            }
            
            // Clear onboarding data from UserDefaults
            self.clearOnboardingData()
            print("✅ Cleared onboarding data from UserDefaults")
        }
    }

    // Helper to upload profile image
    private func uploadProfileImage(imageData: Data, userId: String, completion: @escaping (Bool) -> Void) {
        let storage = self.storage
        let storageRef = storage.reference().child("profile_images/\(userId).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Get download URL
            storageRef.downloadURL { result in
                switch result {
                case .success(let url):
                    // Update profile URL in Firestore
                    self.db.collection("users").document(userId).updateData([
                        "profileImageURL": url.absoluteString
                    ]) { error in
                        if let error = error {
                            print("Error updating profile URL: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                case .failure(let error):
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }

    // Helper to clear onboarding data after transfer
    private func clearOnboardingData() {
        let defaults = UserDefaults.standard
        
        // List of keys to clear
        let keysToRemove = [
            "intro_vaping_frequency", "intro_days_per_week", "intro_vapes_daily",
            "intro_vape_from_boredom", "intro_main_reason", "intro_vape_type",
            "intro_nicotine_type", "intro_nicotine_strength", "intro_weekly_spending",
            "intro_quit_reasons", "intro_personal_reason", "intro_physical_symptoms",
            "intro_mental_symptoms", "intro_confidence_level", "intro_low_confidence_reason",
            "intro_neutral_confidence_reason", "intro_high_confidence_reason",
            "intro_approach", "intro_target_date", "intro_notifications_enabled",
            "intro_profile_image"
        ]
        
        // Remove all keys
        for key in keysToRemove {
            defaults.removeObject(forKey: key)
        }
    }
}
