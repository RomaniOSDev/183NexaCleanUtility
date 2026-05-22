import SwiftUI

struct RoutineFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let existing: WorkoutRoutine?

    @State private var title = ""
    @State private var exercises: [ExerciseItem] = [ExerciseItem(name: "", detail: "")]
    @State private var errorMessage: String?
    @State private var shakeTrigger = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        AccentCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Routine name")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                                TextField("e.g. Upper Body Power", text: $title)
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .shake(trigger: shakeTrigger)
                            }
                        }

                        ScreenHeaderView(
                            title: "Exercises",
                            subtitle: "\(exercises.count) items",
                            actionTitle: "Add",
                            action: {
                                FeedbackService.lightTap()
                                exercises.append(ExerciseItem(name: "", detail: ""))
                            }
                        )

                        ForEach($exercises) { $exercise in
                            AccentCard {
                                VStack(alignment: .leading, spacing: 10) {
                                    TextField("Exercise name", text: $exercise.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    TextField("Reps or duration", text: $exercise.detail)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button("Save Routine") { save() }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(16)
                }
            }
            .navigationTitle(existing == nil ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                if let existing {
                    title = existing.title
                    exercises = existing.exercises
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let validExercises = exercises
            .map {
                ExerciseItem(
                    id: $0.id,
                    name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                    detail: $0.detail.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            .filter { !$0.name.isEmpty }

        guard !trimmedTitle.isEmpty, !validExercises.isEmpty else {
            errorMessage = "Enter a routine name and at least one exercise."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }

        FeedbackService.success()
        if var existing {
            existing.title = trimmedTitle
            existing.exercises = validExercises
            store.updateRoutine(existing)
        } else {
            store.addRoutine(WorkoutRoutine(title: trimmedTitle, exercises: validExercises))
        }
        dismiss()
    }
}
