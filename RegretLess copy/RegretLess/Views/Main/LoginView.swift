//
//  LoginView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/25/25.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    // Toggle between login and registration
    @State private var isShowingRegistration = true  // Default to registration
    @State private var isShowingMainApp = false
    @State private var isShowingOnboarding = false
    @State private var animationsEnabled = false  // Add this line
    
    // Login fields
    @State private var email = ""
    @State private var password = ""
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and title
            VStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 70))
                    .foregroundColor(Color.theme.accent)
                
                Text("RegretLess")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.theme.accent)
                
                Text(isShowingRegistration ? "Create your account to start your journey" : "Welcome back to your journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
            
            // Segmented control to switch between login and register
            Picker("", selection: $isShowingRegistration) {
                Text("Create Account").tag(true)
                Text("Log In").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 30)
            
            if !isShowingRegistration {
                // Login form when not showing registration
                VStack(spacing: 20) {
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
                    
                    Button(action: loginAction) {
                        if authManager.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        } else {
                            Text("Log In")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authManager.isProcessing ? Color.gray : Color.theme.accent)
                    .cornerRadius(10)
                    .disabled(authManager.isProcessing)
                }
                .padding(.horizontal, 30)
            }
            
            if let errorMessage = authManager.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Button to toggle between login and registration
            Button(action: {
                isShowingRegistration.toggle()
            }) {
                Text(isShowingRegistration ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $isShowingRegistration) {
            RegistrationView(isShowingOnboarding: $isShowingOnboarding)
                .environmentObject(authManager)
        }
        .fullScreenCover(isPresented: $isShowingMainApp) {
            MainTabView()
                .environmentObject(HabitTrackingStore())
                .environmentObject(UserStore())
                .environmentObject(PeerStoryStore())
        }
        .fullScreenCover(isPresented: $isShowingOnboarding) {
            OnboardingView(isShowingOnboarding: $isShowingOnboarding)
        }
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            if newValue {
                isShowingMainApp = true
            }
        }
        .onAppear {
            // Delay enabling animations until after view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animationsEnabled = true
            }
        }
        // Use conditional animation based on animationsEnabled flag
        .animation(animationsEnabled ? .easeInOut : nil, value: isShowingRegistration)
    }
    
    private func loginAction() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please enter both email and password"
            showingAlert = true
            return
        }
        
        authManager.loginUser(email: email, password: password) { success in
            if success {
                // Authentication successful, the onChange modifier will handle navigation
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
            } else {
                // Error is already set in authManager.errorMessage
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserStore())
    }
}
