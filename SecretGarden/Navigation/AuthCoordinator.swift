//
//  AuthCoordinator.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import Foundation
import Observation
import CoreArchitecture

@Observable
final class AuthCoordinator {

    let coordinator = Coordinator<AuthRoute>()

    func showLogin() {
        coordinator.popToRoot()
    }

    /// Auth is a peer-level flow - screen transitions always replace the current screen, not stacking.
    func show(_ route: AuthRoute) {
        coordinator.popToRoot()
        coordinator.push(route)
    }
}
