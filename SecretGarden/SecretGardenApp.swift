//
//  SecretGardenApp.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 7/8/26.
//

import SwiftUI
import CoreModels
import CoreNetworking
import CoreStorage
import DesignSystem
import AuthFeature

@main
struct SecretGardenApp: App {

    init() {
        DSFontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            DesignSystemCatalogView()
        }
    }
}
