//
//  DSSuccessToastModifier.swift
//  DesignSystem
//
//  Created by Loi Nguyen on 12/9/26.
//

// Confirmation toast "◆ SUCCESS ◆" — shared across all social actions
// (Follow/Unfollow Group, Follow Author, toggle notifications, successful report submission).
// "Favorite/Notify" in Series Detail & Reader: these areas use silent optimistic updates - there are NO toast notifications.

import SwiftUI

private struct DSSuccessToastModifier: ViewModifier {
    @Binding var message: String?
    let autoDismissDuration: Double

    @State private var dismissTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .overlay {
                if let message {
                    toastOverlay(message)
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                        .zIndex(1)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: message)
            .onChange(of: message) { _, newValue in
                dismissTask?.cancel()
                guard newValue != nil else { return }
                dismissTask = Task {
                    try? await Task.sleep(for: .seconds(autoDismissDuration))
                    guard !Task.isCancelled else { return }
                    await MainActor.run { message = nil }
                }
            }
    }

    private func toastOverlay(_ text: String) -> some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { message = nil }

            DSDecorativeCard {
                VStack(spacing: DSSpacing.md) {
                    header
                    Text(text)
                        .dsFont(.headline)
                        .foregroundStyle(DSColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DSSpacing.lg)
                }
                .padding(.vertical, DSSpacing.xl)
                .frame(maxWidth: .infinity)
            }
            .overlay(alignment: .topTrailing) {
                closeButton
            }
            .padding(.horizontal, DSSpacing.xxl)
        }
    }

    private var header: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "diamond.inset.filled").font(.caption2)
            Text("THÀNH CÔNG")
                .dsFont(.title3)
                .fontWeight(.bold)
            Image(systemName: "diamond.inset.filled").font(.caption2)
        }
        .foregroundStyle(DSColor.brandPrimary)
    }

    private var closeButton: some View {
        Button {
            message = nil
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DSColor.textSecondary)
                .padding(DSSpacing.sm)
        }
        .padding(DSSpacing.xs)
    }
}

extension View {
    /// Attach a shared "SUCCESS" toast
    /// - Parameters:
    ///   - message: nil = hidden, if a value is provided = displays the text and automatically hides after `autoDismissDuration`.
    ///   - autoDismissDuration: defaults to 4s - long enough to read a short sentence without being intrusive.
    public func dsSuccessToast(message: Binding<String?>, autoDismissDuration: Double = 4) -> some View {
        modifier(DSSuccessToastModifier(message: message, autoDismissDuration: autoDismissDuration))
    }
}

#Preview("Toast hiện") {
    struct PreviewHost: View {
        @State private var message: String? = "Đã theo dõi nhóm"
        var body: some View {
            VStack(spacing: DSSpacing.lg) {
                Text("Nội dung nền phía sau")
                Button("Hiện lại toast") { message = "Đã theo dõi nhóm" }
            }
            .padding()
            .dsSuccessToast(message: $message)
        }
    }
    return PreviewHost()
}

#Preview("Dark mode") {
    struct PreviewHost: View {
        @State private var message: String? = "Đã bật thông báo"
        var body: some View {
            Text("Nội dung nền")
                .padding()
                .dsSuccessToast(message: $message)
        }
    }
    return PreviewHost().preferredColorScheme(.dark)
}
