//
//  BreathingExerciseView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct BreathingExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore: UserStore
    
    @State private var breathingState: BreathingState = .initial
    @State private var animationAmount: CGFloat = 1.0
    @State private var breathCount = 0
    @State private var showingCompletionAlert = false
    @State private var selectedExerciseIndex = 0
    
    enum BreathingState {
        case initial, inhale, hold, exhale, complete
    }
    
    let breathingExercises = [
        BreathingExercise(
            name: "4-7-8 Technique",
            description: "Inhale for 4 seconds, hold for 7 seconds, exhale for 8 seconds",
            inhaleDuration: 4.0,
            holdDuration: 7.0,
            exhaleDuration: 8.0,
            cycles: 4
        ),
        BreathingExercise(
            name: "Box Breathing",
            description: "Inhale, hold, exhale, and hold again for equal counts",
            inhaleDuration: 4.0,
            holdDuration: 4.0,
            exhaleDuration: 4.0,
            cycles: 5
        ),
        BreathingExercise(
            name: "Simple Calm",
            description: "Simple deep breathing to calm your nervous system",
            inhaleDuration: 4.0,
            holdDuration: 1.0,
            exhaleDuration: 6.0,
            cycles: 6
        )
    ]
    
    var selectedExercise: BreathingExercise {
        breathingExercises[selectedExerciseIndex]
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if breathingState == .initial {
                    exerciseSelectionView
                } else {
                    breathingGuideView(geometry: geometry)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundGradient.edgesIgnoringSafeArea(.all))
            .alert(isPresented: $showingCompletionAlert) {
                Alert(
                    title: Text("Great Job!"),
                    message: Text("You've completed the breathing exercise! You've earned 15 points."),
                    dismissButton: .default(Text("Done")) {
                        userStore.awardPoints(amount: 15, reason: .appUsage, description: "Completing a breathing exercise")
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .navigationTitle(breathingState == .initial ? "Choose Exercise" : selectedExercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(breathingState != .initial)
        .navigationBarItems(
            trailing: breathingState != .initial ? Button("Exit") {
                breathingState = .initial
                breathCount = 0
                animationAmount = 1.0
            } : nil
        )
    }
    
    // Exercise selection view
    private var exerciseSelectionView: some View {
        VStack(spacing: 25) {
            Text("Choose a Breathing Exercise")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            ForEach(0..<breathingExercises.count, id: \.self) { index in
                exerciseCard(exercise: breathingExercises[index], index: index)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Benefits of Breathing Exercises:")
                    .font(.headline)
                
                bulletPoint("Reduces stress and anxiety")
                bulletPoint("Helps manage cravings")
                bulletPoint("Improves focus and clarity")
                bulletPoint("Decreases heart rate and blood pressure")
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // Exercise card
    private func exerciseCard(exercise: BreathingExercise, index: Int) -> some View {
        Button(action: {
            selectedExerciseIndex = index
            startBreathingExercise()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(exercise.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack(spacing: 15) {
                    infoTag("Inhale: \(Int(exercise.inhaleDuration))s")
                    infoTag("Hold: \(Int(exercise.holdDuration))s")
                    infoTag("Exhale: \(Int(exercise.exhaleDuration))s")
                }
                
                Text("\(exercise.cycles) cycles • ~\(Int(exercise.totalDuration)) seconds")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    // Breathing guide view
    private func breathingGuideView(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            
            // Status Text
            Text(breathingStateText)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .animation(.none)
            
            Spacer()
            
            // Animated circle
            Circle()
                .stroke(Color.white, lineWidth: 5)
                .frame(width: min(geometry.size.width, geometry.size.height) * 0.6)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .scaleEffect(animationAmount)
                )
                .scaleEffect(breathingState == .hold ? 1.0 : animationAmount)
            
            Spacer()
            
            // Progress indicator
            Text("Breath \(breathCount + 1) of \(selectedExercise.cycles)")
                .font(.title3)
                .foregroundColor(.white)
            
            Spacer()
            
            // Instructions
            Text(instructionText)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding()
            
            Spacer()
        }
    }
    
    // Info tag
    private func infoTag(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.3))
            .cornerRadius(8)
    }
    
    // Bullet point
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.white)
        }
    }
    
    // Start breathing exercise
    private func startBreathingExercise() {
        breathingState = .inhale
        breathCount = 0
        startInhaleAnimation()
    }
    
    // Start inhale animation
    private func startInhaleAnimation() {
        animationAmount = 1.0
        withAnimation(.easeIn(duration: selectedExercise.inhaleDuration)) {
            animationAmount = 1.5
            breathingState = .inhale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + selectedExercise.inhaleDuration) {
            startHoldAnimation()
        }
    }
    
    // Start hold animation
    private func startHoldAnimation() {
        breathingState = .hold
        
        DispatchQueue.main.asyncAfter(deadline: .now() + selectedExercise.holdDuration) {
            startExhaleAnimation()
        }
    }
    
    // Start exhale animation
    private func startExhaleAnimation() {
        withAnimation(.easeOut(duration: selectedExercise.exhaleDuration)) {
            animationAmount = 1.0
            breathingState = .exhale
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + selectedExercise.exhaleDuration) {
            completeBreathCycle()
        }
    }
    
    // Complete breath cycle
    private func completeBreathCycle() {
        breathCount += 1
        
        if breathCount < selectedExercise.cycles {
            startInhaleAnimation()
        } else {
            breathingState = .complete
            showingCompletionAlert = true
        }
    }
    
    // Current breathing state text
    private var breathingStateText: String {
        switch breathingState {
        case .initial:
            return "Ready"
        case .inhale:
            return "Inhale"
        case .hold:
            return "Hold"
        case .exhale:
            return "Exhale"
        case .complete:
            return "Complete"
        }
    }
    
    // Current instruction text
    private var instructionText: String {
        switch breathingState {
        case .initial:
            return "Select an exercise to begin"
        case .inhale:
            return "Breathe in slowly through your nose"
        case .hold:
            return "Hold your breath"
        case .exhale:
            return "Breathe out slowly through your mouth"
        case .complete:
            return "Great job! You've completed the exercise"
        }
    }
    
    // Background gradient
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// Breathing exercise model
struct BreathingExercise {
    let name: String
    let description: String
    let inhaleDuration: Double
    let holdDuration: Double
    let exhaleDuration: Double
    let cycles: Int
    
    var totalDuration: Double {
        (inhaleDuration + holdDuration + exhaleDuration) * Double(cycles)
    }
}
