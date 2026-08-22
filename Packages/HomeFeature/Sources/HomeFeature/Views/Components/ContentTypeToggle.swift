//
//  ContentTypeToggle.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Toggle "Yuri Manga" ⟷ "Yuri Novel".

import DesignSystem
import SwiftUI

public enum HomeContentType: String, CaseIterable, Identifiable {
    case manga = "Yuri Manga"
    case novel = "Yuri Novel"

    public var id: String { rawValue }
}

public struct ContentTypeToggle: View {
    @Binding private var selection: HomeContentType

    public init(selection: Binding<HomeContentType>) {
        self._selection = selection
    }

    public var body: some View {
        Picker("Loại nội dung", selection: $selection) {
            ForEach(HomeContentType.allCases) { type in
                Text(type.rawValue).tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DSSpacing.md)
    }
}

#Preview {
    ContentTypeToggle(selection: .constant(.manga))
}
