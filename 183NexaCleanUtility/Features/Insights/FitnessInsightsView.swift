import SwiftUI

struct FitnessInsightsView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievements: AchievementService
    @StateObject private var viewModel = FitnessInsightsViewModel()

    private var filteredSessions: [CompletedSession] {
        store.filteredSessions(tag: viewModel.selectedTagFilter)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                LayeredBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        tagFilterSection

                        if store.sessions.isEmpty && store.workoutsCompleted == 0 {
                            EmptyStateView(
                                icon: "chart.bar.fill",
                                title: "No Insights Yet",
                                message: store.workoutsCompleted > 0
                                    ? "Your stats will appear here after your first workout!"
                                    : "Start logging your sessions to see detailed insights!"
                            )
                        } else {
                            weeklyChart
                        }

                        ScreenHeaderView(
                            title: "Sessions",
                            subtitle: "\(filteredSessions.count) entries"
                        )

                        if filteredSessions.isEmpty {
                            Text("No sessions for this filter.")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .padding(.horizontal, 16)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredSessions) { session in
                                    SessionCardCell(session: session)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        filteredMinutesCard
                    }
                    .padding(.vertical, 16)
                    .screenContentPadding()
                }

                FloatingActionButton(icon: "plus") {
                    viewModel.resetLogForm()
                    viewModel.showLogSheet = true
                }
                .padding(24)
            }
            .navigationTitle("Fitness Insights")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .sheet(isPresented: $viewModel.showLogSheet) {
                logSessionSheet
            }
        }
        .preferredColorScheme(.dark)
    }

    private var tagFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipCell(title: "All", isSelected: viewModel.selectedTagFilter == "All") {
                    viewModel.selectedTagFilter = "All"
                }
                ForEach(store.allKnownTags, id: \.self) { tag in
                    FilterChipCell(title: tag, isSelected: viewModel.selectedTagFilter == tag) {
                        viewModel.selectedTagFilter = tag
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var weeklyChart: some View {
        let chartData = weeklyChartData
        let maxValue = max(chartData.max() ?? 0, 1)
        let labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        return AccentCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Weekly Minutes")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))

                Canvas { context, size in
                    let barWidth = size.width / CGFloat(chartData.count * 2)
                    for (index, value) in chartData.enumerated() {
                        let height = CGFloat(value) / CGFloat(maxValue) * (size.height - 28)
                        let x = CGFloat(index) * (barWidth * 2) + barWidth * 0.5
                        let rect = CGRect(x: x, y: size.height - height - 10, width: barWidth, height: max(height, 4))
                        let color = index == viewModel.highlightBarIndex ? Color("AppAccent") : Color("AppPrimary")
                        context.fill(Path(roundedRect: rect, cornerSize: CGSize(width: 5, height: 5)), with: .color(color))
                    }
                }
                .frame(height: 140)
                .scaleEffect(viewModel.highlightBarIndex != nil ? 1.02 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.highlightBarIndex)

                HStack {
                    ForEach(labels, id: \.self) { label in
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var filteredMinutesCard: some View {
        AccentCard(highlighted: true) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.selectedTagFilter == "All" ? "Total Minutes" : "Filtered Minutes")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("\(store.filteredMinutes(tag: viewModel.selectedTagFilter))")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.largeTitle)
                    .foregroundStyle(Color("AppAccent").opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
    }

    private var weeklyChartData: [Int] {
        guard viewModel.selectedTagFilter != "All" else { return store.weeklyStats }
        let calendar = Calendar.current
        var buckets = Array(repeating: 0, count: 7)
        for session in filteredSessions {
            let index = (calendar.component(.weekday, from: session.date) + 5) % 7
            if buckets.indices.contains(index) {
                buckets[index] += session.durationMinutes
            }
        }
        return buckets
    }

    private var logSessionSheet: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 14) {
                        AccentCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Duration (minutes)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("AppTextSecondary"))
                                TextField("e.g. 45", text: $viewModel.minutesText)
                                    .keyboardType(.numberPad)
                                    .font(.title.weight(.bold).monospacedDigit())
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .padding(12)
                                    .background(Color("AppBackground"))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .shake(trigger: viewModel.shakeTrigger)
                            }
                        }

                        AccentCard {
                            Stepper("Energy: \(viewModel.feeling)/5", value: $viewModel.feeling, in: 1...5)
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
                                            FilterChipCell(
                                                title: tag,
                                                isSelected: viewModel.selectedTags.contains(tag)
                                            ) {
                                                if viewModel.selectedTags.contains(tag) {
                                                    viewModel.selectedTags.remove(tag)
                                                } else {
                                                    viewModel.selectedTags.insert(tag)
                                                }
                                            }
                                        }
                                    }
                                }
                                HStack {
                                    TextField("Custom tag", text: $viewModel.customTag)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Button("Add") { viewModel.addCustomTag() }
                                        .buttonStyle(SecondaryButtonStyle())
                                }
                            }
                        }

                        AccentCard {
                            TextField("Notes (optional)", text: $viewModel.noteText, axis: .vertical)
                                .lineLimit(2...4)
                                .foregroundStyle(Color("AppTextPrimary"))
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 4)
                        }

                        Button("Save Session") {
                            viewModel.logSession(store: store, achievements: achievements)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showLogSheet = false }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
