//
//  SecretGardenApp.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 7/8/26.
//

import CoreArchitecture
import DesignSystem
import SwiftUI

@main
struct SecretGardenApp: App {

    init() {
        if UITestLaunchArguments.shouldResetState {
            AgeGateManager.resetPersistedStateForUITesting()
        }
        DSFontRegistrar.registerFonts()
        DSImagePipeline.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
