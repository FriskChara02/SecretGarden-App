//
//  DSSpacing.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 12/8/26.
//

// 4pt grid-based spacing system — every .padding()/.spacing() in the app
// should use this token instead of magic numbers (e.g., .padding(16) -> .padding(DSSpacing.md)).

import Foundation

public enum DSSpacing {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
}
