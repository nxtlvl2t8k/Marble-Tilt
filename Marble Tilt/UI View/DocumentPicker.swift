//
//  DocumentPicker.swift
//  Marble Tilt
//
//  Created by Scott Mayhew on 2025-11-29.
//


import UIKit
import SwiftUI

struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}
//    .sheet(isPresented: $viewModel.showDocumentPicker) {
//        DocumentPicker { url in
//            viewModel.scene.loadVortexLayout(from: url)
//            viewModel.showDocumentPicker = false
//        }
//    }
