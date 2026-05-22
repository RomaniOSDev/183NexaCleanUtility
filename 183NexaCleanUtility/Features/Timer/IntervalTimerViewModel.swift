import Foundation
import Combine
import SwiftUI

enum TimerPhase: String {
    case idle
    case work
    case rest
    case finished
}

@MainActor
final class IntervalTimerViewModel: ObservableObject {
    @Published var phase: TimerPhase = .idle
    @Published var currentRound = 0
    @Published var remainingSeconds = 0
    @Published var isRunning = false
    @Published var showSummary = false
    @Published var summaryMinutes = 0
    @Published var showFeedbackSheet = false
    @Published var showSuccessCheck = false
    @Published var validationMessage: String?
    @Published var shakeTrigger = 0

    private var phaseEndDate: Date?
    private var totalElapsedSeconds = 0

    func configure(store: AppDataStore) {
        guard phase == .idle else { return }
        remainingSeconds = store.workSeconds > 0 ? store.workSeconds : 0
    }

    func start(store: AppDataStore) {
        guard store.workSeconds > 0, store.restSeconds >= 0, store.roundsCount > 0 else {
            validationMessage = "Set work time, rest time, and rounds before starting."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        validationMessage = nil
        FeedbackService.mediumAction()
        store.saveTimerConfiguration()
        phase = .work
        currentRound = 1
        remainingSeconds = store.workSeconds
        phaseEndDate = Date().addingTimeInterval(TimeInterval(store.workSeconds))
        isRunning = true
        totalElapsedSeconds = 0
        showSummary = false
    }

    func togglePause() {
        if isRunning {
            if let end = phaseEndDate {
                remainingSeconds = max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
            }
            phaseEndDate = nil
            isRunning = false
        } else if phase != .idle && phase != .finished {
            phaseEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            isRunning = true
        }
        FeedbackService.lightTap()
    }

    func tick(store: AppDataStore, now: Date) {
        guard isRunning, let end = phaseEndDate else { return }
        remainingSeconds = max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
        if remainingSeconds <= 0 {
            advancePhase(store: store)
        }
    }

    func handleSceneInactive() {
        guard isRunning else { return }
        if let end = phaseEndDate {
            remainingSeconds = max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
        }
        phaseEndDate = nil
        isRunning = false
    }

    func handleSceneActive(store: AppDataStore) {
        guard phase != .idle, phase != .finished, !isRunning, remainingSeconds > 0 else { return }
        phaseEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
    }

    private func advancePhase(store: AppDataStore) {
        switch phase {
        case .work:
            totalElapsedSeconds += store.workSeconds
            if currentRound >= store.roundsCount {
                completeSession(store: store)
            } else {
                phase = .rest
                remainingSeconds = store.restSeconds
                if store.restSeconds > 0 {
                    phaseEndDate = Date().addingTimeInterval(TimeInterval(store.restSeconds))
                } else {
                    finishRest(store: store)
                }
            }
        case .rest:
            finishRest(store: store)
        default:
            break
        }
    }

    private func finishRest(store: AppDataStore) {
        totalElapsedSeconds += store.restSeconds
        currentRound += 1
        if currentRound > store.roundsCount {
            completeSession(store: store)
        } else {
            phase = .work
            remainingSeconds = store.workSeconds
            phaseEndDate = Date().addingTimeInterval(TimeInterval(store.workSeconds))
            FeedbackService.tick()
        }
    }

    private func completeSession(store: AppDataStore) {
        phase = .finished
        isRunning = false
        phaseEndDate = nil
        let minutes = max(1, Int(ceil(Double(totalElapsedSeconds) / 60.0)))
        summaryMinutes = minutes
        showSummary = true
        showFeedbackSheet = true
        showSuccessCheck = true
        FeedbackService.timerComplete()
    }

    func reset() {
        phase = .idle
        currentRound = 0
        remainingSeconds = 0
        isRunning = false
        phaseEndDate = nil
        showSummary = false
        showFeedbackSheet = false
        totalElapsedSeconds = 0
    }
}
