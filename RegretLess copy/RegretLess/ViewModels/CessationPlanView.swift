//
//  CessationPlanView.swift
//  RegretLess
//
//  Created by Conrad Anton on 5/19/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct CessationPlanView: View {
    let plan: CessationPlan
    @State private var editedPlan: CessationPlan
    @State private var isEditing = false
    @State private var showingDatePicker = false
    @State private var isSaving = false
    @State private var showingSuccessAlert = false
    @State private var errorMessage: String?
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userStore: UserStore
    
    // Initialize with the user's plan and create an editable copy
    init(plan: CessationPlan) {
        self.plan = plan
        self._editedPlan = State(initialValue: plan)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Text("Your Cessation Plan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.accent)
                    
                    Text("Track your journey to quit vaping")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Timeline Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Timeline")
                            .font(.headline)
                        
                        Spacer()
                        
                        if isEditing {
                            Button(action: {
                                showingDatePicker = true
                            }) {
                                Text("Edit")
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.accent)
                            }
                        }
                    }
                    
                    VStack(spacing: 15) {
                        timelineRow(
                            title: "Start Date",
                            date: editedPlan.startDate,
                            icon: "calendar",
                            color: Color.theme.accent
                        )
                        
                        // Progress bar
                        ProgressView(value: progress)
                            .accentColor(Color.theme.accent)
                            .padding(.vertical, 5)
                        
                        timelineRow(
                            title: "Target Quit Date",
                            date: editedPlan.targetQuitDate ?? Date(),
                            icon: "flag.fill",
                            color: Color.theme.green
                        )
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(15)
                    
                    // Days remaining
                    if let targetDate = editedPlan.targetQuitDate {
                        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0
                        
                        if daysRemaining > 0 {
                            Text("\(daysRemaining) days remaining until your target quit date")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                        } else {
                            Text("You've reached your target quit date! How are you doing?")
                                .font(.caption)
                                .foregroundColor(Color.theme.green)
                                .padding(.top, 5)
                        }
                    }
                }
                .padding()
                .background(Color.theme.background)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Daily Goals Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Today's Goal")
                            .font(.headline)
                        
                        Spacer()
                        
                        if isEditing {
                            Button(action: {
                                let newGoal = max(1, userStore.currentUser.dailyVapingGoal - 1)
                                userStore.updateDailyVapingGoal(to: newGoal)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(Color.theme.accent)
                            }
                            
                            Text("\(userStore.currentUser.dailyVapingGoal)")
                                .padding(.horizontal, 10)
                            
                            Button(action: {
                                let newGoal = userStore.currentUser.dailyVapingGoal + 1
                                userStore.updateDailyVapingGoal(to: newGoal)
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Color.theme.accent)
                            }
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Current Goal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Maximum \(userStore.currentUser.dailyVapingGoal) vaping sessions per day")
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        Text("0/\(userStore.currentUser.dailyVapingGoal)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.theme.secondaryBackground.opacity(0.3))
                    .cornerRadius(15)
                    
                    if isEditing {
                        HStack {
                            Text("Tip: ")
                                .font(.caption)
                                .fontWeight(.bold)
                            
                            Text("Gradually reduce your daily goal to help you quit. For best results, aim to decrease by 1-2 sessions per week.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 5)
                    }
                }
                
                .padding()
                .background(Color.theme.background)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Coping Strategies Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Your Strategies")
                            .font(.headline)
                        
                        Spacer()
                        
                        if isEditing {
                            Button(action: {
                                editedPlan.strategies.append(
                                    CopingStrategy(
                                        id: UUID(),
                                        title: "New Strategy",
                                        description: "Tap to edit this strategy",
                                        timesUsed: 0
                                    )
                                )
                            }) {
                                Text("Add New")
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.accent)
                            }
                        }
                    }
                    
                    if editedPlan.strategies.isEmpty {
                        Text("No strategies added yet")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.secondaryBackground.opacity(0.3))
                            .cornerRadius(15)
                    } else {
                        ForEach(editedPlan.strategies.indices, id: \.self) { index in
                            strategyRow(strategy: $editedPlan.strategies[index], isEditing: isEditing)
                        }
                    }
                }
                .padding()
                .background(Color.theme.background)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Progress Notes Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Progress Notes")
                            .font(.headline)
                        
                        Spacer()
                        
                        if isEditing {
                            Button(action: {
                                editedPlan.progressNotes.append(
                                    ProgressNote(
                                        id: UUID(),
                                        date: Date(),
                                        content: "",
                                        mood: .neutral
                                    )
                                )
                            }) {
                                Text("Add Note")
                                    .font(.subheadline)
                                    .foregroundColor(Color.theme.accent)
                            }
                        }
                    }
                    
                    if editedPlan.progressNotes.isEmpty {
                        Text("No progress notes yet")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.theme.secondaryBackground.opacity(0.3))
                            .cornerRadius(15)
                    } else {
                        ForEach(editedPlan.progressNotes.indices, id: \.self) { index in
                            noteRow(note: $editedPlan.progressNotes[index], isEditing: isEditing)
                        }
                    }
                }
                .padding()
                .background(Color.theme.background)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Edit/Save Button
                Button(action: {
                    if isEditing {
                        savePlan()
                    } else {
                        isEditing = true
                    }
                }) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isEditing ? "Save Changes" : "Edit Plan")
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isEditing ? Color.theme.accent : Color.theme.secondary)
                .foregroundColor(.white)
                .cornerRadius(15)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .disabled(isSaving)
                
                if isEditing {
                    Button("Cancel") {
                        // Restore original plan
                        editedPlan = plan
                        isEditing = false
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding(.horizontal)
        }
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        .navigationTitle("Cessation Plan")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Plan Updated"),
                message: Text("Your cessation plan has been successfully updated."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(date: $editedPlan.targetQuitDate.toUnwrapped(defaultValue: Date()), title: "Select Target Quit Date") {
                showingDatePicker = false
            }
        }
    }
    
    // Timeline row helper view
    private func timelineRow(title: String, date: Date, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .padding(8)
                .background(color)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(date, style: .date)
                    .font(.headline)
            }
            
            Spacer()
        }
    }
    
    // Strategy row helper view
    private func strategyRow(strategy: Binding<CopingStrategy>, isEditing: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if isEditing {
                TextField("Strategy Title", text: strategy.title)
                    .font(.headline)
                
                TextField("Strategy Description", text: strategy.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text(strategy.wrappedValue.title)
                    .font(.headline)
                
                Text(strategy.wrappedValue.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Used \(strategy.wrappedValue.timesUsed) times")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let effectiveness = strategy.wrappedValue.effectiveness {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= effectiveness ? "star.fill" : "star")
                                .foregroundColor(star <= effectiveness ? .yellow : .gray)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.theme.secondaryBackground.opacity(0.3))
        .cornerRadius(15)
    }
    
    // Note row helper view
    private func noteRow(note: Binding<ProgressNote>, isEditing: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(note.wrappedValue.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: note.wrappedValue.mood.icon)
                    .foregroundColor(Color.theme.accent)
            }
            
            if isEditing {
                TextEditor(text: note.content)
                    .frame(minHeight: 80)
                    .padding(5)
                    .background(Color.theme.background)
                    .cornerRadius(8)
                
                Picker("Mood", selection: note.mood) {
                    ForEach(Mood.allCases) { mood in
                        Label(mood.rawValue, systemImage: mood.icon).tag(mood)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            } else {
                Text(note.wrappedValue.content)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.theme.secondaryBackground.opacity(0.3))
        .cornerRadius(15)
    }
    
    // Calculate progress percentage
    private var progress: Double {
        guard let targetDate = editedPlan.targetQuitDate else {
            return 0.1
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = editedPlan.startDate
        
        // If the target date is in the past, show 100%
        if targetDate < now {
            return 1.0
        }
        
        // Calculate progress
        let totalDays = max(1, calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 1)
        let progressDays = calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
        
        return min(Double(progressDays) / Double(totalDays), 1.0)
    }
    
    // Save changes to Firebase
    private func savePlan() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        
        isSaving = true
        
        // Create document data
        let planData: [String: Any] = [
            "startDate": Timestamp(date: editedPlan.startDate),
            "targetQuitDate": editedPlan.targetQuitDate.map { Timestamp(date: $0) } as Any,
            "dailyGoals": editedPlan.dailyGoals.map { goal in
                [
                    "id": goal.id.uuidString,
                    "date": Timestamp(date: goal.date),
                    "maxSessions": goal.maxSessions,
                    "achievedSessions": goal.achievedSessions as Any,
                    "completed": goal.completed
                ]
            },
            "strategies": editedPlan.strategies.map { strategy in
                [
                    "id": strategy.id.uuidString,
                    "title": strategy.title,
                    "description": strategy.description,
                    "timesUsed": strategy.timesUsed,
                    "effectiveness": strategy.effectiveness as Any
                ]
            },
            "progressNotes": editedPlan.progressNotes.map { note in
                [
                    "id": note.id.uuidString,
                    "date": Timestamp(date: note.date),
                    "content": note.content,
                    "mood": note.mood.rawValue
                ]
            }
        ]
        
        // Update in Firestore
        Firestore.firestore().collection("users").document(userId).updateData([
            "cessationPlan": planData
        ]) { error in
            isSaving = false
            
            if let error = error {
                errorMessage = "Error saving plan: \(error.localizedDescription)"
                print("❌ Error saving cessation plan: \(error.localizedDescription)")
            } else {
                // Update user in UserStore to reflect changes
                if var userPlan = userStore.currentUser.cessationPlan {
                    userPlan = editedPlan
                    userStore.currentUser.cessationPlan = userPlan
                } else {
                    userStore.currentUser.cessationPlan = editedPlan
                }
                
                // Show success message
                showingSuccessAlert = true
                isEditing = false
                
                print("✅ Cessation plan saved successfully")
            }
        }
    }
}

// Helper for optional Date binding
extension Binding where Value == Date? {
    func toUnwrapped(defaultValue: Date) -> Binding<Date> {
        Binding<Date>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

// Date picker sheet
struct DatePickerView: View {
    @Binding var date: Date
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    title,
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
                Button("Done") {
                    onDismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.theme.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarItems(trailing: Button("Done") {
                onDismiss()
            })
        }
    }
}
