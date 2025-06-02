//
//  ViewModels.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/12/25.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth
import Firebase

// Add this enum for reward errors
enum RewardError: Error, LocalizedError {
    case insufficientPoints
    case alreadyUnlocked
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .insufficientPoints: return "Not enough points to unlock this reward"
        case .alreadyUnlocked: return "This reward is already unlocked"
        case .notFound: return "Reward not found"
        }
    }
}

// MARK: - Habit Tracking Store

class HabitTrackingStore: ObservableObject {
    @Published var vapingSessions: [VapingSession] = []
    @Published var currentGoal: VapingGoal?
    @Published var weeklySessionCount: Int = 0
    @Published var dailySessionCount: Int = 0
    @Published var triggerAnalytics: [VapingTrigger: Int] = [:]
    @Published var moodAnalytics: [Mood: Int] = [:]
    
    // Sample data for development
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVapingHabitsLoaded),
            name: NSNotification.Name("UserVapingHabitsLoaded"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNicotineInfoLoaded),
            name: NSNotification.Name("UserNicotineInfoLoaded"),
            object: nil
        )
    }
    
    func loadSampleData() {
        // This would be replaced with actual data loading logic from UserDefaults, CoreData, or a backend
        let sampleSession1 = VapingSession(
            date: Date().addingTimeInterval(-86400), // Yesterday
            intensity: 3,
            trigger: .stress,
            location: "School",
            mood: .anxious,
            notes: "After math test",
            cravingLevel: 7
        )
        
        let sampleSession2 = VapingSession(
            date: Date().addingTimeInterval(-43200), // 12 hours ago
            intensity: 2,
            trigger: .social,
            location: "Friend's house",
            mood: .happy,
            notes: nil,
            cravingLevel: 4
        )
        
        vapingSessions = [sampleSession1, sampleSession2]
        updateAnalytics()
    }
    
    func addSession(_ session: VapingSession) {
        vapingSessions.append(session)
        updateAnalytics()
    }
    
    func updateAnalytics() {
        // Calculate daily and weekly counts
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        dailySessionCount = vapingSessions.filter { calendar.isDate($0.date, inSameDayAs: now) }.count
        
        weeklySessionCount = vapingSessions.filter { $0.date >= startOfWeek }.count
        
        // Update trigger analytics
        triggerAnalytics = [:]
        for trigger in VapingTrigger.allCases {
            triggerAnalytics[trigger] = vapingSessions.filter { $0.trigger == trigger }.count
        }
        
        // Update mood analytics
        moodAnalytics = [:]
        for mood in Mood.allCases {
            moodAnalytics[mood] = vapingSessions.filter { $0.mood == mood }.count
        }
    }
    // Add this computed property to the HabitTrackingStore class
    var vapeFreeDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if there are any sessions today
        let hasSessionsToday = vapingSessions.contains { calendar.isDate($0.date, inSameDayAs: today) }
        
        // If there are sessions today, start counting from tomorrow
        var startDate = hasSessionsToday ? calendar.date(byAdding: .day, value: 1, to: today)! : today
        var consecutiveDays = hasSessionsToday ? 0 : 1
        
        // Find the last session date
        if let lastSessionDate = vapingSessions.map({ $0.date }).max() {
            let lastSessionDay = calendar.startOfDay(for: lastSessionDate)
            
            // If the last session was before today, count days from the next day
            if lastSessionDay < today {
                startDate = calendar.date(byAdding: .day, value: 1, to: lastSessionDay)!
                
                // Calculate days between last session and today
                let components = calendar.dateComponents([.day], from: startDate, to: today)
                consecutiveDays = max(0, components.day ?? 0) + 1 // Include today if clean
            }
        }
        
        return consecutiveDays
    }
    // ADD these methods:
    @objc private func handleVapingHabitsLoaded(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let frequency = userInfo["vapingFrequency"] as? Int {
            // You may need to adapt this to your actual properties
            // This is just an example
            self.weeklySessionCount = frequency
        }
        
        if let daysPerWeek = userInfo["daysPerWeekVaping"] as? Int {
            // Store the days per week data
            // Example: self.daysPerWeek = daysPerWeek
        }
        
        // Update analytics display
        updateAnalytics()
        print("✅ HabitTrackingStore updated with vaping habits")
    }

    @objc private func handleNicotineInfoLoaded(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        // Process and store the nicotine information
        // This depends on your HabitTrackingStore properties
        
        print("✅ HabitTrackingStore updated with nicotine info")
    }
}

