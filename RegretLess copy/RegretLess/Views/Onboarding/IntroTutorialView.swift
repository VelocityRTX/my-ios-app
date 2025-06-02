//
//  IntroTutorialView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/28/25.
//

import SwiftUI

struct IntroTutorialView: View {
    @StateObject private var introViewModel = IntroTutorialViewModel()
    @Binding var showLogin: Bool
    
    
    var body: some View {
        ZStack {
            // Background color
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.background, Color.theme.secondaryBackground.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
            
            // Content based on current page
            VStack {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<getTotalPages(), id: \.self) { index in
                        Circle()
                            .fill(index <= introViewModel.currentPage ? Color.theme.accent : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Show different view based on current page
                if introViewModel.currentPage == 0 {
                    IntroWelcomeView(introViewModel: introViewModel)
                } else if introViewModel.currentPage == 1 {
                    PathSelectionView(introViewModel: introViewModel)
                } else if introViewModel.currentPage >= 2 {
                    // Branch based on selected path
                    if introViewModel.userPath == "quitting" {
                        // Original quitting flow
                        if introViewModel.currentPage == 2 {
                            CombinedVapingDetailsView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 3 {
                            SymptomsView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 4 {
                            QuitReasonView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 5 {
                            ConfidenceView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 6 {
                            GoalSelectionView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 7 {
                            // Only show timeline view for gradual approach
                            if introViewModel.selectedApproach == "Gradual" {
                                TimelineSelectionView(introViewModel: introViewModel)
                            } else {
                                // Skip to notifications for cold turkey
                                NotificationsPermissionView(introViewModel: introViewModel)
                            }
                        } else if introViewModel.currentPage == 8 {
                            // Show notifications or profile picture based on approach
                            if introViewModel.selectedApproach == "Gradual" {
                                NotificationsPermissionView(introViewModel: introViewModel)
                            } else {
                                ProfilePictureSelectionView(introViewModel: introViewModel)
                            }
                        } else if introViewModel.currentPage == 9 {
                            // Show profile picture or summary based on approach
                            if introViewModel.selectedApproach == "Gradual" {
                                ProfilePictureSelectionView(introViewModel: introViewModel)
                            } else {
                                IntroSummaryView(introViewModel: introViewModel, showLogin: $showLogin)
                            }
                        } else if introViewModel.currentPage == 10 {
                            // Only gradual approach reaches here
                            IntroSummaryView(introViewModel: introViewModel, showLogin: $showLogin)
                        }
                    } else if introViewModel.userPath == "learning" {
                        // Learning path flow - with explicit page checks for summary view
                        if introViewModel.currentPage == 2 {
                            LearningReasonView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 3 {
                            LearningTopicsView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 4 {
                            NotificationsPermissionView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 5 {
                            ProfilePictureSelectionView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 6 {
                            // Only show summary view once for learning path
                            LearningPathSummaryView(introViewModel: introViewModel, showLogin: $showLogin)
                        }else {
                            // For any page > 6, show a redirection view
                            // This should never happen due to isLastPage checks
                            // But adding as a safeguard
                            VStack {
                                Text("Continuing to account creation...")
                                    .font(.headline)
                                    .padding()
                                
                                ProgressView()
                            }
                            .onAppear {
                                // Use onAppear to trigger the actions
                                introViewModel.savePreferences()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showLogin = true
                                }
                            }
                        }
                    } else {
                        // Undecided path
                        if introViewModel.currentPage == 2 {
                            UndecidedExplanationView(introViewModel: introViewModel)
                        } else if introViewModel.currentPage == 3 {
                            // After explanation, prompt them to choose again
                            PathSelectionView(introViewModel: introViewModel)
                        }
                    }
                }
                
                // Navigation buttons
                if introViewModel.currentPage > 0 {
                    HStack {
                        // Back button
                        Button(action: {
                            if introViewModel.currentPage > 0 {
                                introViewModel.currentPage -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(introViewModel.currentPage > 0 ? Color.theme.secondaryBackground : Color.clear)
                            .foregroundColor(introViewModel.currentPage > 0 ? Color.theme.accent : Color.clear)
                            .cornerRadius(20)
                            .opacity(introViewModel.currentPage > 0 ? 1 : 0)
                        }
                        .disabled(introViewModel.currentPage == 0)
                        
                        Spacer()
                        
                        // Next button
                        Button(action: {
                            // Handle different paths based on approach
                            let maxPages = getTotalPages() - 1
                            
                            if introViewModel.currentPage < maxPages {
                                introViewModel.currentPage += 1
                            } else {
                                introViewModel.savePreferences()
                                showLogin = true
                            }
                        }) {
                            HStack {
                                Text(isLastPage() ? "Finish" : "Next")
                                Image(systemName: "chevron.right")
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(color: Color.theme.accent.opacity(0.3), radius: 3, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    // Helper to determine if we're on the last page based on approach
    private func isLastPage() -> Bool {
        if introViewModel.userPath == "quitting" {
            return (introViewModel.selectedApproach == "Gradual" && introViewModel.currentPage == 10) ||
                   (introViewModel.selectedApproach == "Cold Turkey" && introViewModel.currentPage == 9)
        } else if introViewModel.userPath == "learning" {
            return introViewModel.currentPage == 6
        }
        return false
    }

    // Helper to get total number of pages based on approach and path
    private func getTotalPages() -> Int {
        if introViewModel.userPath == "quitting" {
            return introViewModel.selectedApproach == "Gradual" ? 11 : 10
        } else if introViewModel.userPath == "learning" {
            return 7
        }
        return 7 // Default value
    }
}

struct PathSelectionView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    @State private var showingExplanation = false
    
    var body: some View {
        VStack(spacing: 25) {
            Text("I want to use RegretLess to...")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()
            
            // Not sure button - now first
            Button(action: {
                showingExplanation = true
            }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.gray)
                        .frame(width: 60, height: 60)
                        .background(Color.theme.secondaryBackground)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("I'm Not Sure")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Help me understand my options")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.theme.secondaryBackground.opacity(0.3))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            .sheet(isPresented: $showingExplanation) {
                UndecidedExplanationView(introViewModel: introViewModel)
            }
            
            // Then the other two buttons
            Button(action: {
                introViewModel.userPath = "quitting"
            }) {
                pathOptionCard(
                    title: "Quit Vaping",
                    description: "Get help and support for reducing or stopping vaping",
                    iconName: "lungs.fill",
                    isSelected: introViewModel.userPath == "quitting"
                )
            }
            
            Button(action: {
                introViewModel.userPath = "learning"
            }) {
                pathOptionCard(
                    title: "Learn About Vaping",
                    description: "Get facts and information about vaping and its effects",
                    iconName: "book.fill",
                    isSelected: introViewModel.userPath == "learning"
                )
            }
        }
        .padding()
    }
    
    private func pathOptionCard(title: String, description: String, iconName: String, isSelected: Bool) -> some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 30))
                .foregroundColor(isSelected ? .white : Color.theme.accent)
                .frame(width: 60, height: 60)
                .background(isSelected ? Color.theme.accent : Color.theme.accent.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? Color.theme.accent : .primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? Color.theme.accent : .gray)
        }
        .padding()
        .background(isSelected ? Color.theme.accent.opacity(0.1) : Color.theme.secondaryBackground.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.theme.accent : Color.clear, lineWidth: 2)
        )
    }
}

// Add this to IntroTutorialView.swift
struct QuitReasonView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    
    let reasons = [
        "Health concerns",
        "Cost savings",
        "Social pressure",
        "Setting an example",
        "Freedom from addiction",
        "Improved fitness",
        "Better mental clarity",
        "Family concerns"
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Why Do You Want to Quit?")
                    .font(.largeTitle)
                    .padding()
                
                Text("Select all that apply")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: {
                            // Toggle selection
                            if introViewModel.quitReasons.contains(reason) {
                                introViewModel.quitReasons.remove(reason)
                            } else {
                                introViewModel.quitReasons.insert(reason)
                            }
                        }) {
                            HStack {
                                Text(reason)
                                    .padding()
                                
                                Spacer()
                                
                                Image(systemName: introViewModel.quitReasons.contains(reason) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(introViewModel.quitReasons.contains(reason) ? Color.theme.accent : .gray)
                            }
                            .padding(.horizontal)
                            .background(Color.theme.secondaryBackground.opacity(0.3))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                VStack(alignment: .leading) {
                    Text("Tell us more about why you want to quit:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $introViewModel.personalQuitReason)
                        .frame(minHeight: 100)
                        .padding(5)
                        .background(Color.theme.secondaryBackground)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// Add this to IntroTutorialView.swift
struct NotificationsPermissionView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    @State private var hasAskedPermission = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Stay Motivated")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundColor(Color.theme.accent)
                .padding()
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.theme.accent)
                .padding()
                .background(Color.theme.accent.opacity(0.1))
                .clipShape(Circle())
            
            Text("Enable notifications to get reminders, track your progress, and celebrate your achievements")
                .font(.headline)
                .foregroundColor(Color.theme.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("You can change this later in your settings")
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
                .padding(.top, 5)
            
            VStack(spacing: 15) {
                Button(action: {
                    requestNotificationPermission()
                }) {
                    Text("Enable Notifications")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.theme.accent.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                
                Button(action: {
                    introViewModel.notificationsEnabled = false
                    // Manually proceed to next page
                    introViewModel.currentPage += 1
                }) {
                    Text("Not Now")
                        .padding()
                        .foregroundColor(Color.theme.secondaryText)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.theme.background)
    }
    
    private func requestNotificationPermission() {
        introViewModel.notificationsEnabled = true
        hasAskedPermission = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // We need to use the main thread to update UI properties
            DispatchQueue.main.async {
                // Move to next page after permission prompt regardless of result
                introViewModel.currentPage += 1
            }
        }
    }
}

    struct CombinedVapingDetailsView: View {
        @ObservedObject var introViewModel: IntroTutorialViewModel
        
        let vapeTypes = [
            "Disposable (Puff Bar, etc.)",
            "Pod System (JUUL, etc.)",
            "Box Mod",
            "Vape Pen",
            "Other"
        ]
        
        let mainReasons = [
            "Stress relief",
            "Enjoyment",
            "Social habit",
            "Nicotine addiction",
            "Boredom",
            "Weight management",
            "Other"
        ]
        
        let nicotineTypes = ["Freebase Nicotine", "Nicotine Salts"]
        
        var body: some View {
            ScrollView {
                VStack(spacing: 25) {
                    Text("Your Vaping Habits")
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .foregroundColor(Color.theme.accent)
                        .padding(.top)
                    
                    Text("Help us understand your current vaping behavior")
                        .font(.headline)
                        .foregroundColor(Color.theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // Days per week slider
                    VStack(alignment: .leading) {
                        Text("How many days per week do you vape?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Text("\(introViewModel.daysPerWeekVaping) days")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        // Centered slider
                        GeometryReader { geometry in
                            VStack {
                                Slider(value: .convert(from: $introViewModel.daysPerWeekVaping), in: 1...7, step: 1)
                                    .accentColor(Color.theme.accent)
                                    .frame(width: geometry.size.width * 0.9)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                        .frame(height: 30)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Do you vape daily
                    VStack(alignment: .leading) {
                        Text("Do you vape daily?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Picker("Daily vaping", selection: $introViewModel.vapesDaily) {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 5)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Times per day
                    VStack(alignment: .leading) {
                        Text("On days you vape, how many times do you use it?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Text("\(introViewModel.vapingFrequency) times")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        // Centered slider
                        GeometryReader { geometry in
                            VStack {
                                Slider(value: .convert(from: $introViewModel.vapingFrequency), in: 1...50, step: 1)
                                    .accentColor(Color.theme.accent)
                                    .frame(width: geometry.size.width * 0.9)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                        .frame(height: 30)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Vape from boredom
                    VStack(alignment: .leading) {
                        Text("Do you find yourself vaping out of boredom?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Picker("Vape from boredom", selection: $introViewModel.vapeFromBoredom) {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 5)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Main reason for vaping
                    VStack(alignment: .leading) {
                        Text("What's your main reason for vaping?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Picker("Main reason", selection: $introViewModel.mainVapingReason) {
                            ForEach(mainReasons, id: \.self) { reason in
                                Text(reason).tag(reason)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.vertical, 5)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Vape type
                    VStack(alignment: .leading) {
                        Text("What type of vape do you use?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Picker("Vape type", selection: $introViewModel.vapeType) {
                            ForEach(vapeTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.vertical, 5)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Nicotine type
                    VStack(alignment: .leading) {
                        Text("What type of nicotine do you use?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Picker("Nicotine type", selection: $introViewModel.nicotineType) {
                            ForEach(nicotineTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 5)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Nicotine strength slider
                    VStack(alignment: .leading) {
                        Text("Nicotine strength (mg):")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Text("\(introViewModel.nicotineStrength) mg")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        // Centered slider
                        GeometryReader { geometry in
                            VStack {
                                Slider(value: .convert(from: $introViewModel.nicotineStrength), in: 0...50, step: 5)
                                    .accentColor(Color.theme.accent)
                                    .frame(width: geometry.size.width * 0.9)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                        .frame(height: 30)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Weekly spending slider
                    VStack(alignment: .leading) {
                        Text("How much do you spend on vaping weekly?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        Text("$\(Int(introViewModel.weeklySpending))")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        // Centered slider
                        GeometryReader { geometry in
                            VStack {
                                Slider(value: $introViewModel.weeklySpending, in: 0...100, step: 5)
                                    .accentColor(Color.theme.accent)
                                    .frame(width: geometry.size.width * 0.9)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                        .frame(height: 30)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
    }

struct SymptomsView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    
    let physicalSymptoms = [
        "Coughing",
        "Shortness of breath",
        "Chest pain",
        "Headaches",
        "Dry mouth/throat",
        "Nausea",
        "Increased heart rate",
        "Dizziness",
        "None"
    ]
    
    let mentalSymptoms = [
        "Anxiety",
        "Irritability",
        "Difficulty concentrating",
        "Mood swings",
        "Depression",
        "Cravings",
        "Sleep issues",
        "None"
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Vaping Symptoms")
                    .font(.largeTitle)
                    .padding()
                
                Text("Select any symptoms you experience when vaping or when you try to stop")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Physical Symptoms")
                        .font(.title2)
                        .padding(.top)
                    
                    VStack(spacing: 10) {
                        ForEach(physicalSymptoms, id: \.self) { symptom in
                            Button(action: {
                                toggleSymptom(symptom: symptom, inSet: &introViewModel.physicalSymptoms)
                            }) {
                                HStack {
                                    Text(symptom)
                                        .padding(.vertical, 5)
                                    
                                    Spacer()
                                    
                                    Image(systemName: introViewModel.physicalSymptoms.contains(symptom) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(introViewModel.physicalSymptoms.contains(symptom) ? Color.theme.accent : .gray)
                                }
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Mental Symptoms")
                        .font(.title2)
                        .padding(.top)
                    
                    VStack(spacing: 10) {
                        ForEach(mentalSymptoms, id: \.self) { symptom in
                            Button(action: {
                                toggleSymptom(symptom: symptom, inSet: &introViewModel.mentalSymptoms)
                            }) {
                                HStack {
                                       Text(symptom)
                                           .padding(.vertical, 5)
                                       
                                       Spacer()
                                       
                                       Image(systemName: introViewModel.mentalSymptoms.contains(symptom) ? "checkmark.square.fill" : "square")
                                           .foregroundColor(introViewModel.mentalSymptoms.contains(symptom) ? Color.theme.accent : .gray)
                                   }
                                   .padding(.horizontal)
                               }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
    }
    
    // Add this function to the SymptomsView
    private func toggleSymptom(symptom: String, inSet: inout Set<String>) {
        if symptom == "None" {
            // If "None" was selected
            if inSet.contains("None") {
                // If already contains None, remove it (toggle behavior)
                inSet.remove("None")
            } else {
                // Clear all other selections and set to None
                inSet.removeAll()
                inSet.insert("None")
            }
        } else {
            // If a regular symptom was selected
            if inSet.contains(symptom) {
                // Remove if already selected (toggle behavior)
                inSet.remove(symptom)
            } else {
                // Add the selected symptom and remove "None" if present
                inSet.insert(symptom)
                inSet.remove("None")
            }
        }
    }
}

struct ConfidenceView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Confidence in Quitting")
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .foregroundColor(Color.theme.accent)
                    .padding()
                
                Text("How confident are you in your ability to quit vaping?")
                    .font(.headline)
                    .foregroundColor(Color.theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Confidence slider
                VStack {
                    HStack {
                        Text("Not confident")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Spacer()
                        
                        Text("Very confident")
                            .font(.caption)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                    .padding(.horizontal, 20)
                    
                    // Centered slider
                    GeometryReader { geometry in
                        VStack {
                            Slider(value: .convert(from: $introViewModel.confidenceLevel), in: 1...10, step: 1)
                                .accentColor(Color.theme.accent)
                                .frame(width: geometry.size.width * 0.9)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .frame(height: 30)
                    
                    Text("\(introViewModel.confidenceLevel)/10")
                        .font(.headline)
                        .foregroundColor(Color.theme.text)
                        .padding(.top, 5)
                }
                .padding()
                .background(Color.theme.secondaryBackground.opacity(0.3))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Different questions based on confidence level
                VStack(alignment: .leading) {
                    if introViewModel.confidenceLevel < 5 {
                        Text("What makes quitting difficult for you?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        TextEditor(text: $introViewModel.lackOfConfidenceReason)
                            .frame(minHeight: 100)
                            .padding(5)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                    } else if introViewModel.confidenceLevel == 5 {
                        Text("What would make you feel more confident about quitting?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        TextEditor(text: $introViewModel.neutralConfidenceReason)
                            .frame(minHeight: 100)
                            .padding(5)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                    } else {
                        Text("What makes you feel confident about quitting?")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                        
                        TextEditor(text: $introViewModel.highConfidenceReason)
                            .frame(minHeight: 100)
                            .padding(5)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.theme.secondaryBackground.opacity(0.3))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct LearningReasonView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    
    let reasons = [
        "I'm curious about vaping",
        "I'm considering starting",
        "A friend or family member vapes",
        "School project/research",
        "Health concerns",
        "Other reason"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Why are you interested in learning about vaping?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Select all that apply")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 10) {
                    ForEach(reasons, id: \.self) { reason in
                        Button(action: {
                            if introViewModel.learningReasons.contains(reason) {
                                introViewModel.learningReasons.remove(reason)
                            } else {
                                introViewModel.learningReasons.insert(reason)
                            }
                        }) {
                            HStack {
                                Text(reason)
                                    .padding()
                                
                                Spacer()
                                
                                Image(systemName: introViewModel.learningReasons.contains(reason) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(introViewModel.learningReasons.contains(reason) ? Color.theme.accent : .gray)
                            }
                            .padding(.horizontal)
                            .background(Color.theme.secondaryBackground.opacity(0.3))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                if introViewModel.learningReasons.contains("Other reason") {
                    VStack(alignment: .leading) {
                        Text("Tell us more:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TextEditor(text: $introViewModel.otherLearningReason)
                            .frame(minHeight: 100)
                            .padding(5)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct UndecidedExplanationView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 25) {
            Text("How RegretLess Works")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Image(systemName: "info.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.theme.accent)
                .padding()
            
            Text("RegretLess offers two different experiences:")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    Image(systemName: "lungs.fill")
                        .foregroundColor(Color.theme.accent)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading) {
                        Text("Quitting Path")
                            .font(.headline)
                            .foregroundColor(Color.theme.accent)
                        
                        Text("For those who want support to reduce or stop vaping. Includes tracking, personalized plan, and community support.")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "book.fill")
                        .foregroundColor(Color.theme.accent)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading) {
                        Text("Learning Path")
                            .font(.headline)
                            .foregroundColor(Color.theme.accent)
                        
                        Text("For those seeking information about vaping. Includes educational resources, research, and facts about vaping.")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(Color.theme.secondaryBackground.opacity(0.3))
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
            
            Button("I Understand") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.theme.accent)
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }
}

struct LearningTopicsView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    
    let topics = [
        "Health effects of vaping",
        "Vaping vs smoking",
        "Nicotine addiction",
        "Teen vaping trends",
        "Vaping regulations",
        "Ingredients in vape products",
        "How vaping works",
        "Research and studies"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("What would you like to learn about?")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Select topics that interest you")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 10) {
                    ForEach(topics, id: \.self) { topic in
                        Button(action: {
                            if introViewModel.selectedTopics.contains(topic) {
                                introViewModel.selectedTopics.remove(topic)
                            } else {
                                introViewModel.selectedTopics.insert(topic)
                            }
                        }) {
                            HStack {
                                Text(topic)
                                    .padding()
                                
                                Spacer()
                                
                                Image(systemName: introViewModel.selectedTopics.contains(topic) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(introViewModel.selectedTopics.contains(topic) ? Color.theme.accent : .gray)
                            }
                            .padding(.horizontal)
                            .background(Color.theme.secondaryBackground.opacity(0.3))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                Text("We'll customize your experience based on your selections")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
    }
}

struct LearningPathSummaryView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    @Binding var showLogin: Bool
    
    // Create the formatter outside of the view body
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Learning Plan")
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .foregroundColor(Color.theme.accent)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                SummarySection(title: "Your Interests") {
                    if !introViewModel.selectedTopics.isEmpty {
                        Text(Array(introViewModel.selectedTopics).joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(Color.theme.text)
                    } else {
                        Text("No specific topics selected")
                            .font(.body)
                            .foregroundColor(Color.theme.text)
                    }
                }
                
                SummarySection(title: "Why You're Learning") {
                    if !introViewModel.learningReasons.isEmpty {
                        Text(Array(introViewModel.learningReasons).joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(Color.theme.text)
                    }
                    
                    if !introViewModel.otherLearningReason.isEmpty {
                        Text(introViewModel.otherLearningReason)
                            .font(.body)
                            .foregroundColor(Color.theme.text)
                            .padding(.top, 5)
                    }
                }
                
                VStack(alignment: .center, spacing: 20) {
                    Text("You're ready to start learning!")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                        .multilineTextAlignment(.center)
                    
                    Text("Create an account to access educational resources and personalized content")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        print("Continue button pressed")
                        introViewModel.savePreferences()
                        
                        // Add a delay to ensure preferences are saved before transition
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            print("Setting showLogin to true after delay")
                            showLogin = true
                            print("ShowLogin is now: \(showLogin)")
                        }
                    }) {
                        Text("Continue to Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: Color.theme.accent.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color.theme.background)
    }
}
