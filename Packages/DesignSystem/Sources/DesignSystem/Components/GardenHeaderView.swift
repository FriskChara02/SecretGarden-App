//
//  GardenHeaderView.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 26/8/26.
//

// Fixed header on a pink background (logo + app name) that scrolls with the content
// (not the system NavigationBar) — placed as the first item inside each tab's ScrollView.
// Tapping the logo/name triggers the onTap closure (behavior determined by the app target).

import SwiftUI

public struct GardenHeaderView: View {
    private let title: String
    private let onTap: () -> Void

    public init(title: String = "SECRET GARDEN", onTap: @escaping () -> Void) {
        self.title = title
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.sm) {
                logoIcon
                Text(title)
                    .dsFont(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.md)
            .frame(maxWidth: .infinity)
            .background(headerBackground)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var logoIcon: some View {
        // "AppLogo" — Asset Catalog Image Set in DesignSystem
        if let uiImage = UIImage(named: "AppLogo", in: .designSystemModule, compatibleWith: nil) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        } else {
            Image(systemName: "leaf.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
        }
    }

    private var headerBackground: some View {
        LinearGradient(
            colors: [DSColor.brandPrimary, DSColor.brandPrimary.opacity(0.85)],
            startPoint: .leading, endPoint: .trailing
        )
        .overlay {
            Rectangle().strokeBorder(Color.white.opacity(0.4), lineWidth: 1).padding(4)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(DSColor.brandPrimaryLight).frame(height: 2)
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    ScrollView {
        GardenHeaderView(onTap: {})
        Color.clear.frame(height: 400)
    }
    .ignoresSafeArea(edges: .top)
}
