//
//  AppRoute.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 19/8/26.
//

// The top-level route for the entire app — maps 1-1 to the 3 cases of SessionState
// (AppRootViewModel.swift), as this is the only place where the app translates SessionState
// into AppRoute for the RootCoordinator. The RootCoordinator does NOT import SessionState.

import Foundation

enum AppRoute: Hashable {
    case checking
    case auth
    case main
}
