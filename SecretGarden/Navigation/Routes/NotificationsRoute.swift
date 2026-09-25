//
//  NotificationsRoute.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import Foundation
import DesignSystem

enum NotificationsRoute: Hashable {
    case notificationSettings
    case seriesDetail(id: String)
    case policy(PolicyKind)
}
