//
//  StoryDetailView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct StoryDetailView: View {
    @EnvironmentObject var storyStore: PeerStoryStore
    @EnvironmentObject var userStore: UserStore
    
    let story: PeerStory
    @State private var newComment = ""
    @State private var isShowingReportSheet = false
    @State private var isAnonymousComment = false
    @State private var showingThankYouAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Story header
                storyHeader
                
                Divider()
                
                // Story content
                Text(story.content)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                
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
                
                Divider()
                
                // Interaction buttons
                HStack(spacing: 30) {
                    // Like button
                    Button(action: {
                        likeStory()
                    }) {
                        Label("Like (\(story.likes))", systemImage: "hand.thumbsup")
                            .font(.subheadline)
                    }
                    
                    // Comment count
                    Label("\(story.comments.count) comments", systemImage: "bubble.right")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    // Report button
                    Button(action: {
                        isShowingReportSheet = true
                    }) {
                        Image(systemName: "flag")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 5)
                
                // Add comment section
                addCommentSection
                
                // Comments section
                commentsSection
            }
            .padding()
            .navigationTitle("Story")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isShowingReportSheet) {
                ReportContentView(contentType: "story", contentAuthor: story.author)
            }
            .alert(isPresented: $showingThankYouAlert) {
                Alert(
                    title: Text("Thanks for Engaging!"),
                    message: Text("You earned 5 points for participating in the community."),
                    dismissButton: .default(Text("Great!"))
                )
            }
        }
    }
    
    // Story header view
    private var storyHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(story.title)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                if story.isAnonymous {
                    Label("Anonymous", systemImage: "person.fill.questionmark")
                } else {
                    Label(story.author, systemImage: "person.fill")
                }
                
                Spacer()
                
                Text(story.datePosted, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
    
    // Add comment section
    private var addCommentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add a Comment")
                .font(.headline)
            
            HStack {
                TextField("Your supportive comment...", text: $newComment)
                    .padding(10)
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(8)
                
                Button(action: {
                    submitComment()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(newComment.isEmpty ? Color.gray : Color.theme.accent)
                        .cornerRadius(8)
                }
                .disabled(newComment.isEmpty)
            }
            
            Toggle("Post anonymously", isOn: $isAnonymousComment)
                .font(.caption)
        }
        .padding(.vertical, 10)
    }
    
    // Comments section
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Comments")
                .font(.headline)
            
            if story.comments.isEmpty {
                Text("No comments yet. Be the first to leave a supportive comment!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            } else {
                ForEach(story.comments) { comment in
                    CommentView(comment: comment)
                    
                    if comment.id != story.comments.last?.id {
                        Divider()
                    }
                }
            }
        }
    }
    
    // Like the story
    private func likeStory() {
        if let index = storyStore.stories.firstIndex(where: { $0.id == story.id }) {
            storyStore.stories[index].likes += 1
            
            // Award points for engagement
            userStore.awardPoints(amount: 5, reason: .communityEngagement, description: "Engaging with the community")
            showingThankYouAlert = true
        }
    }
    
    // Submit a comment
    private func submitComment() {
        let newComment = Comment(
            id: UUID(),
            author: userStore.currentUser.username,
            content: self.newComment,
            datePosted: Date(),
            isAnonymous: isAnonymousComment
        )
        
        if let index = storyStore.stories.firstIndex(where: { $0.id == story.id }) {
            storyStore.stories[index].comments.append(newComment)
            self.newComment = ""
            
            // Award points for commenting
            userStore.awardPoints(amount: 10, reason: .communityEngagement, description: "Commenting on a story")
            showingThankYouAlert = true
        }
    }
}

// Enhanced comment view
struct CommentView: View {
    let comment: Comment
    @State private var likeCount: Int
    @State private var hasLiked = false
    
    init(comment: Comment) {
        self.comment = comment
        self._likeCount = State(initialValue: comment.likes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if comment.isAnonymous {
                    Text("Anonymous")
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text(comment.author)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(comment.datePosted, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.content)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Spacer()
                
                Button(action: {
                    if !hasLiked {
                        likeCount += 1
                        hasLiked = true
                    } else {
                        likeCount -= 1
                        hasLiked = false
                    }
                }) {
                    Label("\(likeCount)", systemImage: hasLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.caption)
                        .foregroundColor(hasLiked ? Color.theme.accent : .gray)
                }
            }
        }
        .padding(.vertical, 5)
    }
}

// Content reporting view
struct ReportContentView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let contentType: String
    let contentAuthor: String
    
    @State private var reportReason = ""
    @State private var selectedReasonIndex = 0
    @State private var showingConfirmation = false
    
    let reportReasons = [
        "Please select a reason",
        "Inappropriate content",
        "Harmful information",
        "Bullying or harassment",
        "Spam or misleading",
        "Other concern"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Report \(contentType.capitalized)")) {
                    Text("We want to keep RegretLess a safe and supportive community. Please let us know why you're reporting this content.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Reason for Reporting")) {
                    Picker("Select a reason", selection: $selectedReasonIndex) {
                        ForEach(0..<reportReasons.count, id: \.self) { index in
                            Text(reportReasons[index]).tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Additional Information (Optional)")) {
                    TextEditor(text: $reportReason)
                        .frame(height: 120)
                }
                
                Section {
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        Text("Submit Report")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                            .background(selectedReasonIndex == 0 ? Color.gray : Color.red)
                            .cornerRadius(8)
                    }
                    .disabled(selectedReasonIndex == 0)
                }
            }
            .navigationTitle("Report Content")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("Report Submitted"),
                    message: Text("Thank you for helping keep our community safe. Our team will review this content soon."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
}
