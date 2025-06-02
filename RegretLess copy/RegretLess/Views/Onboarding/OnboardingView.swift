//
//  OnboardingView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isShowingOnboarding: Bool
    @State private var currentPage = 0
    
    // The different pages of our onboarding
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to RegretLess",
            description: "Your personal guide on the journey to reducing vaping habits and improving your health.",
            imageName: "leaf.fill",
            backgroundColor: Color.theme.accent
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Log your vaping sessions and see patterns. Understanding your habits is the first step to changing them.",
            imageName: "chart.bar.fill",
            backgroundColor: Color.theme.coral
        ),
        OnboardingPage(
            title: "Earn Rewards",
            description: "Get points for tracking sessions and making progress. Redeem them for in-app rewards and celebrate your achievements.",
            imageName: "star.fill",
            backgroundColor: Color.theme.mauve
        ),
        OnboardingPage(
            title: "Community Support",
            description: "Share your journey with others trying to reduce vaping. You're not alone in this journey.",
            imageName: "person.2.fill",
            backgroundColor: Color.theme.primary
        )
    ]
    
    var body: some View {
        ZStack {
            // Current page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // Bottom buttons
            VStack {
                Spacer()
                
                HStack {
                    // Back button, hidden on first page
                    Button(action: {
                        if currentPage > 0 {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                    }) {
                        Text("Back")
                            .foregroundColor(.white)
                            .padding()
                            .opacity(currentPage > 0 ? 1 : 0)
                    }
                    .disabled(currentPage == 0)
                    
                    Spacer()
                    
                    // Next/Get Started button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            // Last page, complete onboarding
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.theme.accent)
                            .cornerRadius(10)
                    }
                }
                .padding(30)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func completeOnboarding() {
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Auto login
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        // Create a default user with the registered username
        let username = UserDefaults.standard.string(forKey: "username") ?? "NewUser"
        
        // This would typically be done by your UserStore
        // For now, we're just using default values for testing
        
        // Dismiss onboarding
        isShowingOnboarding = false
    }
}

// Each page of the onboarding
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

// View for a single onboarding page
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        ZStack {
            page.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: page.imageName)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(page.description)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                Spacer()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(isShowingOnboarding: .constant(true))
    }
}
