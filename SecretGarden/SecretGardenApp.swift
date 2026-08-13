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
                    .dsFont(.largeTitle)
                    .foregroundStyle(DSColor.brandPrimary)
                Text("Sayonara, Watashi no Cramer")
                    .dsFont(.title3)
                    .foregroundStyle(DSColor.textPrimary)
                Text("Nhóm dịch: Yuri no Sono")
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
                Text("Chưa có mô tả")
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
                Text("Mạng xã hội - Trang chủ - Cá nhân")
                    .dsFont(.subheadline)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(DSSpacing.lg)
            .background(DSColor.backgroundPrimary)
        }
    }
}
