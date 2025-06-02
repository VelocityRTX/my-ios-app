//
//  Models.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/12/25.
//

import Foundation
import SwiftUI

// MARK: - User Profile Model

struct User: Identifiable, Codable {
    var id = UUID()
    var username: String
    var joinDate: Date
    var milestones: [Milestone]
    var streakDays: Int
    var totalPointsEarned: Int
    var profileIsPrivate: Bool = true
    var dailyVapingGoal: Int = 10
    var weeklySpending: Double = 0.0
    var vapingFrequency: Int = 0
    var daysPerWeekVaping: Int = 0   
    
    // User settings and preferences
    var notificationsEnabled: Bool = true
    var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    
    // Personal cessation plan
    var cessationPlan: CessationPlan?
    
    // Add this to the User struct in Models.swift
    var unlockedRewards: [UUID] = []
}

// MARK: - Habit Tracking Models

struct VapingSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var intensity: Int // 1-5 scale
    var trigger: VapingTrigger
    var location: String?
    var mood: Mood
    var notes: String?
    var cravingLevel: Int // 1-10 scale
    
    // For reporting
    var duration: TimeInterval?
}

enum VapingTrigger: String, Codable, CaseIterable, Identifiable {
    case stress = "Stress or anxiety"
    case social = "Social situations"
    case boredom = "Boredom"
    case afterMeals = "After meals"
    case alcohol = "When drinking alcohol"
    case morning = "Morning routine"
    case concentration = "To aid concentration"
    
    var id: String { self.rawValue }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case anxious = "Anxious"
    case stressed = "Stressed"
    case bored = "Bored"
    case happy = "Happy"
    case sad = "Sad"
    case angry = "Angry"
    case neutral = "Neutral"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .anxious: return "bolt.heart"
        case .stressed: return "brain.head.profile"
        case .bored: return "zzz"
        case .happy: return "face.smiling"
        case .sad: return "cloud.rain"
        case .angry: return "flame"
        case .neutral: return "minus.circle"
        }
    }
}

// MARK: - Cessation Plan Models

struct CessationPlan: Identifiable, Codable {
    var id = UUID()
    var startDate: Date
    var targetQuitDate: Date?
    var dailyGoals: [VapingGoal]
    var strategies: [CopingStrategy]
    var progressNotes: [ProgressNote]
}

struct VapingGoal: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var maxSessions: Int
    var achievedSessions: Int?
    var completed: Bool = false
}

struct CopingStrategy: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var timesUsed: Int = 0
    var effectiveness: Int? // 1-5 scale, nil if not rated
}

struct ProgressNote: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var content: String
    var mood: Mood
}

// MARK: - Rewards & Milestones

struct Milestone: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var pointsAwarded: Int
    var dateAchieved: Date
    var iconName: String
}

struct Reward: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var pointCost: Int
    var iconName: String
    var isUnlocked: Bool = false
}

// MARK: - Peer Story Models

struct PeerStory: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var author: String // Username or "Anonymous"
    var datePosted: Date
    var tags: [String]
    var likes: Int = 0
    var comments: [Comment] = []
    var isAnonymous: Bool = false
}

struct Comment: Identifiable, Codable {
    var id = UUID()
    var author: String
    var content: String
    var datePosted: Date
    var likes: Int = 0
    var isAnonymous: Bool = false
}
