import SwiftUI

struct PersonalRecordsView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        let records = store.personalRecords

        VStack(alignment: .leading, spacing: 12) {
            ScreenHeaderView(title: "Personal Records", subtitle: "Your best performances")

            VStack(spacing: 10) {
                recordRow(
                    title: "Longest Session",
                    value: records.longestSessionMinutes > 0 ? "\(records.longestSessionMinutes) min" : "—",
                    icon: "clock.badge.checkmark.fill",
                    tint: Color("AppPrimary")
                )
                recordRow(
                    title: "Best Week",
                    value: records.bestWeekMinutes > 0 ? "\(records.bestWeekMinutes) min" : "—",
                    icon: "calendar.badge.clock",
                    tint: Color("AppAccent")
                )
                recordRow(
                    title: "Longest Interval Set",
                    value: records.longestIntervalMinutes > 0 ? "\(records.longestIntervalMinutes) min" : "—",
                    icon: "stopwatch.fill",
                    tint: Color("AppPrimary")
                )
            }
        }
        .padding(.horizontal, 16)
    }

    private func recordRow(title: String, value: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 48, height: 48)
                .background(tint.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
        }
        .padding(14)
        .appCardStyle(.low, cornerRadius: 16, elevatedFill: true)
    }
}
