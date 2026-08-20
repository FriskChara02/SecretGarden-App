//
//  MainTab.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

// The app's 4 main tabs

import Foundation

enum MainTab: String, CaseIterable, Hashable, Identifiable {
    case home
    case search
    case notifications
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Trang chủ"
        case .search: return "Tìm kiếm"
        case .notifications: return "Thông báo"
        case .profile: return "Cá nhân"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .notifications: return "bell"
        case .profile: return "person"
        }
    }
}
