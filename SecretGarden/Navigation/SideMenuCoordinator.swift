//
//  SideMenuCoordinator.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

// Manages opening/closing the Side Menu AND internal navigation (pushing SideMenuRoute).
// Special case "Profile Page": instead of pushing an internal route, it invokes the
// onNavigateToProfileTab closure—since tab switching is the responsibility of MainTabCoordinator,
// and SideMenuCoordinator must not hold a direct reference back to MainTabCoordinator
// (to avoid a circular dependency between these sibling coordinators).

import Foundation
import Observation
import CoreArchitecture

@Observable
final class SideMenuCoordinator {

    var isPresented = false
    let contentCoordinator = Coordinator<SideMenuRoute>()

    /// Assigned by MainTabCoordinator upon initialization - the only way SideMenuCoordinator
    /// can "communicate back" to the parent coordinator without importing or holding a reference to it.
    var onNavigateToProfileTab: (() -> Void)?

    init() {}

    func present() {
        isPresented = true
    }

    func dismiss() {
        isPresented = false
        contentCoordinator.popToRoot() // Reset to the original Drawer list each time it is closed and reopened
    }

    func selectPersonalProfile() {
        isPresented = false
        onNavigateToProfileTab?()
    }
}
