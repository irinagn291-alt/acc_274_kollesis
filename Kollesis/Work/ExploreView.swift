import SwiftUI

/// Sheet that keeps one Gardner painting so the roll can split it.
struct ExploreView: View {
    @ObservedObject var store: RollStore
    var onClose: () -> Void
    @StateObject private var hunt = ExploreHunt()
    @State private var chosenObjectId: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            Group {
                if hunt.rows.isEmpty && !hunt.isSearching && hunt.failure == nil {
                    emptyPage
                } else {
                    filingDesk
                }
            }
            .background(KolInk.background.ignoresSafeArea())
            .navigationTitle("Keep a painting")
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
            .onChange(of: hunt.query) { _, value in
                hunt.schedule(query: value, store: store)
            }
            .onChange(of: hunt.rows.map(\.objectId)) { _, ids in
                if chosenObjectId == nil || !ids.contains(chosenObjectId ?? "") {
                    chosenObjectId = ids.first
                }
            }
            .task {
                await hunt.prime(store: store)
                if chosenObjectId == nil {
                    chosenObjectId = hunt.rows.first?.objectId
                }
            }
        }
    }

    private var chosen: Work? {
        filingWorks.first { $0.objectId == chosenObjectId } ?? filingWorks.first
    }

    private var filingDesk: some View {
        ScrollViewReader { proxy in
            ScrollView {
                filingColumn
            }
            .onChange(of: store.focusSerial) { _, _ in
                revealFocused(using: proxy)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var filingColumn: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(2)) {
                Text("Keep this painting.")
                    .kolDisplay()
                    .foregroundStyle(KolInk.ink)
                Text("The next tap files the painting on this device.")
                    .font(KolType.body)
                    .foregroundStyle(KolInk.ink)
                    .fixedSize(horizontal: false, vertical: true)

                TextField("Painting or maker", text: $hunt.query)
                    .font(KolType.body)
                    .foregroundStyle(KolInk.ink)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, KolSpace.n(2))
                    .frame(minHeight: 44)
                    .background(KolInk.surface, in: Capsule())
                    .accessibilityLabel("Painting or maker")

                if let work = chosen {
                    Button("File this painting") {
                        let inserted = store.crateWork(work)
                        if inserted {
                            onClose()
                        } else {
                            chosenObjectId = store.document.focusedObjectId
                        }
                    }
                    .buttonStyle(GluePillStyle(isEnabled: true, isLoading: false))
                    .accessibilityHint("Keeps this painting so you can split it on the roll")
                }

                if hunt.isSearching {
                    HStack(spacing: KolSpace.n(1)) {
                        ProgressView()
                        Text("Looking up the shelf")
                            .font(KolType.body)
                            .foregroundStyle(KolInk.muted)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                }

                if let failure = hunt.failure {
                    VStack(alignment: .leading, spacing: KolSpace.n(1)) {
                        Text("Search could not finish.")
                            .font(KolType.headline)
                            .foregroundStyle(KolInk.ink)
                        Text(failure)
                            .font(KolType.caption)
                            .foregroundStyle(KolInk.muted)
                        Button("Retry") {
                            hunt.schedule(query: hunt.query, store: store)
                        }
                        .frame(minHeight: 44)
                    }
                    .padding(KolSpace.n(2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
                }

                paintingPicker
            }
            .padding(KolSpace.n(2))
            .padding(.bottom, KolSpace.n(2))
            .frame(maxWidth: .infinity, alignment: .top)
    }

    /// Shelf rows come from the hunt object, which keeps one stable identity.
    private var filingWorks: [Work] {
        var seen = Set<String>()
        var list: [Work] = []
        for work in hunt.rows + hunt.shelf {
            if seen.insert(work.objectId).inserted {
                list.append(work)
            }
        }
        if let focused = store.document.focusedObjectId,
           !seen.contains(focused),
           let saved = store.works.first(where: { $0.objectId == focused }) {
            list.insert(saved, at: 0)
        }
        return list
    }

    private func revealFocused(using proxy: ScrollViewProxy) {
        guard let id = store.document.focusedObjectId else { return }
        chosenObjectId = id
        if reduceMotion {
            proxy.scrollTo(id, anchor: .center)
        } else {
            withAnimation(.easeOut(duration: KolMotion.press)) {
                proxy.scrollTo(id, anchor: .center)
            }
        }
    }

    private var paintingPicker: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(1)) {
            Text("Pick another painting")
                .font(KolType.headline)
                .foregroundStyle(KolInk.ink)
            ForEach(filingWorks) { work in
                Button {
                    chosenObjectId = work.objectId
                } label: {
                    VStack(alignment: .leading, spacing: KolSpace.n(0.5)) {
                        Text(work.title)
                            .font(KolType.headline)
                            .foregroundStyle(KolInk.ink)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        Text(work.artist)
                            .font(KolType.body)
                            .foregroundStyle(KolInk.muted)
                            .lineLimit(1)
                        Text(alreadyFiled(work) ? "Already on the roll" : "Ready to file")
                            .font(KolType.caption)
                            .foregroundStyle(KolInk.ink)
                    }
                    .padding(KolSpace.n(2))
                    .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                    .background(
                        work.objectId == chosen?.objectId
                            ? KolInk.accent.opacity(0.16)
                            : KolInk.surface,
                        in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(KolPressStyle())
                .id(work.objectId)
                .accessibilityAddTraits(work.objectId == chosen?.objectId ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var emptyPage: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(2)) {
            Spacer(minLength: KolSpace.n(2))
            Image("kol_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 220)
                .accessibilityHidden(true)
            Text("The shelf is waiting.")
                .kolDisplay()
                .foregroundStyle(KolInk.ink)
            Text("Load a painting, then file it for the split.")
                .font(KolType.body)
                .foregroundStyle(KolInk.ink)
            Spacer()
            Button("Show local shelf") {
                hunt.rows = hunt.shelf
                chosenObjectId = hunt.rows.first?.objectId
            }
            .buttonStyle(GluePillStyle(isEnabled: true, isLoading: false))
        }
        .padding(KolSpace.n(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func alreadyFiled(_ work: Work) -> Bool {
        store.document.works.contains { $0.objectId == work.objectId }
    }
}

@MainActor
final class ExploreHunt: ObservableObject {
    @Published var query = ""
    @Published var rows: [Work] = []
    @Published var isSearching = false
    @Published var failure: String?
    let shelf = GardnerShelf.seedWorks()
    private let client = CatalogClient()

    func prime(store: RollStore) async {
        let cached = await client.lastResolvedWorks()
        if !cached.isEmpty {
            rows = cached
        } else if !store.document.cachedWorks.isEmpty {
            rows = store.document.cachedWorks
        } else {
            rows = GardnerShelf.seedWorks()
        }
    }

    func schedule(query: String, store: RollStore) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        failure = nil
        if trimmed.isEmpty {
            client.cancelHunt()
            isSearching = false
            rows = store.document.cachedWorks.isEmpty ? GardnerShelf.seedWorks() : store.document.cachedWorks
            return
        }
        Task {
            let spin = Task {
                try? await Task.sleep(for: .milliseconds(150))
                if !Task.isCancelled {
                    isSearching = true
                }
            }
            do {
                let found = try await client.huntWorks(query: trimmed)
                spin.cancel()
                isSearching = false
                if found.isEmpty {
                    rows = GardnerShelf.hunt(query: trimmed)
                    if rows.isEmpty {
                        rows = GardnerShelf.seedWorks()
                    }
                } else {
                    rows = found
                    store.rememberCatalog(found)
                }
            } catch is CancellationError {
                spin.cancel()
                return
            } catch CatalogError.cancelled {
                spin.cancel()
                return
            } catch {
                spin.cancel()
                isSearching = false
                failure = "The catalog did not answer. The local shelf is still here."
                rows = GardnerShelf.hunt(query: trimmed)
                if rows.isEmpty {
                    rows = GardnerShelf.seedWorks()
                }
            }
        }
    }
}
