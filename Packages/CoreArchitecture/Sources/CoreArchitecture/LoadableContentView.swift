//
//  LoadableContentView.swift
//  CoreArchitecture
//
//  Created by Loi Nguyen on 13/8/26.
//

// The bridge between LoadableState (CoreArchitecture) and the UI state components (DesignSystem).
// This is the ONLY place in the app allowed to "switch" on
// LoadableState to select the UI — feature code simply calls LoadableContentView,
// without manually writing if/else logic based on state for each screen.

import SwiftUI
import DesignSystem

public struct LoadableContentView<T: Equatable, Content: View>: View {
    private let state: LoadableState<T>
    private let loadingStyle: DSLoadingStyle
    private let emptyTitle: String
    private let emptyMessage: String?
    private let isEmpty: (T) -> Bool
    private let retryAction: (() -> Void)?
    @ViewBuilder private let content: (T) -> Content

    public init(
        state: LoadableState<T>,
        loadingStyle: DSLoadingStyle = .spinner,
        emptyTitle: String = "Không có dữ liệu",
        emptyMessage: String? = nil,
        isEmpty: @escaping (T) -> Bool,
        retryAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.state = state
        self.loadingStyle = loadingStyle
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.isEmpty = isEmpty
        self.retryAction = retryAction
        self.content = content
    }

    public var body: some View {
        switch state {
        case .idle:
            Color.clear

        case .loading:
            DSLoadingView(style: loadingStyle)

        case .loaded(let value):
            if isEmpty(value) {
                DSEmptyStateView(title: emptyTitle, message: emptyMessage)
            } else {
                content(value)
            }

        case .failed(let error):
            DSErrorView(message: error.localizedDescription, retryAction: retryAction)
        }
    }
}
