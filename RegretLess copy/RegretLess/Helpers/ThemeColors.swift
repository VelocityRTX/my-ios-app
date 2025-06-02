//
//  ThemeColors.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/12/25.
//

import SwiftUI
import Foundation

// Extension to define app theme colors
extension Color {
    static let theme = ColorTheme()
}

// Color theme struct with all app colors
struct ColorTheme {
    let peach = Color("peach") // #F8B195
    let coral = Color("coral") // #F67280
    let mauve = Color("mauve") // #C06C84
    let purple = Color("purple") // #6C5B7B
    let deepBlue = Color("deepBlue") // #355C7D
    
    // Semantic color assignments
    let primary = Color("deepBlue") // #355C7D - Primary app color
    let secondary = Color("mauve") // #C06C84 - Secondary app color
    let accent = Color("coral") // #F67280 - Accent for important buttons and highlights
    let background = Color.white // Main background
    let secondaryBackground = Color("peach").opacity(0.3) // For cards, sections
    let text = Color("deepBlue") // Main text color
    let secondaryText = Color("purple") // Secondary text color
    
    let blue = Color("blue")     // For breathing exercise and other blue elements
    let red = Color("red")       // For health warnings and alerts
    let green = Color("green")   // For success indicators and progress
    let orange = Color("orange") // For certain UI elements
}

// This struct is for previews in SwiftUI canvas
struct ColorConstants {
    static let peach = "#F8B195"
    static let coral = "#F67280"
    static let mauve = "#C06C84"
    static let purple = "#6C5B7B"
    static let deepBlue = "#355C7D"
}
