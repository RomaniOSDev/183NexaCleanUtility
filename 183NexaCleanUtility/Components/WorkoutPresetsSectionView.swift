import SwiftUI

struct WorkoutPresetsSectionView: View {
    @EnvironmentObject private var store: AppDataStore
    var onApplied: (() -> Void)?
    @State private var selectedPresetId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScreenHeaderView(
                title: "Workout Templates",
                subtitle: "One tap to load intervals"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(WorkoutPresets.all) { preset in
                        Button {
                            FeedbackService.mediumAction()
                            selectedPresetId = preset.id
                            store.applyPreset(preset)
                            onApplied?()
                        } label: {
                            PresetCardCell(preset: preset, isSelected: selectedPresetId == preset.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
