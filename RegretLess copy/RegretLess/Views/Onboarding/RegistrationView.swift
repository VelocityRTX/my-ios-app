//
//  RegistrationView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import SwiftUI
import Firebase

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthenticationManager
    @Binding var isShowingOnboarding: Bool
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.accent)
                
                Text("Start your journey to vape less")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            
            // Registration form
            VStack(spacing: 20) {
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(10)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(10)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color.theme.secondaryBackground)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            // Register button
            Button(action: registerAction) {
                if authManager.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    Text("Create Account")
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(authManager.isProcessing ? Color.gray : Color.theme.accent)
            .cornerRadius(10)
            .disabled(authManager.isProcessing)
            .padding(.horizontal, 30)
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Back button
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Already have an account? Log In")
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.bottom, 20)
        }
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func registerAction() {
        // Validate input
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill out all fields"
            showingAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match"
            showingAlert = true
            return
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showingAlert = true
            return
        }
        
        // Register user with Firebase
        authManager.registerUser(email: email, password: password, username: username) { success in
            if success {
                // Store the username for later use in onboarding
                UserDefaults.standard.set(username, forKey: "username")
                isShowingOnboarding = true
            } else {
                // Error is already set in authManager.errorMessage
            }
        }
    }
    
    // Simple email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
