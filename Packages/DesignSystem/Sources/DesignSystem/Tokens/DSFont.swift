//
//  DSFont.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 12/8/26.
//

// Typography scale — every .font() in the Feature MUST use .dsFont(_:)
// instead of directly using .font(.system(size:)), to ensure Dynamic Type works correctly.

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

    var weight: Font.Weight {
        switch self {
        case .largeTitle, .title1: return .bold
        case .title2, .title3, .headline: return .semibold
        case .body, .callout, .subheadline, .footnote, .caption: return .regular
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

    /// Returns a SwiftUI Font scaled correctly according to Dynamic Type, based on UIFontMetrics.
    public static func font(_ token: DSFontToken) -> Font {
        let baseFont = UIFont.systemFont(ofSize: token.size, weight: token.weight.uiKitWeight)
        let scaledFont = UIFontMetrics(forTextStyle: token.metricsTextStyle).scaledFont(for: baseFont)
        return Font(scaledFont)
    }
}

// MARK: - Font.Weight -> UIFont.Weight bridge

private extension Font.Weight {
    var uiKitWeight: UIFont.Weight {
        switch self {
        case .bold: return .bold
        case .semibold: return .semibold
        case .regular: return .regular
        case .medium: return .medium
        case .light: return .light
        case .heavy: return .heavy
        case .black: return .black
        case .thin: return .thin
        case .ultraLight: return .ultraLight
        default: return .regular
        }
    }
}

// MARK: - ViewModifier + helper function

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
