import Combine
import SwiftUI

@MainActor
final class AchievementService: ObservableObject {
    @Published private(set) var pendingBannerTitle: String?
    @Published private(set) var showBanner = false

    private var bannerQueue: [String] = []
    private var isPresenting = false

    func evaluate(store: AppDataStore) {
        var newlyUnlocked: [String] = []

        let checks: [(String, Bool)] = [
            ("first_steps", store.workoutsCompleted >= 1),
            ("consistency_builder", store.workoutsCompleted >= 10),
            ("time_investor", store.totalMinutesUsed >= 100),
            ("streak_starter", store.streakDays >= 3),
            ("routine_mastery", store.roundsCompleted >= 5),
            ("dedicated_trainer", store.longestSessionMinutes >= 60),
            ("committed_streaker", store.streakDays >= 7),
            ("habit_former", store.workoutsCompleted >= 30)
        ]

        for (id, condition) in checks where condition {
            if store.unlockAchievement(id: id),
               let title = AchievementDefinition.all.first(where: { $0.id == id })?.title {
                newlyUnlocked.append(title)
            }
        }

        guard !newlyUnlocked.isEmpty else { return }

        for title in newlyUnlocked {
            FeedbackService.success()
            enqueueBanner(title: title)
        }
    }

    private func enqueueBanner(title: String) {
        bannerQueue.append(title)
        presentNextIfNeeded()
    }

    private func presentNextIfNeeded() {
        guard !isPresenting, let next = bannerQueue.first else { return }
        bannerQueue.removeFirst()
        isPresenting = true
        pendingBannerTitle = next
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showBanner = true
        }

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showBanner = false
                }
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            await MainActor.run {
                isPresenting = false
                pendingBannerTitle = nil
                presentNextIfNeeded()
            }
        }
    }
}
