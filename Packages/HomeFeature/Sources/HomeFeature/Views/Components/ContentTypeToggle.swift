//
//  ContentTypeToggle.swift
//  HomeFeature
//
//  Created by Loi Nguyen on 22/8/26.
//

// Toggle "Yuri Manga" ⟷ "Yuri Novel".

import CoreModels
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

extension HomeContentType {
    /// Map the UI toggle (Manga/Novel) to the actual `SeriesType` domain for client-side filtering.
    /// Note: `.doujinshi` does not fall under either of these two toggle options - consistent with
    /// the system design (the toggle only switches between "Yurineko Manga" and "Yurineko Novel", Doujinshi has its own tab).
    var seriesType: SeriesType {
        switch self {
        case .manga: return .manga
        case .novel: return .novel
        }
    }
}

#Preview {
    ContentTypeToggle(selection: .constant(.manga))
}
