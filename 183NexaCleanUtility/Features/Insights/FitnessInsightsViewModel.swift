import Combine
import SwiftUI

@MainActor
final class FitnessInsightsViewModel: ObservableObject {
    @Published var showLogSheet = false
    @Published var highlightBarIndex: Int?
    @Published var minutesText = ""
    @Published var noteText = ""
    @Published var feeling = 3
    @Published var selectedTags: Set<String> = []
    @Published var customTag = ""
    @Published var selectedTagFilter = "All"
    @Published var errorMessage: String?
    @Published var shakeTrigger = 0

    func logSession(store: AppDataStore, achievements: AchievementService) {
        guard let minutes = Int(minutesText.filter(\.isNumber)), minutes > 0 else {
            errorMessage = "Enter a valid duration in minutes."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        errorMessage = nil
        let tags = selectedTags.map { SessionTags.normalize($0) }.filter { !$0.isEmpty }
        let session = CompletedSession(
            durationMinutes: minutes,
            note: noteText.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags,
            feeling: feeling
        )
        store.logSession(session)
        FeedbackService.sessionLogged()
        let weekday = (Calendar.current.component(.weekday, from: Date()) + 5) % 7
        highlightBarIndex = weekday
        achievements.evaluate(store: store)
        resetLogForm()
        showLogSheet = false

        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            await MainActor.run { highlightBarIndex = nil }
        }
    }

    func resetLogForm() {
        minutesText = ""
        noteText = ""
        feeling = 3
        selectedTags = []
        customTag = ""
    }

    func addCustomTag() {
        let normalized = SessionTags.normalize(customTag)
        guard !normalized.isEmpty else { return }
        selectedTags.insert(normalized)
        customTag = ""
        FeedbackService.lightTap()
    }
}
