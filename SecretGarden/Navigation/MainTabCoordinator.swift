//
//  MainTabCoordinator.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

// Level 2 Coordinator: manages the currently selected tab and
// the Side Menu display flag — the actual SideMenuCoordinator will replace `isSideMenuPresented: Bool`
// with a specific route; this is just a temporary hook for the hamburger button on the Home screen.
//
// Each tab owns its OWN Coordinator<PlaceholderRoute> (4 independent instances) —
// this is the mechanism that preserves separate state when switching between tabs.

import Foundation
import Observation
import CoreArchitecture

@Observable
final class MainTabCoordinator {

    var selectedTab: MainTab = .home

    // placeholder — not yet using the actual SideMenuCoordinator.
    var isSideMenuPresented = false

    let homeCoordinator = Coordinator<PlaceholderRoute>()
    let searchCoordinator = Coordinator<PlaceholderRoute>()
    let notificationsCoordinator = Coordinator<PlaceholderRoute>()
    let profileCoordinator = Coordinator<PlaceholderRoute>()

    init() {}

    func selectTab(_ tab: MainTab) {
        selectedTab = tab
    }

    func presentSideMenu() {
        isSideMenuPresented = true
    }

    func dismissSideMenu() {
        isSideMenuPresented = false
    }
}
