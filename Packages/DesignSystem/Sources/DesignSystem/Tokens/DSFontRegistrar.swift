//
//  DSFontRegistrar.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 12/8/26.
//

import CoreText
import Foundation

public enum DSFontRegistrar {

    private static let fontFileNames = [
        "Quicksand-Regular",
        "Quicksand-Medium",
        "Quicksand-SemiBold",
        "Quicksand-Bold",
        "Quicksand-Light"
    ]

    private static var didRegister = false

    /// Call this function once in the `init()` of the App struct (SecretGardenApp).
    /// It is safe to call multiple times (includes a guard against duplicate registration).
    public static func registerFonts() {
        guard !didRegister else { return }
        didRegister = true

        for name in fontFileNames {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                assertionFailure("Không tìm thấy file font '\(name).ttf' trong bundle DesignSystem.")
                continue
            }

            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)

            if !success, let error = error?.takeRetainedValue() {
                // Ignore "already registered" conflicts during Hot Reload/Preview; treat them as normal.
                let nsError = error as Error as NSError
                if nsError.code != CTFontManagerError.duplicatedName.rawValue {
                    assertionFailure("Đăng ký font '\(name)' thất bại: \(error)")
                }
            }
        }
    }
}
