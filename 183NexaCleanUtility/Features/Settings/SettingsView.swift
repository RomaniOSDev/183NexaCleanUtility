import StoreKit
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var backupDocument = BackupDocument()
    @State private var importError: String?
    @State private var importSuccess = false
    @State private var reminderDate = Date()

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LayeredBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        statsSection
                        workoutSection
                        reminderSection
                        backupSection
                        legalSection
                        dangerSection

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                    .padding(16)
                    .screenContentPadding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .onAppear { syncReminderDateFromStore() }
            .fileExporter(isPresented: $showExporter, document: backupDocument, contentType: .json, defaultFilename: "PulseGuide-Backup") { _ in }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
                importBackup(result)
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    FeedbackService.warning()
                }
            } message: {
                Text("This will permanently remove all workouts, routines, and progress on this device.")
            }
            .alert("Import Failed", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(importError ?? "") }
            .alert("Import Complete", isPresented: $importSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your backup was restored successfully.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var statsSection: some View {
        AccentCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Stats")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 10) {
                    StatPillView(value: "\(store.totalEntriesCreated)", label: "Entries", icon: "tray.full.fill")
                    StatPillView(value: "\(store.totalMinutesUsed)", label: "Minutes", icon: "clock.fill")
                    StatPillView(value: "\(store.streakDays)", label: "Streak", icon: "flame.fill")
                }
            }
        }
    }

    private var workoutSection: some View {
        VStack(spacing: 10) {
            ScreenHeaderView(title: "Workout", subtitle: "Planner preferences")
            AccentCard {
                HStack {
                    Image(systemName: "timer")
                        .foregroundStyle(Color("AppAccent"))
                    Text("Rest between exercises")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Stepper("\(store.restTimerSeconds)s", value: Binding(
                        get: { store.restTimerSeconds },
                        set: { store.restTimerSeconds = max(15, min($0, 300)) }
                    ), in: 15...300, step: 15)
                    .labelsHidden()
                    Text("\(store.restTimerSeconds)s")
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(Color("AppAccent"))
                        .frame(width: 48)
                }
            }
        }
    }

    private var reminderSection: some View {
        VStack(spacing: 10) {
            ScreenHeaderView(title: "Reminders", subtitle: "Local notification")
            AccentCard {
                VStack(spacing: 14) {
                    Toggle(isOn: $store.reminderEnabled) {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(Color("AppPrimary"))
                            Text("Daily Workout Reminder")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                    }
                    .tint(Color("AppPrimary"))
                    .onChange(of: store.reminderEnabled) { enabled in
                        if enabled { requestReminderPermission() }
                        else { store.updateReminderSchedule() }
                    }
                    if store.reminderEnabled {
                        DatePicker("Time", selection: $reminderDate, displayedComponents: .hourAndMinute)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .onChange(of: reminderDate) { _ in syncReminderTime() }
                    }
                }
            }
        }
    }

    private var backupSection: some View {
        VStack(spacing: 10) {
            ScreenHeaderView(title: "Backup", subtitle: "Keep data on your device")
            Button { exportBackup() } label: {
                SettingsRowCell(icon: "square.and.arrow.up.fill", title: "Export Backup (JSON)", subtitle: "Save all progress to a file")
            }
            .buttonStyle(.plain)
            Button { showImporter = true } label: {
                SettingsRowCell(icon: "square.and.arrow.down.fill", title: "Import Backup", subtitle: "Restore from a JSON file")
            }
            .buttonStyle(.plain)
        }
    }

    private var legalSection: some View {
        VStack(spacing: 10) {
            ScreenHeaderView(title: "Legal & Feedback", subtitle: nil)

            Button { rateApp() } label: {
                SettingsRowCell(icon: "star.fill", title: "Rate Us", subtitle: "Enjoying the app? Leave a review")
            }
            .buttonStyle(.plain)

            Button { openPrivacyPolicy() } label: {
                SettingsRowCell(icon: "hand.raised.fill", title: "Privacy Policy", subtitle: "Opens in browser")
            }
            .buttonStyle(.plain)

            Button { openTermsOfUse() } label: {
                SettingsRowCell(icon: "doc.text.fill", title: "Terms of Use", subtitle: "Opens in browser")
            }
            .buttonStyle(.plain)
        }
    }

    private var dangerSection: some View {
        VStack(spacing: 10) {
            ScreenHeaderView(title: "Data", subtitle: nil)
            Button { showResetAlert = true } label: {
                SettingsRowCell(icon: "trash.fill", title: "Reset All Data", destructive: true)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func rateApp() {
        FeedbackService.lightTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openPrivacyPolicy() {
        openExternalLink(.privacyPolicy)
    }

    private func openTermsOfUse() {
        openExternalLink(.termsOfUse)
    }

    private func openExternalLink(_ link: AppExternalLink) {
        FeedbackService.lightTap()
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func exportBackup() {
        do {
            backupDocument = BackupDocument(data: try store.exportBundle())
            showExporter = true
            FeedbackService.success()
        } catch {
            importError = "Could not create backup file."
        }
    }

    private func importBackup(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importError = error.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }
                try store.importBundle(from: Data(contentsOf: url))
                importSuccess = true
                FeedbackService.success()
            } catch {
                importError = "Invalid or unsupported backup file."
            }
        }
    }

    private func requestReminderPermission() {
        NotificationService.requestAuthorization { granted in
            if granted {
                syncReminderTime()
                store.updateReminderSchedule()
                FeedbackService.success()
            } else {
                store.reminderEnabled = false
                importError = "Enable notifications in Settings to use reminders."
            }
        }
    }

    private func syncReminderDateFromStore() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = store.reminderHour
        components.minute = store.reminderMinute
        if let date = Calendar.current.date(from: components) { reminderDate = date }
    }

    private func syncReminderTime() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        store.reminderHour = components.hour ?? 18
        store.reminderMinute = components.minute ?? 0
        store.updateReminderSchedule()
    }
}
