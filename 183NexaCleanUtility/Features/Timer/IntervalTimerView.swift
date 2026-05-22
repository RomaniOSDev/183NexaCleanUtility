import SwiftUI

struct IntervalTimerView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievements: AchievementService
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = IntervalTimerViewModel()
    @State private var roundsText = ""
    @State private var showRecents = false

    private var isConfigured: Bool {
        store.workSeconds > 0 && store.roundsCount > 0
    }

    private var timerProgress: Double {
        guard store.roundsCount > 0 else { return 0 }
        let phaseDuration: Double
        switch viewModel.phase {
        case .work:
            phaseDuration = Double(max(store.workSeconds, 1))
        case .rest:
            phaseDuration = Double(max(store.restSeconds, 1))
        default:
            return 1
        }
        return min(1, Double(viewModel.remainingSeconds) / phaseDuration)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LayeredBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if viewModel.phase == .idle && !isConfigured {
                            EmptyStateView(
                                icon: "stopwatch.fill",
                                title: "Ready to Train",
                                message: isConfigured ? "Configure your workout intervals to start" : "Set your intervals to begin"
                            )
                        }

                        if viewModel.phase != .idle {
                            TimerHeroCard(
                                phaseTitle: viewModel.phase == .work ? "Work" : viewModel.phase == .rest ? "Rest" : "Done",
                                timeText: timeString(viewModel.remainingSeconds),
                                roundText: "Round \(max(viewModel.currentRound, 1)) of \(store.roundsCount)",
                                progress: timerProgress,
                                isRunning: viewModel.isRunning,
                                onTap: { viewModel.togglePause() }
                            )
                            .padding(.horizontal, 16)
                        }

                        VStack(spacing: 12) {
                            ScreenHeaderView(title: "Interval Setup", subtitle: "Drag to adjust")

                            SliderControlCell(
                                title: "Work",
                                valueLabel: "\(store.workSeconds)s",
                                icon: "flame.fill",
                                value: Binding(
                                    get: { Double(store.workSeconds) },
                                    set: { store.workSeconds = Int($0.rounded()) }
                                ),
                                range: 0...120,
                                step: 5,
                                tint: Color("AppPrimary")
                            )

                            SliderControlCell(
                                title: "Rest",
                                valueLabel: "\(store.restSeconds)s",
                                icon: "leaf.fill",
                                value: Binding(
                                    get: { Double(store.restSeconds) },
                                    set: { store.restSeconds = Int($0.rounded()) }
                                ),
                                range: 0...90,
                                step: 5,
                                tint: Color("AppAccent")
                            )

                            AccentCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "repeat")
                                            .foregroundStyle(Color("AppPrimary"))
                                        Text("Rounds")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        TextField("0", text: $roundsText)
                                            .keyboardType(.numberPad)
                                            .multilineTextAlignment(.trailing)
                                            .font(.title3.weight(.bold).monospacedDigit())
                                            .foregroundStyle(Color("AppAccent"))
                                            .frame(width: 64)
                                            .padding(8)
                                            .background(Color("AppBackground"))
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .shake(trigger: viewModel.shakeTrigger)
                                            .onChange(of: roundsText) { value in
                                                let filtered = value.filter(\.isNumber)
                                                if filtered != value { roundsText = filtered }
                                                store.roundsCount = Int(filtered) ?? 0
                                            }
                                    }
                                    if let message = viewModel.validationMessage {
                                        Text(message)
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }

                            Button {
                                if viewModel.phase == .idle {
                                    viewModel.start(store: store)
                                } else {
                                    viewModel.togglePause()
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: viewModel.phase == .idle ? "play.fill" : (viewModel.isRunning ? "pause.fill" : "play.fill"))
                                    Text(viewModel.phase == .idle ? "Start Session" : (viewModel.isRunning ? "Pause" : "Resume"))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            Button {
                                FeedbackService.lightTap()
                                showRecents = true
                            } label: {
                                HStack {
                                    Image(systemName: "clock.arrow.circlepath")
                                    Text("Recent Configurations")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding(.horizontal, 16)
                    }
                    .screenContentPadding()
                }

                if viewModel.showSuccessCheck {
                    SuccessCheckmarkView(isVisible: $viewModel.showSuccessCheck)
                }

                if viewModel.showSummary {
                    sessionSummaryOverlay
                }
            }
            .navigationTitle("Interval Session Timer")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .sheet(isPresented: $showRecents) {
                recentConfigurationsSheet
            }
            .sheet(isPresented: $viewModel.showFeedbackSheet, onDismiss: {
                if viewModel.phase == .finished {
                    viewModel.showSummary = false
                    viewModel.reset()
                    roundsText = store.roundsCount > 0 ? "\(store.roundsCount)" : ""
                }
            }) {
                SessionFeedbackSheet(
                    minutes: viewModel.summaryMinutes,
                    source: .intervalTimer,
                    roundsInSession: store.roundsCount
                ) {
                    viewModel.showSummary = false
                    viewModel.reset()
                    roundsText = store.roundsCount > 0 ? "\(store.roundsCount)" : ""
                }
            }
            .onAppear {
                roundsText = store.roundsCount > 0 ? "\(store.roundsCount)" : ""
                viewModel.configure(store: store)
            }
            .onChange(of: viewModel.showSummary) { shown in
                if shown { achievements.evaluate(store: store) }
            }
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    viewModel.handleSceneInactive()
                } else {
                    viewModel.handleSceneActive(store: store)
                }
            }
            .overlay {
                TimelineView(.periodic(from: .now, by: 0.25)) { timeline in
                    Color.clear
                        .frame(width: 0, height: 0)
                        .onChange(of: timeline.date) { date in
                            viewModel.tick(store: store, now: date)
                        }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var sessionSummaryOverlay: some View {
        ZStack {
            Color("AppBackground").opacity(0.75).ignoresSafeArea()
            AccentCard(highlighted: true) {
                VStack(spacing: 18) {
                    Image(systemName: "trophy.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color("AppAccent"))
                    Text("Session Complete")
                        .font(.title2.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(viewModel.summaryMinutes) minutes logged")
                        .foregroundStyle(Color("AppTextSecondary"))
                    Button("Add Details") {
                        FeedbackService.lightTap()
                        viewModel.showFeedbackSheet = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(32)
        }
        .transition(.opacity.combined(with: .scale))
    }

    private var recentConfigurationsSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 10) {
                        if store.recentConfigurations.isEmpty {
                            EmptyStateView(
                                icon: "clock.arrow.circlepath",
                                title: "No History",
                                message: "Your saved timer setups will appear here."
                            )
                        } else {
                            ForEach(store.recentConfigurations) { config in
                                Button {
                                    FeedbackService.lightTap()
                                    store.applyConfiguration(config)
                                    roundsText = "\(config.roundsCount)"
                                    showRecents = false
                                } label: {
                                    IconListCell(
                                        icon: "timer",
                                        iconColor: Color("AppAccent"),
                                        title: config.label,
                                        subtitle: config.savedAt.formatted(date: .abbreviated, time: .shortened),
                                        showChevron: false
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Recent")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showRecents = false }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
