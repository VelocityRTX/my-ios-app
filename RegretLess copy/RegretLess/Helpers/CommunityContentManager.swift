//
//  CommunityContentManager.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SwiftUI
import FirebaseAnalytics
import Foundation

class CommunityContentManager: ObservableObject {
    @Published var stories: [FirebasePeerStory] = []
    @Published var featuredStories: [FirebasePeerStory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var storiesListener: ListenerRegistration?
    
    deinit {
        storiesListener?.remove()
    }
    
    // Load all stories
    func loadStories() {
        isLoading = true
        errorMessage = nil
        
        // Remove previous listener if exists
        storiesListener?.remove()
        
        // Create a new listener for real-time updates with better error handling
        storiesListener = db.collection("stories")
            .order(by: "datePosted", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("Firestore Error loading stories: \(error.localizedDescription)")
                    self.errorMessage = "Error loading stories: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.stories = []
                    return
                }
                
                self.stories = documents.compactMap { document in
                    return FirebasePeerStory(document: document)
                }
                
                // Log analytics event
                Analytics.logEvent("stories_loaded", parameters: [
                    "count": self.stories.count
                ])
            }
    }
    
    // Load featured stories
    func loadFeaturedStories() {
        db.collection("stories")
            .whereField("isFeatured", isEqualTo: true)
            .order(by: "datePosted", descending: true)
            .limit(to: 5)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error loading featured stories: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.featuredStories = []
                    return
                }
                
                self.featuredStories = documents.compactMap { document in
                    return FirebasePeerStory(document: document)
                }
            }
    }
    
    // Filter stories by tag
    func loadStoriesByTag(_ tag: String) {
        isLoading = true
        errorMessage = nil
        
        // Remove previous listener if exists
        storiesListener?.remove()
        
        // Create a new listener filtered by tag
        storiesListener = db.collection("stories")
            .whereField("tags", arrayContains: tag)
            .order(by: "datePosted", descending: true)
            .limit(to: 30)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error loading stories: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.stories = []
                    return
                }
                
                self.stories = documents.compactMap { document in
                    return FirebasePeerStory(document: document)
                }
                
                // Log analytics event
                Analytics.logEvent("stories_filtered", parameters: [
                    "tag": tag,
                    "count": self.stories.count
                ])
            }
    }
    
    // Add new story
    func addStory(userId: String, title: String, content: String, isAnonymous: Bool, tags: [String], imageData: Data? = nil, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        // If there's an image, upload it first
        if let imageData = imageData {
            let storyId = UUID().uuidString
            let storageRef = storage.reference().child("story_images/\(storyId).jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storageRef.putData(imageData, metadata: metadata) { [weak self] _, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Error uploading image: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                // Get download URL and create story
                storageRef.downloadURL { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let url):
                        let imageURL = url.absoluteString
                        self.createStoryDocument(userId: userId, storyId: storyId, title: title, content: content, isAnonymous: isAnonymous, tags: tags, imageURL: imageURL, completion: completion)
                    case .failure(let error):
                        self.isLoading = false
                        self.errorMessage = "Error getting image URL: \(error.localizedDescription)"
                        completion(false)
                    }
                }
            }
        } else {
            // No image, create story directly
            let storyId = UUID().uuidString
            createStoryDocument(userId: userId, storyId: storyId, title: title, content: content, isAnonymous: isAnonymous, tags: tags, imageURL: nil, completion: completion)
        }
    }
    
    // Create a new story document in Firestore
    private func createStoryDocument(userId: String, storyId: String, title: String, content: String, isAnonymous: Bool, tags: [String], imageURL: String?, completion: @escaping (Bool) -> Void) {
        // Get user info first (for username)
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = "Error getting user info: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            guard let document = document, document.exists else {
                self.isLoading = false
                self.errorMessage = "User document not found"
                completion(false)
                return
            }

            guard let data = document.data() else {
                self.isLoading = false
                self.errorMessage = "User data not found"
                completion(false)
                return
            }

            guard let username = data["username"] as? String else {
                self.isLoading = false
                self.errorMessage = "Username not found"
                completion(false)
                return
            }
            
            // Create story data
            var storyData: [String: Any] = [
                "authorId": userId,
                "author": isAnonymous ? "Anonymous" : username,
                "title": title,
                "content": content,
                "datePosted": FieldValue.serverTimestamp(),
                "tags": tags,
                "likes": 0,
                "isAnonymous": isAnonymous,
                "isFeatured": false
            ]
            
            if let imageURL = imageURL {
                storyData["imageURL"] = imageURL
            }
            
            // Save to Firestore
            self.db.collection("stories").document(storyId).setData(storyData) { [weak self] error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error posting story: \(error.localizedDescription)"
                    completion(false)
                    return
                }
                
                // Log analytics event
                Analytics.logEvent("story_created", parameters: [
                    "has_image": imageURL != nil,
                    "tag_count": tags.count,
                    "is_anonymous": isAnonymous
                ])
                
                completion(true)
            }
        }
    }
    
    // Like a story
    func likeStory(storyId: String, userId: String, completion: @escaping (Bool) -> Void) {
        // Start a batch update
        let batch = db.batch()
        
        // Increment the like count
        let storyRef = db.collection("stories").document(storyId)
        batch.updateData(["likes": FieldValue.increment(Int64(1))], forDocument: storyRef)
        
        // Record the like in user-story likes
        let likeRef = db.collection("users").document(userId).collection("likes").document(storyId)
        batch.setData(["timestamp": FieldValue.serverTimestamp()], forDocument: likeRef)
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("Error liking story: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Log analytics event
            Analytics.logEvent("story_liked", parameters: nil)
            
            completion(true)
        }
    }
    
    // Add comment to a story
    func addComment(storyId: String, userId: String, content: String, isAnonymous: Bool, completion: @escaping (Bool) -> Void) {
        // Get user info first (for username)
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error getting user info: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data(),
                  let username = data["username"] as? String else {
                self.errorMessage = "User info not found"
                completion(false)
                return
            }
            
            // Create comment data
            let commentData: [String: Any] = [
                "authorId": userId,
                "author": isAnonymous ? "Anonymous" : username,
                "content": content,
                "datePosted": FieldValue.serverTimestamp(),
                "likes": 0,
                "isAnonymous": isAnonymous
            ]
            
            // Add to Firestore
            self.db.collection("stories").document(storyId).collection("comments")
                .addDocument(data: commentData) { error in
                    if let error = error {
                        print("Error adding comment: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    // Log analytics event
                    Analytics.logEvent("comment_added", parameters: nil)
                    
                    completion(true)
                }
        }
    }
    
    // Load comments for a story
    func loadComments(storyId: String, completion: @escaping ([FirebaseComment]) -> Void) {
        db.collection("stories").document(storyId).collection("comments")
            .order(by: "datePosted", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error loading comments: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let comments = documents.compactMap { document -> FirebaseComment? in
                    // Get data directly
                    let data = document.data()
                    
                    // Check for required fields
                    guard let author = data["author"] as? String,
                          let content = data["content"] as? String,
                          let likes = data["likes"] as? Int,
                          let isAnonymous = data["isAnonymous"] as? Bool else {
                        return nil
                    }
                    
                    let datePosted: Date
                    if let timestamp = data["datePosted"] as? Timestamp {
                        datePosted = timestamp.dateValue()
                    } else {
                        datePosted = Date()
                    }
                    
                    return FirebaseComment(
                        id: document.documentID,
                        author: author,
                        content: content,
                        datePosted: datePosted,
                        likes: likes,
                        isAnonymous: isAnonymous
                    )
                }
                
                completion(comments)
            }
    }
}

