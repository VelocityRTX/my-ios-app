//
//  StoryRowView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct StoryRowView: View {
    let story: PeerStory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title and author
            VStack(alignment: .leading, spacing: 5) {
                Text(story.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Text(story.isAnonymous ? "Anonymous" : story.author)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Content preview
            Text(story.content)
                .font(.subheadline)
                .lineLimit(3)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Stats and tags
            HStack {
                // Tags scrollview
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
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
                
                Spacer()
                
                // Stats
                HStack(spacing: 12) {
                    Label("\(story.likes)", systemImage: "hand.thumbsup")
                        .font(.caption)
                    
                    Label("\(story.comments.count)", systemImage: "bubble.right")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.theme.background)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Format the time ago string
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: story.datePosted, relativeTo: Date())
    }
}
