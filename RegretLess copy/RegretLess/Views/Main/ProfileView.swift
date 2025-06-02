//
//  ProfileView.swift
//  RegretLess
//  Created by Conrad Anton on 4/20/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var habitStore: HabitTrackingStore
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var selectedMilestoneCategory: String = "All"
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isUploading = false
    @State private var showingUploadSuccess = false
    enum ActiveSheet: Identifiable {
        case settings
        
        var id: Int {
            switch self {
            case .settings: return 0
            }
        }
    }

    @State private var activeSheet: ActiveSheet?
    
    // We'll use this for milestone filtering
    private let milestoneCategories = ["All", "Streaks", "Sessions", "Stories", "Tools"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User profile header with streak info
                    ProfileHeaderSection()
                    
                    // Progress summary and stats
                    ProgressSummarySection(user: userStore.currentUser, habitStore: habitStore)
                    
                    // Milestone achievements with category filter
                    MilestonesSection(
                        user: userStore.currentUser,
                        selectedCategory: $selectedMilestoneCategory,
                        categories: milestoneCategories
                    )
                    
                    // Rewards preview
                    RewardsPreviewSection(
                        user: userStore.currentUser,
                        userStore: userStore
                    )
                    
                    // Cessation plan summary if available
                    if let plan = userStore.currentUser.cessationPlan {
                        CessationPlanSection(plan: plan)
                    }
                    
                    // Settings button
                    SettingsButton(activeSheet: $activeSheet)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(Color.theme.secondaryBackground.edgesIgnoringSafeArea(.all))
            .navigationTitle("Profile")
            .sheet(item: $activeSheet) { item in
                switch item {
                case .settings:
                    SettingsSheetView()
                }
            }
        }
    }
    
    // Helper to filter milestones by category
    private func filteredMilestones(_ user: User, category: String) -> [Milestone] {
        if category == "All" {
            return user.milestones
        } else {
            return user.milestones.filter { milestone in
                categorizeAchievement(milestone) == category
            }
        }
    }
    
    // Helper to categorize milestones based on their title or content
    private func categorizeAchievement(_ milestone: Milestone) -> String {
        let title = milestone.title.lowercased()
        
        if title.contains("streak") || title.contains("consecutive") {
            return "Streaks"
        } else if title.contains("session") || title.contains("vaping") {
            return "Sessions"
        } else if title.contains("story") || title.contains("comment") || title.contains("share") {
            return "Stories"
        } else if title.contains("tool") || title.contains("resource") || title.contains("exercise") {
            return "Tools"
        }
        
        return "All"
    }
}

// MARK: - Profile Header Section

struct ProfileHeaderSection: View {
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var isUploading = false
    @State private var showingUploadSuccess = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // Add a state variable to show upload-related errors
    @State private var uploadErrorMessage: String?
    @State private var showingUploadErrorAlert = false
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                // Profile Image section
                Button(action: {
                    sourceType = .photoLibrary
                    isShowingImagePicker = true
                }) {
                    ZStack {
                        // Current profile image or default
                        Group {
                            if let profileImageURL = profileManager.currentUser?.profileImageURL,
                               let url = URL(string: profileImageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        // Consider showing a specific error icon or message here if uploadErrorMessage is set
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                            .foregroundColor(Color.theme.accent)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.theme.secondaryBackground)
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                            .foregroundColor(Color.theme.accent)
                                    )
                            }
                        }
                        
