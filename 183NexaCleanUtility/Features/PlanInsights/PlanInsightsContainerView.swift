import SwiftUI

enum PlanInsightsSection: String, CaseIterable {
    case routines = "Routines"
    case insights = "Insights"
}

struct PlanInsightsContainerView: View {
    @State private var section: PlanInsightsSection = .routines

    var body: some View {
        VStack(spacing: 0) {
            CustomSegmentedControl(selection: $section)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            switch section {
            case .routines:
                WorkoutPlannerView()
            case .insights:
                FitnessInsightsView()
            }
        }
        .background(Color("AppBackground"))
    }
}
