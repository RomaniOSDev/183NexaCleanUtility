import Foundation

struct ExerciseItem: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var detail: String

    init(id: UUID = UUID(), name: String, detail: String) {
        self.id = id
        self.name = name
        self.detail = detail
    }
}

struct WorkoutRoutine: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var title: String
    var exercises: [ExerciseItem]

    var exerciseCount: Int { exercises.count }

    var estimatedMinutes: Int {
        exercises.reduce(0) { partial, exercise in
            let digits = exercise.detail.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let value = Int(digits), value > 0 {
                return partial + max(value / 60, 1)
            }
            return partial + 3
        }
    }

    init(id: UUID = UUID(), title: String, exercises: [ExerciseItem]) {
        self.id = id
        self.title = title
        self.exercises = exercises
    }
}

struct CompletedSession: Codable, Identifiable, Equatable {
    var id: UUID
    var date: Date
    var durationMinutes: Int
    var note: String
    var tags: [String]
    var feeling: Int?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        durationMinutes: Int,
        note: String = "",
        tags: [String] = [],
        feeling: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.note = note
        self.tags = tags
        self.feeling = feeling
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        feeling = try container.decodeIfPresent(Int.self, forKey: .feeling)
    }
}

struct TimerConfiguration: Codable, Equatable, Identifiable {
    var id: UUID
    var workSeconds: Int
    var restSeconds: Int
    var roundsCount: Int
    var savedAt: Date

    init(id: UUID = UUID(), workSeconds: Int, restSeconds: Int, roundsCount: Int, savedAt: Date = Date()) {
        self.id = id
        self.workSeconds = workSeconds
        self.restSeconds = restSeconds
        self.roundsCount = roundsCount
        self.savedAt = savedAt
    }

    var label: String {
        "\(workSeconds)s work / \(restSeconds)s rest × \(roundsCount) rounds"
    }
}

struct WorkoutPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let subtitle: String
    let goal: String
    let workSeconds: Int
    let restSeconds: Int
    let roundsCount: Int
    let suggestedRoutineTitle: String?
    let suggestedExercises: [ExerciseItem]?

    var estimatedMinutes: Int {
        let cycle = workSeconds + restSeconds
        return max(1, (cycle * roundsCount) / 60)
    }
}

struct PersonalRecords: Equatable {
    let longestSessionMinutes: Int
    let bestWeekMinutes: Int
    let longestIntervalMinutes: Int
}

struct AppExportBundle: Codable {
    let version: Int
    let exportedAt: Date
    let hasSeenOnboarding: Bool
    let workoutsCompleted: Int
    let totalMinutesUsed: Int
    let streakDays: Int
    let lastActivityDate: Date?
    let achievementsUnlocked: [String: Date]
    let workSeconds: Int
    let restSeconds: Int
    let roundsCount: Int
    let recentConfigurations: [TimerConfiguration]
    let routines: [WorkoutRoutine]
    let routineProgress: [String: [Bool]]
    let sessions: [CompletedSession]
    let weeklyStats: [Int]
    let longestSessionMinutes: Int
    let roundsCompleted: Int
    let totalEntriesCreated: Int
    let todayPlanRoutineId: String?
    let todayPlanIntervalTarget: Int
    let todayPlanRoutineDone: Bool
    let todayPlanIntervalsDone: Bool
    let todayPlanDayKey: String
    let activityMinutesByDay: [String: Int]
    let restTimerSeconds: Int
    let reminderEnabled: Bool
    let reminderHour: Int
    let reminderMinute: Int
    let bestWeekMinutes: Int
    let longestIntervalSessionMinutes: Int
}

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_steps", title: "First Steps", description: "Completed your very first workout session.", systemImage: "figure.walk"),
        AchievementDefinition(id: "consistency_builder", title: "Consistency Builder", description: "Completed 10 workout sessions.", systemImage: "calendar"),
        AchievementDefinition(id: "time_investor", title: "Time Investor", description: "Accumulated over 100 minutes of total workout time.", systemImage: "clock.fill"),
        AchievementDefinition(id: "streak_starter", title: "Streak Starter", description: "Maintained a workout streak for 3 consecutive days.", systemImage: "flame.fill"),
        AchievementDefinition(id: "routine_mastery", title: "Routine Mastery", description: "Completed at least one routine consisting of 5 or more exercises.", systemImage: "list.bullet.rectangle"),
        AchievementDefinition(id: "dedicated_trainer", title: "Dedicated Trainer", description: "Achieved a longest session lasting over 60 minutes.", systemImage: "hourglass"),
        AchievementDefinition(id: "committed_streaker", title: "Committed Streaker", description: "Maintained a consistent workout streak for over a week.", systemImage: "star.fill"),
        AchievementDefinition(id: "habit_former", title: "Habit Former", description: "Reached a total of 30 completed workouts.", systemImage: "checkmark.seal.fill")
    ]
}

enum SessionTags {
    static let suggested = ["legs", "cardio", "upper", "core", "stretch", "hiit"]

    static func normalize(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return "" }
        return trimmed.hasPrefix("#") ? trimmed : "#\(trimmed)"
    }
}
