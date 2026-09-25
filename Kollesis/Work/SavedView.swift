import SwiftUI

/// Sheet of Parted works plus reviewable SeamMarks and TearMarks.
struct SavedView: View {
    @ObservedObject var store: RollStore
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            Group {
                if store.persistFailed && store.partedWorks.isEmpty && store.document.seamMarks.isEmpty && store.document.tearMarks.isEmpty {
                    persistPage
                } else if store.partedWorks.isEmpty && store.document.seamMarks.isEmpty && store.document.tearMarks.isEmpty {
                    emptyPage
                } else {
                    list
                }
            }
            .background(KolInk.background.ignoresSafeArea())
            .navigationTitle("Saved")
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
        }
    }

    private var persistPage: some View {
        VStack(spacing: KolSpace.n(2)) {
            Spacer()
            Image("kol_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 220)
                .accessibilityHidden(true)
            Text("Marks did not save.")
                .kolDisplay()
                .foregroundStyle(KolInk.ink)
            Text("Retry keeps this list on the device.")
                .font(KolType.body)
                .foregroundStyle(KolInk.muted)
            Spacer()
            Button("Retry save") {
                store.retryPersist()
            }
            .buttonStyle(GluePillStyle(isEnabled: true, isLoading: false))
            .padding(.horizontal, KolSpace.n(2))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyPage: some View {
        VStack(spacing: KolSpace.n(2)) {
            Spacer()
            Image("kol_EmptyList")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 220)
                .accessibilityHidden(true)
            Text("Nothing parted yet.")
                .kolDisplay()
                .foregroundStyle(KolInk.ink)
            Text("Split a caption on the roll.")
                .font(KolType.body)
                .foregroundStyle(KolInk.muted)
            Spacer()
            Button("Back to the roll", action: onClose)
                .buttonStyle(GluePillStyle(isEnabled: true, isLoading: false))
                .padding(.horizontal, KolSpace.n(2))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var list: some View {
        GeometryReader { geo in
            ViewThatFits(in: .vertical) {
                savedStack
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                ScrollView {
                    savedStack
                        .frame(width: geo.size.width, alignment: .top)
                }
            }
        }
    }

    private var savedStack: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(2)) {
            if store.persistFailed {
                VStack(alignment: .leading, spacing: KolSpace.n(1)) {
                    Text("The roll did not save.")
                        .font(KolType.headline)
                        .foregroundStyle(KolInk.ink)
                    Button("Retry save") {
                        store.retryPersist()
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .padding(KolSpace.n(2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
            }
            if !store.partedWorks.isEmpty {
                savedBand(title: "Parted works") {
                    ForEach(store.partedWorks) { work in
                        VStack(alignment: .leading, spacing: KolSpace.n(0.5)) {
                            Text(work.title)
                                .font(KolType.headline)
                                .foregroundStyle(KolInk.ink)
                                .lineLimit(2)
                            Text(work.artist)
                                .font(KolType.body)
                                .foregroundStyle(KolInk.muted)
                                .lineLimit(1)
                            Text(KolType.day(work.dayKey))
                                .font(KolType.caption)
                                .foregroundStyle(KolInk.muted)
                                .monospacedDigit()
                        }
                        .padding(KolSpace.n(2))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
                    }
                }
            }
            if !store.document.seamMarks.isEmpty {
                savedBand(title: "Filed joins") {
                    ForEach(store.document.seamMarks) { mark in
                        markRow(label: "Filed", workId: mark.workId, day: mark.dayKey)
                    }
                }
            }
            if !store.document.tearMarks.isEmpty {
                savedBand(title: "Wrong joins") {
                    ForEach(store.document.tearMarks) { mark in
                        markRow(label: "Wrong", workId: mark.workId, day: mark.dayKey)
                    }
                }
            }
        }
        .padding(KolSpace.n(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func savedBand<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: KolSpace.n(1)) {
            Text(title)
                .font(KolType.headline)
                .foregroundStyle(KolInk.ink)
            VStack(alignment: .leading, spacing: KolSpace.n(1)) {
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func markRow(label: String, workId: UUID, day: Int) -> some View {
        let name = store.works.first { $0.id == workId }?.title ?? "Work"
        return HStack {
            Text(label)
                .font(KolType.caption)
                .foregroundStyle(KolInk.muted)
                .padding(.horizontal, KolSpace.n(1))
                .frame(minHeight: 28)
                .background(KolInk.background, in: Capsule())
            Text(name)
                .font(KolType.body)
                .foregroundStyle(KolInk.ink)
                .lineLimit(2)
            Spacer(minLength: KolSpace.n(1))
            Text(KolType.day(day))
                .font(KolType.caption)
                .foregroundStyle(KolInk.muted)
                .monospacedDigit()
        }
        .padding(KolSpace.n(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
    }
}
