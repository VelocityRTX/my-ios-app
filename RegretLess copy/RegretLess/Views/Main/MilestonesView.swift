//
//  MilestonesView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/21/25.
//

import SwiftUI

struct MilestonesView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var selectedFilter: MilestoneFilter = .all
    @State private var selectedMilestone: Milestone?
    @State private var showingDetail = false
    
    enum MilestoneFilter: String, CaseIterable {
        case all = "All"
        case achieved = "Achieved"
        case upcoming = "Upcoming"
    }
    
    // Sample upcoming milestones (would be in your model normally)
    let upcomingMilestones: [Milestone] = [
        Milestone(
            id: UUID(),
            title: "Track 20 Sessions",
            description: "Log 20 vaping sessions in the tracking tool",
            pointsAwarded: 150,
            dateAchieved: Date(), // This is a placeholder, we'll hide it
            iconName: "doc.text.magnifyingglass"
        ),
        Milestone(
            id: UUID(),
            title: "First Week Streak",
            description: "Complete 7 consecutive days of app use",
            pointsAwarded: 200,
            dateAchieved: Date(), // This is a placeholder, we'll hide it
            iconName: "calendar"
        ),
        Milestone(
            id: UUID(),
            title: "Coping Master",
            description: "Use 5 different coping strategies",
            pointsAwarded: 175,
            dateAchieved: Date(), // This is a placeholder, we'll hide it
            iconName: "brain.head.profile"
        ),
        Milestone(
            id: UUID(),
            title: "Community Supporter",
            description: "Comment on 10 peer stories",
            pointsAwarded: 225,
            dateAchieved: Date(), // This is a placeholder, we'll hide it
            iconName: "person.2.fill"
        ),
        Milestone(
            id: UUID(),
            title: "Goal Achiever",
            description: "Meet your daily vaping goal for 5 days",
            pointsAwarded: 250,
            dateAchieved: Date(), // This is a placeholder, we'll hide it
            iconName: "checkmark.circle"
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress summary
            achievementSummary
            
            // Filter tabs
            filterTabs
            
            // Milestones grid
            milestonesGrid
        }
        .navigationTitle("Milestones")
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingDetail) {
            if let milestone = selectedMilestone {
                MilestoneDetailView(milestone: milestone)
            }
        }
    }
    
    // Achievement summary
    private var achievementSummary: some View {
        VStack(spacing: 10) {
            Text("Your Progress")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.theme.secondaryBackground, lineWidth: 15)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.theme.coral, Color.theme.accent]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 15, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(achievedCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color.theme.accent)
                    
                    Text("of \(totalMilestones)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 10)
            
            // Points earned
            HStack(spacing: 20) {
                VStack {
                    Text("\(totalPointsEarned)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.accent)
                    
                    Text("Points Earned")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("\(upcomingMilestones.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.secondary)
                    
                    Text("Up Next")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.theme.secondaryBackground.opacity(0.3))
            .cornerRadius(15)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding()
    }
    
    // Filter tabs
    private var filterTabs: some View {
        HStack(spacing: 0) {
            ForEach(MilestoneFilter.allCases, id: \.self) { filter in
                Button(action: {
                    selectedFilter = filter
                }) {
                    Text(filter.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(selectedFilter == filter ? Color.theme.accent : .secondary)
                .background(
                    selectedFilter == filter ?
                    Color.theme.secondaryBackground :
                    Color.clear
                )
                .cornerRadius(selectedFilter == filter ? 10 : 0)
                .padding(.horizontal, selectedFilter == filter ? 10 : 0)
            }
        }
        .padding(.vertical, 10)
        .background(Color.theme.background)
    }
    
    // Milestones grid
    private var milestonesGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(filteredMilestones) { milestone in
                    MilestoneCard(
                        milestone: milestone,
                        isLocked: !userStore.currentUser.milestones.contains { $0.id == milestone.id }
                    )
                    .onTapGesture {
                        selectedMilestone = milestone
                        showingDetail = true
                    }
                }
            }
            .padding()
        }
    }
    
    // Calculated properties
    private var achievedCount: Int {
        userStore.currentUser.milestones.count
    }
    
    private var totalMilestones: Int {
        userStore.currentUser.milestones.count + upcomingMilestones.count
    }
    
    private var progressPercentage: CGFloat {
        if totalMilestones == 0 {
            return 0
        }
        return CGFloat(achievedCount) / CGFloat(totalMilestones)
    }
    
    private var totalPointsEarned: Int {
        userStore.currentUser.milestones.reduce(0) { $0 + $1.pointsAwarded }
    }
    
    // Filtered milestones based on selected filter
    private var filteredMilestones: [Milestone] {
        switch selectedFilter {
        case .all:
            return userStore.currentUser.milestones + upcomingMilestones
        case .achieved:
            return userStore.currentUser.milestones
        case .upcoming:
            return upcomingMilestones
        }
    }
}

// Milestone detail view
struct MilestoneDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let milestone: Milestone
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Icon
                Image(systemName: milestone.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(Color.theme.accent)
                    .frame(width: 120, height: 120)
                    .background(Color.theme.accent.opacity(0.2))
                    .clipShape(Circle())
                
                // Title and description
                Text(milestone.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(milestone.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Points awarded
                HStack {
                    Text("Points Awarded:")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(milestone.pointsAwarded)")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                .padding()
                .background(Color.theme.secondaryBackground)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Achievement date (if achieved)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Achievement Date:")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(Color.theme.accent)
                        
                        Text(formattedDate(milestone.dateAchieved))
                            .font(.body)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.theme.secondaryBackground)
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Additional info or tips
                VStack(alignment: .leading, spacing: 10) {
                    Text("Achievement Tips:")
                        .font(.headline)
                    
                    Text(achievementTip(for: milestone))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.theme.secondaryBackground)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
                // Close button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.accent)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .padding(.top, 30)
        }
    }
    
    // Format the date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Get tips for achieving the milestone
    private func achievementTip(for milestone: Milestone) -> String {
        // In a real app, you would have custom tips for each milestone
        // This is a placeholder implementation
        if milestone.title.contains("Track") {
            return "Make sure to log your vaping sessions consistently. Even if you forget, you can add past sessions later by selecting the date."
        } else if milestone.title.contains("Streak") {
            return "Open the app daily to maintain your streak. Using the coping tools or reading educational content counts as app activity."
        } else if milestone.title.contains("Coping") {
            return "Try different coping strategies from the Toolkit section to find what works best for you in different situations."
        } else if milestone.title.contains("Community") {
            return "Engaging with the community not only helps you, but supports others on their journey too. Thoughtful comments earn you bonus points!"
        } else if milestone.title.contains("Goal") {
            return "Set realistic daily goals in your profile section. It's better to succeed with modest goals than to fail with ambitious ones."
        } else {
            return "Keep using the app regularly and exploring its features to unlock more milestones and rewards!"
        }
    }
}

struct MilestonesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MilestonesView()
                .environmentObject(UserStore())
        }
    }
}
