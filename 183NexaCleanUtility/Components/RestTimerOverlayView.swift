import SwiftUI

struct RestTimerOverlayView: View {
    @EnvironmentObject private var restTimer: RestTimerManager

    var body: some View {
        Group {
            if restTimer.isActive {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(Color("AppBackground"), lineWidth: 4)
                            .frame(width: 52, height: 52)
                        Text(timeString(restTimer.remainingSeconds))
                            .font(.caption.weight(.bold).monospacedDigit())
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Rest Timer")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                        Text("Breathe and recover")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Spacer()
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        restTimer.cancel()
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppPrimary"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color("AppPrimary").opacity(0.14))
                    .clipShape(Capsule())
                }
                .padding(14)
                .appCardStyle(.medium, cornerRadius: 18, highlighted: true)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: restTimer.isActive)
        .overlay {
            TimelineView(.periodic(from: .now, by: 0.5)) { timeline in
                Color.clear
                    .frame(width: 0, height: 0)
                    .onChange(of: timeline.date) { _ in restTimer.tick() }
            }
        }
    }

    private func timeString(_ seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }
}
