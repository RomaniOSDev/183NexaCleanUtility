//
//  ContentView.swift
//  183NexaCleanUtility
//

import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppDataStore()
    @StateObject private var achievements = AchievementService()
    @StateObject private var restTimer = RestTimerManager()

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .environmentObject(achievements)
        .environmentObject(restTimer)
        .onAppear {
            if store.reminderEnabled {
                store.updateReminderSchedule()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
