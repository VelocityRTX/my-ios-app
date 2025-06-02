//
//  IntroWelcomeView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/28/25.
//

import SwiftUI

struct IntroWelcomeView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    
    var body: some View {
        VStack {
            Text("Welcome to RegretLess")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundColor(Color.theme.accent)
                .padding()
            
            Text("Your journey to vape less starts here")
                .font(.headline)
                .foregroundColor(Color.theme.secondaryText)
                .padding()
            
            Spacer()
            
            Button(action: {
                // Go to the next page
                introViewModel.currentPage = 1
            }) {
                Text("Get Started")
                    .fontWeight(.bold)
                    .padding()
                    .frame(width: 200)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.theme.accent, Color.theme.secondary]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: Color.theme.accent.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            .padding(.top, 30)
            .padding(.bottom, 50)
        }
    }
}
