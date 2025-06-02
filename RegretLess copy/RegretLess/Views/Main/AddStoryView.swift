//
//  AddStoryView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/19/25.
//

import SwiftUI

struct AddStoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var storyStore: PeerStoryStore
    @EnvironmentObject var userStore: UserStore
    
    @State private var title = ""
    @State private var content = ""
    @State private var isAnonymous = false
    @State private var selectedTags = Set<String>()
    
    let availableTags = [
        "success", "challenge", "tips", "relapse", "stress",
        "school", "family", "friends", "anxiety", "progress",
        "motivation", "coping", "triggers"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Story Details")) {
                    TextField("Title", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Share your experience, challenges, or success story...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .opacity(content.isEmpty ? 0.25 : 1)
                    }
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("Post Anonymously", isOn: $isAnonymous)
                }
                
                Section(header: Text("Tags (Select up to 3)")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(availableTags, id: \.self) { tag in
                                TagButton(
                                    title: tag,
                                    isSelected: selectedTags.contains(tag),
                                    action: {
                                        toggleTag(tag)
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                if !isFormValid {
                    Section {
                        Text(validationMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Text("Your story helps others feel less alone. Thank you for sharing.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Post button
                Button(action: {
                    submitStory()
                }) {
                    Text("Share My Story")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .background(isFormValid ? Color.theme.accent : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid)
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Share Your Story")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        title.count <= 100 &&
        content.count >= 10
    }
    
    private var validationMessage: String {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please add a title"
        } else if title.count > 100 {
            return "Title is too long (max 100 characters)"
        } else if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please add your story"
        } else if content.count < 10 {
            return "Story is too short (min 10 characters)"
        }
        return ""
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            if selectedTags.count < 3 {
                selectedTags.insert(tag)
            }
        }
    }
    
    private func submitStory() {
        let newStory = PeerStory(
            id: UUID(),
            title: title,
            content: content,
            author: userStore.currentUser.username,
            datePosted: Date(),
            tags: Array(selectedTags),
            likes: 0,
            comments: [],
            isAnonymous: isAnonymous
        )
        
        storyStore.addStory(newStory)
        
        // Award points for sharing a story
        userStore.awardPoints(amount: 25, reason: .storyShared, description: "Sharing your story")
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct TagButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("#\(title)")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .foregroundColor(isSelected ? .white : .primary)
                .background(isSelected ? Color.theme.accent : Color.theme.secondaryBackground)
                .cornerRadius(15)
        }
    }
}
