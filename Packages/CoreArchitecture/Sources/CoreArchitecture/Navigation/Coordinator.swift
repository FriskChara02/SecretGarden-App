//
//  Coordinator.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 19/8/26.
//

// A generic navigation engine shared by Root, Tab, and Feature Coordinators.
// It must have no knowledge of the domain model (Series, User, ...) —
// it works only with `Route: Hashable` types defined by the App target or individual features.

import SwiftUI

/// A generic navigation engine based on the specific Route pattern.
/// Each child Coordinator (RootCoordinator, HomeCoordinator, etc.) owns an instance
/// of this class (via inheritance or composition) to gain immediate access to
/// push/pop/present functionality without rewriting the logic.
@Observable
public final class Coordinator<Route: Hashable> {

    // MARK: - Push Navigation (NavigationStack)

    /// Path for NavigationStack — bound directly to the View.
    public var path = NavigationPath()

    // MARK: - Modal Presentation

    /// The route is currently presented as a sheet (nil = no sheet is open).
    public var presentedSheet: Route?

    /// The route is currently being presented as a fullScreenCover.
    public var presentedFullScreenCover: Route?

    public init() {}

    // MARK: - Push Actions

    /// Push a new screen onto the top of the NavigationStack.
    public func push(_ route: Route) {
        path.append(route)
    }

    /// Go back one screen (pop top).
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Return to the root of the current stack (after logging out or pressing the Home button in the Reader Menu).
    public func popToRoot() {
        guard !path.isEmpty else { return }
        path.removeLast(path.count)
    }

    /// The number of screens currently in the stack (useful for unit tests or conditional rendering of a custom Back button).
    public var stackDepth: Int {
        path.count
    }

    // MARK: - Sheet Actions

    /// Open a sheet-style screen (modal, swipe-down to close).
    public func presentSheet(_ route: Route) {
        presentedSheet = route
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    // MARK: - Full Screen Cover Actions

    /// Open a fullScreenCover (a full-screen modal that cannot be dismissed by swiping down).
    public func presentFullScreenCover(_ route: Route) {
        presentedFullScreenCover = route
    }

    public func dismissFullScreenCover() {
        presentedFullScreenCover = nil
    }
}