// MARK: - User Store

class UserStore: ObservableObject {
    @Published var currentUser: User
    @Published var rewards: [Reward] = []
    @Published var availableCopingStrategies: [CopingStrategy] = []
    @Published var pointsHistory: [PointTransaction] = []
    @Published var pendingPointNotifications: [PointNotification] = []
    @Published var unlockedRewards: [Reward] = []
    @Published var showRewardAnimation = false
    @Published var purchasedReward: Reward?
    var habitStore: HabitTrackingStore?
    
    init() {
        // Initialize with sample user
        self.currentUser = User(
            username: "SampleUser",
            joinDate: Date().addingTimeInterval(-30 * 86400), // 30 days ago
            milestones: [],
            streakDays: 3,
            totalPointsEarned: 150,
            cessationPlan: CessationPlan(
                startDate: Date().addingTimeInterval(-15 * 86400), // 15 days ago
                targetQuitDate: Date().addingTimeInterval(30 * 86400), // 30 days from now
                dailyGoals: [],
                strategies: [],
                progressNotes: []
            )
        )
        
        loadSampleData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCessationPlanLoaded),
            name: NSNotification.Name("UserCessationPlanLoaded"),
            object: nil
        )
        
        // Add this observer for spending data
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSpendingDataLoaded),
            name: NSNotification.Name("UserSpendingDataLoaded"),
            object: nil
        )
    }

    @objc private func handleCessationPlanLoaded(notification: Notification) {
        if let plan = notification.userInfo?["cessationPlan"] as? CessationPlan {
            self.currentUser.cessationPlan = plan
            print("✅ UserStore updated with cessation plan")
        }
}
    @objc private func handleSpendingDataLoaded(notification: Notification) {
        if let weeklySpending = notification.userInfo?["weeklySpending"] as? Double {
            self.currentUser.weeklySpending = weeklySpending
            print("✅ UserStore updated with weekly spending: \(weeklySpending)")
        }
        
        if let vapingFrequency = notification.userInfo?["vapingFrequency"] as? Int {
            self.currentUser.vapingFrequency = vapingFrequency
        }
        
        if let daysPerWeekVaping = notification.userInfo?["daysPerWeekVaping"] as? Int {
            self.currentUser.daysPerWeekVaping = daysPerWeekVaping
        }
}
    
    func loadSampleData() {
        // Sample rewards
        rewards = [
            Reward(id: UUID(), title: "Custom Avatar", description: "Unlock special avatar options", pointCost: 100, iconName: "person.crop.circle"),
            Reward(id: UUID(), title: "Theme Colors", description: "Unlock custom app color themes", pointCost: 250, iconName: "paintpalette"),
            Reward(id: UUID(), title: "Meditation Pack", description: "Unlock premium guided meditations", pointCost: 500, iconName: "brain.head.profile")
        ]
        
        // Sample coping strategies
        availableCopingStrategies = [
            CopingStrategy(id: UUID(), title: "Deep Breathing", description: "Take 5 deep breaths when you feel a craving", timesUsed: 12, effectiveness: 4),
            CopingStrategy(id: UUID(), title: "Drink Water", description: "Drink a full glass of water slowly", timesUsed: 8, effectiveness: 3),
            CopingStrategy(id: UUID(), title: "Distraction Activity", description: "Play a quick game or text a friend", timesUsed: 5, effectiveness: 4)
        ]
        
        // Sample milestones
        currentUser.milestones = [
            Milestone(id: UUID(), title: "First Day Complete", description: "You've completed your first day with the app", pointsAwarded: 50, dateAchieved: Date().addingTimeInterval(-14 * 86400), iconName: "1.circle"),
            Milestone(id: UUID(), title: "Tracked 10 Sessions", description: "You've tracked 10 vaping sessions", pointsAwarded: 100, dateAchieved: Date().addingTimeInterval(-7 * 86400), iconName: "10.circle")
        ]
    }
    // Enhanced UserStore methods (update these in ViewModels.swift)

    // Enhanced awardPoints with proper milestone tracking and persistence
    func awardPoints(amount: Int, reason: PointReason, description: String? = nil) {
        guard amount > 0 else { return }
        
        // Update user total
        currentUser.totalPointsEarned += amount
        
        // Record transaction
        let transaction = PointTransaction(
            id: UUID(),
            date: Date(),
            amount: amount,
            reason: reason,
            description: description ?? reason.defaultDescription
        )
        savePointTransaction(transaction)
        
        // Create notification
        let notification = PointNotification(
            id: UUID(),
            points: amount,
            message: description ?? reason.defaultDescription,
            date: Date()
        )
        pendingPointNotifications.append(notification)
        
        // Check for milestones (already have this functionality)
        checkForNewMilestones()
        
        // Save user data
        saveUserData()
    }

    // Add this helper method
    private func savePointTransaction(_ transaction: PointTransaction) {
        pointsHistory.append(transaction)
        // In a real app, you might persist to a database here
        saveUserData() // This calls your existing method
    }

    // Enhanced unlockReward with error handling and persistence
    func unlockRewardOld(_ reward: Reward) -> Bool {
        // Validation checks
        guard !reward.isUnlocked else {
            print("Reward already unlocked")
            return false
        }
        
        guard currentUser.totalPointsEarned >= reward.pointCost else {
            print("Not enough points to unlock this reward")
            return false
        }
        
        // Update reward status
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index].isUnlocked = true
            currentUser.totalPointsEarned -= reward.pointCost
            
            // Add to user's unlocked rewards collection
            currentUser.unlockedRewards.append(rewards[index].id)
            
            // Save changes
            saveUserData()
            
            // Record analytics
            logRewardUnlocked(rewardId: reward.id, rewardTitle: reward.title)
            
            return true
        } else {
            print("Reward not found in available rewards")
            return false
        }
    }
    
    func unlockRewardWithResult(_ reward: Reward) -> Result<Void, RewardError> {
        // Validation checks
        guard !reward.isUnlocked else {
            return .failure(.alreadyUnlocked)
        }
        
        guard currentUser.totalPointsEarned >= reward.pointCost else {
            return .failure(.insufficientPoints)
        }
        
        // Update reward status
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index].isUnlocked = true
            currentUser.totalPointsEarned -= reward.pointCost
            
            // Add to user's unlocked rewards collection
            currentUser.unlockedRewards.append(rewards[index].id)
            
            // Save changes
            saveUserData()
            
            // Record analytics
            logRewardUnlocked(rewardId: reward.id, rewardTitle: reward.title)
            
            return .success(())
        } else {
            return .failure(.notFound)
        }
    }
    
    func unlockReward(_ reward: Reward) -> Bool {
        let result = unlockRewardWithResult(reward)
        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    func processRewardUnlock(_ reward: Reward, completion: @escaping (Bool, RewardError?) -> Void) {
        let result = unlockRewardWithResult(reward)
        
        switch result {
        case .success:
            completion(true, nil)
        case .failure(let error):
            completion(false, error)
        }
    }

    // Comprehensive milestone checking based on user activity
    private func checkForNewMilestones() {
        // Track all milestones that can be awarded
        var newlyAchievedMilestones: [Milestone] = []
        
        // Track session count milestones
        let sessionCount = getSessionCount()
        checkSessionCountMilestones(count: sessionCount, achievedMilestones: &newlyAchievedMilestones)
        
        // Track streak milestones
        checkStreakMilestones(streak: currentUser.streakDays, achievedMilestones: &newlyAchievedMilestones)
        
        // Track points milestones
        checkPointsMilestones(points: currentUser.totalPointsEarned, achievedMilestones: &newlyAchievedMilestones)
        
        // Track engagement milestones (comments, likes, etc.)
        checkEngagementMilestones(achievedMilestones: &newlyAchievedMilestones)
        
        // Award all newly achieved milestones
        for milestone in newlyAchievedMilestones {
            currentUser.milestones.append(milestone)
            
            // Award bonus points for milestone (without triggering recursive milestone checks)
            currentUser.totalPointsEarned += milestone.pointsAwarded
            
            // In a production app, we'd trigger a celebration here
            // triggerMilestoneCelebration(milestone)
        }
        
        // Save if any milestones were achieved
        if !newlyAchievedMilestones.isEmpty {
            saveUserData()
        }
    }

    // These are example milestone check methods (in a real app, these would be more sophisticated)
    private func checkSessionCountMilestones(count: Int, achievedMilestones: inout [Milestone]) {
        // First tracking milestone
        if count >= 5 && !hasMilestone(with: "Track 5 Sessions") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "Track 5 Sessions",
                description: "Log 5 vaping sessions in the tracking tool",
                pointsAwarded: 50,
                dateAchieved: Date(),
                iconName: "doc.text.magnifyingglass"
            ))
        }
        
        // More advanced tracking milestone
        if count >= 20 && !hasMilestone(with: "Track 20 Sessions") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "Track 20 Sessions",
                description: "Log 20 vaping sessions in the tracking tool",
                pointsAwarded: 100,
                dateAchieved: Date(),
                iconName: "doc.text.magnifyingglass"
            ))
        }
    }

    private func checkStreakMilestones(streak: Int, achievedMilestones: inout [Milestone]) {
        // 3-day streak
        if streak >= 3 && !hasMilestone(with: "3-Day Streak") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "3-Day Streak",
                description: "Use the app for 3 days in a row",
                pointsAwarded: 75,
                dateAchieved: Date(),
                iconName: "calendar.badge.clock"
            ))
        }
        
        // 7-day streak
        if streak >= 7 && !hasMilestone(with: "Weekly Streak") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "Weekly Streak",
                description: "Complete 7 consecutive days of app use",
                pointsAwarded: 150,
                dateAchieved: Date(),
                iconName: "calendar"
            ))
        }
    }

    private func checkPointsMilestones(points: Int, achievedMilestones: inout [Milestone]) {
        // 100 points milestone
        if points >= 100 && !hasMilestone(with: "Century Club") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "Century Club",
                description: "Earn 100 points in the app",
                pointsAwarded: 50,
                dateAchieved: Date(),
                iconName: "star.circle.fill"
            ))
        }
        
        // 500 points milestone
        if points >= 500 && !hasMilestone(with: "High Achiever") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "High Achiever",
                description: "Earn 500 points in the app",
                pointsAwarded: 100,
                dateAchieved: Date(),
                iconName: "star.circle.fill"
            ))
        }
    }

    private func checkEngagementMilestones(achievedMilestones: inout [Milestone]) {
        // This would check things like comments made, stories shared, etc.
        // For this example, we'll just simulate it based on existing data
        
        // In a real app, you'd query the actual counts from your data store
        let commentCount = getCommentCount()
        let likesCount = getLikesCount()
        
        if commentCount >= 5 && !hasMilestone(with: "Supportive Friend") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "Supportive Friend",
                description: "Comment on 5 peer stories",
                pointsAwarded: 75,
                dateAchieved: Date(),
                iconName: "bubble.left.fill"
            ))
        }
        
        if likesCount >= 10 && !hasMilestone(with: "Community Supporter") {
            achievedMilestones.append(Milestone(
                id: UUID(),
                title: "Community Supporter",
                description: "Like 10 peer stories or comments",
                pointsAwarded: 50,
                dateAchieved: Date(),
                iconName: "hand.thumbsup.fill"
            ))
        }
    }

    // Helper methods for milestone checking - in a real app, these would query your data store
    private func getSessionCount() -> Int {
        // This would query your database or local storage
        // For now, we'll just return a placeholder
        return 15
    }

    private func getCommentCount() -> Int {
        // This would query your database or local storage
        return 3
    }

    private func getLikesCount() -> Int {
        // This would query your database or local storage
        return 8
    }

    // Save user data to persistent storage
    private func saveUserData() {
        // In a real app, this would save to UserDefaults, CoreData, or a backend
        // For now, we'll just log that we're saving
        print("Saving user data: \(currentUser.username), Points: \(currentUser.totalPointsEarned)")
    }

    // Log events for analytics
    private func logPointsEarned(points: Int, reason: String) {
        // In a real app, this would log to an analytics service
        print("ANALYTICS: User earned \(points) points for \(reason)")
    }

    private func logRewardUnlocked(rewardId: UUID, rewardTitle: String) {
        // In a real app, this would log to an analytics service
        print("ANALYTICS: User unlocked reward: \(rewardTitle)")
    }

    // Helper method to check if a milestone exists by title
    private func hasMilestone(with title: String) -> Bool {
        return currentUser.milestones.contains { $0.title == title }
    }
    // Method to clear notifications after they're displayed
    func dismissPointNotification(_ notification: PointNotification) {
        pendingPointNotifications.removeAll(where: { $0.id == notification.id })
    }

    // Get recent point history
    func getRecentPointHistory(days: Int = 7) -> [PointTransaction] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: today) else {
            return []
        }
        
        return pointsHistory
            .filter { $0.date >= startDate }
            .sorted(by: { $0.date > $1.date })
    }

    // Calculate points earned in a period
    func getPointsForPeriod(days: Int) -> Int {
        getRecentPointHistory(days: days)
            .map { $0.amount }
            .reduce(0, +)
    }

    // Enhanced reward purchase logic
    func purchaseReward(_ reward: Reward) {
        guard currentUser.totalPointsEarned >= reward.pointCost &&
              !reward.isUnlocked else { return }
        
        // Deduct points
        currentUser.totalPointsEarned -= reward.pointCost
        
        // Record transaction
        let transaction = PointTransaction(
            id: UUID(),
            date: Date(),
            amount: -reward.pointCost,
            reason: .rewardPurchased,
            description: "Purchased: \(reward.title)"
        )
        pointsHistory.append(transaction)
        
        // Update reward status
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index].isUnlocked = true
            unlockedRewards.append(rewards[index])
        }
        
        // Save the updated state
        saveUserData()
    }
    // Add these properties to your UserStore class in ViewModels.swift

    // For showing point award animation
    @Published var showPointAnimation = false
    @Published var pointsToShow = 0

    // For showing milestone achievement animation
    @Published var showMilestoneAnimation = false
    @Published var achievedMilestone: Milestone?

    // Enhanced milestone check with animation
    func checkForNewMilestonesWithAnimation() {
        // Store milestone count before check
        let beforeCount = currentUser.milestones.count
        
        // Perform your existing milestone check
        checkForNewMilestones()
        
        // If new milestone was added, show animation
        if currentUser.milestones.count > beforeCount {
            // Get the newest milestone (assuming it's the last one added)
            if let newMilestone = currentUser.milestones.last {
                achievedMilestone = newMilestone
                showMilestoneAnimation = true
                
                // Auto-dismiss after a few seconds or let user dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.showMilestoneAnimation = false
                }
            }
        }
    }
    // Add this function inside the UserStore class
    func getUnlockedRewards() -> [Reward] {
        // Get all rewards that are either in the user's unlockedRewards array
        // or have isUnlocked set to true
        return rewards.filter { reward in
            currentUser.unlockedRewards.contains(reward.id) || reward.isUnlocked
        }
    }
    func dismissMilestoneAnimation() {
        showMilestoneAnimation = false
        achievedMilestone = nil
    }
    func updateDailyVapingGoal(to newGoal: Int) {
        // Update the user model
        currentUser.dailyVapingGoal = newGoal
        
        // Save to Firebase
        saveDailyGoalToFirebase(newGoal: newGoal)
        
        // Notify other components about the change
        NotificationCenter.default.post(
            name: NSNotification.Name("DailyVapingGoalUpdated"),
            object: nil,
            userInfo: ["dailyVapingGoal": newGoal]
        )
    }
    
    // MARK: - Savings Calculations
        
    // MARK: - Savings Calculations
        
    func calculateSavings() -> (current: Double, yearly: Double) {
        // Use the data from currentUser, with proper fallbacks
        let weeklySpending = currentUser.weeklySpending > 0 ? currentUser.weeklySpending : 20.0
        
        // Get vaping frequency from user data with proper fallbacks
        let originalFrequency = currentUser.vapingFrequency > 0 ? currentUser.vapingFrequency : 10
        let daysPerWeek = currentUser.daysPerWeekVaping > 0 ? currentUser.daysPerWeekVaping : 7
        
        // Get start date - either cessation plan start or join date
        let startDate = currentUser.cessationPlan?.startDate ?? currentUser.joinDate
        let weeksActive = max(1.0, Double(Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0) / 7.0)
        
        // Calculate expected sessions and costs
        let originalSessionsPerWeekInt = originalFrequency * daysPerWeek
        let originalSessionsPerWeek = Double(originalSessionsPerWeekInt)
        let expectedTotalSessions = originalSessionsPerWeek * weeksActive
        let costPerSession = originalSessionsPerWeek > 0 ? weeklySpending / originalSessionsPerWeek : 0.0
        
        // Get actual sessions tracked since start date
        var actualSessions = 0.0
        if let habitStore = habitStore {
            let actualSessionsCount = habitStore.vapingSessions.filter { $0.date >= startDate }.count
            actualSessions = Double(actualSessionsCount)
        }
        
        // Calculate savings
        let expectedCost = expectedTotalSessions * costPerSession
        let actualCost = actualSessions * costPerSession
        let currentSavings = expectedCost - actualCost
        
        // Project yearly savings
        let reductionRate = expectedTotalSessions > 0 ? (expectedTotalSessions - actualSessions) / expectedTotalSessions : 0.0
        let yearlySpending = weeklySpending * 52.0
        let projectedYearlySavings = yearlySpending * reductionRate
        
        return (max(0.0, currentSavings), max(0.0, projectedYearlySavings))
    }

    // Helper property to get formatted savings string
    func formattedSavings() -> (current: String, yearly: String) {
        let savings = calculateSavings()
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        let currentString = formatter.string(from: NSNumber(value: savings.current)) ?? "$0"
        let yearlyString = formatter.string(from: NSNumber(value: savings.yearly)) ?? "$0"
        
        return (currentString, yearlyString)
    }

    // Method to save to Firebase
    private func saveDailyGoalToFirebase(newGoal: Int) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No user logged in, can't save goal")
            return
        }
        
        Firestore.firestore().collection("users").document(userId).updateData([
            "dailyVapingGoal": newGoal
        ]) { error in
            if let error = error {
                print("❌ Error saving daily goal: \(error.localizedDescription)")
            } else {
                print("✅ Daily vaping goal saved to Firebase: \(newGoal)")
            }
        }
    }
}

