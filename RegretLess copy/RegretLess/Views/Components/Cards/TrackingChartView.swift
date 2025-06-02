//
//  TrackingChartView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/17/25.
//

import SwiftUI

struct TrackingChartView: View {
    @EnvironmentObject var habitStore: HabitTrackingStore
    let barWidth: CGFloat = 20
    let spacing: CGFloat = 6
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Sessions")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(lastWeekData.indices, id: \.self) { index in
                    VStack {
                        ZStack(alignment: .bottom) {
                            Rectangle()
                                .fill(Color.theme.secondaryBackground)
                                .frame(width: barWidth, height: 120)
                            
                            Rectangle()
                                .fill(barColor(for: lastWeekData[index]))
                                .frame(width: barWidth, height: barHeight(for: lastWeekData[index]))
                        }
                        .cornerRadius(5)
                        
                        Text(dayLabels[index])
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }
                }
            }
            .padding(.top, 10)
            
            // Legend
            HStack(spacing: 20) {
                HStack {
                    Circle()
                        .fill(Color.theme.accent)
                        .frame(width: 10, height: 10)
                    Text("Goal Met")
                        .font(.caption)
                }
                
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    Text("Goal Missed")
                        .font(.caption)
                }
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Get the last 7 days of session counts
    var lastWeekData: [Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).map { offset -> Int in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            return habitStore.vapingSessions.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
        }.reversed()
    }
    
    // Day labels for the chart
    var dayLabels: [String] {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        return (0..<7).map { offset -> String in
            let day = calendar.date(byAdding: .day, value: -6 + offset, to: calendar.startOfDay(for: today))!
            return formatter.string(from: day)
        }
    }
    
    // Calculate bar height based on value
    func barHeight(for value: Int) -> CGFloat {
        let maxHeight: CGFloat = 120
        let maxValue = max(5, lastWeekData.max() ?? 1) // At least 5 for scale
        return value > 0 ? max(20, CGFloat(value) / CGFloat(maxValue) * maxHeight) : 2
    }
    
    // Determine bar color based on goal
    func barColor(for value: Int) -> Color {
        // Assuming goal is 3 or fewer sessions per day
        return value <= 3 ? Color.theme.accent : Color.red
    }
}