                        // Camera icon on the bottom right
                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.theme.accent)
                            .clipShape(Circle())
                            .offset(x: 25, y: 25)
                        
                        // Upload indicator
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                .frame(width: 80, height: 80)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 5) {
                    Text(profileManager.currentUser?.username ?? "User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Member since \(profileManager.currentUser?.joinDate ?? Date(), style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color.theme.coral)
                        
                        Text("\(profileManager.currentUser?.streakDays ?? 0)-day streak")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
            }
            
            // Show upload button if image is selected but not uploaded
            if selectedImage != nil && !isUploading {
                Button(action: {
                    uploadProfilePicture()
                }) {
                    Text("Save New Picture")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.theme.accent)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
        .alert("Profile Picture Updated", isPresented: $showingUploadSuccess) {
            Button("OK", role: .cancel) { }
        }
        // Add an alert for upload errors
        .alert(isPresented: $showingUploadErrorAlert) {
            Alert(
                title: Text("Upload Failed"),
                message: Text(uploadErrorMessage ?? "An unknown error occurred during upload."),
                dismissButton: .default(Text("OK"))
            )
        }
        // When selectedImage changes, clear previous error message
        .onChange(of: selectedImage) { newValue in
            if newValue != nil {
                uploadErrorMessage = nil
                showingUploadErrorAlert = false
            }
        }
    }
    
    private func uploadProfilePicture() {
        guard let image = selectedImage,
              let userId = Auth.auth().currentUser?.uid else {
            // Handle case where user is not logged in or image is nil (shouldn't happen with button logic)
            uploadErrorMessage = "Could not initiate upload."
            showingUploadErrorAlert = true
            return
        }
        
        isUploading = true
        uploadErrorMessage = nil // Clear previous error messages
        showingUploadErrorAlert = false
        
        profileManager.uploadProfileImage(image, userId: userId) { result in
            // isUploading is set to false inside the result block below
            
            switch result {
            case .success(let imageUrl):
                print("✅ Image uploaded successfully. Attempting to update Firestore URL...")
                profileManager.updateProfilePicture(userId: userId, imageUrl: imageUrl) { success in
                    isUploading = false // Set here after *both* Storage and Firestore attempts
                    if success {
                        print("✅ Firestore profileImageURL updated successfully.")
                        showingUploadSuccess = true
                        selectedImage = nil  // Clear the selected image after successful upload
                    } else {
                        // *** ADDED ERROR HANDLING HERE ***
                        print("❌ Firestore updateProfilePicture failed.")
                        uploadErrorMessage = "Failed to save profile picture URL to profile."
                        showingUploadErrorAlert = true
                        // You might want to keep the selectedImage here so the user can try saving again? Or clear it.
                        // For now, let's clear it to avoid confusion.
                         selectedImage = nil
                    }
                }
            case .failure(let error):
                // *** Existing error handling for Storage upload failure ***
                isUploading = false
                print("❌ Error uploading profile picture to Storage: \(error.localizedDescription)")
                uploadErrorMessage = "Failed to upload image: \(error.localizedDescription)"
                showingUploadErrorAlert = true
                selectedImage = nil // Clear the selected image on upload failure
            }
        }
    }
}

// MARK: - Progress Summary Section

struct ProgressSummarySection: View {
    let user: User
    let habitStore: HabitTrackingStore
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Your Progress")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Streak Progress
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(user.streakDays) Days")
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
                    
                    let progress = calculateProgress(user: user)
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
            
            // Quick Stats Grid
            HStack(spacing: 0) {
                StatBox(
                    title: "Vape-Free Days",
                    value: "\(habitStore.vapeFreeDays)",
                    icon: "checkmark.circle.fill",
                    color: Color.theme.green
                )
                
                StatBox(
                    title: "Points Earned",
                    value: "\(user.totalPointsEarned)",
                    icon: "star.fill",
                    color: Color.theme.coral
                )
                
                StatBox(
                    title: "Milestones",
                    value: "\(user.milestones.count)",
                    icon: "flag.fill",
                    color: Color.theme.mauve
                )
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func calculateProgress(user: User) -> CGFloat {
        if let plan = user.cessationPlan, let targetDate = plan.targetQuitDate {
            let calendar = Calendar.current
            let startDate = plan.startDate
            let currentDate = Date()
            
            let totalDays = max(1, calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 1)
            let progressDays = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
            
            return min(CGFloat(progressDays) / CGFloat(totalDays), 1.0)
        } else {
            // If no cessation plan, calculate based on milestones
            // Assuming a typical user might achieve around 20 milestones
            let totalExpectedMilestones = 20
            let achievedMilestones = user.milestones.count
            
            return min(CGFloat(achievedMilestones) / CGFloat(totalExpectedMilestones), 1.0)
        }
    }
}

// MARK: - Stat Box Component

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}

// MARK: - Milestones Section

