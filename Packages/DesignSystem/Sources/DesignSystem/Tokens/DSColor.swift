//
//  DSColor.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 12/8/26.
//

// Semantic color tokens — reference Colors.xcassets.
// Do NOT use Color(hex:) directly in Features — always use DSColor to enable centralized theme switching.

import SwiftUI

public enum DSColor {
    public static let brandPrimary = Color("BrandPrimary", bundle: .module)
    public static let brandSecondary = Color("BrandSecondary", bundle: .module)

    public static let backgroundPrimary = Color("BackgroundPrimary", bundle: .module)
    public static let backgroundSecondary = Color("BackgroundSecondary", bundle: .module)

    public static let textPrimary = Color("TextPrimary", bundle: .module)
    public static let textSecondary = Color("TextSecondary", bundle: .module)

    public static let borderDefault = Color("BorderDefault", bundle: .module)

    public static let statusError = Color("StatusError", bundle: .module)
    public static let statusSuccess = Color("StatusSuccess", bundle: .module)
}
