//
//  TimelineSelectionView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/28/25.
//

import SwiftUI

struct TimelineSelectionView: View {
    @ObservedObject var introViewModel: IntroTutorialViewModel
    
    var body: some View {
        VStack {
            Text("Your Quit Date")
                .font(.largeTitle)
                .padding()
            
            Text("When would you like to be completely vape-free?")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            DatePicker(
                "Target Date",
                selection: $introViewModel.targetQuitDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()
            
            Text("Set a date that feels realistic but challenging")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding()
    }
}
