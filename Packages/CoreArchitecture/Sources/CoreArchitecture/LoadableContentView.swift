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
    private let emptyIcon: String
    private let emptyImageName: String?
    private let emptyTitle: String
    private let emptyTitleFont: DSFontToken
    private let emptyTitleColor: Color
    private let emptyMessage: String?
    private let emptyTopPadding: CGFloat
    private let isEmpty: (T) -> Bool
    private let retryAction: (() -> Void)?
    @ViewBuilder private let content: (T) -> Content

    public init(
        state: LoadableState<T>,
        loadingStyle: DSLoadingStyle = .spinner,
        emptyIcon: String = "tray",
        emptyImageName: String? = nil,
        emptyTitle: String = "Không có dữ liệu",
        emptyTitleFont: DSFontToken = .headline,
        emptyTitleColor: Color = DSColor.textPrimary,
        emptyMessage: String? = nil,
        emptyTopPadding: CGFloat = 0,
        isEmpty: @escaping (T) -> Bool,
        retryAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.state = state
        self.loadingStyle = loadingStyle
        self.emptyIcon = emptyIcon
        self.emptyImageName = emptyImageName
        self.emptyTitle = emptyTitle
        self.emptyTitleFont = emptyTitleFont
        self.emptyTitleColor = emptyTitleColor
        self.emptyMessage = emptyMessage
        self.emptyTopPadding = emptyTopPadding
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
                DSEmptyStateView(
                    icon: emptyIcon,
                    imageName: emptyImageName,
                    title: emptyTitle,
                    titleFont: emptyTitleFont,
                    titleColor: emptyTitleColor,
                    message: emptyMessage,
                    topPadding: emptyTopPadding
                )
            } else {
                content(value)
            }

        case .failed(let error):
            DSErrorView(message: error.localizedDescription, retryAction: retryAction)
        }
    }
}
