import SwiftUI

struct SessionFeedbackSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievements: AchievementService

    let minutes: Int
    let source: AppDataStore.SessionSource
    let roundsInSession: Int
    var onSaved: (() -> Void)?

    @State private var note = ""
    @State private var feeling = 3
    @State private var selectedTags: Set<String> = []
    @State private var customTag = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        AccentCard(highlighted: true) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Great work!")
                                        .font(.headline)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text("\(minutes) minutes completed")
                                        .font(.subheadline)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                                Spacer()
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundStyle(Color("AppAccent"))
                            }
                        }

                        AccentCard {
                            Stepper("Energy: \(feeling)/5", value: $feeling, in: 1...5)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }

                        AccentCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Tags")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(store.allKnownTags, id: \.self) { tag in
                                            FilterChipCell(title: tag, isSelected: selectedTags.contains(tag)) {
                                                toggleTag(tag)
                                            }
                                        }
                                    }
                                }
                                HStack {
                                    TextField("Add tag", text: $customTag)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Button("Add") { addCustomTag() }
                                        .buttonStyle(SecondaryButtonStyle())
                                }
                            }
                        }

                        AccentCard {
                            TextField("Optional notes", text: $note, axis: .vertical)
                                .lineLimit(2...4)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }

                        Button("Save Session") { save() }
                            .buttonStyle(PrimaryButtonStyle())
                        Button("Skip") { save() }
                            .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func toggleTag(_ tag: String) {
        FeedbackService.lightTap()
        if selectedTags.contains(tag) { selectedTags.remove(tag) }
        else { selectedTags.insert(tag) }
    }

    private func addCustomTag() {
        let normalized = SessionTags.normalize(customTag)
        guard !normalized.isEmpty else { return }
        selectedTags.insert(normalized)
        customTag = ""
        FeedbackService.lightTap()
    }

    private func save() {
        FeedbackService.success()
        store.recordWorkoutSession(
            minutes: minutes,
            roundsInSession: roundsInSession,
            tags: Array(selectedTags),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            feeling: feeling,
            source: source
        )
        achievements.evaluate(store: store)
        onSaved?()
        dismiss()
    }
}
