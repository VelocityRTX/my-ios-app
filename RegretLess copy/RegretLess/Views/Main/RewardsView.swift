//
//  RewardsView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/21/25.
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedCategory: RewardCategory = .all
    @State private var selectedReward: Reward?
    @State private var activeSheet: ActiveSheet?
    @State private var searchText = ""

    enum ActiveSheet: Identifiable {
        case confirmation(Reward)
        case animation(Reward)
        
        var id: Int {
            switch self {
            case .confirmation: return 0
            case .animation: return 1
            }
        }
    }
    enum RewardCategory: String, CaseIterable {
        case all = "All"
        case themes = "Themes"
        case avatars = "Avatars"
        case features = "Features"
        case boosters = "Boosters"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Points balance
            pointsBalanceHeader
            
            // Filter categories
            categoryFilter
            
            // Search bar
            searchBar
            
            // Rewards list
            rewardsList
        }
        .navigationTitle("Rewards Shop")
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .confirmation(let reward):
                // This would be a confirmation view if needed
                Text("Confirm") // Placeholder
            case .animation(let reward):
                UnlockAnimationView(reward: reward)
            }
        }
    }
    
    // Points balance header
    private var pointsBalanceHeader: some View {
        VStack(spacing: 5) {
            Text("Your Balance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(userStore.currentUser.totalPointsEarned) Points")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.theme.accent)
            
            Text("Complete activities in the app to earn more points")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding()
    }
    
    // Category filter tabs
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RewardCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.theme.accent : Color.theme.secondaryBackground)
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 10)
    }
    
    // Search bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search rewards...", text: $searchText)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color.theme.secondaryBackground)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    // Rewards list
    private var rewardsList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(filteredRewards) { reward in
                    RewardCardView(
                        reward: reward,
                        canAfford: userStore.currentUser.totalPointsEarned >= reward.pointCost,
                        action: {
                            selectedReward = reward
                            activeSheet = .confirmation(reward)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // Filter rewards based on category and search
    private var filteredRewards: [Reward] {
        return RewardsHelper.filterRewards(userStore.rewards, category: selectedCategory, searchText: searchText)
    }
    
    // Confirmation alert for unlocking rewards
    private var confirmationAlert: Alert {
        guard let reward = selectedReward else {
            return Alert(title: Text("Error"), message: Text("No reward selected"), dismissButton: .default(Text("OK")))
        }
        
        return Alert(
            title: Text("Unlock \(reward.title)?"),
            message: Text("This will cost \(reward.pointCost) points from your balance."),
            primaryButton: .default(Text("Unlock")) {
                unlockReward(reward)
            },
            secondaryButton: .cancel()
        )
    }
    
    // Unlock the reward
    private func unlockReward(_ reward: Reward) {
        RewardsHelper.processRewardUnlock(
            userStore: userStore,
            reward: reward,
            onSuccess: { reward in
                self.selectedReward = reward
                self.activeSheet = .animation(reward)
            },
            onError: { error in
                // Show an error message
                print("Error unlocking reward: \(error.localizedDescription)")
            }
        )
    }
}

// Reward card view
struct RewardCardView: View {
    let reward: Reward
    let canAfford: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: canAfford && !reward.isUnlocked ? action : {}) {
            VStack(spacing: 10) {
                // Icon
                Image(systemName: reward.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(cardColor)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(cardBorderColor, lineWidth: 3)
                    )
                    .padding(.top, 10)
                
                // Title
                Text(reward.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(cardTextColor)
                
                // Description
                Text(reward.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 5)
                
                // Cost or status
                if reward.isUnlocked {
                    Text("Unlocked")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 5)
                        .background(Color.green)
                        .cornerRadius(10)
                } else {
                    HStack {
                        Text("\(reward.pointCost)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(canAfford ? Color.theme.accent : .gray)
                        
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(canAfford ? Color.yellow : .gray)
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(10)
                }
            }
            .padding(.bottom, 10)
            .frame(height: 200)
            .background(cardBackground)
            .cornerRadius(15)
            .shadow(color: cardShadow, radius: 5, x: 0, y: 2)
            .opacity(cardOpacity)
        }
        .disabled(reward.isUnlocked || !canAfford)
    }
    
    // Card styling based on state
    private var cardColor: Color {
        if reward.isUnlocked {
            return Color.green
        } else if !canAfford {
            return Color.gray
        } else {
            return Color.theme.accent
        }
    }
    
    private var cardBorderColor: Color {
        if reward.isUnlocked {
            return Color.green.opacity(0.3)
        } else if canAfford {
            return Color.theme.accent.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private var cardBackground: Color {
        if reward.isUnlocked {
            return Color.green.opacity(0.1)
        } else {
            return Color.theme.background
        }
    }
    
    private var cardTextColor: Color {
        if reward.isUnlocked {
            return Color.green
        } else if !canAfford {
            return Color.gray
        } else {
            return .primary
        }
    }
    
    private var cardShadow: Color {
        if reward.isUnlocked {
            return Color.green.opacity(0.2)
        } else if !canAfford {
            return Color.black.opacity(0.05)
        } else {
            return Color.black.opacity(0.1)
        }
    }
    
    private var cardOpacity: Double {
        if !canAfford && !reward.isUnlocked {
            return 0.7
        } else {
            return 1.0
        }
    }
}

// Unlock animation view
struct UnlockAnimationView: View {
    @Environment(\.presentationMode) var presentationMode
    let reward: Reward
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Confetti (if shown)
            if showConfetti {
                ConfettiView()
            }
            
            // Content
            VStack(spacing: 25) {
                Spacer()
                
                // Reward icon
                Image(systemName: reward.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .frame(width: 160, height: 160)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 5)
                    )
                    .rotationEffect(.degrees(rotation))
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // Reward name
                Text("Unlocked!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text(reward.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(opacity)
                
                // Reward description
                Text(reward.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(opacity)
                
                Spacer()
                
                // Close button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.accent)
                        .cornerRadius(15)
                        .padding(.horizontal, 50)
                        .opacity(opacity)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Rotation animation
            withAnimation(.easeInOut(duration: 1.0)) {
                rotation = 360
            }
            
            // Show confetti after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}



struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RewardsView()
                .environmentObject(UserStore())
        }
    }
}
