import SwiftUI

struct TodayPlanCardView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showRoutinePicker = false

    private var completionProgress: Double {
        var done = 0
        if store.todayPlanRoutineDone { done += 1 }
        if store.todayPlanIntervalsDone { done += 1 }
        return Double(done) / 2.0
    }

    var body: some View {
        AccentCard(highlighted: completionProgress >= 1) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's Plan")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(Date(), format: .dateTime.weekday(.wide).month().day())
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color("AppBackground"), lineWidth: 4)
                            .frame(width: 48, height: 48)
                        Circle()
                            .trim(from: 0, to: completionProgress)
                            .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 48, height: 48)
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(completionProgress * 100))%")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }

                Button {
                    FeedbackService.lightTap()
                    showRoutinePicker = true
                } label: {
                    IconListCell(
                        icon: "list.bullet.rectangle.fill",
                        iconColor: Color("AppPrimary"),
                        title: store.todayPlanRoutine?.title ?? "Choose a routine",
                        subtitle: "Tap to set today's workout",
                        showChevron: true,
                        isCompleted: store.todayPlanRoutineDone
                    )
                }
                .buttonStyle(.plain)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Interval target")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        HStack(spacing: 12) {
                            Button {
                                FeedbackService.lightTap()
                                store.setTodayIntervalTarget(store.todayPlanIntervalTarget - 5)
                            } label: {
                                Image(systemName: "minus")
                                    .frame(width: 36, height: 36)
                                    .background(Color("AppBackground"))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)

                            Text("\(store.todayPlanIntervalTarget) min")
                                .font(.title3.weight(.bold).monospacedDigit())
                                .foregroundStyle(Color("AppAccent"))
                                .frame(minWidth: 72)

                            Button {
                                FeedbackService.lightTap()
                                store.setTodayIntervalTarget(store.todayPlanIntervalTarget + 5)
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: 36, height: 36)
                                    .background(Color("AppBackground"))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color("AppBackground").opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Image(systemName: store.todayPlanIntervalsDone ? "checkmark.circle.fill" : "timer")
                        .font(.title)
                        .foregroundStyle(store.todayPlanIntervalsDone ? Color("AppAccent") : Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 16)
        .onAppear { store.refreshTodayPlanIfNewDay() }
        .sheet(isPresented: $showRoutinePicker) {
            TodayRoutinePickerSheet()
        }
    }
}

private struct TodayRoutinePickerSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

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
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
