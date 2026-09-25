import SwiftUI
import UIKit

/// Locked roll. Glue writes a Volumen. Seams hang at every token joint.
/// Split files a SeamMark or a TearMark. Custom drawing stays on the hero tile.
struct QuizView: View {
    @ObservedObject var store: RollStore
    var openSheet: (RollSheet) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ZStack {
                KolInk.background.ignoresSafeArea()
                if store.fold == .smooth || (store.gluePool.isEmpty && store.volumen == nil) {
                    SmoothPage(openExplore: { openSheet(.explore) })
                } else {
                    usedRoll
                }
            }
            .navigationTitle("Split the caption")
            .navigationBarTitleDisplayMode(.inline)
            .id(store.dayKey)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        openSheet(.explore)
                    } label: {
                        Image(systemName: "plus.circle")
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Explore")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: KolSpace.n(1)) {
                        Button {
                            openSheet(.saved)
                        } label: {
                            Image(systemName: "tray.full")
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Saved")
                        Button {
                            openSheet(.settings)
                        } label: {
                            Image(systemName: "gearshape")
                                .frame(minWidth: 44, minHeight: 44)
                                .contentShape(Rectangle())
                        }
                        .accessibilityLabel("Settings")
                    }
                }
            }
        }
    }

    private var usedRoll: some View {
        GeometryReader { geo in
            let hero = heroHeight(in: geo.size)
            ScrollView {
                VStack(alignment: .leading, spacing: KolSpace.n(2)) {
                    if store.persistFailed {
                        persistBanner
                    }
                    Text("Tap Split between the maker and the title.")
                        .font(KolType.body)
                        .foregroundStyle(KolInk.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    heroTile(height: hero)
                    captionBlock
                    railAndStat
                    glueRow
                }
                .padding(.horizontal, KolSpace.n(2))
                .padding(.bottom, KolSpace.n(3))
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }

    private func heroHeight(in size: CGSize) -> CGFloat {
        let proposed = size.height * 0.34
        return max(KolSpace.n(22), min(proposed, KolSpace.n(40)))
    }

    private var liveWork: Work? {
        guard let id = store.volumen?.workId else { return nil }
        return store.works.first { $0.id == id }
    }

    private var persistBanner: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(1)) {
            Text("The roll did not save.")
                .font(KolType.headline)
                .foregroundStyle(KolInk.ink)
            Text("Your last change is still on screen.")
                .font(KolType.caption)
                .foregroundStyle(KolInk.muted)
            Button("Retry save") {
                store.retryPersist()
            }
            .buttonStyle(FlatPlateStyle(isEnabled: true))
        }
        .padding(KolSpace.n(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
    }

    private func heroTile(height: CGFloat) -> some View {
        ZStack {
            BoundedFill(name: "kol_CardBackdrop", url: liveWorkURL)
            TileGlass()
                .fill(.white.opacity(0.08))
                .overlay {
                    TileGlass().stroke(KolInk.surface.opacity(0.35), lineWidth: 1)
                }
                .allowsHitTesting(false)
            if store.lastSeamHit {
                Image("kol_SuccessMark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: KolSpace.n(11), height: KolSpace.n(11))
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
        .modifier(KolLift.hero())
        .accessibilityLabel(liveWork?.title ?? "Painting")
    }

    private var liveWorkURL: URL? {
        guard let urlString = liveWork?.imageURL else { return nil }
        return URL(string: urlString)
    }

    private var captionBlock: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(1)) {
            Text(captionTitle)
                .kolDisplay()
                .foregroundStyle(KolInk.ink)
            Text(captionLine)
                .font(KolType.body)
                .foregroundStyle(KolInk.ink)
                .fixedSize(horizontal: false, vertical: true)
            if let volumen = store.volumen {
                CaptionJoints(words: volumen.tokens, seams: store.seams) { seam in
                    store.splitSeam(seam.id)
                    if store.lastSeamHit {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                .animation(reduceMotion ? nil : .easeOut(duration: KolMotion.press), value: store.seams.map(\.isCooled))
            }
        }
        .padding(KolSpace.n(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
    }

    private var captionTitle: String {
        if let title = liveWork?.title, store.volumen != nil {
            return title
        }
        return "Glue a caption"
    }

    private var captionLine: String {
        switch store.fold {
        case .glued:
            return "Tap the join between maker and title."
        case .parted:
            return "That join is filed. Glue the next caption."
        case .idle:
            return "Glue a loose painting, then tap the true join."
        case .smooth:
            return "Save a painting, then split."
        }
    }

    private var glueRow: some View {
        VStack(spacing: KolSpace.n(1)) {
            if store.canGlue {
                Button {
                    store.glueRoll()
                } label: {
                    Text(store.fold == .parted ? "Glue another" : "Glue a caption")
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .contentShape(Capsule())
                }
                .buttonStyle(GluePillStyle(isEnabled: true, isLoading: false))
            }
            if store.document.newestMark != nil {
                Button {
                    store.peelNewestMark()
                } label: {
                    Text("Retract newest mark")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .contentShape(Capsule())
                }
                .buttonStyle(FlatPlateStyle(isEnabled: true))
            }
        }
    }

    private var railAndStat: some View {
        HStack(alignment: .top, spacing: KolSpace.n(1)) {
            recentRail
                .frame(maxWidth: .infinity, alignment: .top)
                .layoutPriority(1)
            seamTearColumn
                .frame(width: KolSpace.n(14), alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    /// Narrow seam-versus-tear column. The rail stays the wide half.
    private var seamTearColumn: some View {
        VStack(spacing: KolSpace.n(1)) {
            statCard(title: "Filed joins", value: store.document.seamMarks.count)
            statCard(title: "Wrong joins", value: store.document.tearMarks.count)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var recentRail: some View {
        VStack(alignment: .leading, spacing: KolSpace.n(1)) {
            Text("Recently parted")
                .font(KolType.headline)
                .foregroundStyle(KolInk.ink)
            if store.partedWorks.isEmpty {
                Text("Parted paintings sit here after a filed join.")
                    .font(KolType.body)
                    .foregroundStyle(KolInk.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(KolSpace.n(2))
                    .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
            } else {
                VStack(spacing: KolSpace.n(1)) {
                    ForEach(store.partedWorks.prefix(6)) { work in
                        Button {
                            openSheet(.saved)
                        } label: {
                            HStack(alignment: .center, spacing: KolSpace.n(1)) {
                                BoundedFill(name: "kol_CardBackdrop", url: URL(string: work.imageURL ?? ""))
                                    .frame(width: KolSpace.n(7), height: KolSpace.n(7))
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: KolRadius.chip, style: .continuous))
                                    .accessibilityHidden(true)
                                Text(work.title)
                                    .font(KolType.body)
                                    .foregroundStyle(KolInk.ink)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(KolSpace.n(1))
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
                            .clipShape(RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
                        }
                        .buttonStyle(KolPressStyle())
                        .accessibilityLabel(work.title)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    private func statCard(title: String, value: Int) -> some View {
        Button {
            openSheet(.saved)
        } label: {
            VStack(alignment: .leading, spacing: KolSpace.n(1)) {
                Text(title)
                    .font(KolType.caption)
                    .foregroundStyle(KolInk.ink)
                    .lineLimit(2)
                Text(KolType.count(value))
                    .font(KolType.title)
                    .foregroundStyle(KolInk.ink)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .padding(KolSpace.n(1))
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .background(KolInk.surface, in: RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: KolRadius.card, style: .continuous))
        }
        .buttonStyle(KolPressStyle())
        .accessibilityLabel("\(title), \(KolType.count(value)). Open saved.")
    }
}

/// Photo fill locked to the tile. The image cannot paint past the cell.
struct BoundedFill: View {
    var name: String
    var url: URL?

    var body: some View {
        GeometryReader { geo in
            fill
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
        }
        .clipped()
    }

    @ViewBuilder
    private var fill: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    Image(name).resizable().scaledToFill()
                }
            }
        } else {
            Image(name)
                .resizable()
                .scaledToFill()
        }
    }
}

/// One custom Path on the photo-tile. Nowhere else.
struct TileGlass: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: rect.insetBy(dx: 10, dy: 10),
            cornerSize: CGSize(width: KolRadius.chip, height: KolRadius.chip)
        )
        return path
    }
}

struct FlowSeams: View {
    let words: [VolumenWord]
    let seams: [Seam]
    var onSeam: (Seam) -> Void

    var body: some View {
        CaptionJoints(words: words, seams: seams, onSeam: onSeam)
    }
}

struct WrappingRun: View {
    let words: [VolumenWord]
    let seams: [Seam]
    var onSeam: (Seam) -> Void

    var body: some View {
        CaptionJoints(words: words, seams: seams, onSeam: onSeam)
    }
}

struct CaptionJoints: View {
    let words: [VolumenWord]
    let seams: [Seam]
    var onSeam: (Seam) -> Void

    var body: some View {
        CaptionWrap(spacing: KolSpace.n(1), lineSpacing: KolSpace.n(1)) {
            ForEach(joints) { joint in
                Text(joint.word.text)
                    .font(KolType.body)
                    .foregroundStyle(KolInk.ink)
                    .lineLimit(1)
                    .frame(minHeight: 44)
                if let seam = joint.seam {
                    Button {
                        onSeam(seam)
                    } label: {
                        Text(seam.isCooled ? "Torn" : "Split")
                            .strikethrough(seam.isCooled, color: KolInk.ink)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(RoundedRectangle(cornerRadius: KolRadius.chip, style: .continuous))
                    }
                    .buttonStyle(
                        SeamJointStyle(
                            isCooled: seam.isCooled,
                            isSelected: false,
                            isDisabled: seam.isCooled
                        )
                    )
                    .disabled(seam.isCooled)
                    .accessibilityLabel(seam.isCooled ? "Torn join after \(joint.word.text)" : "Split after \(joint.word.text)")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var joints: [CaptionJoint] {
        words.enumerated().map { index, word in
            CaptionJoint(word: word, seam: seams.first { $0.jointIndex == index })
        }
    }
}

struct CaptionJoint: Identifiable {
    var word: VolumenWord
    var seam: Seam?
    var id: UUID { word.id }
}

struct CaptionWrap: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = arrange(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (subview, origin) in zip(subviews, plan.origins) {
            subview.place(
                at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, origins: [CGPoint]) {
        let limit = proposal.width ?? .infinity
        var origins: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var width: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > limit {
                y += rowHeight + lineSpacing
                x = 0
                rowHeight = 0
            }
            origins.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            width = max(width, x)
        }
        return (CGSize(width: width, height: y + rowHeight), origins)
    }
}

struct SmoothPage: View {
    var openExplore: () -> Void

    var body: some View {
        VStack(spacing: KolSpace.n(2)) {
            Spacer(minLength: KolSpace.n(2))
            Image("kol_EmptyHome")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240, maxHeight: 240)
                .accessibilityHidden(true)
            Text("The roll is smooth.")
                .kolDisplay()
                .foregroundStyle(KolInk.ink)
            Text("Save a painting, then split.")
                .font(KolType.body)
                .foregroundStyle(KolInk.muted)
            Spacer()
            Button("Explore", action: openExplore)
                .buttonStyle(GluePillStyle(isEnabled: true, isLoading: false))
        }
        .padding(KolSpace.n(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
