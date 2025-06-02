//
//  TrackingView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/17/25.
//

import SwiftUI

struct TrackingView: View {
    @State private var showingAddSession = false
    @State private var selectedFilter: SessionFilter = .all
    @EnvironmentObject var habitStore: HabitTrackingStore
    
    enum SessionFilter {
        case all, today, yesterday, week
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter tabs
                filterTabView
                
                // Chart section
                TrackingChartView()
                    .padding(.horizontal)
                    .padding(.top, 15)
                
                // Sessions list
                sessionsList
                    .background(Color.theme.background)
                
                // Add button
                Button(action: {
                    showingAddSession = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Track Vaping Session")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.accent)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Track Vaping")
            .background(Color.theme.background.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingAddSession) {
                AddSessionView()
            }
        }
    }
    
    // Filter tabs
    private var filterTabView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                filterButton(title: "All", filter: .all)
                filterButton(title: "Today", filter: .today)
                filterButton(title: "Yesterday", filter: .yesterday)
                filterButton(title: "This Week", filter: .week)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color.theme.background)
    }
    
    // Filter button
    private func filterButton(title: String, filter: SessionFilter) -> some View {
        Button(action: {
            selectedFilter = filter
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(selectedFilter == filter ? Color.theme.accent : Color.theme.secondaryBackground)
                .foregroundColor(selectedFilter == filter ? .white : .primary)
                .cornerRadius(20)
        }
    }
    
    // List of sessions
    private var sessionsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(filteredSessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        SessionRowView(session: session)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.theme.background)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .padding(.horizontal)
                }
                
                if filteredSessions.isEmpty {
                    Text("No sessions recorded")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding(.vertical)
        }
    }
    
    // Filter sessions based on selected filter
    private var filteredSessions: [VapingSession] {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let startOfWeek = calendar.date(byAdding: .day, value: -6, to: today)!
        
        switch selectedFilter {
        case .all:
            return habitStore.vapingSessions.sorted(by: { $0.date > $1.date })
        case .today:
            return habitStore.vapingSessions.filter { calendar.isDate($0.date, inSameDayAs: now) }
                .sorted(by: { $0.date > $1.date })
        case .yesterday:
            return habitStore.vapingSessions.filter { calendar.isDate($0.date, inSameDayAs: yesterday) }
                .sorted(by: { $0.date > $1.date })
        case .week:
            return habitStore.vapingSessions.filter { $0.date >= startOfWeek && $0.date <= now }
                .sorted(by: { $0.date > $1.date })
        }
    }
}
