import SwiftUI

struct AchievementBannerView: View {
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "star.fill")
                .font(.title2)
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 44, height: 44)
                .background(Color("AppPrimary").opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .appCardStyle(.medium, cornerRadius: 16, highlighted: true, elevatedFill: true)
        .padding(.horizontal, 16)
    }
}
