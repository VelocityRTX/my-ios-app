//
//  DistractionToolsView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct DistractionToolsView: View {
    @EnvironmentObject var userStore: UserStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("When you feel a craving, distract yourself with one of these activities:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Grid of distraction tools
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    NavigationLink(destination: QuickGameView()) {
                        DistractionToolCard(
                            title: "Quick Game",
                            imageName: "gamecontroller.fill",
                            color: Color.theme.mauve
                        )
                    }
                    
                    NavigationLink(destination: GratitudeJournalView()) {
                        DistractionToolCard(
                            title: "Gratitude Journal",
                            imageName: "heart.text.square.fill",
                            color: Color.theme.coral
                        )
                    }
                    
                    NavigationLink(destination: QuickBreakTimerView()) {
                        DistractionToolCard(
                            title: "5-Minute Break",
                            imageName: "timer",
                            color: Color.theme.blue
                        )
                    }
                    
                    NavigationLink(destination: AffirmationsView()) {
                        DistractionToolCard(
                            title: "Affirmations",
                            imageName: "text.bubble.fill",
                            color: Color.theme.green
                        )
                    }
                }
                .padding(.horizontal)
                
                // Tips section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Quick Distraction Tips")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    DistractionTipRow(
                        number: "1",
                        tip: "Drink a glass of cold water slowly"
                    )
                    
                    DistractionTipRow(
                        number: "2",
                        tip: "Text a friend who supports your goals"
                    )
                    
                    DistractionTipRow(
                        number: "3",
                        tip: "Do 10 jumping jacks or push-ups"
                    )
                    
                    DistractionTipRow(
                        number: "4",
                        tip: "Listen to your favorite upbeat song"
                    )
                    
                    DistractionTipRow(
                        number: "5",
                        tip: "Step outside for fresh air for 2 minutes"
                    )
                }
                .padding()
                .background(Color.theme.background)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Distraction Tools")
    }
}

// Distraction tool card
struct DistractionToolCard: View {
    let title: String
    let imageName: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.system(size: 36))
                .foregroundColor(.white)
                .frame(width: 70, height: 70)
                .background(color)
                .clipShape(Circle())
                .padding(.bottom, 5)
            
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Distraction tip row
struct DistractionTipRow: View {
    let number: String
    let tip: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(number)
                .font(.headline)
                .frame(width: 28, height: 28)
                .background(Color.theme.accent)
                .foregroundColor(.white)
                .clipShape(Circle())
            
            Text(tip)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

// MARK: - Distraction Tool Implementations

// Quick game view
struct QuickGameView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore: UserStore
    @State private var gameItems = ["🍎", "🍌", "🍒", "🍓", "🍊", "🍋", "🍍", "🥝", "🍇", "🍉", "🥭", "🍑"]
    @State private var gameBoard = Array(repeating: "", count: 16)
    @State private var flippedIndices: [Int] = []
    @State private var matchedIndices: [Int] = []
    @State private var moves = 0
    @State private var gameComplete = false
    
    var body: some View {
        VStack {
            Text("Memory Match")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Find all matching pairs")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            // Game stats
            HStack(spacing: 30) {
                VStack {
                    Text("\(moves)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Moves")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(matchedIndices.count/2)/8")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Pairs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Game grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(0..<16, id: \.self) { index in
                    cardView(index: index)
                }
            }
            .padding()
            
            Spacer()
            
            if gameComplete {
                VStack(spacing: 10) {
                    Text("Game Complete!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("You completed the game in \(moves) moves")
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        userStore.awardPoints(amount: 20, reason: .appUsage, description: "Completing a distraction game")
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Claim 20 Points & Exit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.accent)
                            .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
                .background(Color.theme.background)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding()
            }
        }
        .navigationTitle("Quick Game")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupGame()
        }
    }
    
