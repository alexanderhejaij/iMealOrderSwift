//
//  Assignment2_20336905App.swift
//  Assignment2_20336905
//
//  Created by Alexander Hejaij on 25/9/2025.
//

import SwiftUI
import PhotosUI

// MARK: - ImagePicker
// A SwiftUI wrapper around PHPickerViewController (UIKit component).
// This allows SwiftUI views to present the system photo picker
// and return a selected UIImage back into SwiftUI state.
struct ImagePicker: UIViewControllerRepresentable {
    // Binding to pass the selected image back to the parent SwiftUI view.
    // When the user picks an image, this binding is updated.
    @Binding var image: UIImage?

    // MARK: - Coordinator
    // Creates the coordinator object that acts as the delegate
    // between the UIKit PHPicker and SwiftUI.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - UIViewControllerRepresentable
    // Creates and configures the PHPickerViewController.
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images          // Only allow image selection (no videos, etc.)
        config.selectionLimit = 1        // Restrict to a single image

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator // Assign delegate to coordinator
        return picker
    }

    // Required by UIViewControllerRepresentable protocol.
    // Used to update the UIKit view controller if SwiftUI state changes.
    // In this case, no updates are needed after creation.
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // MARK: - Coordinator Class
    // Bridges UIKit delegate callbacks back into SwiftUI.
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        // Reference to the parent ImagePicker
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Called when the user finishes picking an image (or cancels).
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Dismiss the picker UI
            picker.dismiss(animated: true)

            // Get the first selected item provider (if any)
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            // Load the UIImage asynchronously from the provider
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    // Assign the loaded image back to the SwiftUI binding
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}
