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
    var body: some Scene {
        WindowGroup {
            VStack(spacing: 8) {
                Text("Environment: \(AppConfig.environment.rawValue)")
                Text("API Base URL: \(AppConfig.apiBaseURL.absoluteString)")
                Text("CoreModels version: \(CoreModelsPlaceholder.version)")
            }
            .padding()
        }
    }
}
