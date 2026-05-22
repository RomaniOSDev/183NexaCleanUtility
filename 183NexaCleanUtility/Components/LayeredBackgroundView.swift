import SwiftUI

/// Lightweight screen background: 3 gradients only, no Canvas (avoids per-frame dot drawing).
struct LayeredBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("AppBackground"),
                    Color("AppBackground").opacity(0.97),
                    Color("AppSurface").opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.1), Color.clear],
                center: .topTrailing,
                startRadius: 8,
                endRadius: 280
            )
            RadialGradient(
                colors: [Color("AppAccent").opacity(0.07), Color.clear],
                center: .bottomLeading,
                startRadius: 8,
                endRadius: 240
            )
        }
        .ignoresSafeArea()
    }
}
