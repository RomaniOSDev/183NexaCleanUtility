import Combine
import Foundation
import SwiftUI

@MainActor
final class RestTimerManager: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var remainingSeconds = 0

    private var endDate: Date?

    func start(seconds: Int) {
        guard seconds > 0 else { return }
        remainingSeconds = seconds
        endDate = Date().addingTimeInterval(TimeInterval(seconds))
        isActive = true
        FeedbackService.mediumAction()
    }

    func tick(now: Date = Date()) {
        guard isActive, let endDate else { return }
        remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow.rounded(.up)))
        if remainingSeconds <= 0 {
            complete()
        }
    }

    func cancel() {
        isActive = false
        remainingSeconds = 0
        endDate = nil
    }

    private func complete() {
        isActive = false
        remainingSeconds = 0
        endDate = nil
        FeedbackService.tick()
    }
}
