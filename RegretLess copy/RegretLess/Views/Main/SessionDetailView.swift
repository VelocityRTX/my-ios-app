//
//  SessionDetailView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/17/25.
//

import SwiftUI

struct SessionDetailView: View {
    let session: VapingSession
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with date and time
                HStack {
                    VStack(alignment: .leading) {
                        Text(dateString)
                            .font(.headline)
                        Text(timeString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: session.mood.icon)
                        .font(.system(size: 30))
                        .foregroundColor(Color.theme.accent)
                        .padding()
                        .background(Color.theme.secondaryBackground)
                        .clipShape(Circle())
                }
                
                Divider()
                
                // Details grid
                VStack(spacing: 15) {
                    detailRow(title: "Trigger", value: session.trigger.rawValue)
                    detailRow(title: "Mood", value: session.mood.rawValue)
                    
                    if let location = session.location {
                        detailRow(title: "Location", value: location)
                    }
                    
                    detailRow(title: "Intensity", value: "\(session.intensity)/5")
                    detailRow(title: "Craving Level", value: "\(session.cravingLevel)/10")
                }
                
                if let notes = session.notes, !notes.isEmpty {
                    Divider()
                    
                    // Notes section
                    VStack(alignment: .leading) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                            .padding()
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                    }
                }
                
                Divider()
                
                // Recommended coping strategies
                VStack(alignment: .leading) {
                    Text("For next time, try:")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        
                        let strategy = recommendedStrategy
                        Text(strategy.title)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        NavigationLink(destination: StrategyDetailView(strategy: strategy)) {
                            Text("View")
                                .font(.caption)
                                .padding(8)
                                .background(Color.theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Session Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper for creating detail rows
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
        }
    }
    
    // Format the date to a readable string
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: session.date)
    }
    
    // Format the time to a readable string
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
    
    // Provide a recommended coping strategy based on the trigger
    private var recommendedStrategy: CopingStrategy {
        // This would ideally come from a real recommendation algorithm
        // For now, just a placeholder strategy
        return CopingStrategy(
            id: UUID(),
            title: triggerBasedRecommendation,
            description: "When you feel triggered by \(session.trigger.rawValue.lowercased()), try this technique to reduce cravings.",
            timesUsed: 0
        )
    }
    
    // Simple strategy recommendation based on trigger
    private var triggerBasedRecommendation: String {
        switch session.trigger {
        case .stress:
            return "Deep Breathing Exercise"
        case .social:
            return "Excuse Yourself Briefly"
        case .boredom:
            return "Try a 5-Minute Activity"
        case .morning:
            return "Replace with a Healthy Routine"
        case .concentration:
            return "Drink Cold Water"
        case .alcohol:
            return "Distraction Technique"
        case .afterMeals:
            return "Yummy Bussing"
        }
    }
}
