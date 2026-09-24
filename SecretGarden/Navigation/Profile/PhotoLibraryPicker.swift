//
//  PhotoLibraryPicker.swift
//  SecretGarden
//
//  Created by Loi Nguyen on 23/9/26.
//

import PhotosUI
import SwiftUI

struct PhotoLibraryPicker: UIViewControllerRepresentable {
    let onImagePicked: (Data) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onImagePicked: onImagePicked, onCancel: onCancel) }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onImagePicked: (Data) -> Void
        let onCancel: () -> Void
        init(onImagePicked: @escaping (Data) -> Void, onCancel: @escaping () -> Void) {
            self.onImagePicked = onImagePicked
            self.onCancel = onCancel
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                DispatchQueue.main.async { self.onCancel() }
                return
            }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    guard let uiImage = image as? UIImage, let data = uiImage.jpegData(compressionQuality: 0.8) else {
                        self.onCancel()
                        return
                    }
                    self.onImagePicked(data)
                }
            }
        }
    }
}
