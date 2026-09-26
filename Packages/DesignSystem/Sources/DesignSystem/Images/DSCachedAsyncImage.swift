//
//  DSCachedAsyncImage.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 26/9/26.
//

// A direct replacement for SwiftUI's AsyncImage - powered by Nuke/NukeUI under the hood
// (featuring two-layer caching + downsampling), yet preserving the original closure signature (AsyncImagePhase)
// so that call sites require minimal changes to their internal switch logic.
//
// Feature packages must NEVER import Nuke/NukeUI directly - they must always go through this type.

import SwiftUI
import Nuke
import NukeUI

/// How to resize an image before decoding it into RAM.
public enum DSImageResizeMode {
    /// Resize and crop-to-fill to fit a fixed frame (for cards/avatars with known dimensions for both width and height).
    case size(CGSize)
    /// Constrain width only, preserving the original aspect ratio (use for images with unknown height, e.g., comic pages).
    case width(CGFloat)
}

public struct DSCachedAsyncImage<Content: View>: View {
    private let url: URL?
    private let resize: DSImageResizeMode?
    private let content: (AsyncImagePhase) -> Content

    public init(
        url: URL?,
        resize: DSImageResizeMode? = nil,
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.resize = resize
        self.content = content
    }

    public var body: some View {
        LazyImage(url: url) { state in
            content(phase(for: state))
        }
        .processors(processors)
    }

    private var processors: [ImageProcessing] {
        switch resize {
        case .size(let size): return [ImageProcessors.Resize(size: size)]
        case .width(let width): return [ImageProcessors.Resize(width: width)]
        case .none: return []
        }
    }

    private func phase(for state: LazyImageState) -> AsyncImagePhase {
        if let image = state.image { return .success(image) }
        if let error = state.error { return .failure(error) }
        return .empty
    }
}