struct MilestonesSection: View {
    let user: User
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Achievements")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: MilestonesView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.primary)
                }
            }
            
            // Categories selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        CategoryButton(
                            title: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
            }
            .padding(.vertical, 5)
            
            // Milestone cards in grid
            if !filteredMilestones().isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(filteredMilestones()) { milestone in
                        // Use the existing MilestoneCard component with isLocked = false
                        MilestoneCard(milestone: milestone, isLocked: false)
                            .frame(height: 180) // Adjust height to fit in grid
                    }
                }
            } else {
                Text("No \(selectedCategory.lowercased()) achievements yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Helper to filter milestones by category
    private func filteredMilestones() -> [Milestone] {
        if selectedCategory == "All" {
            return user.milestones
        } else {
            return user.milestones.filter { milestone in
                categorizeAchievement(milestone) == selectedCategory
            }
        }
    }
    
    // Helper to categorize milestones based on their title or content
    private func categorizeAchievement(_ milestone: Milestone) -> String {
        let title = milestone.title.lowercased()
        
        if title.contains("streak") || title.contains("consecutive") {
            return "Streaks"
        } else if title.contains("session") || title.contains("vaping") {
            return "Sessions"
        } else if title.contains("story") || title.contains("comment") || title.contains("share") {
            return "Stories"
        } else if title.contains("tool") || title.contains("resource") || title.contains("exercise") {
            return "Tools"
        }
        
        return "All"
    }
}

// MARK: - Category Button Component

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.theme.accent.opacity(0.2) : Color.theme.background)
                .foregroundColor(isSelected ? Color.theme.accent : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.theme.accent : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Rewards Preview Section

struct RewardsPreviewSection: View {
    let user: User
    let userStore: UserStore  // Add this line to receive userStore
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Rewards")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: RewardsView()) {
                    Text("Shop")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.primary)
                }
            }
            
            // Points Card
            PointsCard(points: user.totalPointsEarned)
            
            // Unlocked Rewards (if any)
            if hasUnlockedRewards() {
                Text("Recent Rewards")
                    .font(.headline)
                    .padding(.top, 5)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(getUnlockedRewards().prefix(3)) { reward in
                            // Use your existing RewardCard from RewardCard.swift
                            RewardCard(
                                reward: reward,
                                isUnlocked: true,  // Since these are unlocked rewards in the profile
                                canAfford: true    // Not relevant for already unlocked rewards
                            )
                                .frame(width: 130, height: 180)
                        }
                    }
                    .padding(.vertical, 5)
                }
            } else {
                Text("No rewards unlocked yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Helper function to check if user has unlocked rewards
    private func hasUnlockedRewards() -> Bool {
        return !userStore.getUnlockedRewards().isEmpty
    }
    
    // Helper function to get unlocked rewards
    // Note: You'll need to adjust this to match your actual implementation
    private func getUnlockedRewards() -> [Reward] {

        // This is a placeholder implementation - you'll need to implement this
        // based on how your app stores and retrieves unlocked rewards
        // Replace with actual implementation
        return userStore.getUnlockedRewards()
    }
}

// MARK: - Points Card Component

struct PointsCard: View {
    let points: Int
    
    var body: some View {
        HStack {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.theme.accent)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(points) Points Available")
                    .font(.headline)
                
                Text("Use your points to unlock rewards")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.theme.secondaryBackground)
        .cornerRadius(15)
    }
}

// MARK: - Cessation Plan Section

struct CessationPlanSection: View {
    let plan: CessationPlan
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Cessation Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: CessationPlanView(plan: userStore.currentUser.cessationPlan ?? CessationPlan(
                    id: UUID(),
                    startDate: Date(),
                    targetQuitDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
                    dailyGoals: [],
                    strategies: [],
                    progressNotes: []
                ))) {
                    Text("View Plan")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.primary)
                }
            }
            
            if let targetDate = plan.targetQuitDate {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Target Quit Date:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(targetDate, style: .date)
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Days Remaining:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(daysUntilQuit)")
                            .font(.headline)
                    }
                }
                .padding(.top, 5)
                Divider()
                    .padding(.vertical, 5)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Today's Goal:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Max \(userStore.currentUser.dailyVapingGoal) vaping sessions")
                        .font(.headline)
                }
                
                // Show latest progress note if available
                if let latestNote = getLatestProgressNote() {
                    Divider()
                        .padding(.vertical, 5)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Latest Note:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(latestNote.content)
                            .font(.caption)
                            .lineLimit(2)
                    }
                }
            } else {
                Text("Plan in progress")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Days until target quit date
    var daysUntilQuit: Int {
        if let targetDate = plan.targetQuitDate {
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
            return max(0, days)
        }
        return 0
    }
    
    // Get the most recent progress note
    private func getLatestProgressNote() -> ProgressNote? {
        return plan.progressNotes.sorted { $0.date > $1.date }.first
    }
}

// MARK: - Settings Button Component

struct SettingsButton: View {
    @Binding var activeSheet: ProfileView.ActiveSheet?
    
    var body: some View {
        Button(action: {
            activeSheet = .settings
        }) {
            HStack {
                Image(systemName: "gear")
                Text("Settings")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.theme.background)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Settings Sheet View

struct SettingsSheetView: View {
    @EnvironmentObject var userStore: UserStore
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: .constant(userStore.currentUser.notificationsEnabled))
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        Text("Notification Settings")
                    }
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("Private Profile", isOn: .constant(userStore.currentUser.profileIsPrivate))
                }
                
                Section {
                    Button(action: {
                        // Log out action
                        authManager.logoutUser { success in
                            if success {
                                UserDefaults.standard.set(false, forKey: "isLoggedIn")
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
