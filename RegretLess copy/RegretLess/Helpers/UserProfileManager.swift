//
//  UserProfileManager.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAnalytics
import SwiftUI
import Foundation

class UserProfileManager: ObservableObject {
    @Published var currentUser: FirebaseUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Load user profile data with better error handling
    func loadUserProfile(userId: String) {
        isLoading = true
        errorMessage = nil
        
        print("⭐️ Loading user profile for ID: \(userId)")
        
        // Keep your existing code for the listener
        db.collection("users").document(userId)
            .addSnapshotListener { [weak self] document, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    // Keep your existing error handling
                    if let error = error {
                        print("❌ Firestore Error loading profile: \(error.localizedDescription)")
                        self.errorMessage = "Error loading profile: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let document = document, document.exists else {
                        self.errorMessage = "User profile not found"
                        return
                    }
                    
                    print("✅ User document loaded successfully")
                    
                    // Your existing FirebaseUser creation
                    if let user = FirebaseUser(document: document) {
                        self.currentUser = user
                        print("✅ Basic user profile loaded")
                        
                        // ADD THESE LINES to load additional data
                        self.loadUserPreferences(from: document)
                        self.loadCessationPlan(from: document, userId: userId)
                        self.getUserMilestones(userId: userId) { milestones in
                            print("✅ Loaded \(milestones.count) user milestones")
                        }
                        
                        // Keep your existing analytics
                        Analytics.logEvent("profile_loaded", parameters: nil)
                    } else {
                        self.errorMessage = "Invalid user data"
                    }
                }
            }
    }
    
    // Update user profile
    func updateUserProfile(user: FirebaseUser, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let data = user.toDictionary()
        
        db.collection("users").document(user.id).updateData(data) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error updating profile: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            self.currentUser = user
            
            // Log analytics event
            Analytics.logEvent("profile_updated", parameters: nil)
            
            completion(true)
        }
    }
    
    // Award points to user
    func awardPoints(userId: String, amount: Int, reason: String, completion: @escaping (Bool) -> Void) {
        guard amount > 0 else {
            completion(false)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Start a batch update
        let batch = db.batch()
        let userRef = db.collection("users").document(userId)
        
        // Update total points
        batch.updateData(["totalPointsEarned": FieldValue.increment(Int64(amount))], forDocument: userRef)
        
        // Add transaction record
        let transactionRef = db.collection("users").document(userId).collection("pointTransactions").document()
        batch.setData([
            "amount": amount,
            "reason": reason,
            "timestamp": FieldValue.serverTimestamp()
        ], forDocument: transactionRef)
        
        // Commit the batch
        batch.commit { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error awarding points: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            // Update local user data
            if var user = self.currentUser {
                user.totalPointsEarned += amount
                self.currentUser = user
            }
            
            // Log analytics event
            Analytics.logEvent("points_awarded", parameters: [
                "amount": amount,
                "reason": reason
            ])
            
            completion(true)
        }
    }
    
    // Upload profile picture to Firebase Storage
    func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Resize image to reduce storage needs
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not process image"])))
            return
        }
        
        // Create a storage reference
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        
        // Upload image data
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Get download URL
            storageRef.downloadURL { result in
                switch result {
                case .success(let url):
                    // Log analytics event if you're using Firebase Analytics
                    Analytics.logEvent("profile_picture_uploaded", parameters: nil)
                    completion(.success(url.absoluteString))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    // Update profile picture URL in Firestore
    func updateProfilePicture(userId: String, imageUrl: String, completion: @escaping (Bool) -> Void) {
        print("⭐️ Updating profile picture URL in Firestore: \(imageUrl)")
        
        db.collection("users").document(userId).updateData([
            "profileImageURL": imageUrl
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Error updating profile picture URL in Firestore: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            print("✅ Profile picture URL updated successfully in Firestore")
            
            // Update local user data
            if var user = self.currentUser {
                user.profileImageURL = imageUrl
                self.currentUser = user
                print("✅ Local user data updated with new profile image URL")
            }
            
            completion(true)
        }
    }
    
    // Get user achievements/milestones
    func getUserMilestones(userId: String, completion: @escaping ([Milestone]) -> Void) {
        db.collection("users").document(userId).collection("milestones")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching milestones: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let milestones = documents.compactMap { document -> Milestone? in
                    // Get data directly without using guard let for the document.data()
                    let data = document.data()
                    
                    // Check for required fields
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let pointsAwarded = data["pointsAwarded"] as? Int,
                          let timestamp = data["dateAchieved"] as? Timestamp,
                          let iconName = data["iconName"] as? String else {
                        return nil
                    }
                    
                    return Milestone(
                        id: UUID(uuidString: document.documentID) ?? UUID(),
                        title: title,
                        description: description,
                        pointsAwarded: pointsAwarded,
                        dateAchieved: timestamp.dateValue(),
                        iconName: iconName
                    )
                }
                
                completion(milestones)
            }
    }
    
    // Add milestone
    func addMilestone(userId: String, milestone: Milestone, completion: @escaping (Bool) -> Void) {
        let milestoneData: [String: Any] = [
            "title": milestone.title,
            "description": milestone.description,
            "pointsAwarded": milestone.pointsAwarded,
            "dateAchieved": Timestamp(date: milestone.dateAchieved),
            "iconName": milestone.iconName
        ]
        
        db.collection("users").document(userId).collection("milestones")
            .document(milestone.id.uuidString).setData(milestoneData) { error in
                if let error = error {
                    print("Error adding milestone: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // Log analytics event
                Analytics.logEvent("milestone_achieved", parameters: [
                    "milestone": milestone.title
                ])
                
                completion(true)
            }
    }
    // Helper method to load user preferences
    private func loadUserPreferences(from document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        
        // Load vaping habits
        if let vapingFrequency = data["vapingFrequency"] as? Int,
           let daysPerWeekVaping = data["daysPerWeekVaping"] as? Int {
            
            // Notify other stores about this data
            NotificationCenter.default.post(
                name: NSNotification.Name("UserVapingHabitsLoaded"),
                object: nil,
                userInfo: [
                    "vapingFrequency": vapingFrequency,
                    "daysPerWeekVaping": daysPerWeekVaping
                ]
            )
            
            print("✅ User vaping habits loaded and shared")
        }
        
        // Load other preferences that exist in your data model
        if let mainVapingReason = data["mainVapingReason"] as? String,
           let vapeType = data["vapeType"] as? String,
           let nicotineType = data["nicotineType"] as? String,
           let nicotineStrength = data["nicotineStrength"] as? Int {
            
            NotificationCenter.default.post(
                name: NSNotification.Name("UserNicotineInfoLoaded"),
                object: nil,
                userInfo: [
                    "mainVapingReason": mainVapingReason,
                    "vapeType": vapeType,
                    "nicotineType": nicotineType,
                    "nicotineStrength": nicotineStrength
                ]
            )
            
            print("✅ User nicotine info loaded and shared")
        }
        
        // Load spending data
        let weeklySpending = data["weeklySpending"] as? Double ?? 0.0
        
        // Notify about spending data
        NotificationCenter.default.post(
            name: NSNotification.Name("UserSpendingDataLoaded"),
            object: nil,
            userInfo: [
                "weeklySpending": weeklySpending
            ]
        )
        
        print("✅ User spending data loaded and shared")
    }

    // Helper method to load cessation plan
    private func loadCessationPlan(from document: DocumentSnapshot, userId: String) {
        let data = document.data() ?? [:]
        
        if let cessationPlanData = data["cessationPlan"] as? [String: Any] {
            // Parse the plan
            var plan = CessationPlan(
                id: UUID(),
                startDate: Date(),
                targetQuitDate: nil,
                dailyGoals: [],
                strategies: [],
                progressNotes: []
            )
            
            // Fill in the plan details from Firestore data
            if let startTimestamp = cessationPlanData["startDate"] as? Timestamp {
                plan.startDate = startTimestamp.dateValue()
            }
            
            if let targetTimestamp = cessationPlanData["targetQuitDate"] as? Timestamp {
                plan.targetQuitDate = targetTimestamp.dateValue()
            }
            
            // You can also load strategies and other plan details here
            
            // Notify about the cessation plan
            NotificationCenter.default.post(
                name: NSNotification.Name("UserCessationPlanLoaded"),
                object: nil,
                userInfo: ["cessationPlan": plan]
            )
            
            print("✅ User cessation plan loaded and shared")
        } else {
            print("⚠️ No cessation plan found in user document")
        }
    }
}

// Firebase User Model
struct FirebaseUser: Identifiable {
    var id: String  // This will be the Firebase UID
    var username: String
    var email: String
    var joinDate: Date
    var streakDays: Int
    var totalPointsEarned: Int
    var profileImageURL: String?
    var dailyVapingGoal: Int = 10  // Default to 10
    
    // Init from Firestore document
    init?(document: DocumentSnapshot) {
        do {
            guard let data = document.data() else {
                print("Error: No data in user document \(document.documentID)")
                return nil
            }
            
            guard let username = data["username"] as? String,
                  let email = data["email"] as? String else {
                print("Error: Missing required user fields in document \(document.documentID)")
                return nil
            }
            
            self.id = document.documentID
            self.username = username
            self.email = email
            
            // Get optional or default values
            if let timestamp = data["joinDate"] as? Timestamp {
                self.joinDate = timestamp.dateValue()
            } else {
                print("Warning: Missing joinDate in user document \(document.documentID), using current date")
                self.joinDate = Date()
            }
            
            self.streakDays = data["streakDays"] as? Int ?? 0
            self.totalPointsEarned = data["totalPointsEarned"] as? Int ?? 0
            self.profileImageURL = data["profileImageURL"] as? String
            
            // Load dailyVapingGoal
            if let dailyGoal = data["dailyVapingGoal"] as? Int {
                self.dailyVapingGoal = dailyGoal
                print("✅ Loaded daily vaping goal: \(dailyGoal)")
            } else if let vapingFrequency = data["vapingFrequency"] as? Int {
                // If no specific goal is set, calculate from vapingFrequency
                self.dailyVapingGoal = min(vapingFrequency, 20) // Cap at reasonable max
                print("✅ Calculated daily vaping goal from frequency: \(self.dailyVapingGoal)")
            } else {
                // Default value
                self.dailyVapingGoal = 10
                print("⚠️ Using default daily vaping goal: 10")
            }
        } catch {
            print("Error parsing user document \(document.documentID): \(error)")
            return nil
        }
    }
    
    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "username": username,
            "email": email,
            "joinDate": Timestamp(date: joinDate),
            "streakDays": streakDays,
            "totalPointsEarned": totalPointsEarned,
            "dailyVapingGoal": dailyVapingGoal
        ]
        
        if let profileImageURL = profileImageURL {
            dict["profileImageURL"] = profileImageURL
        }
        
        return dict
    }
}
