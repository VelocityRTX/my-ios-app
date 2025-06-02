//
//  IntroTutorialViewModel.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/28/25.
//

import SwiftUI

class IntroTutorialViewModel: ObservableObject {
    // Navigation
    @Published var currentPage: Int = 0
    @Published var vapesDaily: Bool = false
    
    
    // Basic user data
    @Published var vapingFrequency: Int = 0
    @Published var daysPerWeekVaping: Int = 0
    @Published var primaryTriggers: [VapingTrigger] = []
    @Published var selectedApproach: String = ""
    @Published var targetQuitDate: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    @Published var profileImage: UIImage?
    @Published var quitReasons: Set<String> = []
    @Published var personalQuitReason: String = ""
    @Published var vapeFromBoredom: Bool = false
    @Published var mainVapingReason: String = ""
    @Published var confidenceLevel: Int = 0 // 1-10
    @Published var lackOfConfidenceReason: String = ""
    @Published var neutralConfidenceReason: String = ""
    @Published var highConfidenceReason: String = ""
    @Published var vapeType: String = ""
    @Published var nicotineType: String = ""
    @Published var nicotineStrength: Int = 0
    @Published var weeklySpending: Double = 0.0
    @Published var physicalSymptoms: Set<String> = []
    @Published var mentalSymptoms: Set<String> = []
    @Published var notificationsEnabled: Bool = true
    @Published var userPath: String = ""
    @Published var learningReasons: Set<String> = []
    @Published var otherLearningReason: String = ""
    @Published var selectedTopics: Set<String> = []
    
    func savePreferences() {
        // Save all intro survey data to UserDefaults
        let defaults = UserDefaults.standard
        
        // Save vaping path
        defaults.set(userPath, forKey: "intro_user_path")
        
        // Other reasons
        defaults.set(Array(learningReasons), forKey: "intro_learning_reasons")
        defaults.set(otherLearningReason, forKey: "intro_other_learning_reason")
        defaults.set(Array(selectedTopics), forKey: "intro_selected_topics")
        
        // Save vaping habits
        defaults.set(vapingFrequency, forKey: "intro_vaping_frequency")
        defaults.set(daysPerWeekVaping, forKey: "intro_days_per_week")
        defaults.set(vapesDaily, forKey: "intro_vapes_daily")
        defaults.set(vapeFromBoredom, forKey: "intro_vape_from_boredom")
        defaults.set(mainVapingReason, forKey: "intro_main_reason")
        defaults.set(vapeType, forKey: "intro_vape_type")
        defaults.set(nicotineType, forKey: "intro_nicotine_type")
        defaults.set(nicotineStrength, forKey: "intro_nicotine_strength")
        defaults.set(weeklySpending, forKey: "intro_weekly_spending")
        
        // Save quit reasons
        defaults.set(Array(quitReasons), forKey: "intro_quit_reasons")
        defaults.set(personalQuitReason, forKey: "intro_personal_reason")
        
        // Save symptoms
        defaults.set(Array(physicalSymptoms), forKey: "intro_physical_symptoms")
        defaults.set(Array(mentalSymptoms), forKey: "intro_mental_symptoms")
        
        // Save confidence info
        defaults.set(confidenceLevel, forKey: "intro_confidence_level")
        defaults.set(lackOfConfidenceReason, forKey: "intro_low_confidence_reason")
        defaults.set(neutralConfidenceReason, forKey: "intro_neutral_confidence_reason")
        defaults.set(highConfidenceReason, forKey: "intro_high_confidence_reason")
        
        // Save approach and timeline
        defaults.set(selectedApproach, forKey: "intro_approach")
        defaults.set(targetQuitDate.timeIntervalSince1970, forKey: "intro_target_date")
        
        // Save notification preference
        defaults.set(notificationsEnabled, forKey: "intro_notifications_enabled")
        
        // Save profile image if exists
        if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.7) {
            defaults.set(imageData, forKey: "intro_profile_image")
        }
        
        print("All onboarding preferences saved successfully")
    }
    
    // Load saved preferences
    func loadPreferences() {
        print("Loading preferences")
        // This would load from UserDefaults in the real implementation
    }
}
