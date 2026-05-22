import SwiftUI

struct ActivityHeatmapView: View {
    @EnvironmentObject private var store: AppDataStore

    private let weeksToShow = 12
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    var body: some View {
        AccentCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("AppPrimary"))
                        .frame(width: 32, height: 32)
                        .background(Color("AppPrimary").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Activity Calendar")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("12-week training consistency")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }

                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(heatmapDays) { day in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(color(for: day.minutes))
                            .frame(height: 20)
                            .overlay {
                                if Calendar.current.isDateInToday(day.date) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color("AppAccent"), lineWidth: 1.5)
                                }
                            }
                    }
                }

                HStack(spacing: 8) {
                    Text("Less")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                    ForEach([0, 15, 30, 60], id: \.self) { level in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(color(for: level))
                            .frame(width: 16, height: 12)
                    }
                    Text("More")
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var heatmapDays: [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = weeksToShow * 7
        guard let start = calendar.date(byAdding: .day, value: -(totalDays - 1), to: today) else { return [] }
        return (0..<totalDays).compactMap { offset -> HeatmapDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return HeatmapDay(date: date, minutes: store.minutes(on: date))
        }
    }

    private func color(for minutes: Int) -> Color {
        switch minutes {
        case 0: return Color("AppBackground")
        case 1...14: return Color("AppSurface")
        case 15...29: return Color("AppPrimary").opacity(0.5)
        case 30...59: return Color("AppPrimary").opacity(0.8)
        default: return Color("AppAccent")
        }
    }
}

private struct HeatmapDay: Identifiable {
    let date: Date
    let minutes: Int
    var id: String { date.formatted(date: .numeric, time: .omitted) }
}
