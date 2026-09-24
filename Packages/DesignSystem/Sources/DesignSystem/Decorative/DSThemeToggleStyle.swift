//
//  DSThemeToggleStyle.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 7/9/26.
//

// ToggleStyle for "Light/Dark Mode"

import SwiftUI

public struct DSThemeToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            ZStack(alignment: configuration.isOn ? .leading : .trailing) {
                Capsule()
                    .fill(configuration.isOn ? Color.black.opacity(0.85) : DSColor.brandPrimary)
                    .frame(width: 50, height: 30)

                if configuration.isOn {
                    HStack {
                        Spacer()
                        Image(systemName: "sparkle")
                            .font(.system(size: 7))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.trailing, 7)
                    }
                    .frame(width: 50, height: 30)
                }

                Circle()
                    .fill(.white)
                    .frame(width: 26, height: 26)
                    .overlay {
                        Image(systemName: configuration.isOn ? "moon.stars.fill" : "sun.max.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(configuration.isOn ? Color.indigo : .orange)
                    }
                    .padding(2)
                    .shadow(color: .black.opacity(0.15), radius: 1, y: 0.5)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: configuration.isOn)
    }
}
