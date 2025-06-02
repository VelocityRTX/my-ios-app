//
//  SessionRowView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/17/25.
//

import SwiftUI

struct SessionRowView: View {
    let session: VapingSession
    
    var body: some View {
        HStack(spacing: 15) {
            // Mood icon
            Image(systemName: session.mood.icon)
                .font(.system(size: AppSettings.smallIconSize))
                .foregroundColor(Color.theme.accent)
                .frame(width: 44, height: 44)
                .background(Color.theme.secondaryBackground)
                .clipShape(Circle())
            
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.trigger.rawValue)
                    .font(.headline)
                
                HStack(spacing: 10) {
                    Label(timeString(for: session.date), systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = session.location {
                        Label(location, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Intensity indicator
            VStack(spacing: 5) {
                Text("Level")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(session.intensity)")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(8)
                    .background(intensityColor(level: session.intensity))
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
    }
    
    // Format the time
    private func timeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Color based on intensity
    private func intensityColor(level: Int) -> Color {
        switch level {
        case 1...2:
            return .green
        case 3:
            return .orange
        default:
            return .red
        }
    }
}
