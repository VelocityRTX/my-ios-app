//
//  MainTabView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/12/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MainTabView: View {
    @State private var selectedTab = 0

    // Get environment objects for data
    @EnvironmentObject var habitStore: HabitTrackingStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storyStore: PeerStoryStore
    @EnvironmentObject var profileManager: UserProfileManager
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard/Home Tab
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            // Track Vaping Tab
            TrackingView()
                .tabItem {
                    Label("Track", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            // Peer Stories Tab
            PeerStoriesView()
                .tabItem {
                    Label("Stories", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(2)
            
            // Toolkit Tab (Coping Strategies)
            ToolkitView()
                .tabItem {
                    Label("Toolkit", systemImage: "briefcase.fill")
                }
                .tag(3)
            
            // Profile/Rewards Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(Color.theme.accent)
        .onAppear {
            // Set habitStore reference for userStore
            userStore.habitStore = habitStore
            
            if let userId = Auth.auth().currentUser?.uid {
                print("⭐️ Main app appeared, loading user profile...")
                profileManager.loadUserProfile(userId: userId)
            }
            // Customize the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .padding(.vertical, 5)
    }
}

struct ToolkitView: View {
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Coping Toolkit")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tools and strategies to help you manage cravings and reduce vaping")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Quick Relief section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Relief")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                NavigationLink(destination: BreathingExerciseView()) {
                                    QuickReliefCard(
                                        title: "Breathing",
                                        subtitle: "Reduce anxiety",
                                        imageName: "wind",
                                        color: Color.theme.blue
                                    )
                                }
                                
                                NavigationLink(destination: DistractionToolsView()) {
                                    QuickReliefCard(
                                        title: "Distraction",
                                        subtitle: "Redirect your focus",
                                        imageName: "gamecontroller",
                                        color: Color.theme.mauve
                                    )
                                }
                                
                                NavigationLink(destination: AffirmationsView()) {
                                    QuickReliefCard(
                                        title: "Affirmations",
                                        subtitle: "Positive reminders",
                                        imageName: "text.bubble.fill",
                                        color: Color.theme.green
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Strategies section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Coping Strategies")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ForEach(userStore.availableCopingStrategies) { strategy in
                            NavigationLink(destination: StrategyDetailView(strategy: strategy)) {
                                CopingStrategyCard(strategy: strategy)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Resources section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Resources")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: EducationalContentView()) {
                            ResourceCard(
                                title: "Learn About Vaping",
                                description: "Facts, health effects, and science",
                                imageName: "book.fill",
                                color: Color.theme.coral
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: SupportResourcesView()) {
                            ResourceCard(
                                title: "Support Resources",
                                description: "Hotlines, websites, and local help",
                                imageName: "person.3.fill",
                                color: Color.theme.primary
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(Color.theme.background.edgesIgnoringSafeArea(.all))
            .navigationBarHidden(true)
        }
    }
}

// Quick relief card
struct QuickReliefCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: imageName)
                .font(.system(size: AppSettings.smallIconSize))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
            
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 150, height: 160)
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Coping strategy card
struct CopingStrategyCard: View {
    let strategy: CopingStrategy
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: AppSettings.smallIconSize))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.theme.accent)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(strategy.title)
                    .font(.headline)
                
                Text(strategy.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("Used \(strategy.timesUsed)×")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let effectiveness = strategy.effectiveness {
                    HStack(spacing: 0) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= effectiveness ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(star <= effectiveness ? .yellow : .gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Resource card
struct ResourceCard: View {
    let title: String
    let description: String
    let imageName: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: imageName)
                .font(.system(size: AppSettings.smallIconSize))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StrategyRowView: View {
    let strategy: CopingStrategy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(strategy.title)
                .font(.headline)
            
            HStack {
                Text("Used \(strategy.timesUsed) times")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let effectiveness = strategy.effectiveness {
                    Text("Rating: \(effectiveness)/5")
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

struct StrategyDetailView: View {
    let strategy: CopingStrategy
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(strategy.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Divider()
                
                Text(strategy.description)
                    .lineSpacing(5)
                
                Button(action: {
                    // Mark as used functionality
                }) {
                    Text("I Used This Strategy")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.accent)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                if let effectiveness = strategy.effectiveness {
                    HStack {
                        Text("Your rating:")
                        
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= effectiveness ? "star.fill" : "star")
                                .foregroundColor(star <= effectiveness ? .yellow : .gray)
                        }
                    }
                    .padding(.top)
                } else {
                    Text("Rate effectiveness:")
                        .padding(.top)
                    
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Button(action: {
                                // Rate functionality
                            }) {
                                Image(systemName: "star")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Strategy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views

struct ProgressSummaryCard: View {
    @EnvironmentObject var habitStore: HabitTrackingStore
    @EnvironmentObject var userStore: UserStore
    var targetQuitDate: Date?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Progress")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(userStore.currentUser.streakDays) Days")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(Color.theme.secondaryBackground, lineWidth: 10)
                        .frame(width: 70, height: 70)
                    
                    let progress = calculateProgress()
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(progress >= 1.0 ? Color.theme.green : Color.theme.accent,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            
            if let targetDate = targetQuitDate {
                let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
                
                if daysRemaining > 0 {
                    Text("\(daysRemaining) days until target quit date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("You've reached your target quit date!")
                        .font(.caption)
                        .foregroundColor(Color.theme.green)
                }
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Calculate progress based on target date
    private func calculateProgress() -> CGFloat {
        guard let targetDate = targetQuitDate else {
            return 0.1 // Default if no target date
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // If target date is in the future, calculate progress differently
        if targetDate > now {
            // Assume a 30-day plan if we don't have a specific start date
            let estimatedStartDate = calendar.date(byAdding: .day, value: -30, to: targetDate) ??
                                    calendar.date(byAdding: .day, value: -30, to: now) ?? now
            
            // If we're before the estimated start date, show minimal progress
            if now < estimatedStartDate {
                return 0.05
            }
            
            // Calculate progress from start date to target date
            let totalDays = max(1, calendar.dateComponents([.day], from: estimatedStartDate, to: targetDate).day ?? 30)
            let progressDays = calendar.dateComponents([.day], from: estimatedStartDate, to: now).day ?? 0
            
            // Ensure progress is between 0% and 100%
            return max(0.05, min(CGFloat(progressDays) / CGFloat(totalDays), 1.0))
        } else {
            // If we've passed the target date, show 100%
            return 1.0
        }
    }
}

struct DailyGoalCard: View {
    @EnvironmentObject var habitStore: HabitTrackingStore
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Goal")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    // Use the centralized dailyVapingGoal value
                    Text("Maximum \(userStore.currentUser.dailyVapingGoal) vaping sessions")
                        .font(.subheadline)
                    
                    Text("\(habitStore.dailySessionCount)/\(userStore.currentUser.dailyVapingGoal) so far")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(habitStore.dailySessionCount <= userStore.currentUser.dailyVapingGoal ? .primary : .red)
                }
                
                Spacer()
                
                Image(systemName: habitStore.dailySessionCount <= userStore.currentUser.dailyVapingGoal ? "checkmark.circle" : "exclamationmark.circle")
                    .font(.system(size: 30))
                    .foregroundColor(habitStore.dailySessionCount <= userStore.currentUser.dailyVapingGoal ? .green : .red)
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatsGridView: View {
    @EnvironmentObject var habitStore: HabitTrackingStore
    var weeklyCount: Int
    var mainTrigger: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Stats")
                .font(.headline)
            
            HStack {
                StatItemView(
                    title: "Weekly",
                    value: "\(weeklyCount)",
                    icon: "calendar",
                    color: Color.theme.primary
                )
                
                Spacer()
                
                StatItemView(
                    title: "Top Trigger",
                    value: shortenedTrigger(mainTrigger),
                    icon: "exclamationmark.triangle",
                    color: Color.theme.mauve
                )
                
                Spacer()
                
                StatItemView(
                    title: "Vape-Free Days",
                    value: "\(habitStore.vapeFreeDays)",
                    icon: "checkmark.circle",
                    color: Color.theme.green
                )
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Helper to shorten long trigger names
    private func shortenedTrigger(_ trigger: String) -> String {
        let components = trigger.components(separatedBy: " ")
        if components.count > 1 && trigger.count > 10 {
            return components[0]
        }
        return trigger
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentStoriesCard: View {
    @EnvironmentObject var storyStore: PeerStoryStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Stories")
                .font(.headline)
            
            if storyStore.stories.isEmpty {
                Text("No stories yet")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(storyStore.stories.prefix(2)) { story in
                    NavigationLink {
                        StoryDetailView(story: story)
                    } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(story.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Text(story.content)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    if story.id != storyStore.stories[min(1, storyStore.stories.count - 1)].id {
                        Divider()
                    }
                }
            }
            
            NavigationLink(destination: PeerStoriesView()) {
                Text("See All Stories")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TipsCard: View {
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Coping Tip")
                .font(.headline)
            
            if let strategy = userStore.availableCopingStrategies.randomElement() {
                VStack(alignment: .leading, spacing: 5) {
                    Text(strategy.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(strategy.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 5)
            } else {
                Text("No tips available")
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            NavigationLink(destination: ToolkitView()) {
                Text("See All Tips")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SavingsCard: View {
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Money Saved")
                .font(.headline)
            
            let savings = userStore.formattedSavings()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("So far:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(savings.current)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Yearly projection:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(savings.yearly)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.accent)
                }
            }
            
            Text("Based on your reduction in vaping frequency")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        Text("Notification Settings View")
    }
}

// MARK: - Utils

extension Binding where Value == Double {
    static func convert(from intBinding: Binding<Int>) -> Binding<Double> {
        Binding<Double>(
            get: { Double(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = Int($0) }
        )
    }
}

// MARK: - Tab View Previews

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(HabitTrackingStore())
            .environmentObject(UserStore())
            .environmentObject(PeerStoryStore())
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @EnvironmentObject var habitStore: HabitTrackingStore
    @EnvironmentObject var userStore: UserStore
    @State private var targetQuitDate: Date?
    @State private var vapingFrequency: Int = 0
    @State private var daysPerWeekVaping: Int = 0
    @State private var mainTrigger: String = ""
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress summary card
                    ProgressSummaryCard(targetQuitDate: targetQuitDate)
                    
                    // Today's goal
                    DailyGoalCard()
                    
                    // savings stats
                    SavingsCard()
                    
                    // Quick stats
                    StatsGridView(weeklyCount: daysPerWeekVaping * vapingFrequency, mainTrigger: mainTrigger)
                    
                    // Recent peer stories
                    RecentStoriesCard()
                    
                    // Tips and coping strategies
                    TipsCard()
                    
                        .onAppear {
                            loadUserData()
                        }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        }
    }
    
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No user logged in")
            return
        }
        
        isLoading = true
        
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            isLoading = false
            
            if let error = error {
                print("❌ Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("❌ No user document found")
                return
            }
            
            // Load target quit date
            if let cessationPlanData = data["cessationPlan"] as? [String: Any] {
                if let targetDate = cessationPlanData["targetQuitDate"] as? Timestamp {
                    self.targetQuitDate = targetDate.dateValue()
                }
            }
            
            // Load vaping frequency & daily goal
            if let dailyGoal = data["dailyVapingGoal"] as? Int {
                // Update UserStore with the daily goal
                DispatchQueue.main.async {
                    self.userStore.currentUser.dailyVapingGoal = dailyGoal
                }
            }
            
            // Keep loading other data
            if let frequency = data["vapingFrequency"] as? Int {
                self.vapingFrequency = frequency
            }
            
            if let daysPerWeek = data["daysPerWeekVaping"] as? Int {
                self.daysPerWeekVaping = daysPerWeek
            }
            
            if let trigger = data["mainVapingReason"] as? String {
                self.mainTrigger = trigger
            }
            
            print("✅ User dashboard data loaded")
        }
    }
}

// MARK: - Placeholder Views
// These views are shown as basic structures and would be expanded in the actual implementation
