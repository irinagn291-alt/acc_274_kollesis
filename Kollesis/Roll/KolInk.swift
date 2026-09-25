import SwiftUI
import UIKit

/// Named colours from Assets. Hex lives only here.
enum KolInk {
    /// #FAF7F5 screen background
    static let background = Color("background")
    /// #FEFEFD cards, rows, sheets
    static let surface = Color("surface")
    /// #392818 primary text and icons
    static let ink = Color("ink")
    /// #CC6D19 primary action and figures
    static let accent = Color("accent")
    /// #816C5A secondary text and disabled
    static let muted = Color("muted")
}

enum KolType {
    /// Title2 under 34pt. At accessibility sizes drop to title3 and stay under 34.
    static func display(compact: Bool) -> Font {
        let style: UIFont.TextStyle = compact ? .title3 : .title2
        let preferred = UIFont.preferredFont(forTextStyle: style).pointSize
        let cap: CGFloat = compact ? 28 : 34
        return .system(size: min(preferred, cap), weight: .semibold, design: .default)
    }

    static let title = Font.system(.title3, design: .default).weight(.semibold)
    static let headline = Font.system(.headline, design: .default)
    static let body = Font.system(.body, design: .default).weight(.medium)
    static let caption = Font.system(.footnote, design: .default)
    static let micro = Font.system(.caption, design: .default).weight(.semibold)

    static func count(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func day(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}

enum KolSpace {
    static let unit: CGFloat = 8
    static func n(_ steps: CGFloat) -> CGFloat { unit * steps }
}

enum KolRadius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
}

enum KolLift {
    static func hero() -> some ViewModifier { HeroShadow() }
}

private struct HeroShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: KolInk.ink.opacity(0.16), radius: 16, x: 0, y: 8)
    }
}

enum KolMotion {
    static let press: Double = 0.16
    static let sheet: Double = 0.22

    static func scale(pressed: Bool, enabled: Bool, reduceMotion: Bool) -> CGFloat {
        if reduceMotion || !enabled || !pressed { return 1 }
        return 0.97
    }

    static func opacity(pressed: Bool, enabled: Bool, reduceMotion: Bool, resting: Double) -> Double {
        guard enabled else { return resting }
        if reduceMotion && pressed { return resting * 0.55 }
        return resting
    }
}

struct KolDisplayFont: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize

    func body(content: Content) -> some View {
        content
            .font(KolType.display(compact: typeSize.isAccessibilitySize))
            .lineLimit(1)
            .truncationMode(.tail)
            .minimumScaleFactor(0.8)
    }
}

extension View {
    func kolDisplay() -> some View {
        modifier(KolDisplayFont())
    }
}

struct GluePillStyle: ButtonStyle {
    var isEnabled: Bool
    var isLoading: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let resting = isLoading ? 0.7 : 1.0
        configuration.label
            .font(KolType.headline)
            .foregroundStyle(KolInk.surface)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(isEnabled ? KolInk.accent : KolInk.muted, in: Capsule())
            .opacity(
                KolMotion.opacity(
                    pressed: configuration.isPressed,
                    enabled: isEnabled,
                    reduceMotion: reduceMotion,
                    resting: resting
                )
            )
            .scaleEffect(
                KolMotion.scale(
                    pressed: configuration.isPressed,
                    enabled: isEnabled,
                    reduceMotion: reduceMotion
                )
            )
            .animation(reduceMotion ? nil : .easeOut(duration: KolMotion.press), value: configuration.isPressed)
    }
}

struct FlatPlateStyle: ButtonStyle {
    var isEnabled: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(KolType.body)
            .foregroundStyle(isEnabled ? KolInk.ink : KolInk.muted)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(KolInk.surface, in: Capsule())
            .opacity(
                KolMotion.opacity(
                    pressed: configuration.isPressed,
                    enabled: isEnabled,
                    reduceMotion: reduceMotion,
                    resting: isEnabled ? 1 : 0.45
                )
            )
            .scaleEffect(
                KolMotion.scale(
                    pressed: configuration.isPressed,
                    enabled: isEnabled,
                    reduceMotion: reduceMotion
                )
            )
            .animation(reduceMotion ? nil : .easeOut(duration: KolMotion.press), value: configuration.isPressed)
    }
}

struct KolPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(
                KolMotion.opacity(
                    pressed: configuration.isPressed,
                    enabled: true,
                    reduceMotion: reduceMotion,
                    resting: 1
                )
            )
            .scaleEffect(
                KolMotion.scale(
                    pressed: configuration.isPressed,
                    enabled: true,
                    reduceMotion: reduceMotion
                )
            )
            .animation(reduceMotion ? nil : .easeOut(duration: KolMotion.press), value: configuration.isPressed)
    }
}

struct SeamJointStyle: ButtonStyle {
    var isCooled: Bool
    var isSelected: Bool
    var isDisabled: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var live: Bool { !isCooled && !isDisabled }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(KolType.body)
            .foregroundStyle(live ? KolInk.surface : KolInk.muted)
            .padding(.horizontal, KolSpace.n(1))
            .frame(minWidth: 44, minHeight: 44)
            .background(
                live ? KolInk.accent : (isSelected ? KolInk.accent.opacity(0.16) : KolInk.surface),
                in: RoundedRectangle(cornerRadius: KolRadius.chip, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: KolRadius.chip, style: .continuous)
                    .stroke(
                        live ? KolInk.accent : KolInk.muted,
                        lineWidth: isCooled ? 2 : 1
                    )
            }
            .opacity(
                KolMotion.opacity(
                    pressed: configuration.isPressed,
                    enabled: live,
                    reduceMotion: reduceMotion,
                    resting: isDisabled ? 0.45 : 1
                )
            )
            .scaleEffect(
                KolMotion.scale(
                    pressed: configuration.isPressed,
                    enabled: live,
                    reduceMotion: reduceMotion
                )
            )
            .animation(reduceMotion ? nil : .easeOut(duration: KolMotion.press), value: configuration.isPressed)
    }
}

struct RollSheetModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var arrived = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : (arrived ? 1 : 0.96))
            .opacity(arrived ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: KolMotion.sheet)) {
                    arrived = true
                }
            }
    }
}
