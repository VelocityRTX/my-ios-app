//
//  AppSettings.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import SwiftUI
import Foundation

struct AppSettings {
    // Animation durations
    static let shortAnimationDuration: Double = 0.3
    static let mediumAnimationDuration: Double = 0.6
    static let longAnimationDuration: Double = 1.0
    
    // UI dimensions
    static let smallIconSize: CGFloat = 24
    static let mediumIconSize: CGFloat = 40
    static let largeIconSize: CGFloat = 80
    
    // Corner radii
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 15
    static let largeCornerRadius: CGFloat = 25
    
    // Padding
    static let smallPadding: CGFloat = 8
    static let mediumPadding: CGFloat = 15
    static let largePadding: CGFloat = 30
    
    // Goals
    static let defaultDailyVapingSessionGoal: Int = 3
    static var animationSpeed: Double = 1.0 // Default speed multiplier
}
