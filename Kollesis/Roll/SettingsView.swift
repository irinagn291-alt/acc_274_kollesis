import SwiftUI

/// Kollesis support, Gardner credit, Retract, re-run onboarding, resetAllData.
struct SettingsView: View {
    @ObservedObject var store: RollStore
    var onClose: () -> Void
    var onRerunOnboarding: () -> Void
    @State private var confirmReset = false

    private let supportURL = URL(string: "https://kollesis-roll.pro/contact-us")!

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ViewThatFits(in: .vertical) {
                    settingsStack
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                    ScrollView {
                        settingsStack
                            .frame(width: geo.size.width, alignment: .top)
                    }
                }
            }
            .background(KolInk.background.ignoresSafeArea())
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
            .confirmationDialog(
                "Erase the roll",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Erase the roll", role: .destructive) {
                    store.resetAllData()
                }
                Button("Keep it", role: .cancel) {}
            } message: {
                Text("This removes every painting, mark, and glued caption on this device.")
            }
        }
    }

    private var settingsStack: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(2)) {
            Text("Support")
                .kolDisplay()
                .foregroundStyle(KolInk.ink)
            Text("Questions about this app go to support.")
                .font(KolType.body)
                .foregroundStyle(KolInk.ink)
                .fixedSize(horizontal: false, vertical: true)

            Link(destination: supportURL) {
                Text("Contact support")
                    .font(KolType.headline)
                    .foregroundStyle(KolInk.surface)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(KolInk.accent, in: Capsule())
                    .contentShape(Capsule())
            }
            .accessibilityHint("Opens the support page")

            if store.persistFailed {
                VStack(alignment: .leading, spacing: KolSpace.n(1)) {
                    Text("The roll did not save.")
                        .font(KolType.headline)
                        .foregroundStyle(KolInk.ink)
                    Button("Retry save") {
                        store.retryPersist()
                    }
                    .buttonStyle(FlatPlateStyle(isEnabled: true))
                }
                .padding(KolSpace.n(2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
            }

            if store.decodeIssue != .none {
                Text(store.documentNote)
                    .font(KolType.body)
                    .foregroundStyle(KolInk.muted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(KolSpace.n(2))
                    .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
            }

            VStack(alignment: .leading, spacing: KolSpace.n(1)) {
                Text("Sources")
                    .font(KolType.headline)
                    .foregroundStyle(KolInk.ink)
                Text("Isabella Stewart Gardner Museum")
                    .font(KolType.body)
                    .foregroundStyle(KolInk.ink)
                sourceLink("Museum home", url: "https://www.gardnermuseum.org")
                sourceLink("Collection", url: "https://www.gardnermuseum.org/experience/collection")
                sourceLink("Wikidata Q49135", url: "https://www.wikidata.org/wiki/Q49135")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(KolSpace.n(2))
            .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))

            VStack(alignment: .leading, spacing: KolSpace.n(1)) {
                Text("The roll")
                    .font(KolType.headline)
                    .foregroundStyle(KolInk.ink)
                if store.document.newestMark != nil {
                    rollAction("Retract newest mark", ink: KolInk.ink) {
                        store.peelNewestMark()
                    }
                }
                rollAction("Replay the welcome", ink: KolInk.ink) {
                    store.reopenOnboarding()
                    onRerunOnboarding()
                }
                rollAction("Erase the roll", ink: KolInk.ink) {
                    confirmReset = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(KolSpace.n(2))
            .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
        }
        .padding(KolSpace.n(2))
        .padding(.bottom, KolSpace.n(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func rollAction(_ title: String, ink: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(KolType.body)
                .foregroundStyle(ink)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(KolSpace.n(2))
                .frame(minHeight: 72)
                .background(KolInk.background, in: RoundedRectangle(cornerRadius: KolRadius.chip, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: KolRadius.chip, style: .continuous))
        }
        .buttonStyle(KolPressStyle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sourceLink(_ title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            Text(title)
                .font(KolType.body)
                .foregroundStyle(KolInk.ink)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}

private extension RollStore {
    var documentNote: String {
        decodeIssue == .recoveredFromBackup
            ? "Restored from the last good roll."
            : "Started a fresh roll after a read miss."
    }
}
