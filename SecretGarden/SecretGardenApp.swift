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
import CoreArchitecture

@main
struct SecretGardenApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 8) {
                Text("Environment: \(AppConfig.environment.rawValue)")
                Text("Test AppError: \(AppError.unauthorized.localizedDescription)")
            }
            .padding()
        }
    }
}
