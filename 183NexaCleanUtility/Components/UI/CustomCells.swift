import SwiftUI

// MARK: - List row with icon

struct IconListCell: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String?
    var trailing: String?
    var showChevron: Bool = true
    var isCompleted: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
            }

            Spacer(minLength: 8)

            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
            }

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color("AppAccent"))
            } else if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary").opacity(0.7))
            }
        }
        .padding(14)
        .appCardStyle(.low, cornerRadius: 16)
    }
}

// MARK: - Routine card

struct RoutineCardCell: View {
    let routine: WorkoutRoutine
    var progress: Double = 0

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color("AppBackground"), lineWidth: 4)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(AppGradients.accentProgress, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                Image(systemName: "dumbbell.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(routine.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                HStack(spacing: 8) {
                    Label("\(routine.exerciseCount)", systemImage: "list.bullet")
                    Label("~\(routine.estimatedMinutes)m", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .padding(16)
        .appCardStyle(.medium, cornerRadius: 18, elevatedFill: true)
    }
}

// MARK: - Session card

struct SessionCardCell: View {
    let session: CompletedSession

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 2) {
                Text(session.date, format: .dateTime.day())
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
                Text(session.date, format: .dateTime.month(.abbreviated))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(session.durationMinutes) min")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    if let feeling = session.feeling {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("\(feeling)/5")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(Color("AppAccent"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("AppAccent").opacity(0.18))
                        .clipShape(Capsule())
                    }
                }
                if !session.tags.isEmpty {
                    Text(session.tags.joined(separator: "  "))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color("AppPrimary"))
                        .lineLimit(1)
                }
                if !session.note.isEmpty {
                    Text(session.note)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                }
            }
        }
        .padding(14)
        .appCardStyle(.low, cornerRadius: 16, highlighted: false, elevatedFill: true)
    }
}

// MARK: - Preset card

struct PresetCardCell: View {
    let preset: WorkoutPreset
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconForPreset(preset.id))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(width: 36, height: 36)
                    .background(Color("AppPrimary").opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
                Text("~\(preset.estimatedMinutes)m")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("AppAccent").opacity(0.15))
                    .clipShape(Capsule())
            }
            Text(preset.name)
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(preset.subtitle)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Text(preset.goal)
                .font(.caption2)
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(width: 176, alignment: .leading)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppGradients.selectedFill)
            }
        }
        .appCardStyle(.low, cornerRadius: 18, highlighted: isSelected)
    }

    private func iconForPreset(_ id: String) -> String {
        switch id {
        case "tabata": return "flame.fill"
        case "hiit20": return "bolt.heart.fill"
        case "strength_warmup": return "figure.strengthtraining.traditional"
        case "recovery": return "leaf.fill"
        default: return "star.fill"
        }
    }
}

// MARK: - Achievement card

struct AchievementCardCell: View {
    let achievement: AchievementDefinition
    let unlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: achievement.systemImage)
                    .font(.title3)
                    .foregroundStyle(unlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.45))
                    .frame(width: 40, height: 40)
                    .background(unlocked ? Color("AppPrimary").opacity(0.22) : Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
                if unlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
            Text(achievement.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .appCardStyle(.low, cornerRadius: 16, highlighted: unlocked)
        .opacity(unlocked ? 1 : 0.85)
    }
}

// MARK: - Settings row

struct SettingsRowCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var destructive: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(destructive ? .red : Color("AppPrimary"))
                .frame(width: 36, height: 36)
                .background((destructive ? Color.red : Color("AppPrimary")).opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(destructive ? .red : Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }

            Spacer()

            if !destructive {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(14)
        .frame(minHeight: 56)
        .appCardStyle(.low, cornerRadius: 16)
    }
}

// MARK: - Slider control cell

struct SliderControlCell: View {
    let title: String
    let valueLabel: String
    let icon: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var tint: Color = Color("AppPrimary")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                    .frame(width: 28, height: 28)
                    .background(tint.opacity(0.18))
                    .clipShape(Circle())
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                Text(valueLabel)
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(tint)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(tint.opacity(0.14))
                    .clipShape(Capsule())
            }
            Slider(value: $value, in: range, step: step)
                .tint(tint)
        }
        .padding(16)
        .appCardStyle(.low, cornerRadius: 16, elevatedFill: true)
    }
}

// MARK: - Exercise card

struct ExerciseCardCell: View {
    let name: String
    let detail: String
    let completed: Bool
    let progress: CGFloat
    var showRestButton: Bool = false
    var restSeconds: Int = 60
    var onToggle: () -> Void
    var onRest: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(completed ? Color("AppAccent") : Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
                .frame(minWidth: 44, minHeight: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer(minLength: 0)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("AppBackground"))
                    Capsule()
                        .fill(AppGradients.accentProgress)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)

            if showRestButton, let onRest {
                Button(action: onRest) {
                    HStack {
                        Image(systemName: "timer")
                        Text("Start Rest Timer (\(restSeconds)s)")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Color("AppPrimary").opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .appCardStyle(.medium, cornerRadius: 18, highlighted: completed)
    }
}

// MARK: - Filter chip

struct FilterChipCell: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .background {
                    if isSelected {
                        Capsule().fill(AppGradients.primaryButton)
                    } else {
                        Capsule().fill(AppGradients.surface)
                    }
                }
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color("AppPrimary").opacity(isSelected ? 0 : 0.22), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .shadow(color: Color("AppBackground").opacity(isSelected ? 0.4 : 0), radius: isSelected ? 6 : 0, y: 3)
    }
}

// MARK: - Timer hero display

struct TimerHeroCard: View {
    let phaseTitle: String
    let timeText: String
    let roundText: String
    let progress: Double
    let isRunning: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Text(phaseTitle.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Color("AppAccent"))

                ZStack {
                    Circle()
                        .stroke(Color("AppBackground"), lineWidth: 10)
                        .frame(width: 200, height: 200)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AppGradients.accentProgress,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 6) {
                        Text(timeText)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                        Text(isRunning ? "Tap to pause" : "Paused")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                Text(roundText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .appCardStyle(.high, cornerRadius: 24, highlighted: true, elevatedFill: true)
    }
}
