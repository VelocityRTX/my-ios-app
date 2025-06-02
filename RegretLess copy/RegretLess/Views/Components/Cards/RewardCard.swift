//
//  RewardCard.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/21/25.
//

import SwiftUI

struct RewardCard: View {
    let reward: Reward
    let isUnlocked: Bool
    let canAfford: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // Status indicator (if unlocked)
            if isUnlocked {
                HStack {
                    Spacer()
                    Text("Unlocked")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(8)
                }
            }
            
            // Icon
            Image(systemName: reward.iconName)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(cardColor)
                .clipShape(Circle())
            
            // Title
            Text(reward.title)
                .font(.headline)
                .lineLimit(1)
            
            // Description
            Text(reward.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // Cost
            if !isUnlocked {
                HStack {
                    Text("\(reward.pointCost)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                .foregroundColor(canAfford ? .primary : .gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.theme.secondaryBackground)
                .cornerRadius(12)
            }
        }
        .padding()
        .frame(width: 160, height: 180)
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .opacity((!canAfford && !isUnlocked) ? 0.7 : 1.0)
    }
    
    // Card styling based on state
    private var cardColor: Color {
        if isUnlocked {
            return Color.green
        } else if !canAfford {
            return Color.gray
        } else {
            return Color.theme.accent
        }
    }
}
