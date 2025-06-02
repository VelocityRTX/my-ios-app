//
//  PeerStoriesView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct PeerStoriesView: View {
    @EnvironmentObject var storyStore: PeerStoryStore
    @State private var showingAddStory = false
    @State private var selectedFilter: StoryFilter = .all
    @State private var searchText = ""
    
    enum StoryFilter: String, CaseIterable {
        case all = "All"
        case success = "Success"
        case challenge = "Challenge"
        case tips = "Tips"
        case relapse = "Relapse"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
            // Filter menu
            ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(StoryFilter.allCases, id: \.self) { filter in
                            filterButton(filter)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search stories...", text: $searchText)
                        .foregroundColor(.primary)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color.theme.secondaryBackground)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        if selectedFilter == .all && searchText.isEmpty {
                            featuredStoriesSection
                        }
                        
                        storiesSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Peer Stories")
            .navigationBarItems(trailing:
                Button(action: {
                    showingAddStory = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
            )
            .sheet(isPresented: $showingAddStory) {
                AddStoryView()
            }
            .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        }
    }
    
    // Filter button
    private func filterButton(_ filter: StoryFilter) -> some View {
        Button(action: {
            selectedFilter = filter
        }) {
            Text(filter.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(selectedFilter == filter ? Color.theme.accent : Color.theme.secondaryBackground)
                .foregroundColor(selectedFilter == filter ? .white : .primary)
                .cornerRadius(20)
        }
    }
    
    // Featured stories section
    private var featuredStoriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Featured Stories")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            ForEach(storyStore.featuredStories) { story in
                NavigationLink(destination: StoryDetailView(story: story)) {
                    FeaturedStoryCard(story: story)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // Main stories section
    private var storiesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedFilter == .all ? "Recent Stories" : "\(selectedFilter.rawValue) Stories")
                .font(.title2)
                .fontWeight(.bold)
            
            if filteredStories.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(filteredStories) { story in
                        NavigationLink(destination: StoryDetailView(story: story)) {
                            StoryRowView(story: story)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(Color.theme.secondaryBackground)
            
            Text(searchText.isEmpty ? "No \(selectedFilter.rawValue.lowercased()) stories found" : "No results found for '\(searchText)'")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button(action: {
                searchText = ""
                selectedFilter = .all
            }) {
                Text("Clear Filters")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.theme.accent)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // Filter and search stories
    private var filteredStories: [PeerStory] {
        var stories = storyStore.stories
        
        // Filter by category
        if selectedFilter != .all {
            let filterTag = selectedFilter.rawValue.lowercased()
            stories = stories.filter { $0.tags.contains(filterTag) }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            stories = stories.filter { story in
                let titleMatch = story.title.lowercased().contains(searchText.lowercased())
                let contentMatch = story.content.lowercased().contains(searchText.lowercased())
                let tagMatch = story.tags.contains { tag in
                    tag.lowercased().contains(searchText.lowercased())
                }
                return titleMatch || contentMatch || tagMatch
            }
        }
        
        return stories
    }
}

// Featured story card
struct FeaturedStoryCard: View {
    let story: PeerStory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with featured label
            HStack {
                Text("FEATURED")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.theme.accent)
                    .cornerRadius(5)
                
                Spacer()
                
                Text(story.datePosted, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Title and content preview
            Text(story.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(story.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            
            // Footer with author and stats
            HStack {
                Text(story.isAnonymous ? "Anonymous" : story.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 10) {
                    Label("\(story.likes)", systemImage: "hand.thumbsup")
                        .font(.caption)
                    
                    Label("\(story.comments.count)", systemImage: "bubble.right")
                        .font(.caption)
                }
            }
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(story.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.theme.secondaryBackground)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
