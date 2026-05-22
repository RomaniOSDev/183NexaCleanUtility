import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: MainTab

    @State private var showRoutinePicker = false
    @State private var selectedPresetId: String?

    private let widgetColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var weekMinutes: Int {
        store.weeklyStats.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        HomeHeroBanner(
                            streakDays: store.streakDays,
                            workoutsCompleted: store.workoutsCompleted
                        )
                        .padding(.horizontal, 16)

                        HomeTodayProgressWidget(
                            onOpenTimer: { selectedTab = .timer },
                            onOpenPlan: { showRoutinePicker = true }
                        )
                        .padding(.horizontal, 16)
                        .onAppear { store.refreshTodayPlanIfNewDay() }

                        sectionLabel("Quick Actions", subtitle: "Jump into your tools")
                        LazyVGrid(columns: widgetColumns, spacing: 12) {
                            HomeActionWidget(
                                imageName: "WidgetTimer",
                                title: "Interval Timer",
                                subtitle: store.roundsCount > 0
                                    ? "\(store.workSeconds)s / \(store.restSeconds)s · \(store.roundsCount) rounds"
                                    : "Configure and start a session",
                                accent: Color("AppPrimary")
                            ) { selectedTab = .timer }

                            HomeActionWidget(
                                imageName: "WidgetPlan",
                                title: "Your Routines",
                                subtitle: store.routines.isEmpty
                                    ? "Create your first plan"
                                    : "\(store.routines.count) routines saved",
                                accent: Color("AppAccent")
                            ) { selectedTab = .plan }

                            HomeActionWidget(
                                imageName: "WidgetStats",
                                title: "Progress",
                                subtitle: "Achievements & activity map",
                                accent: Color("AppPrimary")
                            ) { selectedTab = .progress }

                            HomeStatWidget(
                                icon: "clock.fill",
                                value: "\(weekMinutes)",
                                label: "Minutes this week",
                                tint: Color("AppAccent")
                            )
                        }
                        .padding(.horizontal, 16)

                        sectionLabel("Workout Templates", subtitle: "One tap to load intervals")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(WorkoutPresets.all) { preset in
                                    Button {
                                        FeedbackService.mediumAction()
                                        selectedPresetId = preset.id
                                        store.applyPreset(preset)
                                        selectedTab = .timer
                                    } label: {
                                        PresetCardCell(preset: preset, isSelected: selectedPresetId == preset.id)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        sectionLabel("Activity", subtitle: "Your latest results")
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                HomeStatWidget(
                                    icon: "flame.fill",
                                    value: "\(store.streakDays)d",
                                    label: "Current streak",
                                    tint: Color("AppPrimary")
                                )
                                HomeStatWidget(
                                    icon: "hourglass",
                                    value: "\(store.longestSessionMinutes)m",
                                    label: "Longest session",
                                    tint: Color("AppAccent")
                                )
                            }

                            HomeRecentSessionWidget(
                                session: store.sessions.first,
                                onOpenInsights: { selectedTab = .plan }
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)
                    .screenContentPadding()
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        FeedbackService.lightTap()
                        selectedTab = .settings
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(width: 44, height: 44)
                    }
                }
            }
            .sheet(isPresented: $showRoutinePicker) {
                HomeRoutinePickerSheet(onDone: { showRoutinePicker = false })
            }
        }
        .preferredColorScheme(.dark)
    }

    private func sectionLabel(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

private struct HomeRoutinePickerSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    var onDone: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 10) {
                        if store.routines.isEmpty {
                            EmptyStateView(
                                icon: "dumbbell.fill",
                                title: "No Routines",
                                message: "Add a routine in the Plan tab first."
                            )
                        } else {
                            ForEach(store.routines) { routine in
                                Button {
                                    FeedbackService.lightTap()
                                    store.setTodayRoutine(id: routine.id)
                                    onDone()
                                    dismiss()
                                } label: {
                                    RoutineCardCell(routine: routine)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Today's Routine")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onDone()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
