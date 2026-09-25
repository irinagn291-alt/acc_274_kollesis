import SwiftUI

/// Roll-locked chrome. Quiz never leaves. Explore, Saved, Settings arrive as sheets.
struct ContentView: View {
    @ObservedObject var store: RollStore
    @ObservedObject private var router = RollRouter.shared
    @State private var sheet: RollSheet?
    @State private var didReadReview = false

    var body: some View {
        QuizView(store: store, openSheet: present)
            .sheet(item: $sheet) { item in
                switch item {
                case .explore:
                    ExploreView(store: store, onClose: { sheet = nil })
                        .presentationCornerRadius(KolRadius.card)
                        .presentationBackground(KolInk.surface)
                        .modifier(RollSheetModifier())
                case .saved:
                    SavedView(store: store, onClose: { sheet = nil })
                        .presentationCornerRadius(KolRadius.card)
                        .presentationBackground(KolInk.surface)
                        .modifier(RollSheetModifier())
                case .settings:
                    SettingsView(
                        store: store,
                        onClose: { sheet = nil },
                        onRerunOnboarding: { sheet = nil }
                    )
                    .presentationCornerRadius(KolRadius.card)
                    .presentationBackground(KolInk.surface)
                    .modifier(RollSheetModifier())
                }
            }
            .fullScreenCover(isPresented: onboardingBinding) {
                OnboardingFlow {
                    store.markOnboardingComplete()
                }
            }
            .onAppear {
                applyReviewHook()
            }
            .onChange(of: router.ticket) { _, ticket in
                guard let ticket else { return }
                apply(ticket.route)
            }
            .onChange(of: store.document.onboardingComplete) { _, done in
                if done {
                    applyReviewHook()
                }
            }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !store.document.onboardingComplete },
            set: { showing in
                if !showing {
                    store.markOnboardingComplete()
                }
            }
        )
    }

    private func present(_ item: RollSheet) {
        sheet = item
    }

    private func applyReviewHook() {
        guard store.document.onboardingComplete, !didReadReview else { return }
        didReadReview = true
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-ReviewScreen"),
           let route = RollLinks.route(fromArguments: arguments) {
            apply(route)
        }
    }

    private func apply(_ route: RollRoute) {
        switch route {
        case .quiz, .glue, .split:
            sheet = nil
            if route == .glue { store.glueRoll() }
            if route == .split, let seam = store.seams.first(where: { !$0.isCooled }) {
                store.splitSeam(seam.id)
            }
        case .explore:
            sheet = .explore
        case .saved:
            sheet = .saved
        case .settings:
            sheet = .settings
        }
    }
}
