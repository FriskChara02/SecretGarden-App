//
//  DSCrestPlaceholder.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 10/9/26.
//

import SwiftUI

public struct DSCrestPlaceholder: View {
    private let size: CGFloat

    public init(size: CGFloat = 56) {
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(DSColor.backgroundSecondary)
            .frame(width: size, height: size)
            .overlay {
                if let uiImage = UIImage(named: "GroupCrest", in: .designSystemModule, compatibleWith: nil) {
                    Image(uiImage: uiImage).resizable().scaledToFit().padding(size * 0.2)
                } else {
                    Image(systemName: "leaf.fill").foregroundStyle(DSColor.brandPrimary.opacity(0.6))
                }
            }
    }
}
