import Combine
import Foundation

@MainActor
final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "pg_hasSeenOnboarding"
        static let workoutsCompleted = "pg_workoutsCompleted"
        static let totalMinutesUsed = "pg_totalMinutesUsed"
        static let streakDays = "pg_streakDays"
        static let lastActivityDate = "pg_lastActivityDate"
        static let achievementsUnlocked = "pg_achievementsUnlocked"
        static let workSeconds = "pg_workSeconds"
        static let restSeconds = "pg_restSeconds"
        static let roundsCount = "pg_roundsCount"
        static let recentConfigurations = "pg_recentConfigurations"
        static let routines = "pg_routines"
        static let routineProgress = "pg_routineProgress"
        static let sessions = "pg_sessionsCompleted"
        static let weeklyStats = "pg_weeklyStats"
        static let longestSessionMinutes = "pg_longestSessionMinutes"
        static let roundsCompleted = "pg_roundsCompleted"
        static let totalEntriesCreated = "pg_totalEntriesCreated"
        static let todayPlanRoutineId = "pg_todayPlanRoutineId"
        static let todayPlanIntervalTarget = "pg_todayPlanIntervalTarget"
        static let todayPlanRoutineDone = "pg_todayPlanRoutineDone"
        static let todayPlanIntervalsDone = "pg_todayPlanIntervalsDone"
        static let todayPlanDayKey = "pg_todayPlanDayKey"
        static let activityMinutesByDay = "pg_activityMinutesByDay"
        static let restTimerSeconds = "pg_restTimerSeconds"
        static let reminderEnabled = "pg_reminderEnabled"
        static let reminderHour = "pg_reminderHour"
        static let reminderMinute = "pg_reminderMinute"
        static let bestWeekMinutes = "pg_bestWeekMinutes"
        static let longestIntervalSessionMinutes = "pg_longestIntervalSessionMinutes"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let dayKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var workoutsCompleted: Int {
        didSet { defaults.set(workoutsCompleted, forKey: Keys.workoutsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let lastActivityDate {
                defaults.set(lastActivityDate.timeIntervalSince1970, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveAchievements() }
    }

    @Published var workSeconds: Int {
        didSet { defaults.set(workSeconds, forKey: Keys.workSeconds) }
    }

    @Published var restSeconds: Int {
        didSet { defaults.set(restSeconds, forKey: Keys.restSeconds) }
    }

    @Published var roundsCount: Int {
        didSet { defaults.set(roundsCount, forKey: Keys.roundsCount) }
    }

    @Published var recentConfigurations: [TimerConfiguration] {
        didSet { saveRecentConfigurations() }
    }

    @Published var routines: [WorkoutRoutine] {
        didSet {
            saveRoutines()
            totalEntriesCreated = routines.count + sessions.count
        }
    }

    @Published var routineProgress: [String: [Bool]] {
        didSet { saveRoutineProgress() }
    }

    @Published var sessions: [CompletedSession] {
        didSet {
            saveSessions()
            totalEntriesCreated = routines.count + sessions.count
            recalculateBestWeekMinutes()
        }
    }

    @Published var weeklyStats: [Int] {
        didSet { saveWeeklyStats() }
    }

    @Published var longestSessionMinutes: Int {
        didSet { defaults.set(longestSessionMinutes, forKey: Keys.longestSessionMinutes) }
    }

    @Published var roundsCompleted: Int {
        didSet { defaults.set(roundsCompleted, forKey: Keys.roundsCompleted) }
    }

    @Published var totalEntriesCreated: Int {
        didSet { defaults.set(totalEntriesCreated, forKey: Keys.totalEntriesCreated) }
    }

    @Published var todayPlanRoutineId: UUID? {
        didSet { saveTodayPlanRoutineId() }
    }

    @Published var todayPlanIntervalTarget: Int {
        didSet { defaults.set(todayPlanIntervalTarget, forKey: Keys.todayPlanIntervalTarget) }
    }

    @Published var todayPlanRoutineDone: Bool {
        didSet { defaults.set(todayPlanRoutineDone, forKey: Keys.todayPlanRoutineDone) }
    }

    @Published var todayPlanIntervalsDone: Bool {
        didSet { defaults.set(todayPlanIntervalsDone, forKey: Keys.todayPlanIntervalsDone) }
    }

    @Published var todayPlanDayKey: String {
        didSet { defaults.set(todayPlanDayKey, forKey: Keys.todayPlanDayKey) }
    }

    @Published var activityMinutesByDay: [String: Int] {
        didSet { saveActivityMinutes() }
    }

    @Published var restTimerSeconds: Int {
        didSet { defaults.set(restTimerSeconds, forKey: Keys.restTimerSeconds) }
    }

    @Published var reminderEnabled: Bool {
        didSet { defaults.set(reminderEnabled, forKey: Keys.reminderEnabled) }
    }

    @Published var reminderHour: Int {
        didSet { defaults.set(reminderHour, forKey: Keys.reminderHour) }
    }

    @Published var reminderMinute: Int {
        didSet { defaults.set(reminderMinute, forKey: Keys.reminderMinute) }
    }

    @Published var bestWeekMinutes: Int {
        didSet { defaults.set(bestWeekMinutes, forKey: Keys.bestWeekMinutes) }
    }

    @Published var longestIntervalSessionMinutes: Int {
        didSet { defaults.set(longestIntervalSessionMinutes, forKey: Keys.longestIntervalSessionMinutes) }
    }

    var totalSessionsCompleted: Int { workoutsCompleted }

    var todayPlanRoutine: WorkoutRoutine? {
        guard let id = todayPlanRoutineId else { return nil }
        return routines.first { $0.id == id }
    }

    var personalRecords: PersonalRecords {
        PersonalRecords(
            longestSessionMinutes: longestSessionMinutes,
            bestWeekMinutes: bestWeekMinutes,
            longestIntervalMinutes: longestIntervalSessionMinutes
        )
    }

    var allKnownTags: [String] {
        var set = Set(SessionTags.suggested.map { SessionTags.normalize($0) })
        for session in sessions {
            for tag in session.tags {
                let normalized = SessionTags.normalize(tag)
                if !normalized.isEmpty { set.insert(normalized) }
            }
        }
        return set.sorted()
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        workoutsCompleted = defaults.integer(forKey: Keys.workoutsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        if let interval = defaults.object(forKey: Keys.lastActivityDate) as? TimeInterval {
            lastActivityDate = Date(timeIntervalSince1970: interval)
        } else {
            lastActivityDate = nil
        }
        workSeconds = defaults.integer(forKey: Keys.workSeconds)
        restSeconds = defaults.integer(forKey: Keys.restSeconds)
        roundsCount = defaults.integer(forKey: Keys.roundsCount)
        longestSessionMinutes = defaults.integer(forKey: Keys.longestSessionMinutes)
        roundsCompleted = defaults.integer(forKey: Keys.roundsCompleted)
        totalEntriesCreated = defaults.integer(forKey: Keys.totalEntriesCreated)
        todayPlanIntervalTarget = defaults.object(forKey: Keys.todayPlanIntervalTarget) as? Int ?? 15
        todayPlanRoutineDone = defaults.bool(forKey: Keys.todayPlanRoutineDone)
        todayPlanIntervalsDone = defaults.bool(forKey: Keys.todayPlanIntervalsDone)
        todayPlanDayKey = defaults.string(forKey: Keys.todayPlanDayKey) ?? ""
        restTimerSeconds = defaults.object(forKey: Keys.restTimerSeconds) as? Int ?? 60
        reminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)
        reminderHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? 18
        reminderMinute = defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0
        bestWeekMinutes = defaults.integer(forKey: Keys.bestWeekMinutes)
        longestIntervalSessionMinutes = defaults.integer(forKey: Keys.longestIntervalSessionMinutes)

        if let rawId = defaults.string(forKey: Keys.todayPlanRoutineId), let uuid = UUID(uuidString: rawId) {
            todayPlanRoutineId = uuid
        } else {
            todayPlanRoutineId = nil
        }

        if let data = defaults.data(forKey: Keys.achievementsUnlocked),
           let decoded = try? decoder.decode([String: Date].self, from: data) {
            achievementsUnlocked = decoded
        } else {
            achievementsUnlocked = [:]
        }

        if let data = defaults.data(forKey: Keys.recentConfigurations),
           let decoded = try? decoder.decode([TimerConfiguration].self, from: data) {
            recentConfigurations = decoded
        } else {
            recentConfigurations = []
        }

        if let data = defaults.data(forKey: Keys.routines),
           let decoded = try? decoder.decode([WorkoutRoutine].self, from: data) {
            routines = decoded
        } else {
            routines = []
        }

        if let data = defaults.data(forKey: Keys.routineProgress),
           let decoded = try? decoder.decode([String: [Bool]].self, from: data) {
            routineProgress = decoded
        } else {
            routineProgress = [:]
        }

        if let data = defaults.data(forKey: Keys.sessions),
           let decoded = try? decoder.decode([CompletedSession].self, from: data) {
            sessions = decoded.sorted { $0.date > $1.date }
        } else {
            sessions = []
        }

        if let data = defaults.data(forKey: Keys.weeklyStats),
           let decoded = try? decoder.decode([Int].self, from: data), decoded.count == 7 {
            weeklyStats = decoded
        } else {
            weeklyStats = Array(repeating: 0, count: 7)
        }

        if let data = defaults.data(forKey: Keys.activityMinutesByDay),
           let decoded = try? decoder.decode([String: Int].self, from: data) {
            activityMinutesByDay = decoded
        } else {
            activityMinutesByDay = [:]
        }

        if totalEntriesCreated == 0 {
            totalEntriesCreated = routines.count + sessions.count
        }

        refreshTodayPlanIfNewDay()

        NotificationCenter.default.addObserver(
            forName: .dataReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.reloadFromDefaults()
            }
        }
    }

    func dayKey(for date: Date = Date()) -> String {
        dayKeyFormatter.string(from: date)
    }

    func refreshTodayPlanIfNewDay() {
        let current = dayKey()
        guard todayPlanDayKey != current else { return }
        todayPlanDayKey = current
        todayPlanRoutineDone = false
        todayPlanIntervalsDone = false
    }

    func setTodayRoutine(id: UUID?) {
        refreshTodayPlanIfNewDay()
        todayPlanRoutineId = id
    }

    func setTodayIntervalTarget(_ minutes: Int) {
        refreshTodayPlanIfNewDay()
        todayPlanIntervalTarget = max(1, minutes)
    }

    func markTodayRoutineComplete() {
        refreshTodayPlanIfNewDay()
        todayPlanRoutineDone = true
    }

    func markTodayIntervalsComplete() {
        refreshTodayPlanIfNewDay()
        todayPlanIntervalsDone = true
    }

    func addActivityMinutes(_ minutes: Int, on date: Date = Date()) {
        guard minutes > 0 else { return }
        let key = dayKey(for: date)
        activityMinutesByDay[key, default: 0] += minutes
    }

    func minutes(on date: Date) -> Int {
        activityMinutesByDay[dayKey(for: date), default: 0]
    }

    func applyPreset(_ preset: WorkoutPreset, createRoutineIfNeeded: Bool = true) {
        workSeconds = preset.workSeconds
        restSeconds = preset.restSeconds
        roundsCount = preset.roundsCount
        saveTimerConfiguration()

        guard createRoutineIfNeeded,
              let title = preset.suggestedRoutineTitle,
              let exercises = preset.suggestedExercises,
              !routines.contains(where: { $0.title == title }) else { return }

        addRoutine(WorkoutRoutine(title: title, exercises: exercises))
        todayPlanRoutineId = routines.first(where: { $0.title == title })?.id
        if todayPlanIntervalTarget <= 0 {
            todayPlanIntervalTarget = preset.estimatedMinutes
        }
    }

    func filteredSessions(tag: String?) -> [CompletedSession] {
        guard let tag, !tag.isEmpty, tag != "All" else { return sessions }
        let normalized = SessionTags.normalize(tag)
        return sessions.filter { $0.tags.contains(normalized) }
    }

    func filteredMinutes(tag: String?) -> Int {
        filteredSessions(tag: tag).reduce(0) { $0 + $1.durationMinutes }
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func registerMeaningfulActivity(on date: Date = Date()) {
        let calendar = Calendar.current
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let today = calendar.startOfDay(for: date)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                streakDays += 1
            } else if diff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = date
    }

    func recordWorkoutSession(
        minutes: Int,
        roundsInSession: Int = 0,
        tags: [String] = [],
        note: String = "",
        feeling: Int? = nil,
        source: SessionSource = .general
    ) {
        registerMeaningfulActivity()
        workoutsCompleted += 1
        totalMinutesUsed += minutes
        addActivityMinutes(minutes)
        updateWeeklyStats(minutes: minutes)

        if minutes > longestSessionMinutes {
            longestSessionMinutes = minutes
        }
        if roundsInSession >= 5 {
            roundsCompleted = max(roundsCompleted, roundsInSession)
        }

        if source == .intervalTimer {
            longestIntervalSessionMinutes = max(longestIntervalSessionMinutes, minutes)
            markTodayIntervalsComplete()
        }

        if source == .intervalTimer || !tags.isEmpty || !note.isEmpty || feeling != nil {
            let session = CompletedSession(
                durationMinutes: minutes,
                note: note,
                tags: tags.map { SessionTags.normalize($0) }.filter { !$0.isEmpty },
                feeling: feeling
            )
            sessions.insert(session, at: 0)
        }

        totalEntriesCreated = routines.count + sessions.count
        recalculateBestWeekMinutes()
    }

    enum SessionSource {
        case general
        case intervalTimer
        case manualLog
    }

    func logSession(_ session: CompletedSession) {
        var normalized = session
        normalized.tags = session.tags.map { SessionTags.normalize($0) }.filter { !$0.isEmpty }
        sessions.insert(normalized, at: 0)
        updateWeeklyStats(minutes: normalized.durationMinutes)
        addActivityMinutes(normalized.durationMinutes, on: normalized.date)
        registerMeaningfulActivity()
        workoutsCompleted += 1
        totalMinutesUsed += normalized.durationMinutes
        if normalized.durationMinutes > longestSessionMinutes {
            longestSessionMinutes = normalized.durationMinutes
        }
        totalEntriesCreated = routines.count + sessions.count
        recalculateBestWeekMinutes()
    }

    func updateWeeklyStats(minutes: Int) {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let index = (weekday + 5) % 7
        guard weeklyStats.indices.contains(index) else { return }
        weeklyStats[index] += minutes
    }

    func recalculateBestWeekMinutes() {
        let calendar = Calendar.current
        var weekTotals: [Int] = []
        let grouped = Dictionary(grouping: sessions) { session -> Date in
            calendar.dateInterval(of: .weekOfYear, for: session.date)?.start ?? calendar.startOfDay(for: session.date)
        }
        for (_, weekSessions) in grouped {
            let total = weekSessions.reduce(0) { $0 + $1.durationMinutes }
            weekTotals.append(total)
        }
        let fromActivity = rollingWeekTotalsFromHeatmap()
        bestWeekMinutes = max(weekTotals.max() ?? 0, fromActivity.max() ?? 0, bestWeekMinutes)
    }

    private func rollingWeekTotalsFromHeatmap() -> [Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var totals: [Int] = []
        for offset in stride(from: 0, through: 56, by: 7) {
            guard let weekStart = calendar.date(byAdding: .day, value: -offset - 6, to: today) else { continue }
            var sum = 0
            for day in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: day, to: weekStart) {
                    sum += minutes(on: date)
                }
            }
            totals.append(sum)
        }
        return totals
    }

    func progress(for routine: WorkoutRoutine) -> [Bool] {
        let key = routine.id.uuidString
        if let existing = routineProgress[key], existing.count == routine.exercises.count {
            return existing
        }
        let fresh = Array(repeating: false, count: routine.exercises.count)
        routineProgress[key] = fresh
        return fresh
    }

    func toggleExercise(routine: WorkoutRoutine, index: Int) -> Bool {
        var progress = self.progress(for: routine)
        guard progress.indices.contains(index) else { return false }
        let wasAllDone = progress.allSatisfy { $0 }
        progress[index].toggle()
        routineProgress[routine.id.uuidString] = progress
        let allDone = progress.allSatisfy { $0 }
        if allDone && !wasAllDone {
            registerMeaningfulActivity()
            recordWorkoutSession(minutes: routine.estimatedMinutes)
            markTodayRoutineComplete()
            if routine.exercises.count >= 5 {
                roundsCompleted = max(roundsCompleted, routine.exercises.count)
            }
        }
        return allDone
    }

    func addRoutine(_ routine: WorkoutRoutine) {
        routines.append(routine)
        routineProgress[routine.id.uuidString] = Array(repeating: false, count: routine.exercises.count)
        registerMeaningfulActivity()
        totalEntriesCreated = routines.count + sessions.count
    }

    func updateRoutine(_ routine: WorkoutRoutine) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }
        routines[index] = routine
        routineProgress[routine.id.uuidString] = Array(repeating: false, count: routine.exercises.count)
    }

    func deleteRoutine(_ routine: WorkoutRoutine) {
        routines.removeAll { $0.id == routine.id }
        routineProgress.removeValue(forKey: routine.id.uuidString)
        if todayPlanRoutineId == routine.id {
            todayPlanRoutineId = nil
        }
        totalEntriesCreated = routines.count + sessions.count
    }

    func saveTimerConfiguration() {
        let config = TimerConfiguration(
            workSeconds: workSeconds,
            restSeconds: restSeconds,
            roundsCount: roundsCount
        )
        recentConfigurations.removeAll {
            $0.workSeconds == config.workSeconds &&
            $0.restSeconds == config.restSeconds &&
            $0.roundsCount == config.roundsCount
        }
        recentConfigurations.insert(config, at: 0)
        if recentConfigurations.count > 8 {
            recentConfigurations = Array(recentConfigurations.prefix(8))
        }
    }

    func applyConfiguration(_ config: TimerConfiguration) {
        workSeconds = config.workSeconds
        restSeconds = config.restSeconds
        roundsCount = config.roundsCount
    }

    func updateReminderSchedule() {
        if reminderEnabled {
            NotificationService.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
        } else {
            NotificationService.cancelReminder()
        }
    }

    func exportBundle() throws -> Data {
        let bundle = AppExportBundle(
            version: 1,
            exportedAt: Date(),
            hasSeenOnboarding: hasSeenOnboarding,
            workoutsCompleted: workoutsCompleted,
            totalMinutesUsed: totalMinutesUsed,
            streakDays: streakDays,
            lastActivityDate: lastActivityDate,
            achievementsUnlocked: achievementsUnlocked,
            workSeconds: workSeconds,
            restSeconds: restSeconds,
            roundsCount: roundsCount,
            recentConfigurations: recentConfigurations,
            routines: routines,
            routineProgress: routineProgress,
            sessions: sessions,
            weeklyStats: weeklyStats,
            longestSessionMinutes: longestSessionMinutes,
            roundsCompleted: roundsCompleted,
            totalEntriesCreated: totalEntriesCreated,
            todayPlanRoutineId: todayPlanRoutineId?.uuidString,
            todayPlanIntervalTarget: todayPlanIntervalTarget,
            todayPlanRoutineDone: todayPlanRoutineDone,
            todayPlanIntervalsDone: todayPlanIntervalsDone,
            todayPlanDayKey: todayPlanDayKey,
            activityMinutesByDay: activityMinutesByDay,
            restTimerSeconds: restTimerSeconds,
            reminderEnabled: reminderEnabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            bestWeekMinutes: bestWeekMinutes,
            longestIntervalSessionMinutes: longestIntervalSessionMinutes
        )
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(bundle)
    }

    func importBundle(from data: Data) throws {
        let bundle = try decoder.decode(AppExportBundle.self, from: data)
        guard bundle.version == 1 else { return }

        hasSeenOnboarding = bundle.hasSeenOnboarding
        workoutsCompleted = bundle.workoutsCompleted
        totalMinutesUsed = bundle.totalMinutesUsed
        streakDays = bundle.streakDays
        lastActivityDate = bundle.lastActivityDate
        achievementsUnlocked = bundle.achievementsUnlocked
        workSeconds = bundle.workSeconds
        restSeconds = bundle.restSeconds
        roundsCount = bundle.roundsCount
        recentConfigurations = bundle.recentConfigurations
        routines = bundle.routines
        routineProgress = bundle.routineProgress
        sessions = bundle.sessions.sorted { $0.date > $1.date }
        weeklyStats = bundle.weeklyStats.count == 7 ? bundle.weeklyStats : Array(repeating: 0, count: 7)
        longestSessionMinutes = bundle.longestSessionMinutes
        roundsCompleted = bundle.roundsCompleted
        totalEntriesCreated = bundle.totalEntriesCreated
        todayPlanRoutineId = bundle.todayPlanRoutineId.flatMap(UUID.init(uuidString:))
        todayPlanIntervalTarget = bundle.todayPlanIntervalTarget
        todayPlanRoutineDone = bundle.todayPlanRoutineDone
        todayPlanIntervalsDone = bundle.todayPlanIntervalsDone
        todayPlanDayKey = bundle.todayPlanDayKey
        activityMinutesByDay = bundle.activityMinutesByDay
        restTimerSeconds = bundle.restTimerSeconds
        reminderEnabled = bundle.reminderEnabled
        reminderHour = bundle.reminderHour
        reminderMinute = bundle.reminderMinute
        bestWeekMinutes = bundle.bestWeekMinutes
        longestIntervalSessionMinutes = bundle.longestIntervalSessionMinutes
        refreshTodayPlanIfNewDay()
        updateReminderSchedule()
        recalculateBestWeekMinutes()
    }

    @discardableResult
    func unlockAchievement(id: String) -> Bool {
        guard achievementsUnlocked[id] == nil else { return false }
        achievementsUnlocked[id] = Date()
        return true
    }

    func isAchievementUnlocked(id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func resetAllData() {
        NotificationService.cancelReminder()
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        workoutsCompleted = defaults.integer(forKey: Keys.workoutsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = nil
        achievementsUnlocked = [:]
        workSeconds = 0
        restSeconds = 0
        roundsCount = 0
        recentConfigurations = []
        routines = []
        routineProgress = [:]
        sessions = []
        weeklyStats = Array(repeating: 0, count: 7)
        longestSessionMinutes = 0
        roundsCompleted = 0
        totalEntriesCreated = 0
        todayPlanRoutineId = nil
        todayPlanIntervalTarget = 15
        todayPlanRoutineDone = false
        todayPlanIntervalsDone = false
        todayPlanDayKey = dayKey()
        activityMinutesByDay = [:]
        restTimerSeconds = 60
        reminderEnabled = false
        reminderHour = 18
        reminderMinute = 0
        bestWeekMinutes = 0
        longestIntervalSessionMinutes = 0
    }

    private func saveTodayPlanRoutineId() {
        if let id = todayPlanRoutineId {
            defaults.set(id.uuidString, forKey: Keys.todayPlanRoutineId)
        } else {
            defaults.removeObject(forKey: Keys.todayPlanRoutineId)
        }
    }

    private func saveAchievements() {
        if let data = try? encoder.encode(achievementsUnlocked) {
            defaults.set(data, forKey: Keys.achievementsUnlocked)
        }
    }

    private func saveRecentConfigurations() {
        if let data = try? encoder.encode(recentConfigurations) {
            defaults.set(data, forKey: Keys.recentConfigurations)
        }
    }

    private func saveRoutines() {
        if let data = try? encoder.encode(routines) {
            defaults.set(data, forKey: Keys.routines)
        }
    }

    private func saveRoutineProgress() {
        if let data = try? encoder.encode(routineProgress) {
            defaults.set(data, forKey: Keys.routineProgress)
        }
    }

    private func saveSessions() {
        if let data = try? encoder.encode(sessions) {
            defaults.set(data, forKey: Keys.sessions)
        }
    }

    private func saveWeeklyStats() {
        if let data = try? encoder.encode(weeklyStats) {
            defaults.set(data, forKey: Keys.weeklyStats)
        }
    }

    private func saveActivityMinutes() {
        if let data = try? encoder.encode(activityMinutesByDay) {
            defaults.set(data, forKey: Keys.activityMinutesByDay)
        }
    }
}
