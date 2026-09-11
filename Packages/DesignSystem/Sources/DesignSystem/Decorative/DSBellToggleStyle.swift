//
//  DSBellToggleStyle.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 7/9/26.
//

// Custom ToggleStyle: bell icon positioned INSIDE the toggle knob

import SwiftUI

public struct DSBellToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? DSColor.brandPrimary : DSColor.backgroundSecondary)
                    .frame(width: 50, height: 30)
                Circle()
                    .fill(.white)
                    .frame(width: 26, height: 26)
                    .overlay {
                        Image(systemName: configuration.isOn ? "bell.fill" : "bell")
                            .font(.system(size: 12))
                            .foregroundStyle(configuration.isOn ? DSColor.brandPrimary : DSColor.textSecondary)
                    }
                    .padding(2)
                    .shadow(color: .black.opacity(0.15), radius: 1, y: 0.5)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: configuration.isOn)
    }
}
