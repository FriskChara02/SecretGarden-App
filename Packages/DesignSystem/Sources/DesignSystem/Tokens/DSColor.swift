//
//  DSColor.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 12/8/26.
//

// Semantic color tokens — reference Colors.xcassets.
// Do NOT use Color(hex:) directly in Features — always use DSColor to enable centralized theme switching.

import SwiftUI

private final class DesignSystemBundleFinder {}

extension Bundle {
    static var designSystemModule: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: DesignSystemBundleFinder.self)
        #endif
    }
}

public enum DSColor {
    public static let brandPrimary = Color("BrandPrimary", bundle: .designSystemModule)
    public static let brandSecondary = Color("BrandSecondary", bundle: .designSystemModule)

    public static let brandPrimaryLight = Color("BrandPrimaryLight", bundle: .designSystemModule)
    public static let tagNeutral = Color("TagNeutral", bundle: .designSystemModule)
    public static let bookmarkAccent = Color("BookmarkAccent", bundle: .designSystemModule)
    public static let info = Color("Info", bundle: .designSystemModule)
    public static let rankHighlight = Color("RankHighlight", bundle: .designSystemModule)
    public static let rankAccentStripe = Color("RankAccentStripe", bundle: .designSystemModule)

    public static let backgroundPrimary = Color("BackgroundPrimary", bundle: .designSystemModule)
    public static let backgroundSecondary = Color("BackgroundSecondary", bundle: .designSystemModule)

    public static let textPrimary = Color("TextPrimary", bundle: .designSystemModule)
    public static let textSecondary = Color("TextSecondary", bundle: .designSystemModule)

    public static let borderDefault = Color("BorderDefault", bundle: .designSystemModule)

    public static let statusError = Color("StatusError", bundle: .designSystemModule)
    public static let statusSuccess = Color("StatusSuccess", bundle: .designSystemModule)
}
