import SwiftUI

// MARK: - Hero banner

struct HomeHeroBanner: View {
    let streakDays: Int
    let workoutsCompleted: Int

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.1),
                    Color("AppBackground").opacity(0.55),
                    Color("AppBackground").opacity(0.92)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Label("\(streakDays)d streak", systemImage: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color("AppPrimary").opacity(0.35))
                        .clipShape(Capsule())

                    Label("\(workoutsCompleted) sessions", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color("AppSurface").opacity(0.65))
                        .clipShape(Capsule())
                }

                Text(greeting)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text("Ready for today's training?")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day())
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color("AppBackground").opacity(0.5), radius: 12, y: 6)
    }
}

// MARK: - Action widget (image + text)

struct HomeActionWidget: View {
    let imageName: String
    let title: String
    let subtitle: String
    let accent: Color
    var action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackService.lightTap()
            action()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 88)
                        .clipped()

                    LinearGradient(
                        colors: [Color.clear, Color("AppBackground").opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 88)

                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(8)
                        .background(accent.opacity(0.5))
                        .clipShape(Circle())
                        .padding(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppGradients.surface)
            }
        }
        .buttonStyle(.plain)
        .appCardStyle(.medium, cornerRadius: 18, elevatedFill: true)
    }
}

// MARK: - Stat widget (compact)

struct HomeStatWidget: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .appCardStyle(.low, cornerRadius: 16, elevatedFill: true)
    }
}

// MARK: - Today progress widget

struct HomeTodayProgressWidget: View {
    @EnvironmentObject private var store: AppDataStore
    var onOpenTimer: () -> Void
    var onOpenPlan: () -> Void

    private var completionProgress: Double {
        var done = 0
        if store.todayPlanRoutineDone { done += 1 }
        if store.todayPlanIntervalsDone { done += 1 }
        return Double(done) / 2.0
    }

    var body: some View {
        AccentCard(highlighted: completionProgress >= 1) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Today's Focus")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text("\(Int(completionProgress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppAccent"))
                }

                if let routine = store.todayPlanRoutine {
                    HStack(spacing: 10) {
                        Image(systemName: store.todayPlanRoutineDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(store.todayPlanRoutineDone ? Color("AppAccent") : Color("AppTextSecondary"))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(routine.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                            Text("Routine · ~\(routine.estimatedMinutes) min")
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                        Button("Open", action: onOpenPlan)
                            .buttonStyle(SecondaryButtonStyle())
                    }
                } else {
                    Button(action: onOpenPlan) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Set today's routine")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppPrimary"))
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 10) {
                    Image(systemName: store.todayPlanIntervalsDone ? "checkmark.circle.fill" : "timer")
                        .foregroundStyle(store.todayPlanIntervalsDone ? Color("AppAccent") : Color("AppTextSecondary"))
                    Text("\(store.todayPlanIntervalTarget) min intervals")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Button("Start", action: onOpenTimer)
                        .buttonStyle(SecondaryButtonStyle())
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color("AppBackground"))
                        Capsule()
                            .fill(AppGradients.accentProgress)
                            .frame(width: geo.size.width * completionProgress)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

// MARK: - Recent session widget

struct HomeRecentSessionWidget: View {
    let session: CompletedSession?
    var onOpenInsights: () -> Void

    var body: some View {
        Button(action: {
            FeedbackService.lightTap()
            onOpenInsights()
        }) {
            HStack(spacing: 14) {
                Image("WidgetStats")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                if let session {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last Session")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text("\(session.durationMinutes) minutes")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(session.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                        if !session.tags.isEmpty {
                            Text(session.tags.joined(separator: " "))
                                .font(.caption2)
                                .foregroundStyle(Color("AppAccent"))
                                .lineLimit(1)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("No sessions yet")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Log your first workout to see history here.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                    }
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
        .appCardStyle(.low, cornerRadius: 18, elevatedFill: true)
    }
}
