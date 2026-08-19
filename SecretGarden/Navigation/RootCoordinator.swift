//
//  RootCoordinator.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/8/26.
//

// Do NOT import CoreStorage/Repositories/AuthFeature — only AppRoute is known.

import Foundation
import Observation

@Observable
final class RootCoordinator {

    private(set) var currentRoute: AppRoute = .checking

    init() {}

    func switchToMain() {
        currentRoute = .main
    }

    func switchToAuth() {
        currentRoute = .auth
    }
}