// Firebase-compatible models
struct FirebasePeerStory: Identifiable {
    var id: String
    var title: String
    var content: String
    var author: String
    var authorId: String
    var datePosted: Date
    var tags: [String]
    var likes: Int
    var isAnonymous: Bool
    var imageURL: String?
    var isFeatured: Bool
    
    // Initialize from Firestore document with better error handling
    init?(document: DocumentSnapshot) {
        do {
            guard let data = document.data() else {
                print("Error: No data in document \(document.documentID)")
                return nil
            }
            
            guard let title = data["title"] as? String,
                  let content = data["content"] as? String,
                  let author = data["author"] as? String,
                  let authorId = data["authorId"] as? String,
                  let likes = data["likes"] as? Int,
                  let isAnonymous = data["isAnonymous"] as? Bool,
                  let tags = data["tags"] as? [String] else {
                print("Error: Missing required fields in document \(document.documentID)")
                return nil
            }
            
            self.id = document.documentID
            self.title = title
            self.content = content
            self.author = author
            self.authorId = authorId
            self.likes = likes
            self.isAnonymous = isAnonymous
            self.tags = tags
            self.imageURL = data["imageURL"] as? String
            self.isFeatured = data["isFeatured"] as? Bool ?? false
            
            if let timestamp = data["datePosted"] as? Timestamp {
                self.datePosted = timestamp.dateValue()
            } else {
                print("Warning: Missing date in document \(document.documentID), using current date")
                self.datePosted = Date()
            }
        } catch {
            print("Error parsing document \(document.documentID): \(error)")
            return nil
        }
    }
}

struct FirebaseComment: Identifiable {
    var id: String
    var author: String
    var content: String
    var datePosted: Date
    var likes: Int
    var isAnonymous: Bool
}
