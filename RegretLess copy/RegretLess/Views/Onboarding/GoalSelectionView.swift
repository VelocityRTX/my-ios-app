//
//  GoalSelectionView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/28/25.
//

import SwiftUI

struct GoalSelectionView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    let approaches = ["Gradual", "Cold Turkey"]
    
    var body: some View {
        VStack {
            Text("Select Your Approach")
                .font(.largeTitle)
                .padding()
            
            Text("How would you like to quit vaping?")
                .font(.headline)
                .padding()
            
            VStack(spacing: 20) {
                ForEach(approaches, id: \.self) { approach in
                    Button(action: {
                        introViewModel.selectedApproach = approach
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(approach)
                                    .font(.headline)
                                
                                Text(descriptionFor(approach))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: introViewModel.selectedApproach == approach ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(introViewModel.selectedApproach == approach ? Color.theme.accent : .gray)
                        }
                        .padding()
                        .background(Color.theme.secondaryBackground.opacity(0.3))
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    // Helper to get description for each approach
    private func descriptionFor(_ approach: String) -> String {
        switch approach {
        case "Gradual":
            return "Reduce vaping gradually over time at your own pace"
        case "Cold Turkey":
            return "Stop vaping completely from your chosen quit date"
        default:
            return ""
        }
    }
}
