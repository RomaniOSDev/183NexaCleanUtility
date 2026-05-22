import SwiftUI

struct RoutineDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievements: AchievementService
    @EnvironmentObject private var restTimer: RestTimerManager

    let routine: WorkoutRoutine
    @State private var showCheckmark = false
    @State private var restOfferIndex: Int?

    private var progress: [Bool] {
        store.progress(for: routine)
    }

    private var completedCount: Int {
        progress.filter { $0 }.count
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("AppBackground").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    AccentCard {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(Color("AppBackground"), lineWidth: 5)
                                    .frame(width: 64, height: 64)
                                Circle()
                                    .trim(from: 0, to: routine.exercises.isEmpty ? 0 : Double(completedCount) / Double(routine.exercises.count))
                                    .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                    .frame(width: 64, height: 64)
                                    .rotationEffect(.degrees(-90))
                                Text("\(completedCount)/\(routine.exerciseCount)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Session Progress")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Text("~\(routine.estimatedMinutes) min total")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text("Tap an exercise to mark complete")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                            Spacer(minLength: 0)
                        }
                    }

                    ForEach(Array(routine.exercises.enumerated()), id: \.element.id) { index, exercise in
                        let completed = progress.indices.contains(index) ? progress[index] : false
                        let prog: CGFloat = completed ? 1 : 0
                        ExerciseCardCell(
                            name: exercise.name,
                            detail: exercise.detail,
                            completed: completed,
                            progress: prog,
                            showRestButton: restOfferIndex == index || completed,
                            restSeconds: store.restTimerSeconds,
                            onToggle: {
                                FeedbackService.lightTap()
                                let wasCompleted = completed
                                let allDone = store.toggleExercise(routine: routine, index: index)
                                if !wasCompleted { restOfferIndex = index }
                                if allDone {
                                    FeedbackService.routineComplete()
                                    showCheckmark = true
                                    achievements.evaluate(store: store)
                                }
                            },
                            onRest: {
                                FeedbackService.mediumAction()
                                restTimer.start(seconds: store.restTimerSeconds)
                            }
                        )
                    }
                }
                .padding(16)
                .padding(.top, restTimer.isActive ? 88 : 0)
                .screenContentPadding()
            }

            RestTimerOverlayView()
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
        .navigationTitle(routine.title)
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationBar()
        .overlay {
            if showCheckmark {
                SuccessCheckmarkView(isVisible: $showCheckmark)
            }
        }
        .preferredColorScheme(.dark)
    }
}
