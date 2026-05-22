import Combine
import SwiftUI

@MainActor
final class WorkoutPlannerViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var editingRoutine: WorkoutRoutine?
    @Published var showSuccessCheck = false
    @Published var showCheckmarkAnimation = false

    func startAdd() {
        editingRoutine = nil
        showAddSheet = true
    }

    func startEdit(_ routine: WorkoutRoutine) {
        editingRoutine = routine
        showAddSheet = true
    }
}
