import SwiftUI

/// One-shot cover of three pages. Continue or Next at the bottom full width.
struct OnboardingFlow: View {
    var onFinish: () -> Void
    @State private var page = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages: [(image: String, title: String, line: String)] = [
        ("kol_Onboarding1", "Save a painting", "Keep a Gardner painting on this device."),
        ("kol_Onboarding2", "Split the glue", "Tap the join between maker and title."),
        ("kol_Onboarding3", "File the roll", "Parted paintings move to Saved with their marks.")
    ]

    var body: some View {
        VStack(spacing: KolSpace.n(2)) {
            pageView(pages[page])
                .id(page)
                .transition(.opacity)

            HStack(spacing: KolSpace.n(1)) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == page ? KolInk.accent : KolInk.muted)
                        .frame(width: index == page ? KolSpace.n(3) : KolSpace.n(1), height: KolSpace.n(1))
                        .accessibilityHidden(true)
                }
            }

            Button(page < pages.count - 1 ? "Next" : "Continue") {
                if page < pages.count - 1 {
                    page += 1
                } else {
                    onFinish()
                }
            }
            .buttonStyle(GluePillStyle(isEnabled: true, isLoading: false))
            .padding(.horizontal, KolSpace.n(2))
            .padding(.bottom, KolSpace.n(2))
        }
        .background(KolInk.background.ignoresSafeArea())
        .animation(reduceMotion ? nil : .easeOut(duration: KolMotion.press), value: page)
    }

    private func pageView(_ page: (image: String, title: String, line: String)) -> some View {
        VStack(spacing: KolSpace.n(2)) {
            Spacer()
            Image(page.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280, maxHeight: 360)
                .accessibilityHidden(true)
            Text(page.title)
                .kolDisplay()
                .foregroundStyle(KolInk.ink)
            Text(page.line)
                .font(KolType.body)
                .foregroundStyle(KolInk.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, KolSpace.n(2))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
