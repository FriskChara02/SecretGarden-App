//
//  SecretGardenApp.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 7/8/26.
//

import SwiftUI
import DesignSystem

@main
struct SecretGardenApp: App {

    init() {
        DSFontRegistrar.registerFonts()
        DSImagePipeline.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
