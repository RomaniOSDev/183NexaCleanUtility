import SwiftUI

struct SuccessCheckmarkView: View {
    @Binding var isVisible: Bool

    var body: some View {
        Group {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color("AppAccent"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .onChange(of: isVisible) { visible in
            guard visible else { return }
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.25)) {
                        isVisible = false
                    }
                }
            }
        }
    }
}
