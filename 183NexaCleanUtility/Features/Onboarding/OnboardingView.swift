import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            headline: "Get Organized",
            description: "Easily plan and track your workouts with our intuitive tools.",
            imageName: "WidgetPlan",
            icon: "calendar",
            accent: Color("AppPrimary"),
            features: ["Custom routines", "Daily plan", "Track progress"]
        ),
        OnboardingPage(
            headline: "Start Timing",
            description: "Use the dynamic timer to keep precise track of each exercise.",
            imageName: "WidgetTimer",
            icon: "stopwatch.fill",
            accent: Color("AppAccent"),
            features: ["Work & rest intervals", "Round tracking", "Quick presets"]
        ),
        OnboardingPage(
            headline: "Begin Your Journey",
            description: "Create your first workout routine to kickstart your fitness path.",
            imageName: "WidgetStats",
            icon: "figure.strengthtraining.traditional",
            accent: Color("AppPrimary"),
            features: ["Build habits", "Earn achievements", "See insights"]
        )
    ]

    var body: some View {
        ZStack {
            LayeredBackgroundView()

            VStack(spacing: 0) {
                topBar

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                bottomControls
            }
        }
        .preferredColorScheme(.dark)
    }

    private var topBar: some View {
        HStack {
            Text("Step \(pageIndex + 1) of \(pages.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))

            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == pageIndex ? AppGradients.primaryButton : LinearGradient(
                            colors: [Color("AppSurface"), Color("AppSurface")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: index == pageIndex ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: pageIndex)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func onboardingPage(page: OnboardingPage, index: Int) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                OnboardingHeroCard(page: page, isActive: pageIndex == index)
                    .padding(.horizontal, 20)

                AccentCard(highlighted: pageIndex == index, elevated: true) {
                    VStack(spacing: 16) {
                        HStack(spacing: 10) {
                            Image(systemName: page.icon)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(page.accent)
                                .frame(width: 40, height: 40)
                                .background(page.accent.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text(page.headline)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            Spacer(minLength: 0)
                        }

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        VStack(spacing: 8) {
                            ForEach(page.features, id: \.self) { feature in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color("AppAccent"))
                                    Text(feature)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color("AppBackground").opacity(0.55))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 8)
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 14) {
            if pageIndex > 0 {
                Button {
                    FeedbackService.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        pageIndex -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            Button(action: advance) {
                HStack(spacing: 10) {
                    Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                    Image(systemName: pageIndex == pages.count - 1 ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background {
            LinearGradient(
                colors: [Color("AppBackground").opacity(0), Color("AppBackground").opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func advance() {
        FeedbackService.lightTap()
        if pageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                pageIndex += 1
            }
        } else {
            FeedbackService.mediumAction()
            store.completeOnboarding()
        }
    }
}

// MARK: - Page model

private struct OnboardingPage {
    let headline: String
    let description: String
    let imageName: String
    let icon: String
    let accent: Color
    let features: [String]
}

// MARK: - Hero illustration card

private struct OnboardingHeroCard: View {
    let page: OnboardingPage
    let isActive: Bool
    @State private var appeared = false

    var body: some View {
        ZStack {
            Image(page.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.05),
                    Color("AppBackground").opacity(0.45),
                    Color("AppBackground").opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack {
                Spacer()
                HStack {
                    Image(systemName: page.icon)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(width: 48, height: 48)
                        .background(page.accent.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Spacer()
                }
                .padding(16)
            }
        }
        .frame(height: 220)
        .appCardStyle(.high, cornerRadius: 24, highlighted: true, elevatedFill: true)
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .onAppear { animateInIfNeeded() }
        .onChange(of: isActive) { _ in animateInIfNeeded() }
    }

    private func animateInIfNeeded() {
        guard isActive else {
            appeared = false
            return
        }
        appeared = false
        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            appeared = true
        }
    }
}
