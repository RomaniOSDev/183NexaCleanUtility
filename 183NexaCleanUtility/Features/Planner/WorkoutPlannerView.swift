import SwiftUI

struct WorkoutPlannerView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievements: AchievementService
    @StateObject private var viewModel = WorkoutPlannerViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LayeredBackgroundView()
                if store.routines.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            icon: "dumbbell.fill",
                            title: "No Routines Yet",
                            message: "Get started by adding your first workout routine!",
                            buttonTitle: "Add Routine",
                            action: { viewModel.startAdd() }
                        )
                        .padding(.top, 40)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ScreenHeaderView(
                                title: "Your Routines",
                                subtitle: "\(store.routines.count) saved",
                                actionTitle: "Add",
                                action: { viewModel.startAdd() }
                            )
                            .padding(.top, 4)

                            ForEach(store.routines) { routine in
                                NavigationLink(value: routine) {
                                    RoutineCardCell(
                                        routine: routine,
                                        progress: progressRatio(for: routine)
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Edit") { viewModel.startEdit(routine) }
                                    Button("Delete", role: .destructive) {
                                        FeedbackService.warning()
                                        store.deleteRoutine(routine)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .screenContentPadding()
                    }
                }
            }
            .navigationTitle("Your Routines")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .navigationDestination(for: WorkoutRoutine.self) { routine in
                RoutineDetailView(routine: routine)
            }
            .safeAreaInset(edge: .bottom) {
                if !store.routines.isEmpty {
                    Button {
                        viewModel.startAdd()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Routine")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color("AppBackground").opacity(0.95), Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                RoutineFormView(existing: viewModel.editingRoutine)
            }
            .onChange(of: store.routines.count) { _ in
                achievements.evaluate(store: store)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func progressRatio(for routine: WorkoutRoutine) -> Double {
        let progress = store.progress(for: routine)
        guard !progress.isEmpty else { return 0 }
        let done = progress.filter { $0 }.count
        return Double(done) / Double(progress.count)
    }
}
