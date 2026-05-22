import SwiftUI

struct ScreenHeaderView: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer(minLength: 8)
            if let actionTitle, let action {
                Button(action: {
                    FeedbackService.lightTap()
                    action()
                }) {
                    Text(actionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppGradients.primaryButton)
                        .clipShape(Capsule())
                        .shadow(color: Color("AppPrimary").opacity(0.3), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(AppGradients.surfaceElevated)
                    .frame(width: 96, height: 96)
                Circle()
                    .fill(AppGradients.topSheen)
                    .frame(width: 96, height: 96)
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
            .appCardStyle(.medium, cornerRadius: 48)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 40)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct AccentCard<Content: View>: View {
    var highlighted: Bool = false
    var elevated: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .appCardStyle(
                highlighted ? .medium : .low,
                cornerRadius: 18,
                highlighted: highlighted,
                elevatedFill: elevated
            )
    }
}

struct StatPillView: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 28, height: 28)
                .background(Color("AppPrimary").opacity(0.22))
                .clipShape(Circle())
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appCardStyle(.flat, cornerRadius: 14, elevatedFill: true)
    }
}

struct CustomSegmentedControl<T: Hashable & CaseIterable & RawRepresentable>: View where T.RawValue == String, T.AllCases: RandomAccessCollection {
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(T.allCases), id: \.self) { item in
                Button {
                    FeedbackService.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(selection == item ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Group {
                                if selection == item {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppGradients.primaryButton)
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color("AppBackground").opacity(0.6))
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .appCardStyle(.low, cornerRadius: 16)
    }
}

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackService.lightTap()
            action()
        }) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 58, height: 58)
                .background(AppGradients.primaryButton)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .shadow(color: Color("AppPrimary").opacity(0.4), radius: 8, y: 4)
    }
}

struct AppNavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color("AppBackground").opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func appNavigationBar() -> some View {
        modifier(AppNavigationBarModifier())
    }

    func screenContentPadding() -> some View {
        padding(.bottom, 88)
    }
}
