import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LayeredBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        summaryCard
                        ActivityHeatmapView()
                        PersonalRecordsView()

                        ScreenHeaderView(
                            title: "Achievements",
                            subtitle: "\(unlockedCount) of \(AchievementDefinition.all.count) unlocked"
                        )

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(AchievementDefinition.all) { achievement in
                                AchievementCardCell(
                                    achievement: achievement,
                                    unlocked: store.isAchievementUnlocked(id: achievement.id)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                    .screenContentPadding()
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
        }
        .preferredColorScheme(.dark)
    }

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { store.isAchievementUnlocked(id: $0.id) }.count
    }

    private var summaryCard: some View {
        AccentCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Summary")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 10) {
                    StatPillView(value: "\(store.workoutsCompleted)", label: "Sessions", icon: "figure.run")
                    StatPillView(value: "\(store.totalMinutesUsed)", label: "Minutes", icon: "clock.fill")
                    StatPillView(value: "\(store.streakDays)d", label: "Streak", icon: "flame.fill")
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
