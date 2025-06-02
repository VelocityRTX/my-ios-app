//
//  ContentView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/12/25.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var habitStore: HabitTrackingStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var storyStore: PeerStoryStore
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var profileManager: UserProfileManager
    
    var body: some View {
        MainTabView()
            .environmentObject(habitStore)
            .environmentObject(userStore)
            .environmentObject(storyStore)
            .environmentObject(authManager)
            .environmentObject(profileManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HabitTrackingStore())
            .environmentObject(UserStore())
            .environmentObject(PeerStoryStore())
    }
}

