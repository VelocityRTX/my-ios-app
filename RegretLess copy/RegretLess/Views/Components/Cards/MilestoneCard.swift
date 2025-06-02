//
//  MilestoneCard.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/21/25.
//

import SwiftUI

struct MilestoneCard: View {
    let milestone: Milestone
    let isLocked: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(isLocked ? Color.gray.opacity(0.3) : Color.theme.accent.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Image(systemName: milestone.iconName)
                    .font(.system(size: 30))
                    .foregroundColor(isLocked ? Color.gray : Color.theme.accent)
            }
            
            // Title
            Text(milestone.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(isLocked ? .gray : .primary)
            
            // Description
            Text(milestone.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 5)
            
            // Points reward
            HStack {
                Text("\(milestone.pointsAwarded)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(isLocked ? .gray : Color.theme.accent)
                
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(isLocked ? .gray : .yellow)
            }
            
            // Status indicator
            if !isLocked {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text(formattedDate(milestone.dateAchieved))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(height: 220)
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .opacity(isLocked ? 0.7 : 1.0)
    }
    
    // Format the date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
