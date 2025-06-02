//
//  RewardsHelper.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import Foundation
import SwiftUI

class RewardsHelper {
    // Helper to determine reward category
    static func categoryForReward(_ reward: Reward) -> RewardsView.RewardCategory {
        // Categorize rewards based on their properties
        if reward.title.contains("Theme") || reward.title.contains("Color") {
            return .themes
        } else if reward.title.contains("Avatar") {
            return .avatars
        } else if reward.title.contains("Pack") || reward.title.contains("Premium") {
            return .boosters
        } else {
            return .features
        }
    }
    
    // Helper to filter rewards based on category and search
    static func filterRewards(_ rewards: [Reward],
                             category: RewardsView.RewardCategory,
                             searchText: String) -> [Reward] {
        var filteredRewards = rewards
        
        // Filter by category
        if category != .all {
            filteredRewards = filteredRewards.filter { reward in
                return categoryForReward(reward) == category
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredRewards = filteredRewards.filter { reward in
                reward.title.lowercased().contains(searchText.lowercased()) ||
                reward.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        return filteredRewards
    }
    
    // Process reward unlocking with proper error handling
    static func processRewardUnlock(userStore: UserStore,
                                   reward: Reward,
                                   onSuccess: @escaping (Reward) -> Void,
                                   onError: @escaping (RewardError) -> Void) {
        userStore.processRewardUnlock(reward) { success, error in
            if success {
                onSuccess(reward)
            } else if let error = error {
                onError(error)
            }
        }
    }
}
