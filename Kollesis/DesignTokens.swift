import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #FAF7F5
    static let bg = Color(red: 0.980392, green: 0.968627, blue: 0.960784)
    static let bgHex = "#FAF7F5"
    /// #FEFEFD
    static let surface = Color(red: 0.996078, green: 0.996078, blue: 0.992157)
    static let surfaceHex = "#FEFEFD"
    /// #392818
    static let ink = Color(red: 0.223529, green: 0.156863, blue: 0.094118)
    static let inkHex = "#392818"
    /// #CC6D19
    static let accent = Color(red: 0.800000, green: 0.427451, blue: 0.098039)
    static let accentHex = "#CC6D19"
    /// #816C5A
    static let muted = Color(red: 0.505882, green: 0.423529, blue: 0.352941)
    static let mutedHex = "#816C5A"
    static let fontFamily = "SF Pro"
}
