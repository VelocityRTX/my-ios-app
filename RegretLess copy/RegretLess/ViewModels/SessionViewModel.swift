//
//  SessionViewModel.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import Foundation
import SwiftUI
import Combine

class SessionViewModel: ObservableObject {
    // Session data
    @Published var intensity: Int = 3
    @Published var trigger: VapingTrigger = .stress
    @Published var location: String = ""
    @Published var mood: Mood = .neutral
    @Published var notes: String = ""
    @Published var cravingLevel: Int = 5
    @Published var showMotivation: Bool = false
    
    // Store references
    var habitStore: HabitTrackingStore
    var userStore: UserStore
    
    init(habitStore: HabitTrackingStore, userStore: UserStore) {
        self.habitStore = habitStore
        self.userStore = userStore
    }
    
    func saveSession() {
        let newSession = VapingSession(
            date: Date(),
            intensity: intensity,
            trigger: trigger,
            location: location.isEmpty ? nil : location,
            mood: mood,
            notes: notes.isEmpty ? nil : notes,
            cravingLevel: cravingLevel
        )
        
        habitStore.addSession(newSession)
        userStore.awardPoints(amount: 5, reason: .sessionLogged, description: "Tracking a session")
    }
    
    func resetForm() {
        intensity = 3
        trigger = .stress
        location = ""
        mood = .neutral
        notes = ""
        cravingLevel = 5
    }
}
