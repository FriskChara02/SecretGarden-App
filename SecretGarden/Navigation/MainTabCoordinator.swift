//
//  MainTabCoordinator.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

// Each tab now has its own Route enum

import Foundation
import Observation
import CoreArchitecture
import HomeFeature
import SearchFeature

@Observable
final class MainTabCoordinator {

    var selectedTab: MainTab = .home

    let homeCoordinator = Coordinator<HomeRoute>()
    let searchCoordinator = Coordinator<SearchRoute>()
    let notificationsCoordinator = Coordinator<NotificationsRoute>()
    let profileCoordinator = Coordinator<ProfileRoute>()
    let profileDrawerCoordinator = ProfileDrawerCoordinator()

    init() {}

    func selectTab(_ tab: MainTab) { selectedTab = tab }
}
