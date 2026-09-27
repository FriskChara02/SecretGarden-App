//
//  AuthCoordinator.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 20/8/26.
//

import Foundation
import Observation

@Observable
final class AuthCoordinator {
    var currentRoute: AuthRoute?

    func showLogin() {
        currentRoute = nil
    }

    /// Auth is a peer-level flow - screen transitions always replace the current screen, not stacking.
    func show(_ route: AuthRoute) {
        currentRoute = route
    }
}
