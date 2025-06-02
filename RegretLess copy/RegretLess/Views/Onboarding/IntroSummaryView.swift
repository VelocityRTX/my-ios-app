//
//  IntroSummaryView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/28/25.
//

import SwiftUI

struct IntroSummaryView: View {
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
                Text("Your Cessation Plan")
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .foregroundColor(Color.theme.accent)
                    .padding(.bottom)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                SummarySection(title: "Vaping Habits") {
                    SummaryRow(label: "Days per week:", value: "\(introViewModel.daysPerWeekVaping)")
                    SummaryRow(label: "Times per day:", value: "\(introViewModel.vapingFrequency)")
                    SummaryRow(label: "Main reason:", value: introViewModel.mainVapingReason)
                    SummaryRow(label: "Vape from boredom:", value: introViewModel.vapeFromBoredom ? "Yes" : "No")
                    SummaryRow(label: "Vape type:", value: introViewModel.vapeType)
                    SummaryRow(label: "Nicotine type:", value: introViewModel.nicotineType)
                    SummaryRow(label: "Nicotine strength:", value: "\(introViewModel.nicotineStrength) mg")
                    SummaryRow(label: "Weekly spending:", value: "$\(String(format: "%.2f", introViewModel.weeklySpending))")
                }
                
                SummarySection(title: "Your Approach") {
                    SummaryRow(label: "Method:", value: introViewModel.selectedApproach)
                    
                    if introViewModel.selectedApproach == "Gradual" {
                        // Use the formatter we created above
                        SummaryRow(label: "Target quit date:", value: dateFormatter.string(from: introViewModel.targetQuitDate))
                    }
                    
                    SummaryRow(label: "Confidence level:", value: "\(introViewModel.confidenceLevel)/10")
                }
                
                SummarySection(title: "Why You're Quitting") {
                    if !introViewModel.quitReasons.isEmpty {
                        Text(introViewModel.quitReasons.joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(Color.theme.text)
                    }
                    
                    if !introViewModel.personalQuitReason.isEmpty {
                        Text(introViewModel.personalQuitReason)
                            .font(.body)
                            .foregroundColor(Color.theme.text)
                            .padding(.top, 5)
                    }
                }
                
                VStack(alignment: .center, spacing: 20) {
                    Text("You're ready to start your journey!")
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                        .multilineTextAlignment(.center)
                    
                    Text("Create an account to save your plan and track your progress")
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

// Helper views for the summary with enhanced styling
struct SummarySection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.accent)
            
            content
                .padding(.leading, 10)
            
            Divider()
                .background(Color.theme.secondaryBackground)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
                .foregroundColor(Color.theme.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(Color.theme.text)
        }
        .padding(.vertical, 3)
    }
}
