//
//  AppConfig.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 9/8/26.
//

// Đọc các giá trị environment đã cấu hình qua .xcconfig -> Info.plist
// Đây là NƠI DUY NHẤT trong toàn app được phép đọc trực tiếp Bundle.main
// cho mục đích environment config -- các Feature khác PHẢI dùng qua AppConfig,
// không tự đọc Info.plist riêng lẻ (tránh rải rác, khó kiểm soát).

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

    /// Base URL của API, đọc từ key "APIBaseURL" trong Info.plist.
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

    /// Environment hiện tại (development/staging/production), đọc từ key "EnvironmentName".
    static var environment: AppEnvironment = {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: "EnvironmentName") as? String else {
            fatalError(AppConfigError.missingKey("EnvironmentName").localizedDescription)
        }
        guard let env = AppEnvironment(rawValue: rawValue) else {
            fatalError(AppConfigError.invalidEnvironmentValue(rawValue).localizedDescription)
        }
        return env
    }()

    /// Cờ tiện ích, dùng để show/hide debug menu, log chi tiết, v.v.
    static var isDebugEnvironment: Bool {
        environment != .production
    }
}
