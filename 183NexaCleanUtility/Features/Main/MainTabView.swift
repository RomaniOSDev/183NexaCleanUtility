import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @EnvironmentObject private var achievements: AchievementService
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab)
                case .timer:
                    IntervalTimerView()
                case .plan:
                    PlanInsightsContainerView()
                case .progress:
                    ProgressTabView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if achievements.showBanner, let title = achievements.pendingBannerTitle {
                AchievementBannerView(title: title)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBarView(selection: $selectedTab)
        }
        .onAppear {
            achievements.evaluate(store: store)
        }
        .onChange(of: store.workoutsCompleted) { _ in
            achievements.evaluate(store: store)
        }
        .onChange(of: store.totalMinutesUsed) { _ in
            achievements.evaluate(store: store)
        }
        .onChange(of: store.streakDays) { _ in
            achievements.evaluate(store: store)
        }
        .preferredColorScheme(.dark)
    }
}
