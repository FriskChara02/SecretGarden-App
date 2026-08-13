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

@main
struct SecretGardenApp: App {

    init() {
        DSFontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("SecretGarden")
                    .dsFont(DSFontToken.largeTitle)
                    .foregroundStyle(DSColor.brandPrimary)
                Text("Sayonara, Watashi no Cramer")
                    .dsFont(DSFontToken.title3)
                    .foregroundStyle(DSColor.textPrimary)
                Text("Nhóm dịch: Yuri no Sono")
                    .dsFont(DSFontToken.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(DSSpacing.lg)
            .background(DSColor.backgroundPrimary)
        }
    }
}
