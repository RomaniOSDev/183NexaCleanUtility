import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdown = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LayeredBackgroundView()
                ScrollView {
                    if markdown.isEmpty {
                        ProgressView()
                            .tint(Color("AppPrimary"))
                            .padding(.top, 80)
                    } else {
                        AccentCard {
                            Group {
                                if let attributed = try? AttributedString(markdown: markdown) {
                                    Text(attributed)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .tint(Color("AppPrimary"))
                                } else {
                                    Text(markdown)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .appNavigationBar()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color("AppPrimary").opacity(0.15))
                    .clipShape(Capsule())
                }
            }
            .onAppear(perform: loadPolicy)
        }
        .preferredColorScheme(.dark)
    }

    private func loadPolicy() {
        if let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            markdown = text
        } else {
            markdown = "# Privacy Policy\nThis app does NOT collect, store, or transmit any personal data."
        }
    }
}
