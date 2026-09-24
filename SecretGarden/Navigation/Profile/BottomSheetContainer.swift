//
//  BottomSheetContainer.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 23/9/26.
//

import DesignSystem
import SwiftUI

struct BottomSheetContainer<Content: View>: View {
    var isDismissing: Bool = false
    let onTapOutside: () -> Void
    let content: () -> Content

    @State private var showSheetContent = false
    @State private var isBlurVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                BackdropBlurView(radius: 20)
                Color.black.opacity(0.35)
            }
            .ignoresSafeArea()
            .opacity(isBlurVisible ? 1 : 0)
            .onTapGesture(perform: onTapOutside)

            if showSheetContent {
                VStack(spacing: 0) {
                    content()
                }
                .padding(.bottom, 34)
                .frame(maxWidth: .infinity)
                .background(DSColor.backgroundPrimary)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 32,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 32
                    )
                )
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea()
        .background(ClearBackgroundView())
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) { isBlurVisible = true }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showSheetContent = true }
        }
        .onChange(of: isDismissing) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.2)) { isBlurVisible = false }
                withAnimation(.easeIn(duration: 0.25)) { showSheetContent = false }
            }
        }
    }
}

struct BackdropBlurView: UIViewRepresentable {
    let radius: CGFloat

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
