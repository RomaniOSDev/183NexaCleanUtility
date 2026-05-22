import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case timer
    case plan
    case progress
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .timer: return "Timer"
        case .plan: return "Plan"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .timer: return "stopwatch.fill"
        case .plan: return "list.bullet.clipboard.fill"
        case .progress: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBarView: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    FeedbackService.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 17, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
                    .foregroundStyle(selection == tab ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if selection == tab {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppGradients.primaryButton)
                        }
                    }
                    .scaleEffect(selection == tab ? 1 : 0.94)
                }
                .buttonStyle(.plain)
                .frame(minHeight: 50)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppGradients.surface)
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppGradients.topSheen)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.22), lineWidth: 1)
        )
        .shadow(color: Color("AppBackground").opacity(0.55), radius: 12, y: -4)
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}
