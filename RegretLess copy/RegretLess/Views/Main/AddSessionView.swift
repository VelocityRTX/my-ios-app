//
//  AddSessionView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/17/25.
//

import SwiftUI

struct AddSessionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var habitStore: HabitTrackingStore
    @EnvironmentObject var userStore: UserStore
    @StateObject private var viewModel = SessionViewModel(habitStore: HabitTrackingStore(), userStore: UserStore())
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("What triggered you?")) {
                    Picker("Trigger", selection: $viewModel.trigger) {
                        ForEach(VapingTrigger.allCases) { trigger in
                            Text(trigger.rawValue).tag(trigger)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Where were you?", text: $viewModel.location)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("How were you feeling?")) {
                    Picker("Mood", selection: $viewModel.mood) {
                        ForEach(Mood.allCases) { mood in
                            Label(mood.rawValue, systemImage: mood.icon).tag(mood)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Session Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Intensity: \(viewModel.intensity)")
                            .font(.headline)
                        
                        Text("How heavy was this session?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Light")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Slider(value: .convert(from: $viewModel.intensity), in: 1...5, step: 1)
                            Text("Heavy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Craving Level: \(viewModel.cravingLevel)")
                            .font(.headline)
                        
                        Text("How strong was your craving?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Mild")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Slider(value: .convert(from: $viewModel.cravingLevel), in: 1...10, step: 1)
                            
                            Text("Strong")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("Notes (Optional)")) {
                    ZStack(alignment: .topLeading) {
                        if viewModel.notes.isEmpty {
                            Text("What else was happening? How did you feel afterward?")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $viewModel.notes)
                            .frame(minHeight: 100)
                            .opacity(viewModel.notes.isEmpty ? 0.25 : 1)
                    }
                }
                
                Button(action: {
                    viewModel.showMotivation = true
                }) {
                    Text("I need motivation")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(Color.theme.accent)
                }
            }
            .navigationTitle("Log Session")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveSession()
                    presentationMode.wrappedValue.dismiss()
                }
                .fontWeight(.bold)
            )
            .sheet(isPresented: $viewModel.showMotivation) {
                MotivationView()
            }
            .onAppear {
                // Initialize with the current environment objects
                viewModel.habitStore = habitStore
                viewModel.userStore = userStore
            }
        }
    }
    
    func saveSession() {
        viewModel.saveSession()
        presentationMode.wrappedValue.dismiss()
    }
}

// Motivation popup view
struct MotivationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let motivationalMessages = [
        "Each time you track a session, you're learning more about your patterns.",
        "Progress isn't always linear. Every step counts, even the small ones.",
        "You're building awareness, which is the first step to change.",
        "Remember why you started this journey.",
        "Every minute you resist is a victory."
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.theme.accent)
                .padding()
            
            Text(motivationalMessages.randomElement() ?? "You can do this!")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Thanks, I needed that")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.accent)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity)
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
    }
}
