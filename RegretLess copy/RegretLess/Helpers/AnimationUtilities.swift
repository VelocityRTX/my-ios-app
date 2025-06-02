//
//  AnimationUtilities.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/23/25.
//

import SwiftUI
import Foundation

// MARK: - Point Award Animation View
struct PointAwardView: View {
    let points: Int
    @EnvironmentObject var userStore: UserStore
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Text("+\(points) points")
            .font(.system(.title2, design: .rounded).bold())
            .foregroundColor(Color.theme.accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.theme.accent.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(Color.theme.accent, lineWidth: 2)
                    )
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4 * AppSettings.animationSpeed, dampingFraction: 0.7)) {
                    scale = 1.1
                    opacity = 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0 * AppSettings.animationSpeed) {
                    withAnimation(.easeOut(duration: 0.3 * AppSettings.animationSpeed)) {
                        scale = 1.3
                        opacity = 0
                    }
                    
                    // Dismiss after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 * AppSettings.animationSpeed) {
                        userStore.showPointAnimation = false
                    }
                }
            }
    }
}

// MARK: - Milestone Achievement Animation
struct MilestoneAchievementView: View {
    let milestone: Milestone
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    @State private var animationTimer: Timer?
    @EnvironmentObject var userStore: UserStore
    
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            // Confetti (uses your existing ConfettiView)
            if showConfetti {
                ConfettiView()
            }
            
            // Content
            VStack(spacing: 25) {
                Spacer()
                
                GeometryReader { geo in
                    Image(systemName: milestone.iconName)
                        .font(.system(size: geo.size.width * 0.2))
                        .foregroundColor(.white)
                        .frame(width: geo.size.width * 0.4, height: geo.size.width * 0.4)
                }
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
                
                // Milestone name
                Text("Achievement Unlocked!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text(milestone.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(opacity)
                
                // Milestone description
                Text(milestone.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(opacity)
                
                // Points earned
                HStack {
                    Text("+\(milestone.pointsAwarded)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                }
                .opacity(opacity)
                
                Spacer()
                
                // Close button
                Button(action: {
                    userStore.dismissMilestoneAnimation()
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
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                showConfetti = true
            }
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
}
