//
//  DSFont.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 12/8/26.
//

// Typography scale using the custom Quicksand font (registered via DSFontRegistrar).
// All features MUST use .dsFont(_:), do not call .font(.custom(...)) directly.

import SwiftUI
import UIKit

public enum DSFontToken: CaseIterable {
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption

    /// Original size at the default content size category (Large).
    var size: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title1: return 28
        case .title2: return 22
        case .title3: return 18
        case .headline: return 17
        case .body: return 16
        case .callout: return 15
        case .subheadline: return 14
        case .footnote: return 13
        case .caption: return 12
        }
    }

    /// The PostScript name of the Quicksand font corresponding to the desired weight.
    /// Quicksand is used for both headings and body text - maintaining consistency with a single font family.
    var fontName: String {
        switch self {
        case .largeTitle, .title1, .title2, .title3: return "Quicksand-Bold"
        case .headline: return "Quicksand-SemiBold"
        case .body, .callout: return "Quicksand-Medium"
        case .subheadline, .footnote, .caption: return "Quicksand-Regular"
        }
    }

    /// UIFont.TextStyle serves as the "anchor" for UIFontMetrics - determining
    /// the scaling rate when the user changes the system font size (Settings > Accessibility > Display & Text Size).
    var metricsTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title1: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption1
        }
    }
}

public enum DSFont {

    /// Returns a SwiftUI Font using Quicksand, scaled correctly for Dynamic Type via UIFontMetrics.
    /// If the font fails to register for any reason, it falls back to the system font
    /// with an equivalent size and weight instead of crashing - preventing app failure due to font errors.
    public static func font(_ token: DSFontToken) -> Font {
        // Register automatically if not already done — independent of whether the caller (App init) has run.
        // Important for Xcode Previews: XCPreviewAgent runs in a separate process
        // and does NOT call SecretGardenApp.init(), so we cannot assume the font is ready.
        if UIFont(name: token.fontName, size: token.size) == nil {
            DSFontRegistrar.registerFonts()
        }

        guard let baseFont = UIFont(name: token.fontName, size: token.size) else {
            assertionFailure("Font '\(token.fontName)' chưa được đăng ký — kiểm tra DSFontRegistrar.registerFonts() đã gọi chưa.")
            let fallback = UIFont.systemFont(ofSize: token.size, weight: .regular)
            let scaledFallback = UIFontMetrics(forTextStyle: token.metricsTextStyle).scaledFont(for: fallback)
            return Font(scaledFallback)
        }
        let scaledFont = UIFontMetrics(forTextStyle: token.metricsTextStyle).scaledFont(for: baseFont)
        return Font(scaledFont)
    }
}

// MARK: - ViewModifier

private struct DSFontModifier: ViewModifier {
    let token: DSFontToken

    func body(content: Content) -> some View {
        content
            .font(DSFont.font(token))
            // Limit the maximum scale to prevent Card/Grid layout breakage when the user
            // enables the largest accessibility size (AX5) — scaling up to accessibility3
            // is sufficient for readability without disrupting the SeriesCardView's two-column layout.
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }
}

public extension View {
    /// Apply typography tokens; automatically scale according to Dynamic Type (capped at accessibility3).
    func dsFont(_ token: DSFontToken) -> some View {
        modifier(DSFontModifier(token: token))
    }
}
