//
//  AppConfig.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 9/8/26.
//

// Read environment values ​​configured via .xcconfig -> Info.plist.
// This is the ONLY place in the entire app permitted to read directly from Bundle.main
// for environment configuration purposes -- other features MUST use AppConfig
// rather than reading Info.plist individually (to avoid scattered, hard-to-manage code).

import Foundation

enum AppEnvironment: String {
    case development
    case staging
    case production
}

enum AppConfigError: Error, LocalizedError {
    case missingKey(String)
    case invalidEnvironmentValue(String)

    var errorDescription: String? {
        switch self {
        case .missingKey(let key):
            return "Thiếu key '\(key)' trong Info.plist. Kiểm tra lại .xcconfig và Info.plist."
        case .invalidEnvironmentValue(let value):
            return "Giá trị ENVIRONMENT_NAME '\(value)' không hợp lệ. Phải là development/staging/production."
        }
    }
}

enum AppConfig {

    /// The API base URL, read from the "APIBaseURL" key in Info.plist.
    static var apiBaseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
              !urlString.isEmpty else {
            fatalError(AppConfigError.missingKey("APIBaseURL").localizedDescription)
        }
        guard let url = URL(string: urlString) else {
            fatalError("APIBaseURL không phải URL hợp lệ: \(urlString)")
        }
        return url
    }()

    /// Current environment (development/staging/production), read from the "EnvironmentName" key.
    static var environment: AppEnvironment = {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: "EnvironmentName") as? String else {
            fatalError(AppConfigError.missingKey("EnvironmentName").localizedDescription)
        }
        guard let env = AppEnvironment(rawValue: rawValue) else {
            fatalError(AppConfigError.invalidEnvironmentValue(rawValue).localizedDescription)
        }
        return env
    }()

    /// Utility flag used to show/hide the debug menu, detailed logs, ....
    static var isDebugEnvironment: Bool {
        environment != .production
    }
}