// MARK: - Peer Story Store

class PeerStoryStore: ObservableObject {
    @Published var stories: [PeerStory] = []
    @Published var featuredStories: [PeerStory] = []
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        // Sample peer stories
        stories = [
            PeerStory(
                id: UUID(),
                title: "How I reduced my vaping this month",
                content: "I started by tracking when I vaped most often and realized it was mostly when I was stressed about homework. I started using breathing exercises instead and it's helped me cut down from 10 times a day to just 3.",
                author: "RecoveryJourney",
                datePosted: Date().addingTimeInterval(-7 * 86400),
                tags: ["success", "stress", "reduction"],
                likes: 24,
                comments: [
                    Comment(id: UUID(), author: "SupportiveFriend", content: "That's awesome progress! What breathing exercise worked best for you?", datePosted: Date().addingTimeInterval(-6 * 86400), likes: 5)
                ]
            ),
            PeerStory(
                id: UUID(),
                title: "Struggling after 2 weeks",
                content: "I was doing really well for two weeks but then had a really stressful week with finals and started vaping again. Feeling discouraged but trying to get back on track.",
                author: "Anonymous",
                datePosted: Date().addingTimeInterval(-2 * 86400),
                tags: ["relapse", "school", "stress"],
                likes: 18,
                comments: [
                    Comment(id: UUID(), author: "BeenThereToo", content: "Relapses happen to everyone. Be kind to yourself and just start again tomorrow.", datePosted: Date().addingTimeInterval(-1 * 86400), likes: 7)
                ],
                isAnonymous: true
            )
        ]
        
