import SwiftUI

// MARK: - Elevation levels (single shadow each — GPU-friendly)

enum AppElevationLevel {
    case flat
    case low
    case medium
    case high

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 6
        case .medium: return 10
        case .high: return 14
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 3
        case .medium: return 5
        case .high: return 8
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .flat: return 0
        case .low: return 0.35
        case .medium: return 0.45
        case .high: return 0.5
        }
    }
}

// MARK: - Reusable gradients (2-stop only — cheap to rasterize)

enum AppGradients {
    static var surface: LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppSurface").opacity(0.88)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceElevated: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(1),
                Color("AppPrimary").opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButton: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent").opacity(0.92)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var accentProgress: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var topSheen: LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.07), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var selectedFill: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary").opacity(0.28), Color("AppSurface")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Card modifier (background + border + 1 shadow + sheen)

struct AppCardStyleModifier: ViewModifier {
    var level: AppElevationLevel = .low
    var cornerRadius: CGFloat = 16
    var highlighted: Bool = false
    var useElevatedFill: Bool = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let borderColor = highlighted ? Color("AppAccent").opacity(0.55) : Color("AppPrimary").opacity(0.18)
        let borderWidth: CGFloat = highlighted ? 1.5 : 1
        let effectiveLevel: AppElevationLevel = highlighted ? .medium : level

        content
            .background {
                shape
                    .fill(useElevatedFill ? AppGradients.surfaceElevated : AppGradients.surface)
                shape
                    .fill(AppGradients.topSheen)
            }
            .overlay {
                shape.stroke(borderColor, lineWidth: borderWidth)
            }
            .clipShape(shape)
            .shadow(
                color: Color("AppBackground").opacity(effectiveLevel.shadowOpacity),
                radius: effectiveLevel.shadowRadius,
                y: effectiveLevel.shadowY
            )
    }
}

extension View {
    /// Standard card: gradient fill, subtle top sheen, one shadow.
    func appCardStyle(
        _ level: AppElevationLevel = .low,
        cornerRadius: CGFloat = 16,
        highlighted: Bool = false,
        elevatedFill: Bool = false
    ) -> some View {
        modifier(AppCardStyleModifier(
            level: level,
            cornerRadius: cornerRadius,
            highlighted: highlighted,
            useElevatedFill: elevatedFill
        ))
    }
}