    private func cardView(index: Int) -> some View {
        let isFlipped = flippedIndices.contains(index) || matchedIndices.contains(index)
        
        return Button(action: {
            flipCard(index: index)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(matchedIndices.contains(index) ? Color.green.opacity(0.3) : Color.theme.secondaryBackground)
                    .aspectRatio(1, contentMode: .fit)
                
                if isFlipped {
                    Text(gameBoard[index])
                        .font(.system(size: 40))
                } else {
                    Text("?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
        }
        .disabled(isFlipped || gameComplete)
    }
    
    private func setupGame() {
        // Shuffle items and select 8
        let selectedItems = Array(gameItems.shuffled().prefix(8))
        
        // Create pairs
        let pairs = selectedItems + selectedItems
        
        // Shuffle and assign to board
        gameBoard = pairs.shuffled()
        
        // Reset game state
        flippedIndices = []
        matchedIndices = []
        moves = 0
        gameComplete = false
    }
    
    private func flipCard(index: Int) {
        // Ignore if already flipped or matched
        if flippedIndices.contains(index) || matchedIndices.contains(index) {
            return
        }
        
        // Add to flipped cards
        flippedIndices.append(index)
        
        // If we have 2 flipped cards, check for a match
        if flippedIndices.count == 2 {
            moves += 1
            
            let firstIndex = flippedIndices[0]
            let secondIndex = flippedIndices[1]
            
            // Check if cards match
            if gameBoard[firstIndex] == gameBoard[secondIndex] {
                matchedIndices.append(firstIndex)
                matchedIndices.append(secondIndex)
                flippedIndices = []
                
                // Check if game is complete
                if matchedIndices.count == gameBoard.count {
                    gameComplete = true
                }
            } else {
                // Not a match, flip back after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    flippedIndices = []
                }
            }
        }
    }
}

// Gratitude journal view
struct GratitudeJournalView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore: UserStore
    @State private var gratitudeText = ""
    @State private var isComplete = false
    @State private var showPrompt = false
    @State private var currentPrompt = ""
    
    let gratitudePrompts = [
        "What's something small that brought you joy today?",
        "Who is someone you're grateful to have in your life?",
        "What's something your body allowed you to do today?",
        "What's a challenge you've overcome recently?",
        "What's something in nature you appreciate?",
        "What's a quality about yourself you're grateful for?",
        "What's something you're looking forward to?",
        "What's a small convenience you often take for granted?",
        "What's something you learned recently that you're grateful for?",
        "What made you smile today?"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            if !isComplete {
                VStack(alignment: .leading, spacing: 15) {
                    Text("When we focus on gratitude, we're less likely to give in to cravings.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    
                    if showPrompt {
                        Text(currentPrompt)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                    }
                    
                    Text("I'm grateful for...")
                        .font(.headline)
                    
                    ZStack(alignment: .topLeading) {
                        if gratitudeText.isEmpty {
                            Text("Write at least three things you're grateful for right now...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $gratitudeText)
                            .frame(minHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.theme.secondaryBackground, lineWidth: 1)
                            )
                            .opacity(gratitudeText.isEmpty ? 0.25 : 1)
                    }
                    
                    Button(action: {
                        showPrompt = true
                        currentPrompt = gratitudePrompts.randomElement() ?? gratitudePrompts[0]
                    }) {
                        Label("Give me a prompt", systemImage: "lightbulb.fill")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.mauve)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        completeJournal()
                    }) {
                        Text("Complete Journal Entry")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(gratitudeText.count >= 10 ? Color.theme.accent : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(gratitudeText.count < 10)
                }
            } else {
                completionView
            }
        }
        .padding()
        .navigationTitle("Gratitude Journal")
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(Color.theme.accent)
            
            Text("Journal Entry Complete")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Great job focusing on gratitude! This practice has been shown to reduce stress and increase resilience to cravings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                userStore.awardPoints(amount: 15, reason: .appUsage, description: "Completing a gratitude journal entry");                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Claim 15 Points & Exit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.accent)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func completeJournal() {
        // In a real app, we would save the journal entry
        isComplete = true
    }
}

// Quick break timer view
struct QuickBreakTimerView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore: UserStore
    
    @State private var timeRemaining = 300 // 5 minutes in seconds
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    @State private var isComplete = false
    @State private var selectedActivity: String? = nil
    
    let activities = [
        "Go for a short walk",
        "Stretch your body",
        "Listen to a favorite song",
        "Tidy up your space",
        "Call or text a friend",
        "Draw or doodle",
        "Read a few pages",
        "Do a quick workout",
        "Practice mindfulness"
    ]
    
    var body: some View {
        VStack {
            if !isComplete {
                if selectedActivity == nil {
                    activitySelectionView
                } else {
                    timerView
                }
            } else {
                completionView
            }
        }
        .padding()
        .navigationTitle("5-Minute Break")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isRunning)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var activitySelectionView: some View {
        VStack(spacing: 20) {
            Text("Choose a 5-minute activity")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Taking a break and doing something else is one of the most effective ways to overcome a craving.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.bottom)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(activities, id: \.self) { activity in
                        Button(action: {
                            selectedActivity = activity
                        }) {
                            HStack {
                                Text(activity)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                        }
                    }
                }
            }
            
            // Custom activity option
            Button(action: {
                selectedActivity = "Your own activity"
            }) {
                Text("I'll choose my own activity")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.accent)
                    .cornerRadius(10)
            }
        }
    }
    
    private var timerView: some View {
        VStack(spacing: 25) {
            Text("5-Minute Break")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            Text(selectedActivity ?? "")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Timer display
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.2)
                    .foregroundColor(Color.theme.accent)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(timeRemaining) / 300.0)
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.theme.accent)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: timeRemaining)
                
                VStack {
                    Text(timeFormatted)
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                    
                    Text("remaining")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 250, height: 250)
            .padding()
            
            // Control buttons
            if isRunning {
                Button(action: {
                    pauseTimer()
                }) {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    startTimer()
                }) {
                    Label(timer == nil ? "Start" : "Resume", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.accent)
                        .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.theme.accent)
                                            .cornerRadius(10)
                                        }
                                    }
                                    
                                    // Skip button
                                    Button(action: {
                                        completeBreak()
                                    }) {
                                        Text("Skip to End")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding()
                                    }
                                }
                            }
                            
                            private var completionView: some View {
                                VStack(spacing: 25) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 70))
                                        .foregroundColor(.green)
                                    
                                    Text("Great Job!")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Text("You've completed your 5-minute break. Taking regular breaks helps reduce stress and manage cravings.")
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    Button(action: {
                                        userStore.awardPoints(amount: 15, reason: .appUsage, description: "Taking a 5-minute break")
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        Text("Claim 15 Points & Exit")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.theme.accent)
                                            .cornerRadius(10)
                                    }
                                }
                                .padding()
                            }
                            
                            private var timeFormatted: String {
                                let minutes = timeRemaining / 60
                                let seconds = timeRemaining % 60
                                return String(format: "%02d:%02d", minutes, seconds)
                            }
                            
                            private func startTimer() {
                                isRunning = true
                                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    if timeRemaining > 0 {
                                        timeRemaining -= 1
                                    } else {
                                        completeBreak()
                                    }
                                }
                            }
                            
                            private func pauseTimer() {
                                isRunning = false
                                timer?.invalidate()
                            }
                            
                            private func completeBreak() {
                                timer?.invalidate()
                                isComplete = true
                            }
                        }

                        // Affirmations view
                        struct AffirmationsView: View {
                            @Environment(\.presentationMode) var presentationMode
                            @EnvironmentObject var userStore: UserStore
                            
                            @State private var currentAffirmationIndex = 0
                            @State private var isWallpaperShown = false
                            @State private var wallpaperAffirmation = ""
                            
                            let affirmations = [
                                "I am stronger than my cravings",
                                "Each day, I'm building a healthier life",
                                "My body thanks me when I make good choices",
                                "I'm in control of my decisions",
                                "I deserve to feel good naturally",
                                "Progress, not perfection",
                                "I'm breaking free from old patterns",
                                "My health is worth fighting for",
                                "I believe in my ability to change",
                                "Every time I resist, I get stronger"
                            ]
                            
                            var body: some View {
                                if isWallpaperShown {
                                    wallpaperView
                                } else {
                                    affirmationView
                                }
                            }
                            
                            private var affirmationView: some View {
                                VStack(spacing: 25) {
                                    Text("Positive Affirmations")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.top)
                                    
                                    Text("Repeat these affirmations to yourself when you feel a craving. Research shows positive self-talk can help you resist unwanted habits.")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                    
                                    // Affirmation card
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(LinearGradient(
                                                gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .shadow(radius: 10)
                                        
                                        VStack {
                                            Text("\"")
                                                .font(.system(size: 60))
                                                .fontWeight(.bold)
                                                .foregroundColor(.white.opacity(0.6))
                                                .padding(.top, -30)
                                            
                                            Text(affirmations[currentAffirmationIndex])
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.white)
                                                .padding()
                                            
                                            Text("\"")
                                                .font(.system(size: 60))
                                                .fontWeight(.bold)
                                                .foregroundColor(.white.opacity(0.6))
                                                .padding(.bottom, -30)
                                        }
                                        .padding()
                                    }
                                    .frame(height: 200)
                                    .padding(.horizontal)
                                    
                                    Spacer()
                                    
                                    // Control buttons
                                    HStack(spacing: 20) {
                                        Button(action: {
                                            withAnimation {
                                                currentAffirmationIndex = (currentAffirmationIndex - 1 + affirmations.count) % affirmations.count
                                            }
                                        }) {
                                            Image(systemName: "arrow.left")
                                                .font(.title2)
                                                .padding()
                                                .background(Color.theme.secondaryBackground)
                                                .clipShape(Circle())
                                        }
                                        
                                        Button(action: {
                                            wallpaperAffirmation = affirmations[currentAffirmationIndex]
                                            isWallpaperShown = true
                                        }) {
                                            Text("Create Wallpaper")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.theme.accent)
                                                .cornerRadius(10)
                                        }
                                        
                                        Button(action: {
                                            withAnimation {
                                                currentAffirmationIndex = (currentAffirmationIndex + 1) % affirmations.count
                                            }
                                        }) {
                                            Image(systemName: "arrow.right")
                                                .font(.title2)
                                                .padding()
                                                .background(Color.theme.secondaryBackground)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding()
                                    
                                    // Exit and claim points
                                    Button(action: {
                                        userStore.awardPoints(amount: 10, reason: .appUsage, description: "Reading affirmations");                          presentationMode.wrappedValue.dismiss()
                                    }) {
                                        Text("Claim 10 Points & Exit")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .padding()
                                    }
                                }
                                .navigationTitle("Affirmations")
                                .navigationBarTitleDisplayMode(.inline)
                            }
                            
                            private var wallpaperView: some View {
                                ZStack {
                                    // Background gradient
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .edgesIgnoringSafeArea(.all)
                                    
                                    // Affirmation text
                                    VStack(spacing: 40) {
                                        Spacer()
                                        
                                        Text(wallpaperAffirmation)
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 30)
                                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                                        
                                        Spacer()
                                        
                                        // App branding
                                        Text("RegretLess")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        // Back button
                                        Button(action: {
                                            isWallpaperShown = false
                                        }) {
                                            Text("Back to Affirmations")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.black.opacity(0.3))
                                                .cornerRadius(10)
                                        }
                                        .padding(.bottom, 50)
                                    }
                                    .navigationBarHidden(true)
                                }
                            }
                        }