        // Set featured stories
        featuredStories = [stories[0]]
    }
    
    func addStory(_ story: PeerStory) {
        var newStory = story
        newStory.datePosted = Date()
        stories.insert(newStory, at: 0)
    }

    func addComment(_ comment: Comment, to storyId: UUID) {
        if let index = stories.firstIndex(where: { $0.id == storyId }) {
            stories[index].comments.append(comment)
            
            // If this is a featured story, update it there too
            if let featuredIndex = featuredStories.firstIndex(where: { $0.id == storyId }) {
                featuredStories[featuredIndex].comments.append(comment)
            }
        }
    }

    func likeStory(_ storyId: UUID) {
        if let index = stories.firstIndex(where: { $0.id == storyId }) {
            stories[index].likes += 1
            
            // If this is a featured story, update it there too
            if let featuredIndex = featuredStories.firstIndex(where: { $0.id == storyId }) {
                featuredStories[featuredIndex].likes += 1
            }
        }
    }

    func reportStory(_ storyId: UUID, reason: String) {
        // In a real app, this would send the report to a backend
        print("Story \(storyId) reported for reason: \(reason)")
    }

    func findStoriesByTag(_ tag: String) -> [PeerStory] {
        return stories.filter { $0.tags.contains(tag.lowercased()) }
    }
}

enum PointReason: String, Codable {
    case sessionLogged = "Session Logged"
    case dailyStreak = "Daily Streak"
    case streakMilestone = "Streak Milestone"
    case goalCompleted = "Goal Completed"
    case storyShared = "Story Shared"
    case communityEngagement = "Community Engagement"
    case achievementUnlocked = "Achievement Unlocked"
    case rewardPurchased = "Reward Purchased"
    case appUsage = "App Usage"
    
    var defaultDescription: String {
        switch self {
        case .sessionLogged: return "Logged a vaping session"
        case .dailyStreak: return "Daily streak maintained"
        case .streakMilestone: return "Reached a streak milestone"
        case .goalCompleted: return "Completed a daily goal"
        case .storyShared: return "Shared a story with the community"
        case .communityEngagement: return "Engaged with the community"
        case .achievementUnlocked: return "Unlocked an achievement"
        case .rewardPurchased: return "Purchased a reward"
        case .appUsage: return "Used the app features"
        }
    }
}

struct PointTransaction: Identifiable, Codable {
    let id: UUID
    let date: Date
    let amount: Int
    let reason: PointReason
    let description: String
}

struct PointNotification: Identifiable {
    let id: UUID
    let points: Int
    let message: String
    let date: Date
}
