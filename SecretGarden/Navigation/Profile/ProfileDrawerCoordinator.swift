//
//  ProfileDrawerCoordinator.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

// Manages opening/closing the Side Menu AND internal navigation (pushing ProfileRoute).
// Special case "Profile Page": instead of pushing an internal route, it invokes the
// onNavigateToProfileTab closure—since tab switching is the responsibility of MainTabCoordinator,
// and ProfileMenuCoordinator must not hold a direct reference back to MainTabCoordinator
// (to avoid a circular dependency between these sibling coordinators).

import Foundation
import Observation
import CoreArchitecture

@Observable
final class ProfileDrawerCoordinator {

    var isPresented = false
    let contentCoordinator = Coordinator<ProfileRoute>()

    init() {}

    func present() { isPresented = true }
    func dismiss() {
        isPresented = false
        contentCoordinator.popToRoot()
    }
}
